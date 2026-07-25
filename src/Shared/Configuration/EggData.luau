--!strict

local EggData = {
	["Egg_Basic"] = {
		Name = "Starter Common Egg",
		CostCoins = 50,
		CostGems = 0,
		HatchTimeSeconds = 1.0,
		ModelAssetId = 1471714120, -- Basic Egg Mesh
		IconId = "rbxassetid://1471714120",
		Pool = {
			{ PetId = "Pet_Common_Cat", Weight = 50 },
			{ PetId = "Pet_Uncommon_Dog", Weight = 30 },
			{ PetId = "Pet_Rare_Fox", Weight = 14 },
			{ PetId = "Pet_Epic_Unicorn", Weight = 5 },
			{ PetId = "Pet_Legendary_Dragon", Weight = 1 },
		},
	},
	["Egg_Forest"] = {
		Name = "Deep Forest Egg",
		CostCoins = 500,
		CostGems = 0,
		HatchTimeSeconds = 1.5,
		ModelAssetId = 1471714121, -- Forest Egg Mesh
		IconId = "rbxassetid://1471714121",
		Pool = {
			{ PetId = "Pet_Uncommon_Dog", Weight = 40 },
			{ PetId = "Pet_Rare_Fox", Weight = 30 },
			{ PetId = "Pet_Rare_Bear", Weight = 20 },
			{ PetId = "Pet_Epic_Pegasus", Weight = 8 },
			{ PetId = "Pet_Legendary_Dragon", Weight = 2 },
		},
	},
	["Egg_Ocean"] = {
		Name = "Abyssal Ocean Egg",
		CostCoins = 5000,
		CostGems = 0,
		HatchTimeSeconds = 2.0,
		ModelAssetId = 1471714122, -- Ocean Egg Mesh
		IconId = "rbxassetid://1471714122",
		Pool = {
			{ PetId = "Pet_Rare_Bear", Weight = 45 },
			{ PetId = "Pet_Epic_Unicorn", Weight = 30 },
			{ PetId = "Pet_Epic_Pegasus", Weight = 18 },
			{ PetId = "Pet_Legendary_Kraken", Weight = 6 },
			{ PetId = "Pet_Mythic_Hydra", Weight = 1 },
		},
	},
	["Egg_Celestial"] = {
		Name = "Celestial Mythic Egg",
		CostCoins = 50000,
		CostGems = 100,
		HatchTimeSeconds = 3.0,
		ModelAssetId = 1471714123, -- Celestial Egg Mesh
		IconId = "rbxassetid://1471714123",
		Pool = {
			{ PetId = "Pet_Epic_Pegasus", Weight = 50 },
			{ PetId = "Pet_Legendary_Dragon", Weight = 30 },
			{ PetId = "Pet_Legendary_Kraken", Weight = 14 },
			{ PetId = "Pet_Mythic_Phoenix", Weight = 5 },
			{ PetId = "Pet_Secret_CelestialVoid", Weight = 0.9 },
			{ PetId = "Pet_Secret_ChronoTitan", Weight = 0.1 },
		},
	},
}

return table.freeze(EggData)
