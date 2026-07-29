--!strict

export type ConfigSchema = {
	Version: number,
	FeatureFlags: { [string]: boolean },
	Tuning: { [string]: number },
	StringConfig: { [string]: string },
	BoolConfig: { [string]: boolean },
}

local RemoteConfigRepository = {}

local defaultConfig: ConfigSchema = {
	Version = 2,
	-- Feature flags — togglable without commit
	FeatureFlags = {
		EnableGlobalAuctionHouse = true,
		EnableLiveOpsEvents = true,
		EnableDoubleXPWeekend = true,
		EnableQuantumVaultInterest = true,
		EnableLiveOpsJoinPopup = true,
		EnableLiveOpsTopBar = true,
		EnableLiveOpsDrawer = true,
		SkipCinematic = true,
		-- Migrated from GameConfig BOOT_FLAGS
		ServiceEnabled_MachineService = false,
		ServiceEnabled_DiscoveryService = true,
		ServiceEnabled_ReactionEngine = true,
		ServiceEnabled_AlchemyService = true,
	},
	-- Numeric tuning values
	Tuning = {
		-- Combat
		Combat_BaseDamage = 10,
		Combat_Range = 15,
		Combat_MobCombatRange = 15,
		Combat_MobAttackRange = 6,
		Combat_MobAggroRadius = 30,
		Combat_MobLeashDistance = 45,
		Combat_MobWindupDuration = 1.0,
		Combat_MobSpeed = 14,

		-- Economy
		Economy_VaultInterestRate = 0.05,
		Economy_VaultMaxCapDays = 30,
		Economy_RebirthBaseCost = 100000,
		Economy_RebirthScalingExponent = 2.5,
		Economy_RebirthTokenReward = 1,
		Economy_LedgerMaxEntries = 100,
		Economy_CrystalDepositCap = 5000000,
		Economy_LargeDepositBroadcastMin = 10000,
		Economy_BaseStarterAura = 250,
		Economy_BaseStarterSparks = 25,
		Economy_BaseStarterCoins = 250,
		Economy_BaseStarterGems = 25,
		Economy_VaultDailyInterestRate = 0.05,
		Economy_CozyRatingLuckBoost = 0.02,
		Economy_RebirthBaseCostCoins = 5000,
		Economy_RebirthCostMultiplier = 2.2,
		Economy_RebirthTokenRewardBase = 1,
		Economy_MaxBaseEquipSlots = 4,
		Economy_MaxBaseInventorySlots = 75,

		-- Pets
		Pet_MaxStorage = 50,
		Pet_AutoMiningInterval = 2.0,
		Pet_AutoMiningBaseYield = 10,
		Pet_AwakeningMultiplierBonus = 0.5,
		Pet_ScanRadius = 15,

		-- LiveOps
		LiveOps_LuckMultiplier = 1.0,
		LiveOps_CoinMultiplier = 1.0,
		LiveOps_XPMultiplier = 1.0,
		LiveOps_AuraMultiplier = 1.0,
		LiveOps_HatchLuckMultiplier = 1.0,
		LiveOps_SeasonXpPerHatch = 10,
		LiveOps_SeasonXpPerRebirth = 250,

		-- Hatching
		Hatch_ChanceLegendaryMultiplier = 1.0,

		-- Quests
		Quest_DailyRewardCoins = 500,
		Quest_DailyRewardXP = 100,

		-- Machine
		Machine_MaxPerFrame = 10,
		Machine_DefaultHeat = 293,
		Machine_WasteThreshold = 100,

		-- Misc
		AuraEnergyMultiplier = 1.0,
		RebirthCost = 1000000,
		RebirthAuraMultiplier = 0.10,
	},
	-- String config values
	StringConfig = {
		LiveOps_ActiveSeasonId = "Season_01_MythicRise",
		LiveOps_GlobalAnnouncement = "",
		Monetization_GuildedWebhookURL = "",
	},
	-- Boolean config values
	BoolConfig = {
		LiveOps_WeekendDoubleLuck = true,
		LiveOps_WeekendDoubleCoins = true,
	},
}

local cachedConfig: ConfigSchema = defaultConfig

function RemoteConfigRepository.LoadConfig(): ConfigSchema
	return cachedConfig
end

function RemoteConfigRepository.GetDefaultConfig(): ConfigSchema
	return defaultConfig
end

function RemoteConfigRepository.UpdateConfig(updates: { [string]: any })
	for key, value in updates do
		if defaultConfig.Tuning[key] ~= nil then
			cachedConfig.Tuning[key] = value
		elseif defaultConfig.FeatureFlags[key] ~= nil then
			cachedConfig.FeatureFlags[key] = value
		elseif defaultConfig.StringConfig[key] ~= nil then
			cachedConfig.StringConfig[key] = value
		elseif defaultConfig.BoolConfig[key] ~= nil then
			cachedConfig.BoolConfig[key] = value
		end
	end
	cachedConfig.Version += 1
end

return RemoteConfigRepository
