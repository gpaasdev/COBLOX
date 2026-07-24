--!strict

local AssetManifest = {
	Version = "1.1.0",
	GeneratedAt = "2026-07-23",
	
	Models = {
		Nature = {
			["StylizedTree_Emerald"] = "rbxassetid://1290033", -- Stylized Low-Poly Tree Mesh
			["StylizedTree_Sakura"] = "rbxassetid://1033714", -- Stylized Sakura Cone Mesh
			["RockCluster"] = "rbxassetid://1033714", -- Low-Poly Rock Mesh
			["FloatingIslandCore"] = "rbxassetid://1033714", -- Island Cone Mesh
			["ManaCrystalLarge"] = "rbxassetid://1082802", -- Glowing Mana Crystal Mesh
		},
		Tycoon = {
			["Dropper_Tier1"] = "rbxassetid://11442510", -- Alchemical Generator Mesh
			["Dropper_Tier2"] = "rbxassetid://11442510",
			["Dropper_Tier3"] = "rbxassetid://11442510",
			["Dropper_Tier4"] = "rbxassetid://11442510",
			["Collector_Tier1"] = "rbxassetid://11442510", -- Alchemical Receptor Basin Mesh
			["Collector_Tier2"] = "rbxassetid://11442510",
			["Upgrader_Tier1"] = "rbxassetid://11442510",
			["Conveyor_Speed1"] = "rbxassetid://11442510",
		},
		Mounts = {
			["NeonCrocodile"] = "rbxassetid://18863207", -- Giant Alligator Mesh
			["CosmicDragon"] = "rbxassetid://18863207",
		},
		Eggs = {
			["Egg_Basic"] = "rbxassetid://1082802",
			["Egg_Forest"] = "rbxassetid://1082802",
			["Egg_Ocean"] = "rbxassetid://1082802",
			["Egg_Celestial"] = "rbxassetid://1082802",
		},
	},

	Audio = {
		SFX = {
			CoinPurchase = "rbxassetid://6895079853",
			EggHatchCommon = "rbxassetid://9114224001",
			EggHatchLegendary = "rbxassetid://9114224500",
			PortalWarp = "rbxassetid://9114225100",
			MountRoar = "rbxassetid://9114225100",
		},
		BGM = {
			LobbyTheme = "rbxassetid://1837879084",
			ForestTheme = "rbxassetid://1837879500",
		},
	},

	UI = {
		Icons = {
			CoinIcon = "rbxassetid://6031086229",
			GemIcon = "rbxassetid://6031086300",
			RebirthIcon = "rbxassetid://6031086450",
			CrystalIcon = "rbxassetid://6031086229",
			MountIcon = "rbxassetid://6031086229",
		},
	},

	PBRMaterials = {
		PolyHavenSteel = {
			ColorMap = "rbxassetid://1082802",
			NormalMap = "rbxassetid://1082802",
			RoughnessMap = "rbxassetid://1082802",
			MetalnessMap = "rbxassetid://1082802",
		},
		PolyHavenMarble = {
			ColorMap = "rbxassetid://1082802",
			NormalMap = "rbxassetid://1082802",
			RoughnessMap = "rbxassetid://1082802",
		},
	},

	Licensing = {
		DefaultCommercialLicense = "RobloxStandard",

		AssetLicenses = {
			["Models.Nature.StylizedTree_Emerald"] = { Type = "CC0", Source = "CreatorStore_Verified" },
			["Models.Nature.StylizedTree_Sakura"] = { Type = "CC0", Source = "CreatorStore_Verified" },
			["Models.Nature.ManaCrystalLarge"] = { Type = "RobloxStandard", Source = "RobloxStudio" },
			["Audio.SFX.CoinPurchase"] = { Type = "CustomRoyaltyFree", Source = "DevForum_FreeComposition" },
			["Audio.SFX.EggHatchCommon"] = { Type = "CustomRoyaltyFree", Source = "DevForum_FreeComposition" },
			["Audio.BGM.LobbyTheme"] = { Type = "CustomRoyaltyFree", Source = "DevForum_FreeComposition" },
			["Audio.BGM.ForestTheme"] = { Type = "CustomRoyaltyFree", Source = "DevForum_FreeComposition" },
			["PBRMaterials.PolyHavenSteel"] = { Type = "CC0", Source = "PolyHaven" },
			["PBRMaterials.PolyHavenMarble"] = { Type = "CC0", Source = "PolyHaven" },
		},
	},
}

return table.freeze(AssetManifest)
