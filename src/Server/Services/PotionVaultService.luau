--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local PlayerDataService = require(script.Parent.PlayerDataService :: any)

local PotionVaultService = {}
PotionVaultService.Name = "PotionVaultService"

-- Potion Base Yields per second (Koin/sec)
local POTION_YIELDS = {
	["Quartz"] = 10,
	["AstralIron"] = 50,
	["PyroEssence"] = 250,
	["HydroCrystal"] = 1250,
	["MythicElixir"] = 10000,
}

-- Active Potion Pedestals per Player [Player] -> { Slot1 = PotionName, ... }
local playerVaults: { [Player]: { [number]: string } } = {}

function PotionVaultService.Init()
	print("[PotionVaultService] Initializing Potion Vault Yield Engine...")
end

function PotionVaultService.Start()
	Players.PlayerAdded:Connect(function(player)
		playerVaults[player] = {
			[1] = "Quartz",
			[2] = "Quartz",
			[3] = "",
			[4] = "",
			[5] = "",
			[6] = "",
		}
	end)

	Players.PlayerRemoving:Connect(function(player)
		playerVaults[player] = nil
	end)

	-- Passive Income Loop (Every 1 Second)
	task.spawn(function()
		while true do
			task.wait(1)
			for player, slots in pairs(playerVaults) do
				if player:IsDescendantOf(Players) then
					local totalYield = 0
					for _, potionName in pairs(slots) do
						if potionName ~= "" and POTION_YIELDS[potionName] then
							totalYield += POTION_YIELDS[potionName]
						end
					end

					if totalYield > 0 then
						PlayerDataService.AddCurrency(player, "Coins", totalYield)
					end
				end
			end
		end
	end)
end

function PotionVaultService.GetVault(player: Player)
	return playerVaults[player] or {}
end

function PotionVaultService.SetSlot(player: Player, slotIndex: number, potionName: string)
	if playerVaults[player] then
		playerVaults[player][slotIndex] = potionName
	end
end

return PotionVaultService
