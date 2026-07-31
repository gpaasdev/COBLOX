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
		SkyboxTwilight = "rbxassetid://PROCESSING",
		FloatingIslandLarge = "rbxassetid://PROCESSING",
		EnchantedTree = "rbxassetid://PROCESSING",
		BioluminescentMushroom = "rbxassetid://PROCESSING",
		CrystalNodeAether = "rbxassetid://95546194813459",
		AncientPortalArch = "rbxassetid://PROCESSING",
	},
	Items = {
		GenesisPodCommon = "rbxassetid://PROCESSING",
		GenesisPodLegendary = "rbxassetid://PROCESSING",
		AetherCrystalMesh = "rbxassetid://97971631771384",
		ManaBloom = "rbxassetid://97904513888234",
	},
	Entities = {
		SpiritFoxMesh = "rbxassetid://126230304983904",
		CrystalGolemMesh = "rbxassetid://PROCESSING",
		PixieSwarm = "rbxassetid://PROCESSING",
		FairyDragon = "rbxassetid://118084289096110",
	},
	Cosmetics = {
		WingsAether = "rbxassetid://PROCESSING",
		FairyCrown = "rbxassetid://PROCESSING",
		EnchantedRobe = "rbxassetid://PROCESSING",
		TransmutationBadge = "rbxassetid://84604681973464",
	},
	Particles = {
		FairytaleSparkles = "rbxassetid://74429346357342",
		GlowingMotes = "rbxassetid://86655373792709",
		AuraChannelTrail = "rbxassetid://131962962069775",
		TransmutationBurst = "rbxassetid://124374758528939",
	},
	Audio = {
		FairytaleBGM_Main = "rbxassetid://134088863499105",
		MagicHatchSFX = "rbxassetid://134725968275841",
		AuraChannelSFX = "rbxassetid://96494887569423",
		EnchantedAmbient = "rbxassetid://94524502065950",
	},
}

return AssetManifestFairytale
