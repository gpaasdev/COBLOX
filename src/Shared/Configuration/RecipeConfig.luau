--!strict

export type Recipe = {
	Ingredients: { [string]: number },
	Result: string,
	CraftTime: number,
	VFXEffect: string,
}

local RecipeConfig: { [string]: Recipe } = {
	["HydroFlame Core"] = {
		Ingredients = { ["Water Element"] = 2, ["Fire Element"] = 1 },
		Result = "Steam Burst Matrix",
		CraftTime = 3,
		VFXEffect = "SteamExplosionBurst",
	},
	["ThunderChakra Matrix"] = {
		Ingredients = { ["Electro Core"] = 1, ["Chakra Crystal"] = 1 },
		Result = "Thunder God Companion Pod",
		CraftTime = 5,
		VFXEffect = "LightningParticleShow",
	},
	["QuantumAura Catalyst"] = {
		Ingredients = { ["Steam Burst Matrix"] = 1, ["Chakra Crystal"] = 2 },
		Result = "Kitsune Synthesis Spark",
		CraftTime = 8,
		VFXEffect = "QuantumAuraExplosion",
	},
}

return table.freeze(RecipeConfig)
