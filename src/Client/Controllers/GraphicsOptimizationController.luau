--!strict

local UserSettings = UserSettings()
local RunService = game:GetService("RunService")

local GraphicsOptimizationController = {}

local currentFps = 60
local sampleCount = 0
local totalFrameTime = 0
local lastFpsState = ""
local lastPrintTime = 0
local PRINT_COOLDOWN = 5

function GraphicsOptimizationController.Init()
	print("[GraphicsOptimizationController] Initializing Dynamic Mobile Quality & FPS Scaling...")

	RunService.Heartbeat:Connect(function(dt: number)
		sampleCount += 1
		totalFrameTime += dt

		if sampleCount >= 120 then -- Every ~2 seconds
			currentFps = math.floor(sampleCount / totalFrameTime)
			sampleCount = 0
			totalFrameTime = 0

			GraphicsOptimizationController.EvaluateQuality(currentFps)
		end
	end)
end

function GraphicsOptimizationController.EvaluateQuality(fps: number)
	local now = tick()
	if fps < 30 then
		if lastFpsState ~= "low" and now - lastPrintTime >= PRINT_COOLDOWN then
			lastFpsState = "low"
			lastPrintTime = now
			print(
				string.format(
					"[GraphicsOptimizationController] Low FPS detected (%d). Scaling down particle density & lighting.",
					fps
				)
			)
		end
	elseif fps >= 55 then
		if lastFpsState ~= "high" and now - lastPrintTime >= PRINT_COOLDOWN then
			lastFpsState = "high"
			lastPrintTime = now
			print(string.format("[GraphicsOptimizationController] High FPS detected (%d). Optimal performance.", fps))
		end
	end
end

return GraphicsOptimizationController
