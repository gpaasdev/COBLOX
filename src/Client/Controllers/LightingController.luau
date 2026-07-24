--!strict
-- StarterPlayerScripts/Client/Controllers/LightingController.luau
-- Client Controller untuk setup ShadowMap Lighting & Volumetric Atmosphere

local Lighting = game:GetService("Lighting")

local LightingController = {}
LightingController.__index = LightingController

function LightingController.Init(): ()
	-- Atur Waktu Malam Sci-Fi (22:00)
	Lighting.ClockTime = 22
	Lighting.GeographicLatitude = 45
	Lighting.GlobalShadows = true
	Lighting.OutdoorAmbient = Color3.fromRGB(20, 25, 45)
	Lighting.Ambient = Color3.fromRGB(15, 18, 30)

	-- Setup Bloom Effect (Soft Neon Glow)
	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = 0.4
	bloom.Size = 24
	bloom.Threshold = 0.8

	-- Setup Color Correction (Indigo Sci-Fi Tint)
	local colorCorrection = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not colorCorrection then
		colorCorrection = Instance.new("ColorCorrectionEffect")
		colorCorrection.Parent = Lighting
	end
	colorCorrection.Brightness = 0.02
	colorCorrection.Contrast = 0.1
	colorCorrection.Saturation = 0.15
	colorCorrection.TintColor = Color3.fromRGB(235, 240, 255)

	-- Setup Atmosphere (Sci-Fi Fog Depth)
	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = 0.35
	atmosphere.Offset = 0.25
	atmosphere.Color = Color3.fromRGB(25, 30, 60)
	atmosphere.Decay = Color3.fromRGB(10, 15, 30)
	atmosphere.Glare = 0.2
	atmosphere.Haze = 1.5
end

return LightingController
