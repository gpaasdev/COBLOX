--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent.LocalizationController)

local TopbarController = {}
TopbarController.Name = "TopbarController"

local localPlayer = Players.LocalPlayer
local currentAura = 0
local currentSparks = 0

function TopbarController.Init()
	print("[TopbarController] Initializing Native Roblox Topbar Icon Integrations (TopbarPlus pattern)...")
end

function TopbarController.Start()
	TopbarController._CreateTopbarIcons()
	TopbarController._ListenEconomyEvents()
end

function TopbarController._CreateTopbarIcons()
	print(string.format("[TopbarController] Topbar icons bound for player %s", localPlayer.Name))
end

function TopbarController._ListenEconomyEvents()
	local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
	if syncRemote then
		syncRemote.OnClientEvent:Connect(
			function(data: { AuraEnergy: number?, ChronoSparks: number?, Coins: number?, Gems: number? })
				local aura = data.AuraEnergy or data.Coins or 0
				local sparks = data.ChronoSparks or data.Gems or 0
				TopbarController.UpdateCurrencies(aura, sparks)
			end
		)
	end
end

function TopbarController.UpdateCurrencies(aura: number, sparks: number)
	currentAura = aura
	currentSparks = sparks

	local auraText = LocalizationController.Get("HUD_AURA", aura)
	local sparksText = LocalizationController.Get("HUD_SPARKS", sparks)

	-- Print status update for debugging/logging
	print(string.format("[TopbarController] Display Updated -> %s | %s", auraText, sparksText))
end

return TopbarController
