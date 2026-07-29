--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local RecipeConfig = require(ReplicatedStorage.Shared.Configuration.RecipeConfig)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)
local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local RecipeService = {}
RecipeService.Name = "RecipeService"

RecipeService.RecipeCrafted = Signal.new()
RecipeService.SmeltingCompleted = Signal.new()

function RecipeService.Init()
	print(
		"[RecipeService] Initializing Minecraft 3x3 Grid Crafting, Smelting Furnace & Genshin Elemental Reactions Engine..."
	)
end

function RecipeService.Start()
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
	local craftRemoteFunc = NetChannels.GetRemoteFunction("RequestCraft")

	craftRemoteFunc.OnServerInvoke = function(player: Player, grid: { [number]: string })
		if type(grid) ~= "table" then
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "INVALID_GRID",
				Message = "Invalid grid data",
				Data = nil,
				Retryable = false,
			}
		end
		if not RateLimitService.CheckRateLimit(player, "CraftItem", 0.5) then
			return {
				Success = false,
				Category = "RateLimit",
				ErrorCode = "TOO_MANY_REQUESTS",
				Message = "Crafting rate limited",
				Data = nil,
				Retryable = true,
			}
		end
		return RecipeService.CraftGrid3x3(player, grid)
	end
end

function RecipeService.CalculateElementalReactionMultiplier(elem1: string, elem2: string): number
	if (elem1 == "Pyro" and elem2 == "Hydro") or (elem1 == "Hydro" and elem2 == "Pyro") then
		return 2.5 -- Vaporize Reaction
	elseif (elem1 == "Pyro" and elem2 == "Cryo") or (elem1 == "Cryo" and elem2 == "Pyro") then
		return 2.0 -- Melt Reaction
	elseif (elem1 == "Electro" and elem2 == "Hydro") or (elem1 == "Hydro" and elem2 == "Electro") then
		return 1.8 -- Electro-Charged Reaction
	end
	return 1.0
end

function RecipeService.ValidateCraftDistance(player: Player, altarPosition: Vector3?): (boolean, string?)
	if not altarPosition then
		return true, nil
	end
	local character = player.Character
	if not character or not character.PrimaryPart then
		return false, "Player character unavailable for distance check"
	end
	local dist = (character.PrimaryPart.Position - altarPosition).Magnitude
	if dist > 15.0 then
		return false, string.format("Crafting altar out of range: %.1f studs (> 15)", dist)
	end
	return true, nil
end

function RecipeService.CraftGrid3x3(
	player: Player,
	grid: { [number]: string }
): ServiceResult<{ ItemResult: string, YieldMultiplier: number }>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_NOT_LOADED",
			Message = "Player profile unavailable",
			Data = nil,
			Retryable = true,
		}
	end

	local countMap: { [string]: number } = {}
	local elementsUsed: { string } = {}

	for _, itemId in ipairs(grid) do
		if itemId and itemId ~= "" then
			countMap[itemId] = (countMap[itemId] or 0) + 1
			if not table.find(elementsUsed, itemId) then
				table.insert(elementsUsed, itemId)
			end
		end
	end

	local playerInv = res.Data.Inventory or {}
	local playerItems = playerInv.Items or {}

	for itemId, required in pairs(countMap) do
		local owned = playerItems[itemId] or 0
		if owned < required then
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "INSUFFICIENT_INGREDIENTS",
				Message = "Missing ingredient: " .. itemId .. " (need " .. tostring(required) .. ", have " .. tostring(
					owned
				) .. ")",
				Data = nil,
				Retryable = false,
			}
		end
	end

	local yieldMultiplier = 1.0
	if #elementsUsed >= 2 then
		yieldMultiplier = RecipeService.CalculateElementalReactionMultiplier(elementsUsed[1], elementsUsed[2])
	end

	local craftedItem = "AuraElixir_Tier1"
	local itemType = "Consumable"

	if countMap["Quartz"] and countMap["Quartz"] >= 3 then
		craftedItem = "QuartzAltar_Tier1"
		itemType = "Structure"
	elseif countMap["AstralIron"] and countMap["AstralIron"] >= 3 then
		craftedItem = "AstralGenerator_Tier2"
		itemType = "Structure"
	elseif countMap["PyroEssence"] and countMap["PyroEssence"] >= 2 then
		craftedItem = "PyroBuffPotion_Tier2"
		itemType = "Consumable"
	end

	local updateResult = ProfileStoreAdapter.SafeUpdateProfile(player, function(profileData)
		if not profileData.Inventory then
			profileData.Inventory = {}
		end
		if not profileData.Inventory.Items then
			profileData.Inventory.Items = {}
		end
		for itemId, required in pairs(countMap) do
			profileData.Inventory.Items[itemId] = (profileData.Inventory.Items[itemId] or 0) - required
			if profileData.Inventory.Items[itemId] <= 0 then
				profileData.Inventory.Items[itemId] = nil
			end
		end
		profileData.Inventory.Items[craftedItem] = (profileData.Inventory.Items[craftedItem] or 0) + 1
	end)
	if not updateResult.Success then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_UPDATE_FAILED",
			Message = "Failed to persist crafted item: " .. (updateResult.ErrorCode or "UNKNOWN"),
			Data = nil,
			Retryable = true,
		}
	end

	player:SetAttribute("HasCraftedCrystal", true)

	RecipeService.RecipeCrafted:Fire(player, craftedItem, yieldMultiplier)
	print(
		string.format(
			"[RecipeService] Player %s crafted %s (%s) via 3x3 Grid (Yield: %.1fx)",
			player.Name,
			craftedItem,
			itemType,
			yieldMultiplier
		)
	)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "3x3 Crafting successful",
		Data = { ItemResult = craftedItem, ItemType = itemType, YieldMultiplier = yieldMultiplier },
		Retryable = false,
	}
end

function RecipeService.SmeltOre(player: Player, rawOreItem: string, fuelItem: string): ServiceResult<string>
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_NOT_LOADED",
			Message = "Player profile unavailable",
			Data = nil,
			Retryable = true,
		}
	end

	local playerInv = res.Data.Inventory or {}
	local playerItems = playerInv.Items or {}

	if (playerItems[rawOreItem] or 0) < 1 then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INSUFFICIENT_ORE",
			Message = "Missing ore: " .. rawOreItem,
			Data = nil,
			Retryable = false,
		}
	end
	if fuelItem ~= "" and (playerItems[fuelItem] or 0) < 1 then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "INSUFFICIENT_FUEL",
			Message = "Missing fuel: " .. fuelItem,
			Data = nil,
			Retryable = false,
		}
	end

	local refinedResult = "Refined_" .. rawOreItem
	local updateResult = ProfileStoreAdapter.SafeUpdateProfile(player, function(profileData)
		if not profileData.Inventory then
			profileData.Inventory = {}
		end
		if not profileData.Inventory.Items then
			profileData.Inventory.Items = {}
		end
		profileData.Inventory.Items[rawOreItem] = (profileData.Inventory.Items[rawOreItem] or 0) - 1
		if profileData.Inventory.Items[rawOreItem] <= 0 then
			profileData.Inventory.Items[rawOreItem] = nil
		end
		if fuelItem ~= "" then
			profileData.Inventory.Items[fuelItem] = (profileData.Inventory.Items[fuelItem] or 0) - 1
			if profileData.Inventory.Items[fuelItem] <= 0 then
				profileData.Inventory.Items[fuelItem] = nil
			end
		end
		profileData.Inventory.Items[refinedResult] = (profileData.Inventory.Items[refinedResult] or 0) + 1
	end)
	if not updateResult.Success then
		return updateResult
	end

	RecipeService.SmeltingCompleted:Fire(player, rawOreItem, refinedResult)

	print(
		string.format(
			"[RecipeService] Smelted %s into %s using %s fuel for %s",
			rawOreItem,
			refinedResult,
			fuelItem,
			player.Name
		)
	)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Ore smelted into ingot successfully",
		Data = refinedResult,
		Retryable = false,
	}
end

return RecipeService
