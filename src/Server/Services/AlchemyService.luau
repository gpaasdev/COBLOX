--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"):WaitForChild("DataTypes"))
local RecipeConfig = require(Shared:WaitForChild("Configuration"):WaitForChild("RecipeConfig"))
local NetChannels = require(Shared:WaitForChild("Network"):WaitForChild("NetChannels"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local ProfileStoreAdapter = require(script.Parent:WaitForChild("ProfileStoreAdapter"))
local GlobalBroadcastService = require(script.Parent:WaitForChild("GlobalBroadcastService"))
local AnalyticsService = require(script.Parent:WaitForChild("AnalyticsService"))

local AlchemyService = {}

function AlchemyService.Init()
	local craftRecipeEvent = NetChannels.GetRemoteFunction("CraftRecipe")
	
	if craftRecipeEvent then
		craftRecipeEvent.OnServerInvoke = function(player: Player, recipeId: string)
			return AlchemyService.HandleCraftRequest(player, recipeId)
		end
	end
end

function AlchemyService.HandleCraftRequest(player: Player, recipeId: string): Types.ServiceResult<string>
	local recipe = RecipeConfig.Recipes[recipeId]
	
	if not recipe then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INVALID_RECIPE",
			Message = "Resep alkimia tidak ditemukan.",
			Retryable = false,
		}
	end
	
	local playerProfile = PlayerDataService.GetProfile(player)
	if not playerProfile then
		return {
			Success = false,
			Category = "Fatal",
			ErrorCode = "PROFILE_NOT_LOADED",
			Message = "Profil pemain belum termuat.",
			Retryable = true,
		}
	end
	
	local inventory = playerProfile.Data.Inventory
	
	-- Zero-Trust Validation: Check if player has all ingredients
	for ingredientName, requiredAmount in pairs(recipe.Ingredients) do
		local currentAmount = inventory.Items[ingredientName] or 0
		if currentAmount < requiredAmount then
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "INSUFFICIENT_INGREDIENTS",
				Message = "Bahan alkimia tidak mencukupi untuk: " .. ingredientName,
				Retryable = false,
			}
		end
	end
	
	-- Consume ingredients
	local updateResult = ProfileStoreAdapter.SafeUpdateProfile(player, function(profileData)
		local inventory = profileData.Inventory
		-- Consume ingredients
		for ingredientName, requiredAmount in pairs(recipe.Ingredients) do
			inventory.Items[ingredientName] -= requiredAmount
		end
		-- Add result to inventory based on ResultType
		if recipe.ResultType == "Spirit" then
			inventory.Spirits[recipe.Result] = { Level = 1, Experience = 0, AcquiredAt = os.time() }
		else
			local currentResultAmount = inventory.Items[recipe.Result] or 0
			inventory.Items[recipe.Result] = currentResultAmount + 1
		end
	end)
	if not updateResult.Success then
		return updateResult
	end
	
	-- Open Cloud & Cross-Server Announcement for Legendary/Mythic
	if recipe.Rarity == "Legendary" or recipe.Rarity == "Mythic" then
		local messagePayload = {
			PlayerName = player.Name,
			ItemName = recipe.Name,
			Rarity = recipe.Rarity,
			Timestamp = os.time()
		}

		-- Real telemetry via AnalyticsService (Fase 8)
		AnalyticsService.LogEvent("alchemy.legendary_craft", {
			playerId   = player.UserId,
			playerName = player.Name,
			recipeId   = recipeId,
			rarity     = recipe.Rarity,
			timestamp  = os.time(),
		}, player.UserId)

		-- Use MessagingService directly to trigger cross server broadcast
		local success, err = pcall(function()
			MessagingService:PublishAsync("GlobalLegendaryCraft", messagePayload)
		end)
		if success then
			print("[MessagingService] Published GlobalLegendaryCraft for", player.Name)
		else
			-- Fallback to in-server broadcast
			warn("[AlchemyService] MessagingService failed:", tostring(err))
			GlobalBroadcastService.Broadcast(
				string.format("⚗️ %s crafted a %s %s!", player.Name, recipe.Rarity, recipe.Name),
				255, 215, 0
			)
		end
	end
	
	return {
		Success = true,
		Data = recipe.Result,
		Message = "Berhasil meracik " .. recipe.Name .. "!",
		Retryable = false,
	}
end

return AlchemyService
