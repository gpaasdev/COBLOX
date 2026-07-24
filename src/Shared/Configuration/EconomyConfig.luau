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
	GAME_PASSES = {
		SUPER_LUCK = 1924362417,
		VIP_PASS = 1923436403,
		PLUS_50_INVENTORY_SLOTS = 1924818406,
		AUTO_HATCH = 1925292405,
	},
	
	DEV_PRODUCTS = {
		GEMS_LARGE_PACK = 3611126995,
		COINS_LARGE_PACK = 3611126895,
		GEMS_SMALL_PACK = 3611126819,
		COINS_SMALL_PACK = 3611126655,
	},
}

return table.freeze(EconomyConfig)
