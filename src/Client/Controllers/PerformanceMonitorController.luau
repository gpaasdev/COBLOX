--!strict
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")
local Maid = require(game:GetService("ReplicatedStorage").Shared.Utility.Maid)

local PerformanceMonitorController = {}
PerformanceMonitorController.Name = "PerformanceMonitorController"

local TARGET_FPS = 60
local THROTTLE_THRESHOLD_FPS = 45
local RESTORE_THRESHOLD_FPS = 50
local THROTTLE_COOLDOWN = 10
local checkInterval = 2
local frameHistory = {}
local controllerMaid = Maid.new()
local lastThrottleChange = 0

function PerformanceMonitorController.Init()
	print("[PerformanceMonitorController] Initializing Mobile FPS Monitoring & Dynamic Throttling...")
end

function PerformanceMonitorController.Start()
	local lastTime = tick()
	local frames = 0

	controllerMaid:GiveTask(RunService.RenderStepped:Connect(function()
		frames += 1
	end))

	local evalRunning = true
	controllerMaid:GiveTask(function()
		evalRunning = false
	end)
	task.spawn(function()
		while evalRunning do
			task.wait(checkInterval)
			local now = tick()
			local currentFPS = frames / (now - lastTime)
			table.insert(frameHistory, currentFPS)
			if #frameHistory > 5 then
				table.remove(frameHistory, 1)
			end

			local avgFPS = 0
			for _, fps in ipairs(frameHistory) do
				avgFPS += fps
			end
			avgFPS = avgFPS / #frameHistory

			local now = tick()
			if _G.GraphicsThrottled then
				if avgFPS > RESTORE_THRESHOLD_FPS and now - lastThrottleChange > THROTTLE_COOLDOWN then
					PerformanceMonitorController.RestoreGraphics()
				end
			else
				if avgFPS < THROTTLE_THRESHOLD_FPS then
					PerformanceMonitorController.ThrottleGraphics()
					lastThrottleChange = now
				end
			end

			frames = 0
			lastTime = now
		end
	end)
end

function PerformanceMonitorController.ThrottleGraphics()
	-- Dynamic Particle Throttling for Low-End Mobile
	if not _G.GraphicsThrottled then
		_G.GraphicsThrottled = true
		print("[PerformanceMonitorController] Low FPS detected! Throttling particles...")
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") then
				obj:SetAttribute("OriginalRate", obj.Rate)
				obj.Rate = math.clamp(obj.Rate * 0.3, 1, 20)
			end
		end
	end
end

function PerformanceMonitorController.RestoreGraphics()
	if _G.GraphicsThrottled then
		_G.GraphicsThrottled = false
		print("[PerformanceMonitorController] FPS stabilized. Restoring particles...")
		for _, obj in ipairs(Workspace:GetDescendants()) do
			if obj:IsA("ParticleEmitter") then
				local origRate = obj:GetAttribute("OriginalRate")
				if type(origRate) == "number" then
					obj.Rate = origRate
				end
			end
		end
	end
end

return PerformanceMonitorController
