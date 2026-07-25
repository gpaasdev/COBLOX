--!strict
-- COBLOX Shared Client Configuration
-- Data-driven configuration for Client Systems & Controllers.

export type ARLensConfigType = {
	ScanDistance: number,
	MaxWidgets: number,
	AdaptiveRates: {
		Idle: number,       -- Hz (2)
		Walking: number,    -- Hz (10)
		Interacting: number,-- Hz (20)
		Scanning: number,   -- Hz (30)
		Combat: number,     -- Hz (60)
	},
	FadeDistance: number,
	LODDistance: number,
	AnimationSpeed: number,
}

export type LightingConfigType = {
	FpsSampleWindow: number,
	FpsDowngradeThreshold: number,
	FpsUpgradeThreshold: number,
	StableDurationRequired: number,
}

export type UIConfigType = {
	AnimationDuration: number,
	FadeDistance: number,
	DefaultTransparency: number,
}

export type AccessibilityConfigType = {
	FontScaling: number,
	HighContrast: boolean,
	ReducedMotion: boolean,
}

local ClientConfig = {
	ARLens = {
		ScanDistance = 100,
		MaxWidgets = 10,
		AdaptiveRates = {
			Idle = 2,
			Walking = 10,
			Interacting = 20,
			Scanning = 30,
			Combat = 60,
		},
		FadeDistance = 120,
		LODDistance = 60,
		AnimationSpeed = 0.25,
	} :: ARLensConfigType,

	Lighting = {
		FpsSampleWindow = 5,
		FpsDowngradeThreshold = 45,
		FpsUpgradeThreshold = 58,
		StableDurationRequired = 5,
	} :: LightingConfigType,

	UI = {
		AnimationDuration = 0.3,
		FadeDistance = 150,
		DefaultTransparency = 0.15,
	} :: UIConfigType,

	Accessibility = {
		FontScaling = 1.0,
		HighContrast = false,
		ReducedMotion = false,
	} :: AccessibilityConfigType,
}

return ClientConfig
