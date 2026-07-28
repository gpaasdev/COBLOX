--!strict
local QuestRegistry = {
	["harvest_crystals_10"] = {
		Id = "harvest_crystals_10",
		Name = "Crystal Harvester",
		Description = "Harvest 10 Aura Crystals.",
		Target = 10,
		Reward = {
			AuraEnergy = 500,
			SeasonXP = 50,
		},
	},
	["hatch_pods_5"] = {
		Id = "hatch_pods_5",
		Name = "Spirit Breeder",
		Description = "Hatch 5 Genesis Pods.",
		Target = 5,
		Reward = {
			ChronoSparks = 10,
			SeasonXP = 100,
		},
	},
}

return QuestRegistry
