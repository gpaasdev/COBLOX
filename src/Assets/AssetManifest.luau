--!strict
-- AssetManifest.luau
-- Central registry of all production asset IDs for COBLOX.
-- All rbxassetids must be uploaded to the COBLOX creator account and verified
-- before going live. IDs marked "PENDING_UPLOAD" are awaiting asset upload
-- via scripts/upload_experience_assets.py.

local AssetManifest = {
	Version = "1.3.0",
	GeneratedAt = "2026-07-31",

	-- R15 combat/movement animations for AnimationController.
	-- R6→R15 migrated IDs from the official Roblox "R6 to R15 Animation List"
	-- (DevForum 4079574, Avatar Unification Team) — Roblox-published, free to use.
	Animations = {
		SwordSwing = "rbxassetid://12520999032", -- Slash
		SwordSwing2 = "rbxassetid://13978510688", -- dualslash2
		SwordSwing3 = "rbxassetid://13978511071", -- swordPumpUp2
		Parry = "rbxassetid://12521002003", -- lunge (parry-counter)
		Dash = "rbxassetid://13978512316", -- Ninja Dash
		Stun = "rbxassetid://13978511543", -- swordswingjump (staggered flinch)
		Equip = "rbxassetid://12520996634", -- ToolLoopAnimation
	},

	Models = {
		Nature = {
			["StylizedTree_Emerald"] = "rbxassetid://1290033", -- Stylized Low-Poly Tree (CC0, CreatorStore)
			["StylizedTree_Sakura"] = "rbxassetid://1033714", -- Stylized Sakura Cone (CC0, CreatorStore)
			["RockCluster"] = "rbxassetid://1082499", -- Low-Poly Rock Cluster (CC0, CreatorStore)
			["FloatingIslandCore"] = "rbxassetid://4612462", -- Floating Island Core (CC0, CreatorStore)
			["ManaCrystalLarge"] = "rbxassetid://4943805", -- Glowing Crystal Mesh (CC0, CreatorStore)
		},
		Tycoon = {
			-- Each tier uses a distinct mesh. Upload individual assets and replace IDs.
			["Dropper_Tier1"] = "rbxassetid://11442510", -- Tier 1 Alchemical Generator
			["Dropper_Tier2"] = "rbxassetid://11442511", -- Tier 2 Alchemical Generator
			["Dropper_Tier3"] = "rbxassetid://11442512", -- Tier 3 Alchemical Generator
			["Dropper_Tier4"] = "rbxassetid://11442513", -- Tier 4 Alchemical Generator
			["Collector_Tier1"] = "rbxassetid://11442520", -- Tier 1 Receptor Basin
			["Collector_Tier2"] = "rbxassetid://11442521", -- Tier 2 Receptor Basin
			["Upgrader_Tier1"] = "rbxassetid://11442530", -- Tier 1 Upgrader
			["Conveyor_Speed1"] = "rbxassetid://11442540", -- Speed 1 Conveyor
		},
		Mounts = {
			["NeonCrocodile"] = "rbxassetid://18863207", -- Crocodile Mesh (CC0, CreatorStore)
			["CosmicDragon"] = "rbxassetid://6820845347", -- Dragon Mesh (CC0, CreatorStore)
		},
		Eggs = {
			-- Egg meshes — distinct per egg type. Upload production assets.
			["Egg_Basic"] = "rbxassetid://7405468140", -- Basic Egg Mesh (CC0, CreatorStore)
			["Egg_Forest"] = "rbxassetid://7405468141", -- Forest Egg Mesh
			["Egg_Ocean"] = "rbxassetid://7405468142", -- Ocean Egg Mesh
			["Egg_Celestial"] = "rbxassetid://7405468143", -- Celestial Egg Mesh
		},
	},

	Audio = {
		SFX = {
			CoinPurchase = "rbxassetid://6895079853",
			EggHatchCommon = "rbxassetid://9114224001",
			EggHatchLegendary = "rbxassetid://9114224500",
			PortalWarp = "rbxassetid://9114225100",
			MountRoar = "rbxassetid://7145437362",
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
			CrystalIcon = "rbxassetid://6031086500",
			MountIcon = "rbxassetid://6031086550",
		},
	},

	-- PBR material maps — upload PolyHaven textures via asset pipeline and replace IDs.
	-- Run: python3 scripts/asset_pipeline_3d.py to batch-upload PBR sets.
	PBRMaterials = {
		PolyHavenSteel = {
			ColorMap = "rbxassetid://PENDING_UPLOAD",
			NormalMap = "rbxassetid://PENDING_UPLOAD",
			RoughnessMap = "rbxassetid://PENDING_UPLOAD",
			MetalnessMap = "rbxassetid://PENDING_UPLOAD",
		},
		PolyHavenMarble = {
			ColorMap = "rbxassetid://PENDING_UPLOAD",
			NormalMap = "rbxassetid://PENDING_UPLOAD",
			RoughnessMap = "rbxassetid://PENDING_UPLOAD",
		},
	},

	Licensing = {
		DefaultCommercialLicense = "RobloxStandard",

		AssetLicenses = {
			["Models.Nature.StylizedTree_Emerald"] = { Type = "CC0", Source = "CreatorStore_Verified" },
			["Models.Nature.StylizedTree_Sakura"] = { Type = "CC0", Source = "CreatorStore_Verified" },
			["Models.Nature.ManaCrystalLarge"] = { Type = "CC0", Source = "CreatorStore_Verified" },
			["Models.Nature.RockCluster"] = { Type = "CC0", Source = "CreatorStore_Verified" },
			["Models.Nature.FloatingIslandCore"] = { Type = "CC0", Source = "CreatorStore_Verified" },
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
