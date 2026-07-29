--!strict

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local StreamingController = {}
local localPlayer = Players.LocalPlayer

function StreamingController.Init()
	self.maid = Maid.new()
	print("[StreamingController] Initializing Mobile Streaming & Integrity Manager...")

	-- Listen for Workspace Streaming Pause events (wrapped in pcall since StreamingPauseMode is not scriptable on all platforms)
	local ok = pcall(function()
		self.maid:GiveTask(Workspace:GetPropertyChangedSignal("StreamingPauseMode"):Connect(function()
			print("[StreamingController] Workspace Streaming Mode update detected.")
		end)
	end)
	if not ok then
		warn("[StreamingController] StreamingPauseMode signal unavailable on this platform, skipping listener.")
	end
end

function StreamingController.RequestRegionStream(targetPosition: Vector3): boolean
	if not localPlayer then
		return false
	end

	local success, err = pcall(function()
		localPlayer:RequestStreamAroundAsync(targetPosition, 5)
	end)

	if not success then
		warn("[StreamingController] RequestStreamAroundAsync failed:", err)
		return false
	end

	return true
end

return StreamingController
