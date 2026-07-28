--!strict
-- RealmAssemblyService.luau
-- Realm-Aware World Assembly (LGBOS v11.0)
-- Reads RealmConfig.CurrentTheme at boot & delegates to appropriate assembly path

local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")

local RealmConfig = require(ReplicatedStorage.Shared.Configuration.RealmConfig)
type RealmTheme = RealmConfig.RealmTheme

local RealmAssemblyService = {}
RealmAssemblyService.Name = "RealmAssemblyService"
RealmAssemblyService.ServiceStatus = "Production"

function RealmAssemblyService.Init()
	local theme = RealmConfig.CurrentTheme
	print(string.format("[RealmAssemblyService] Assembling world for realm: %s", theme))

	local preset = RealmConfig.GetPreset(theme)
	if not preset then
		warn(string.format("[RealmAssemblyService] Unknown theme '%s', falling back to CyberAlchemist", theme))
		preset = RealmConfig.GetPreset("CyberAlchemist")
		if not preset then
			return
		end
	end

	RealmAssemblyService._ApplyLightingPreset(preset.Lighting)

	if theme == "Fairytale" then
		RealmAssemblyService._AssembleFairytaleWorld(preset)
	else
		local WorldAssemblyService = require(ServerScriptService.Server.Services.WorldAssemblyService)
		WorldAssemblyService.Init()
	end
end

function RealmAssemblyService._ApplyLightingPreset(lp: RealmConfig.RealmLightingPreset)
	Lighting.ClockTime = lp.ClockTime
	Lighting.GeographicLatitude = lp.GeographicLatitude
	Lighting.Ambient = lp.Ambient
	Lighting.OutdoorAmbient = lp.OutdoorAmbient
	Lighting.Brightness = lp.Brightness
	Lighting.ExposureCompensation = lp.ExposureCompensation
	Lighting.EnvironmentDiffuseScale = lp.EnvironmentDiffuseScale
	Lighting.EnvironmentSpecularScale = lp.EnvironmentSpecularScale

	local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end
	atmosphere.Density = lp.AtmosphereDensity
	atmosphere.Offset = lp.AtmosphereOffset
	atmosphere.Color = lp.AtmosphereColor
	atmosphere.Decay = lp.AtmosphereDecay
	atmosphere.Glare = lp.AtmosphereGlare
	atmosphere.Haze = lp.AtmosphereHaze

	local bloom = Lighting:FindFirstChildOfClass("BloomEffect")
	if not bloom then
		bloom = Instance.new("BloomEffect")
		bloom.Parent = Lighting
	end
	bloom.Intensity = lp.BloomIntensity
	bloom.Size = lp.BloomSize
	bloom.Threshold = lp.BloomThreshold

	local colorCorr = Lighting:FindFirstChildOfClass("ColorCorrectionEffect")
	if not colorCorr then
		colorCorr = Instance.new("ColorCorrectionEffect")
		colorCorr.Parent = Lighting
	end
	colorCorr.Brightness = lp.ColorCorrectionBrightness
	colorCorr.Contrast = lp.ColorCorrectionContrast
	colorCorr.Saturation = lp.ColorCorrectionSaturation
	colorCorr.TintColor = lp.ColorCorrectionTint
end

function RealmAssemblyService._AssembleFairytaleWorld(preset: RealmConfig.RealmConfigSchema)
	local mapFolder = Workspace:FindFirstChild("Map")
	if not mapFolder then
		mapFolder = Instance.new("Folder")
		mapFolder.Name = "Map"
		mapFolder.Parent = Workspace
	end

	-- Spawn
	local spawn = mapFolder:FindFirstChild("SpawnLocation") :: SpawnLocation
	if not spawn then
		spawn = Instance.new("SpawnLocation")
		spawn.Name = "SpawnLocation"
		spawn.Size = Vector3.new(20, 1.5, 20)
		spawn.Position = Vector3.new(0, 0.75, 0)
		spawn.Anchored = true
		spawn.CanCollide = true
		spawn.Material = Enum.Material.Glass
		spawn.Color = Color3.fromRGB(200, 180, 255)
		spawn.Transparency = 0.15
		spawn.Parent = mapFolder
	end

	-- Baseplate — Twilight Indigo
	local baseplate = mapFolder:FindFirstChild("Baseplate")
	if not baseplate then
		baseplate = Instance.new("Part")
		baseplate.Name = "Baseplate"
		baseplate.Size = Vector3.new(600, 2, 600)
		baseplate.Position = Vector3.new(0, -1, 0)
		baseplate.Anchored = true
		baseplate.Color = Color3.fromRGB(26, 0, 51)
		baseplate.Material = Enum.Material.SmoothPlastic
		baseplate.Parent = mapFolder
	end

	-- Sanctum Citadel hub area
	local hub = mapFolder:FindFirstChild("CentralHub")
	if not hub then
		hub = Instance.new("Folder")
		hub.Name = "CentralHub"
		hub.Parent = mapFolder

		local hubFloor = Instance.new("Part")
		hubFloor.Name = "HubFloor"
		hubFloor.Size = Vector3.new(120, 1, 120)
		hubFloor.Position = Vector3.new(0, 0, 0)
		hubFloor.Anchored = true
		hubFloor.Color = Color3.fromRGB(40, 20, 60)
		hubFloor.Material = Enum.Material.SmoothPlastic
		hubFloor.Parent = hub
	end

	-- Portal back to Main Realm
	local portal = mapFolder:FindFirstChild("RealmPortal")
	if not portal then
		portal = Instance.new("Part")
		portal.Name = "RealmPortal"
		portal.Size = Vector3.new(8, 14, 2)
		portal.Position = Vector3.new(0, 7, 50)
		portal.Anchored = true
		portal.CanCollide = false
		portal.Material = Enum.Material.Glass
		portal.Color = Color3.fromRGB(0, 255, 255)
		portal.Transparency = 0.3
		portal.Parent = mapFolder

		local glow = Instance.new("PointLight")
		glow.Color = Color3.fromRGB(0, 255, 255)
		glow.Range = 20
		glow.Brightness = 8
		glow.Parent = portal

		local prompt = Instance.new("ProximityPrompt")
		prompt.ObjectText = "Portal to Sanctum"
		prompt.ActionText = "Return to Main Realm"
		prompt.HoldDuration = 1.0
		prompt.Triggered:Connect(function(player: Player)
			local RealmTeleportService = require(ServerScriptService.Server.Services.RealmTeleportService)
			RealmTeleportService.TeleportToRealm(player, "MAIN")
		end)
		prompt.Parent = portal
	end

	-- Immersive Ad Billboard (Fairytale themed)
	local adPart = mapFolder:FindFirstChild("ImmersiveAdBillboard")
	if not adPart then
		adPart = Instance.new("Part")
		adPart.Name = "ImmersiveAdBillboard"
		adPart.Size = Vector3.new(36, 20, 1.5)
		adPart.Position = Vector3.new(0, 16, -55)
		adPart.Anchored = true
		adPart.Color = Color3.fromRGB(26, 0, 51)
		adPart.Material = Enum.Material.Glass
		adPart.Parent = mapFolder

		local adPortal = Instance.new("AdPortal")
		adPortal.Name = "AdPortal"
		adPortal.Parent = adPart

		local adGui = Instance.new("SurfaceGui")
		adGui.Name = "AdGui"
		adGui.Face = Enum.NormalId.Front
		adGui.Parent = adPart
	end

	print(string.format("[RealmAssemblyService] Fairytale Realm '%s' ready.", preset.DisplayName))
end

function RealmAssemblyService.Start()
end

return RealmAssemblyService
