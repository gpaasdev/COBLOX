--!strict
local MachineConfig = {
	Types = {
		Reactor = {
			DisplayName = "Alchemical Reactor",
			PowerConsumption = 10,
			HeatGeneration = 5,
			MaxHeat = 500,
			Durability = 1000,
			BaseProduction = 1.0,
		},
		Smelter = {
			DisplayName = "Arcane Smelter",
			PowerConsumption = 15,
			HeatGeneration = 20,
			MaxHeat = 1200,
			Durability = 800,
			BaseProduction = 1.5,
		},
		Furnace = {
			DisplayName = "Mana Furnace",
			PowerConsumption = 8,
			HeatGeneration = 15,
			MaxHeat = 900,
			Durability = 600,
			BaseProduction = 0.8,
		},
		Crucible = {
			DisplayName = "Void Crucible",
			PowerConsumption = 25,
			HeatGeneration = 30,
			MaxHeat = 2000,
			Durability = 1500,
			BaseProduction = 2.0,
		},
	},
	Defaults = {
		MaxPower = 100,
		StartPower = 50,
		PowerRegenRate = 2,
		PassiveWasteDecay = 0.1,
	},
	Costs = {
		Reactor = { Coins = 5000, Gems = 25 },
		Smelter = { Coins = 8000, Gems = 50 },
		Furnace = { Coins = 3000, Gems = 10 },
		Crucible = { Coins = 15000, Gems = 100 },
	},
}
return table.freeze(MachineConfig)
