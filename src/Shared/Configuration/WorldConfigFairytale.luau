--!strict
-- WorldConfigFairytale.luau
-- World configuration for Fairytale Realm (LGBOS v11.0)
-- Defines zones, plot layout, lighting, and NPC spawns

local WorldConfigFairytale = {
	Zones = {
		fairy_CentralHub = {
			Name = "Sanctum Citadel",
			DisplayName = "Sanctum Citadel",
			Description = "Main spawn hub in the Fairytale Realm",
			AmbientLighting = {
				Ambient = Color3.fromRGB(26, 0, 51),
				OutdoorAmbient = Color3.fromRGB(40, 20, 60),
			},
		},
		fairy_EnchantedForest = {
			Name = "Enchanted Forest",
			DisplayName = "Enchanted Forest",
			Description = "Bioluminescent woods with glowing flora",
			AmbientLighting = {
				Ambient = Color3.fromRGB(20, 40, 30),
				OutdoorAmbient = Color3.fromRGB(30, 60, 40),
			},
		},
		fairy_AetherSkyCitadel = {
			Name = "Aether Sky Citadel",
			DisplayName = "Aether Sky Citadel",
			Description = "Floating islands with cascading waterfalls",
			AmbientLighting = {
				Ambient = Color3.fromRGB(30, 20, 60),
				OutdoorAmbient = Color3.fromRGB(50, 40, 80),
			},
		},
		fairy_GlacialCavern = {
			Name = "Glacial Cavern",
			DisplayName = "Glacial Cavern",
			Description = "Ice crystal caves with glowing mushrooms",
			AmbientLighting = {
				Ambient = Color3.fromRGB(10, 30, 50),
				OutdoorAmbient = Color3.fromRGB(20, 50, 70),
			},
		},
		fairy_VolcanicForge = {
			Name = "Volcanic Forge",
			DisplayName = "Volcanic Forge",
			Description = "Alchemical lava fields with gold veins",
			AmbientLighting = {
				Ambient = Color3.fromRGB(60, 20, 10),
				OutdoorAmbient = Color3.fromRGB(80, 30, 20),
			},
		},
		fairy_VoidCaves = {
			Name = "Void Caves",
			DisplayName = "Void Caves",
			Description = "Deep subterranean caves with rare mana nodes",
			AmbientLighting = {
				Ambient = Color3.fromRGB(5, 5, 15),
				OutdoorAmbient = Color3.fromRGB(10, 10, 25),
			},
		},
	},

	Plots = {
		PlotCount = 0,
	},

	Lore = {
		Title = "Fairytale Fantasy Realm",
		Description = "A parallel realm of twilight magic, where bioluminescent nature meets ancient alchemy.",
		HubName = "Sanctum Citadel",
	},
}

return WorldConfigFairytale
