--!strict

local EconomyConfig = {
	-- Starter Currencies (LGBOS v11.0)
	BASE_STARTER_AURA = 250,
	BASE_STARTER_SPARKS = 25,
	BASE_STARTER_COINS = 250, -- Compatibility alias
	BASE_STARTER_GEMS = 25, -- Compatibility alias

	-- Quantum Vault (Compound Interest)
	VAULT_DAILY_INTEREST_RATE = 0.05, -- 5% per day (Prevents hyper-inflation vs 5% hourly)
	COZY_RATING_LUCK_BOOST = 0.02, -- 2% Luck Boost per 100 Cozy Rating

	-- Rebirth / Fusion Multipliers
	REBIRTH_BASE_COST_COINS = 5000,
	REBIRTH_COST_MULTIPLIER = 2.2,
	REBIRTH_TOKEN_REWARD_BASE = 1,

	MAX_BASE_EQUIP_SLOTS = 4,
	MAX_BASE_INVENTORY_SLOTS = 75,

	-- Monetization Constants
	-- Source of Truth: Creator Dashboard confirmed 2026-07-28
	GAME_PASSES = {
		VIP_PASS = 1923436403, -- VIP Sanctum Overlord (299 R$)
		SUPER_LUCK = 1924362417, -- Super Alchemical Luck (199 R$)
		PLUS_50_INVENTORY_SLOTS = 1924818406, -- +50 Inventory Slots (99 R$)
		AUTO_HATCH = 1925292405, -- Quantum Auto-Hatch (149 R$)
		CYBER_NEON_TRAIL = 1923484423, -- Cyber-Neon Trail (Free)
		-- Fairytale Realm (Phase 3 — create via Creator Dashboard)
		FAIRYTALE_REALM_PASS = 0, -- Fairytale Realm Pass (299 R$) — set after creation
		CELESTIAL_WINGS_BUNDLE = 0, -- Celestial Wings Bundle (499 R$) — set after creation
		COVEN_GUILDMASTER = 0, -- Coven Guildmaster License (999 R$) — set after creation
	},

	DEV_PRODUCTS = {
		-- Confirmed active (Creator Dashboard 2026-07-28):
		GEMS_LARGE_PACK = 3611126995, -- +1,000 Gems (199 R$)
		COINS_LARGE_PACK = 3611126895, -- +50,000 Coins (99 R$)
		GEMS_SMALL_PACK = 3611126819, -- +100 Gems (49 R$)
		COINS_SMALL_PACK = 3611126655, -- +5,000 Coins (25 R$)
		-- Pending verification (create via Dashboard if 404):
		AURA_BOOST_MEDIUM = 3612013293, -- +2,500 Aura Energy (79 R$)
		CHRONO_SPARKS_PACK = 3612013298, -- +100 Chrono Sparks (149 R$)
		INSTANT_EGG_HATCH = 3612013299, -- Instant Egg Hatch (15 R$)
		REBIRTH_SKIP_TOKEN = 3612013301, -- +1 Rebirth Token (299 R$)
		-- Fairytale Realm (Phase 3)
		FAIRY_DUST_PACK = 0, -- Fairy Dust Bundle (99 R$) — set after creation
		ENCHANTED_ELIXIR = 0, -- Enchanted Elixir (79 R$) — set after creation
	},

	SUBSCRIPTION = {
		MONTHLY_ALCHEMIST_ID = 0, -- Monthly Alchemist ($4.99/mo — create via Creator Dashboard)
		MONTHLY_PRICE_USD = 4.99,
		MONTHLY_GEMS_PER_DAY = 500,
		MONTHLY_EXP_BOOST = 0.2,
		MONTHLY_EXCLUSIVE_PET = "SP_FAIRY_FOX",
	},
}

return table.freeze(EconomyConfig)
