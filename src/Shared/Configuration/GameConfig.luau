--!strict
-- GameConfig.luau
-- Central configuration for COBLOX gameplay systems.
-- All hardcoded magic numbers should reference this module.
-- Sesuai Q6: hand-authored configs di Configuration/, Generated output di Config/.

local GameConfig = {

	Combat = {
		BaseDamage = 10,
		CombatRange = 15, -- studs: zero-trust max distance for melee hit
		ZoneModifiers = {
			Wilderness = { damage = 1.5, hitStun = 1.2 },
			Arena = { damage = 0.8, hitStun = 0.2 },
			FactionWars = { damage = 2.5, hitStun = 0.4 },
			Safezone = { damage = 0.0, hitStun = 0.0 },
		},
		MobCombatRange = 15, -- studs: distance mob tries to attack
		MobAttackRange = 6, -- studs: distance mob deal damage
		MobAggroRadius = 30, -- studs: activation radius
		MobLeashDistance = 45, -- studs: leash-back threshold
		MobWindupDuration = 1.0, -- seconds
		MobSpeed = 14, -- Humanoid.WalkSpeed for mobs
	},

	MobLootTable = {
		Default = {
			-- { Type, ItemId, Amount, Weight(%) }
			{ "Currency", "Coins", 50, 70 },
			{ "Currency", "Coins", 150, 20 },
			{ "Item", "Fire Element", 1, 8 },
			{ "Currency", "Gems", 1, 2 },
		},
		Boss = {
			{ "Currency", "Coins", 500, 40 },
			{ "Currency", "Gems", 5, 30 },
			{ "Item", "Void Crystal", 1, 20 },
			{ "Currency", "RebirthTokens", 1, 10 },
		},
	},

	Pet = {
		MaxPetStorage = 50,
		AutoMiningInterval = 2.0, -- seconds between auto-mine cycles
		AutoMiningBaseYield = 10, -- base Coins per cycle before multiplier
		AwakeningMultiplierBonus = 0.5, -- +50% on awakening
		ScanRadius = 15, -- studs: pet mines nodes within this range
	},

	Economy = {
		VaultInterestRate = 0.05, -- 5% compound interest per AddCrystalCharge call
		VaultMaxCapDays = 30, -- days before interest stops compounding
		RebirthBaseCost = 100000,
		RebirthScalingExponent = 2.5,
		RebirthTokenReward = 1,
		LedgerMaxEntries = 100, -- Q4: rolling window
		CrystalDepositCap = 5000000, -- max Coins per purification transaction
		LargeDepositBroadcastMin = 10000, -- threshold for global broadcast
	},

	-- Service Boot Feature Flags (RC-2 — 2026-07-28)
	-- true  = service is booted on startup
	-- false = service is skipped (safe off for gradual rollout)
	-- Existing 38 services are implicitly true; only new services are listed here.
	-- Flip to true after Studio validation is confirmed.
	BOOT_FLAGS = {
		-- Tier 1.5 (lightweight — safe to boot immediately)
		DailyLoginService = true, -- Stub: PlayerAdded hook only
		LeaderboardService = true, -- Production: ODS read/write
		SocialSimulationService = true, -- Stub: no deps, Init/Start only
		PoliticalService = true, -- Stub: no heavy processing
		MacroEconomyService = true, -- Stub: lazy price calc

		-- Tier 2.5 (gameplay systems — enabled Phase B)
		DiscoveryService = true, -- Production: recipe discovery system
		ReactionEngine = true, -- Production: alchemical reaction simulator
		MachineService = true, -- Production: BoundedTick + MachineConfig enabled

		-- Tier 3.5 (core gameplay — enabled Phase B)
		AlchemyService = true, -- Production: crafting/synthesis system
		ResourceService = true, -- Production: world resource nodes
		InteractionService = true, -- Production: grab/drop/throw
		BlockBuilderService = true, -- Production: procedural block building system

		-- Tier 4+ (announcements — safe)
		AnnouncementService = true, -- Stub: DomainEventBus only
		CrossServerMessagingService = true, -- Production: pcall-wrapped

		-- Tier 2.75 (Realm — multi-place)
		RealmAssemblyService = true, -- Production: realm-aware WorldAssembly
		RealmTeleportService = true, -- Production: cross-realm teleport

		-- Tier 5 (Monetization & Social — Production Ready)
		RewardedAdService = true, -- Production: AdService + reward dispense
		BadgeService = true, -- Production: Roblox BadgeService + Open Cloud sync
		SocialEngagementService = true, -- Production: PromptGameInvite + notifications

		-- Tier 5.5 (Subscription — Pending Dashboard Setup)
		SubscriptionService = true, -- Production: Monthly Alchemist $4.99/mo

		-- Tier 6 (Gameplay Systems — Phase A)
		WeaponService = true, -- Production: Weapon tiers & progression
	},
}

return GameConfig
