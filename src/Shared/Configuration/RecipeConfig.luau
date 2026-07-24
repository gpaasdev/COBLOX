--!strict

export type RecipeResultType = "Consumable" | "Spirit" | "Potion"
export type RecipeRarity = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic"

export type RecipeDef = {
	Id: string,
	Name: string,
	ResultType: RecipeResultType,
	Rarity: RecipeRarity,
	Ingredients: { [string]: number },
	Result: string,
	CraftingTime: number, -- Seconds
	VFXEffect: string,
	LoreDescription: string?,
}

local RecipeConfig = {
	Recipes = {
		["ramuan_aura_murni"] = {
			Id = "ramuan_aura_murni",
			Name = "Ramuan Aura Murni",
			ResultType = "Potion",
			Rarity = "Legendary",
			Ingredients = {
				["Luminous Herb"] = 5,
				["Void Dust"] = 3,
			},
			Result = "Ramuan Aura Murni",
			CraftingTime = 5,
			VFXEffect = "AuraExplosion",
			LoreDescription = "Penyatuan bahan mistis untuk menghasilkan Ramuan yang kuat.",
		},
		["spirit_void_dragon"] = {
			Id = "spirit_void_dragon",
			Name = "Void Dragon",
			ResultType = "Spirit",
			Rarity = "Mythic",
			Ingredients = {
				["Void Dust"] = 10,
				["Dragon Scale"] = 1,
				["Ramuan Aura Murni"] = 1,
			},
			Result = "Void Dragon Companion",
			CraftingTime = 15,
			VFXEffect = "DragonSummonBurst",
			LoreDescription = "Mensintesis roh naga kuno dari kehampaan.",
		},
		["HydroFlame Core"] = {
			Id = "HydroFlame Core",
			Name = "HydroFlame Core",
			ResultType = "Consumable",
			Rarity = "Rare",
			Ingredients = { ["Water Element"] = 2, ["Fire Element"] = 1 },
			Result = "Steam Burst Matrix",
			CraftingTime = 3,
			VFXEffect = "SteamExplosionBurst",
			LoreDescription = "Penyatuan mistis elemen Air dan Api untuk melepaskan percikan energi uap magis.",
		},
	} :: { [string]: RecipeDef }
}

return table.freeze(RecipeConfig)
