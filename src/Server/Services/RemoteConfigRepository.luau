--!strict

export type ConfigSchema = {
	Version: number,
	FeatureFlags: { [string]: boolean },
	Tuning: { [string]: number },
}

local RemoteConfigRepository = {}

local defaultConfig: ConfigSchema = {
	Version = 1,
	FeatureFlags = {
		EnableGlobalAuctionHouse = true,
		EnableLiveOpsEvents = true,
		EnableDoubleXPWeekend = true,
		EnableQuantumVaultInterest = true,
		EnableLiveOpsJoinPopup = true,
		EnableLiveOpsTopBar = true,
		EnableLiveOpsDrawer = true,
		SkipCinematic = true,
	},
	Tuning = {
		AuraEnergyMultiplier = 1.0,
		VaultInterestRate = 0.05, -- 5% daily interest
		HatchChanceLegendaryMultiplier = 1.0,
		DailyQuestRewardCoins = 500,
		DailyQuestRewardXP = 100,
		RebirthCost = 1000000,
		RebirthTokenReward = 1,
		RebirthAuraMultiplier = 0.10,
	},
}

local cachedConfig: ConfigSchema = defaultConfig

function RemoteConfigRepository.LoadConfig(): ConfigSchema
	print("[RemoteConfigRepository] Loading runtime configuration repository (Version 1)...")
	return cachedConfig
end

function RemoteConfigRepository.GetDefaultConfig(): ConfigSchema
	return defaultConfig
end

return RemoteConfigRepository
