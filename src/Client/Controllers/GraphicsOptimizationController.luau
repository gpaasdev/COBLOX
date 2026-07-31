--!strict

local userSettings = UserSettings()
local userGameSettings = userSettings:GetService("UserGameSettings")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local GraphicsOptimizationController = {}

local currentFps = 60
local sampleCount = 0
local totalFrameTime = 0
local currentQuality: "low" | "medium" | "high" = "high"
local lastChangeTime = 0
local CHANGE_COOLDOWN = 10
local SAMPLE_TARGET = 120

function GraphicsOptimizationController.Init(self)
	self.maid = Maid.new()
	print("[GraphicsOptimizationController] Initializing Dynamic Mobile Quality & FPS Scaling...")

	local isMobile = UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled

	if isMobile then
		pcall(function()
			userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel8
		end)
		currentQuality = "medium"
		print("[GraphicsOptimizationController] Mobile detected — starting at Quality Level 8")
	end

	self.maid:GiveTask(RunService.Heartbeat:Connect(function(dt: number)
		sampleCount += 1
		totalFrameTime += dt

		if sampleCount >= SAMPLE_TARGET then
			currentFps = math.floor(sampleCount / totalFrameTime)
			sampleCount = 0
			totalFrameTime = 0
			GraphicsOptimizationController._EvaluateQuality()
		end
	end))
end

function GraphicsOptimizationController._EvaluateQuality()
	local now = tick()
	if now - lastChangeTime < CHANGE_COOLDOWN then
		return
	end

	local targetQuality: "low" | "medium" | "high"

	if currentFps < 25 then
		targetQuality = "low"
	elseif currentFps < 45 then
		targetQuality = "medium"
	else
		targetQuality = "high"
	end

	if targetQuality == currentQuality then
		return
	end

	currentQuality = targetQuality
	lastChangeTime = now

	if targetQuality == "low" then
		pcall(function()
			userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel3
		end)
		Lighting.ShadowSoftness = 0.1
		Lighting.GlobalShadows = false
		print(
			string.format(
				"[GraphicsOptimizationController] Low quality mode (FPS: %d) — shadows disabled, LOD aggressive",
				currentFps
			)
		)
	elseif targetQuality == "medium" then
		pcall(function()
			userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel8
		end)
		Lighting.ShadowSoftness = 0.2
		Lighting.GlobalShadows = true
		print(string.format("[GraphicsOptimizationController] Medium quality mode (FPS: %d)", currentFps))
	elseif targetQuality == "high" then
		pcall(function()
			userGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel10
		end)
		Lighting.ShadowSoftness = 0.3
		Lighting.GlobalShadows = true
		print(
			string.format("[GraphicsOptimizationController] High quality mode (FPS: %d) — full fidelity", currentFps)
		)
	end
end

function GraphicsOptimizationController.GetCurrentQuality(): "low" | "medium" | "high"
	return currentQuality
end

function GraphicsOptimizationController.GetCurrentFps(): number
	return currentFps
end

return GraphicsOptimizationController
