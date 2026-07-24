--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)

local ShadowRaidController = {}
ShadowRaidController.Name = "ShadowRaidController"

local MAX_RAID_DISTANCE = 15

function ShadowRaidController.Init()
	print("[ShadowRaidController] Initializing Shadow Raid Action UI...")
end

function ShadowRaidController.Start()
	-- Keybind for Begal Aura / Shadow Raid (Hotkey: 'B')
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end
		if input.KeyCode == Enum.KeyCode.B then
			ShadowRaidController.AttemptRaidFromNearest()
		end
	end)
end

function ShadowRaidController.AttemptRaidFromNearest()
	local localPlayer = Players.LocalPlayer
	local char = localPlayer.Character
	if not char or not char.PrimaryPart then return end

	local myPos = char.PrimaryPart.Position
	local nearestPlayer: Player? = nil
	local nearestDist = MAX_RAID_DISTANCE

	for _, otherPlayer in ipairs(Players:GetPlayers()) do
		if otherPlayer ~= localPlayer then
			local otherChar = otherPlayer.Character
			if otherChar and otherChar.PrimaryPart then
				local dist = (myPos - otherChar.PrimaryPart.Position).Magnitude
				if dist <= nearestDist then
					nearestDist = dist
					nearestPlayer = otherPlayer
				end
			end
		end
	end

	if nearestPlayer then
		print(string.format("[ShadowRaidController] Attempting Shadow Raid from %s...", nearestPlayer.Name))
		if ClientRemotes.RequestShadowRaid then
			local response = ClientRemotes.RequestShadowRaid:InvokeServer(nearestPlayer.UserId, 1)
			if response and response.Success then
				print(string.format("[ShadowRaidController] 🎉 BEGAL AURA BERHASIL! %s diambil!", response.PotionName or "Aura"))
			else
				warn("[ShadowRaidController] Raid failed:", response and response.Message or "Unknown error")
			end
		end
	else
		print("[ShadowRaidController] No target nearby for Shadow Raid (Max 15 studs).")
	end
end

return ShadowRaidController
