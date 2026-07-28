--!strict
-- FairytaleBiomeRegistry.luau
-- Content registry for Fairytale Realm biomes (LGBOS v11.0)
-- Each biome defines ambient lighting, fog, terrain params, and spawn tables

export type FairytaleBiomeDef = {
	Id: string,
	Name: string,
	Description: string,
	AmbientColor: Color3,
	OutdoorAmbient: Color3,
	FogColor: Color3,
	FogStart: number,
	FogEnd: number,
	TerrainMaterial: Enum.Material,
	ResourceNodes: { string },
	SpiritPool: { string },
}

local FairytaleBiomeRegistry: { [string]: FairytaleBiomeDef } = {}

FairytaleBiomeRegistry["fairy_CentralHub"] = {
	Id = "fairy_CentralHub",
	Name = "Sanctum Citadel",
	Description = "Main spawn hub in the Fairytale Realm",
	AmbientColor = Color3.fromRGB(26, 0, 51),
	OutdoorAmbient = Color3.fromRGB(40, 20, 60),
	FogColor = Color3.fromRGB(100, 80, 160),
	FogStart = 80,
	FogEnd = 200,
	TerrainMaterial = Enum.Material.SmoothPlastic,
	ResourceNodes = {},
	SpiritPool = {},
}

FairytaleBiomeRegistry["fairy_EnchantedForest"] = {
	Id = "fairy_EnchantedForest",
	Name = "Enchanted Forest",
	Description = "Bioluminescent woods with glowing flora",
	AmbientColor = Color3.fromRGB(20, 40, 30),
	OutdoorAmbient = Color3.fromRGB(30, 60, 40),
	FogColor = Color3.fromRGB(50, 80, 60),
	FogStart = 40,
	FogEnd = 120,
	TerrainMaterial = Enum.Material.Grass,
	ResourceNodes = { "ManaCrystal", "EnchantedWood", "MoonBloom" },
	SpiritPool = { "SPIRITFOX", "ENCHANTEDDEER", "PIXIESWARM" },
}

FairytaleBiomeRegistry["fairy_AetherSkyCitadel"] = {
	Id = "fairy_AetherSkyCitadel",
	Name = "Aether Sky Citadel",
	Description = "Floating islands with cascading waterfalls",
	AmbientColor = Color3.fromRGB(30, 20, 60),
	OutdoorAmbient = Color3.fromRGB(50, 40, 80),
	FogColor = Color3.fromRGB(120, 100, 180),
	FogStart = 60,
	FogEnd = 180,
	TerrainMaterial = Enum.Material.Glass,
	ResourceNodes = { "AetherCrystal", "SkyShard", "CloudEssence" },
	SpiritPool = { "AETHERWISP", "WYVERN", "STARGAZER" },
}

FairytaleBiomeRegistry["fairy_GlacialCavern"] = {
	Id = "fairy_GlacialCavern",
	Name = "Glacial Cavern",
	Description = "Ice crystal caves with glowing mushrooms",
	AmbientColor = Color3.fromRGB(10, 30, 50),
	OutdoorAmbient = Color3.fromRGB(20, 50, 70),
	FogColor = Color3.fromRGB(150, 180, 220),
	FogStart = 30,
	FogEnd = 100,
	TerrainMaterial = Enum.Material.Ice,
	ResourceNodes = { "FrostCrystal", "GlacialShard", "IcyMushroom" },
	SpiritPool = { "CRYSTALGOLEM", "FROSTPHOENIX", "ICEWRAITH" },
}

FairytaleBiomeRegistry["fairy_VolcanicForge"] = {
	Id = "fairy_VolcanicForge",
	Name = "Volcanic Forge",
	Description = "Alchemical lava fields with gold veins",
	AmbientColor = Color3.fromRGB(60, 20, 10),
	OutdoorAmbient = Color3.fromRGB(80, 30, 20),
	FogColor = Color3.fromRGB(180, 80, 30),
	FogStart = 50,
	FogEnd = 140,
	TerrainMaterial = Enum.Material.Slate,
	ResourceNodes = { "GoldVein", "FireCrystal", "LavaRock" },
	SpiritPool = { "ASHPUFF", "LAVASERPENT", "MAGMAGOLEM" },
}

FairytaleBiomeRegistry["fairy_VoidCaves"] = {
	Id = "fairy_VoidCaves",
	Name = "Void Caves",
	Description = "Deep subterranean caves with rare mana nodes",
	AmbientColor = Color3.fromRGB(5, 5, 15),
	OutdoorAmbient = Color3.fromRGB(10, 10, 25),
	FogColor = Color3.fromRGB(20, 10, 40),
	FogStart = 20,
	FogEnd = 60,
	TerrainMaterial = Enum.Material.SmoothPlastic,
	ResourceNodes = { "VoidCrystal", "DarkEssence", "AbyssalShard" },
	SpiritPool = { "VOIDSHADE", "ABYSSALKRAKEN", "DARKWISP" },
}

function FairytaleBiomeRegistry.Get(id: string): FairytaleBiomeDef?
	return FairytaleBiomeRegistry[id]
end

function FairytaleBiomeRegistry.GetAll(): { [string]: FairytaleBiomeDef }
	return FairytaleBiomeRegistry
end

return FairytaleBiomeRegistry
