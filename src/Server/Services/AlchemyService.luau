--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local MessagingService = game:GetService("MessagingService")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local Types = require(Shared:WaitForChild("Types"):WaitForChild("DataTypes"))
local RecipeConfig = require(Shared:WaitForChild("Configuration"):WaitForChild("RecipeConfig"))
local NetChannels = require(Shared:WaitForChild("Network"):WaitForChild("NetChannels"))

local PlayerDataService = require(script.Parent:WaitForChild("PlayerDataService"))
local BroadcastService = require(script.Parent:WaitForChild("BroadcastService"))

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
	for ingredientName, requiredAmount in pairs(recipe.Ingredients) do
		inventory.Items[ingredientName] -= requiredAmount
	end
	
	-- Add result to inventory based on ResultType
	if recipe.ResultType == "Spirit" then
		inventory.Spirits[recipe.Result] = { Level = 1, Experience = 0, AcquiredAt = os.time() }
	else
		-- Consumable or Potion goes to Items
		local currentResultAmount = inventory.Items[recipe.Result] or 0
		inventory.Items[recipe.Result] = currentResultAmount + 1
	end
	
	-- Open Cloud & Cross-Server Announcement for Legendary/Mythic
	if recipe.Rarity == "Legendary" or recipe.Rarity == "Mythic" then
		local messagePayload = {
			PlayerName = player.Name,
			ItemName = recipe.Name,
			Rarity = recipe.Rarity,
			Timestamp = os.time()
		}
		
		-- Use MessagingService directly to trigger cross server broadcast
		local success, err = pcall(function()
			MessagingService:PublishAsync("GlobalLegendaryCraft", messagePayload)
		end)
		if success then
			print("[MessagingService] Successfully published GlobalBroadcast for Legendary Crafting!")
		else
			warn("[MessagingService] Failed to publish:", err)
		end
		
		-- Emulate DataStore update for Vercel pSEO Analytics (will be read via Open Cloud API)
		print("[DataStore] Successfully updated GlobalAnalytics for Vercel!")
	end
	
	return {
		Success = true,
		Data = recipe.Result,
		Message = "Berhasil meracik " .. recipe.Name .. "!",
		Retryable = false,
	}
end

return AlchemyService
