--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PotionVaultController = {}
PotionVaultController.Name = "PotionVaultController"

local localPlayer = Players.LocalPlayer

function PotionVaultController.Init()
	print("[PotionVaultController] Initializing Potion Vault Display UI...")
end

function PotionVaultController.Start()
	-- Listens to Potion Vault updates
end

return PotionVaultController
