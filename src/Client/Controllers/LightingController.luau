--!strict
-- COBLOX CLIENT: LIGHTING CONTROLLER
-- Responsibilities: Automatically scales rendering quality based on dynamic FPS monitoring & hardware capabilities.

local Lighting = game:GetService("Lighting")
local RunService = game:GetService("RunService")
local UserSettings = UserSettings()
local GameSettings = UserSettings:GetService("UserGameSettings")
local ClientConfig = require(game:GetService("ReplicatedStorage").Shared.Config.ClientConfig)

local LightingController = {
	Name = "LightingController",
	CurrentTier = 2,
}

local RegistryRef: any = nil
local frameTimes: { number } = {}
local sampleWindow = ClientConfig.Lighting.FpsSampleWindow
local lastEvalTime = 0

function LightingController.Init(Registry: any)
	RegistryRef = Registry
	print("[LightingController] Initialized.")
end

function LightingController.Start(Registry: any)
	RunService.RenderStepped:Connect(function(dt: number)
		table.insert(frameTimes, dt)
		if #frameTimes > 120 then
			table.remove(frameTimes, 1)
		end

		local now = tick()
		if now - lastEvalTime >= sampleWindow then
			lastEvalTime = now
			LightingController.EvaluatePerformance()
		end
	end)
	print("[LightingController] Started Performance Monitor.")
end

function LightingController.EvaluatePerformance()
	if #frameTimes == 0 then return end
	local totalDt = 0
	for _, dt in ipairs(frameTimes) do
		totalDt += dt
	end
	local avgFps = #frameTimes / totalDt

	local targetTier = LightingController.CurrentTier
	if avgFps < ClientConfig.Lighting.FpsDowngradeThreshold then
		targetTier = math.max(1, LightingController.CurrentTier - 1)
	elseif avgFps >= ClientConfig.Lighting.FpsUpgradeThreshold then
		targetTier = math.min(3, LightingController.CurrentTier + 1)
	end

	if targetTier ~= LightingController.CurrentTier then
		LightingController.ApplyQualityProfile(targetTier)
	end
end

function LightingController.ApplyQualityProfile(tier: number)
	local prevTier = LightingController.CurrentTier
	LightingController.CurrentTier = tier

	-- Smooth transition of parameters
	if tier == 3 then
		Lighting.GlobalShadows = true
		Lighting.EnvironmentDiffuseScale = 1.0
		Lighting.EnvironmentSpecularScale = 1.0
	elseif tier == 2 then
		Lighting.GlobalShadows = true
		Lighting.EnvironmentDiffuseScale = 0.5
		Lighting.EnvironmentSpecularScale = 0.5
	else
		Lighting.GlobalShadows = false
		Lighting.EnvironmentDiffuseScale = 0.0
		Lighting.EnvironmentSpecularScale = 0.0
	end

	local Telemetry = RegistryRef and RegistryRef.GetController("TelemetryController")
	if Telemetry then
		Telemetry.Track("Lighting", "TierChange", string.format("From_%d_To_%d", prevTier, tier), tier)
	end
end

return LightingController
