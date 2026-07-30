--!strict

export type ElementMarket = {
	Id: string,
	BasePrice: number,
	GlobalSupply: number,
	GlobalDemand: number,
	Volatility: number,
	Category: "Basic" | "Refined" | "Exotic",
}

local ElementMarketConfig: { [string]: ElementMarket } = {
	Iron_Ore = { Id = "Iron_Ore", BasePrice = 5, GlobalSupply = 5000, GlobalDemand = 3000, Volatility = 0.05, Category = "Basic" },
	Copper_Ore = { Id = "Copper_Ore", BasePrice = 8, GlobalSupply = 4000, GlobalDemand = 2500, Volatility = 0.05, Category = "Basic" },
	Coal = { Id = "Coal", BasePrice = 12, GlobalSupply = 3000, GlobalDemand = 2000, Volatility = 0.08, Category = "Basic" },
	Quartz = { Id = "Quartz", BasePrice = 25, GlobalSupply = 2000, GlobalDemand = 1800, Volatility = 0.1, Category = "Basic" },

	["Water Element"] = { Id = "Water Element", BasePrice = 40, GlobalSupply = 1500, GlobalDemand = 2000, Volatility = 0.12, Category = "Basic" },
	["Fire Element"] = { Id = "Fire Element", BasePrice = 45, GlobalSupply = 1400, GlobalDemand = 2100, Volatility = 0.12, Category = "Basic" },
	AstralIron = { Id = "AstralIron", BasePrice = 80, GlobalSupply = 800, GlobalDemand = 1500, Volatility = 0.15, Category = "Refined" },
	PyroEssence = { Id = "PyroEssence", BasePrice = 120, GlobalSupply = 500, GlobalDemand = 1200, Volatility = 0.2, Category = "Refined" },
	HydroCrystal = { Id = "HydroCrystal", BasePrice = 130, GlobalSupply = 450, GlobalDemand = 1100, Volatility = 0.2, Category = "Refined" },

	AetherCrystal = { Id = "AetherCrystal", BasePrice = 500, GlobalSupply = 100, GlobalDemand = 500, Volatility = 0.25, Category = "Exotic" },
	VoidBone = { Id = "VoidBone", BasePrice = 250, GlobalSupply = 50, GlobalDemand = 100, Volatility = 0.35, Category = "Exotic" },
	FerriumAlloy = { Id = "FerriumAlloy", BasePrice = 1200, GlobalSupply = 10, GlobalDemand = 50, Volatility = 0.15, Category = "Exotic" },
}

return ElementMarketConfig
