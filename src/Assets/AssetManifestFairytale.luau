--!strict
-- AssetManifestFairytale.luau
-- Single Source of Truth (SSOT) Asset Registry for Fairytale Realm COBLOX
-- ⚠️ All asset IDs are placeholders — upload via Creator Dashboard & replace

export type AssetGroup = { [string]: string }

export type ManifestSchema = {
	Environment: AssetGroup,
	Items: AssetGroup,
	Entities: AssetGroup,
	Cosmetics: AssetGroup,
	Particles: AssetGroup,
	Audio: AssetGroup,
}

local AssetManifestFairytale: ManifestSchema = {
	Environment = {
		SkyboxTwilight = "rbxassetid://0",
		FloatingIslandLarge = "rbxassetid://0",
		EnchantedTree = "rbxassetid://0",
		BioluminescentMushroom = "rbxassetid://0",
		CrystalNodeAether = "rbxassetid://0",
		AncientPortalArch = "rbxassetid://0",
	},
	Items = {
		GenesisPodCommon = "rbxassetid://0",
		GenesisPodLegendary = "rbxassetid://0",
		AetherCrystalMesh = "rbxassetid://0",
		ManaBloom = "rbxassetid://0",
	},
	Entities = {
		SpiritFoxMesh = "rbxassetid://0",
		CrystalGolemMesh = "rbxassetid://0",
		PixieSwarm = "rbxassetid://0",
		FairyDragon = "rbxassetid://0",
	},
	Cosmetics = {
		WingsAether = "rbxassetid://0",
		FairyCrown = "rbxassetid://0",
		EnchantedRobe = "rbxassetid://0",
	},
	Particles = {
		FairytaleSparkles = "rbxassetid://0",
		GlowingMotes = "rbxassetid://0",
		AuraChannelTrail = "rbxassetid://0",
		TransmutationBurst = "rbxassetid://0",
	},
	Audio = {
		FairytaleBGM_Main = "rbxassetid://0",
		MagicHatchSFX = "rbxassetid://0",
		AuraChannelSFX = "rbxassetid://0",
		EnchantedAmbient = "rbxassetid://0",
	},
}

return AssetManifestFairytale
