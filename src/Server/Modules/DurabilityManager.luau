--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local DurabilityManager = {}

export type ItemWithDurability = {
	itemId: string,
	uuid: string,
	maxDurability: number,
	currentDurability: number,
	broken: boolean,
}

local DURABILITY_MAP: { [string]: number } = {
	AstralIron = 100,
	PyroEssence = 50,
	HydroCrystal = 50,
	FerriumAlloy = 200,
	AetherCrystal = 75,
}

function DurabilityManager.GetMaxDurability(itemId: string): number
	return DURABILITY_MAP[itemId] or 25
end

function DurabilityManager.ReduceDurability(player: Player, itemUUID: string, amount: number): boolean
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return false
	end

	local inventory = res.Data.Inventory
	local item = inventory.Items[itemUUID]
	if not item then
		return false
	end

	local durableItem = item :: ItemWithDurability
	if durableItem.broken then
		return false
	end

	durableItem.currentDurability -= amount

	if durableItem.currentDurability <= 0 then
		durableItem.currentDurability = 0
		durableItem.broken = true
		warn(string.format("[Durability] Item %s (%s) broke!", itemUUID, durableItem.itemId))
	end

	return true
end

function DurabilityManager.RepairItem(player: Player, itemUUID: string, repairAmount: number): boolean
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return false
	end

	local inventory = res.Data.Inventory
	local item = inventory.Items[itemUUID]
	if not item then
		return false
	end

	local durableItem = item :: ItemWithDurability
	durableItem.currentDurability = math.min(
		durableItem.currentDurability + repairAmount,
		durableItem.maxDurability
	)
	durableItem.broken = false

	return true
end

function DurabilityManager.GetDurability(player: Player, itemUUID: string): (number, number, boolean)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return 0, 0, true
	end

	local item = res.Data.Inventory.Items[itemUUID]
	if not item then
		return 0, 0, true
	end

	local durableItem = item :: ItemWithDurability
	return durableItem.currentDurability, durableItem.maxDurability, durableItem.broken
end

return DurabilityManager
