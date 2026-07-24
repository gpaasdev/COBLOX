--!strict
-- Client/Controllers/StealController.luau
-- Client controller for Begal Aura & Karma Retribution Mechanics

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local StealController = {}
StealController.Name = "StealController"

local localPlayer = Players.LocalPlayer

function StealController.Init()
	print("[StealController] Initializing Begal Aura Client Controller...")
end

function StealController.Start()
	local stealEvent = NetChannels.GetRemoteEvent("StealAuraEvent")
	if stealEvent then
		stealEvent.OnClientEvent:Connect(function(thiefName: string, amount: number)
			print(string.format("[StealController] %s stole %d Aura Energy!", thiefName, amount))
		end)
	end
end

return StealController
