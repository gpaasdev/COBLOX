--!strict
-- RealmConfig.luau
-- Realm/Theme configuration for multi-place COBLOX architecture (LGBOS v11.0)
-- Defines visual identity, lighting presets, biome groups per realm

export type RealmTheme = "CyberAlchemist" | "Fairytale"

export type RealmLightingPreset = {
	ClockTime: number,
	GeographicLatitude: number,
	Ambient: Color3,
	OutdoorAmbient: Color3,
	Brightness: number,
	ExposureCompensation: number,
	EnvironmentDiffuseScale: number,
	EnvironmentSpecularScale: number,
	AtmosphereDensity: number,
	AtmosphereOffset: number,
	AtmosphereColor: Color3,
	AtmosphereDecay: Color3,
	AtmosphereGlare: number,
	AtmosphereHaze: number,
	BloomIntensity: number,
	BloomSize: number,
	BloomThreshold: number,
	ColorCorrectionBrightness: number,
	ColorCorrectionContrast: number,
	ColorCorrectionSaturation: number,
	ColorCorrectionTint: Color3,
}

export type RealmConfigSchema = {
	Theme: RealmTheme,
	DisplayName: string,
	Description: string,
	PlaceId: number,
	DefaultBiomeGroup: string,
	AllowedBiomes: { string },
	Lighting: RealmLightingPreset,
	AssetManifestOverride: string?,
}

local RealmConfig = {
	CurrentTheme = "CyberAlchemist" :: RealmTheme,
}

RealmConfig.Presets = {
	CyberAlchemist = {
		Theme = "CyberAlchemist",
		DisplayName = "COBLOX: Multiverse Alchemy Sanctum",
		Description = "Cyber-Alchemist Industrial — Main Realm",
		PlaceId = 105075159736246,
		DefaultBiomeGroup = "CyberAlchemist",
		AllowedBiomes = {
			"Zone_1_Lobby",
			"Zone_2_Forest",
			"Zone_3_Ocean",
			"Zone_4_Celestial",
		},
		Lighting = {
			ClockTime = 20.0,
			GeographicLatitude = 41.7,
			Ambient = Color3.fromRGB(24, 28, 48),
			OutdoorAmbient = Color3.fromRGB(15, 23, 42),
			Brightness = 1.8,
			ExposureCompensation = 0.2,
			EnvironmentDiffuseScale = 0.8,
			EnvironmentSpecularScale = 1.0,
			AtmosphereDensity = 0.35,
			AtmosphereOffset = 0.25,
			AtmosphereColor = Color3.fromRGB(30, 41, 89),
			AtmosphereDecay = Color3.fromRGB(15, 23, 42),
			AtmosphereGlare = 0.4,
			AtmosphereHaze = 1.2,
			BloomIntensity = 0.75,
			BloomSize = 24,
			BloomThreshold = 0.8,
			ColorCorrectionBrightness = 0.05,
			ColorCorrectionContrast = 0.15,
			ColorCorrectionSaturation = 0.2,
			ColorCorrectionTint = Color3.fromRGB(245, 248, 255),
		},
		AssetManifestOverride = nil,
	} :: RealmConfigSchema,

	Fairytale = {
		Theme = "Fairytale",
		DisplayName = "COBLOX: Fairytale Fantasy Realm",
		Description = "Enchanted Fairytale Realm — Expansion",
		PlaceId = 89919608022831,
		DefaultBiomeGroup = "Fairytale",
		AllowedBiomes = {
			"fairy_EnchantedForest",
			"fairy_AetherSkyCitadel",
			"fairy_GlacialCavern",
			"fairy_VolcanicForge",
			"fairy_VoidCaves",
			"fairy_CentralHub",
		},
		Lighting = {
			ClockTime = 5.5,
			GeographicLatitude = 45.0,
			Ambient = Color3.fromRGB(26, 0, 51),
			OutdoorAmbient = Color3.fromRGB(40, 20, 60),
			Brightness = 1.5,
			ExposureCompensation = 0.5,
			EnvironmentDiffuseScale = 0.9,
			EnvironmentSpecularScale = 0.7,
			AtmosphereDensity = 0.25,
			AtmosphereOffset = 0.15,
			AtmosphereColor = Color3.fromRGB(120, 80, 200),
			AtmosphereDecay = Color3.fromRGB(60, 30, 100),
			AtmosphereGlare = 0.6,
			AtmosphereHaze = 0.8,
			BloomIntensity = 1.2,
			BloomSize = 32,
			BloomThreshold = 0.6,
			ColorCorrectionBrightness = 0.08,
			ColorCorrectionContrast = 0.1,
			ColorCorrectionSaturation = 0.35,
			ColorCorrectionTint = Color3.fromRGB(240, 230, 255),
		},
		AssetManifestOverride = "AssetManifestFairytale",
	} :: RealmConfigSchema,
}

function RealmConfig.GetPreset(theme: RealmTheme): RealmConfigSchema?
	return RealmConfig.Presets[theme]
end

return RealmConfig
