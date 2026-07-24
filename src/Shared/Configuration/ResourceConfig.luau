--!strict

local ResourceTypes = require(script.Parent.Parent.Types.ResourceTypes)

type ResourceNodeDef = ResourceTypes.ResourceNodeDef

export type ToolStats = {
	Id: string,
	Name: string,
	Type: ResourceTypes.ToolTypeRequirement,
	Tier: number,
	MiningSpeed: number, -- Cooldown in seconds between hits
	YieldMultiplier: number,
}

local ResourceConfig = {
	Tools = {
		["StarterSickle"] = {
			Id = "StarterSickle",
			Name = "Novice Herbal Sickle",
			Type = "Sickle",
			Tier = 1,
			MiningSpeed = 1.0,
			YieldMultiplier = 1.0,
		},
		["StarterPickaxe"] = {
			Id = "StarterPickaxe",
			Name = "Rusty Mining Pick",
			Type = "Pickaxe",
			Tier = 1,
			MiningSpeed = 1.2,
			YieldMultiplier = 1.0,
		},
		["VoidBreakerPickaxe"] = {
			Id = "VoidBreakerPickaxe",
			Name = "Void-Breaker Titanium Pick",
			Type = "Pickaxe",
			Tier = 3,
			MiningSpeed = 0.6,
			YieldMultiplier = 2.5,
		},
	} :: { [string]: ToolStats },

	Nodes = {
		["luminous_bush"] = {
			Id = "luminous_bush",
			Name = "Luminous Herb Bush",
			Type = "Herb",
			MaxHealth = 1,
			RespawnTime = 10,
			RequiredToolType = "None",
			RequiredToolTier = 1,
			LootTable = {
				{ ItemId = "Luminous Herb", Chance = 100, MinQuantity = 1, MaxQuantity = 3 },
				{ ItemId = "Aura Dew", Chance = 25, MinQuantity = 1, MaxQuantity = 1 },
			},
			HitSFX = "rbxassetid://9114223166",
			DestroyVFX = "HerbBurstVFX",
		},
		["void_ore_node"] = {
			Id = "void_ore_node",
			Name = "Void Ore Deposit",
			Type = "Ore",
			MaxHealth = 3,
			RespawnTime = 20,
			RequiredToolType = "Pickaxe",
			RequiredToolTier = 1,
			LootTable = {
				{ ItemId = "Void Dust", Chance = 100, MinQuantity = 2, MaxQuantity = 4 },
				{ ItemId = "Quantum Shard", Chance = 15, MinQuantity = 1, MaxQuantity = 1 },
			},
			HitSFX = "rbxassetid://9114223166",
			DestroyVFX = "OreCrushVFX",
		},
		["celestial_crystal_boss"] = {
			Id = "celestial_crystal_boss",
			Name = "Celestial Void Crystal (Boss)",
			Type = "Boss",
			MaxHealth = 10,
			RespawnTime = 120,
			RequiredToolType = "Pickaxe",
			RequiredToolTier = 3,
			LootTable = {
				{ ItemId = "Celestial Void Essence", Chance = 100, MinQuantity = 1, MaxQuantity = 2 },
				{ ItemId = "Dragon Scale", Chance = 50, MinQuantity = 1, MaxQuantity = 2 },
			},
			HitSFX = "rbxassetid://9114223166",
			DestroyVFX = "CelestialExplosionVFX",
		},
	} :: { [string]: ResourceNodeDef },

	SpawnZones = {
		["Forest_Herb_Zone"] = {
			NodeId = "luminous_bush",
			MaxNodes = 15,
			BoundsMin = Vector3.new(-100, 0, -100),
			BoundsMax = Vector3.new(100, 0, 100),
		},
		["Void_Mines_Zone"] = {
			NodeId = "void_ore_node",
			MaxNodes = 8,
			BoundsMin = Vector3.new(200, 0, 200),
			BoundsMax = Vector3.new(400, 0, 400),
		},
	},
}

return table.freeze(ResourceConfig)
