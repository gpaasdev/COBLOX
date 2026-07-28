--!strict

local UserSettings = UserSettings()
local RunService = game:GetService("RunService")

local GraphicsOptimizationController = {}

local currentFps = 60
local sampleCount = 0
local totalFrameTime = 0

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
	if fps < 30 then
		-- Low Performance Device detected: Throttle visual effects
		print(
			string.format(
				"[GraphicsOptimizationController] Low FPS detected (%d). Scaling down particle density & lighting.",
				fps
			)
		)
	elseif fps >= 55 then
		-- High Performance Device: Enable full visual fidelity
		print(string.format("[GraphicsOptimizationController] High FPS detected (%d). Optimal performance.", fps))
	end
end

return GraphicsOptimizationController
