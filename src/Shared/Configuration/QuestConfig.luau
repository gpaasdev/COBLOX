--!strict

local QuestConfig = {
	Quests = {
		["Quest_001_FirstDrop"] = {
			Id = "Quest_001_FirstDrop",
			Title = "First Extraction",
			Description = "Collect income from your initial Tycoon Synthesizer.",
			RewardCoins = 250,
			RewardGems = 5,
			TargetType = "CollectIncome",
			TargetAmount = 1,
			NextQuestId = "Quest_002_FirstUpgrade",
		},
		["Quest_002_FirstUpgrade"] = {
			Id = "Quest_002_FirstUpgrade",
			Title = "Factory Expansion",
			Description = "Purchase your first Tycoon upgrade from the plot board.",
			RewardCoins = 1000,
			RewardGems = 10,
			TargetType = "BuyUpgrade",
			TargetAmount = 1,
			NextQuestId = "Quest_003_FirstHatch",
		},
		["Quest_003_FirstHatch"] = {
			Id = "Quest_003_FirstHatch",
			Title = "Companion Companion",
			Description = "Hatch your very first pet from the Starter Common Egg.",
			RewardCoins = 2500,
			RewardGems = 25,
			TargetType = "HatchEgg",
			TargetAmount = 1,
			NextQuestId = "Quest_004_ForestTravel",
		},
		["Quest_004_ForestTravel"] = {
			Id = "Quest_004_ForestTravel",
			Title = "Into the Neon Forest",
			Description = "Unlock Zone 2 (Neon Forest Biome) using the portal network.",
			RewardCoins = 10000,
			RewardGems = 50,
			TargetType = "UnlockZone",
			TargetAmount = 1,
			NextQuestId = "Quest_005_RebirthPioneer",
		},
		["Quest_005_RebirthPioneer"] = {
			Id = "Quest_005_RebirthPioneer",
			Title = "Quantum Rebirth",
			Description = "Perform your first Rebirth to earn permanent multipliers and Rebirth Tokens.",
			RewardCoins = 50000,
			RewardGems = 200,
			TargetType = "Rebirth",
			TargetAmount = 1,
			NextQuestId = nil,
		},
	},

	NPCs = {
		["NPC_Guide_Cyber"] = {
			Id = "NPC_Guide_Cyber",
			Name = "Cyber Cyberia Overseer",
			Zone = "Zone_1_Lobby",
			Dialog = {
				Welcome = "Welcome to COBLOX! Build your automated tycoon, hatch rare companion pets, and conquer all biomes!",
				QuestOffer = "Ready to start your production empire?",
			},
		},
		["NPC_Merchant_Forest"] = {
			Id = "NPC_Merchant_Forest",
			Name = "Forest Relic Trader",
			Zone = "Zone_2_Forest",
			Dialog = {
				Welcome = "Greetings traveler! Trade your extra pets or gems for ancient forest artifacts.",
			},
		},
	},
}

return table.freeze(QuestConfig)
