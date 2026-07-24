--!strict

local LiveOpsConfig = {
	Events = {
		["Weekend_2x_Luck"] = {
			Name = "Weekend Super Luck Event",
			Active = true,
			LuckMultiplier = 2.0,
			CoinMultiplier = 1.5,
			BannerMessage = "⚡ 2X LUCK & 1.5X COIN WEEKEND IS LIVE! ⚡",
		},
	},

	SeasonPass = {
		SeasonNumber = 1,
		Title = "Cyber Genesis Season Pass",
		DurationDays = 30,
		MaxTier = 20,
		Tiers = {
			{ Tier = 1, RequiredXp = 100, RewardType = "Coins", RewardValue = 5000 },
			{ Tier = 2, RequiredXp = 250, RewardType = "Gems", RewardValue = 50 },
			{ Tier = 3, RequiredXp = 500, RewardType = "Egg", RewardValue = "Egg_Forest" },
			{ Tier = 5, RequiredXp = 1200, RewardType = "Pet", RewardValue = "Pet_Epic_Pegasus" },
			{ Tier = 10, RequiredXp = 3000, RewardType = "Pet", RewardValue = "Pet_Mythic_Phoenix" },
			{ Tier = 20, RequiredXp = 10000, RewardType = "Pet", RewardValue = "Pet_Secret_CelestialVoid" },
		},
	},

	DailyRewards = {
		Day1 = { Coins = 1000, Gems = 5 },
		Day2 = { Coins = 2500, Gems = 10 },
		Day3 = { Coins = 5000, Gems = 20 },
		Day4 = { Coins = 10000, Gems = 35 },
		Day5 = { Egg = "Egg_Forest" },
		Day6 = { Coins = 25000, Gems = 75 },
		Day7 = { Pet = "Pet_Legendary_Dragon", Gems = 150 },
	},
}

return table.freeze(LiveOpsConfig)
