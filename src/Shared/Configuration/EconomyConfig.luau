--!strict

	local EconomyConfig = {
	BASE_STARTER_AURA = 250,
	BASE_STARTER_SPARKS = 25,
	BASE_STARTER_COINS = 250,
	BASE_STARTER_GEMS = 25,

	VAULT_DAILY_INTEREST_RATE = 0.05,
	COZY_RATING_LUCK_BOOST = 0.02,

	REBIRTH_BASE_COST_COINS = 5000,
	REBIRTH_COST_MULTIPLIER = 2.2,
	REBIRTH_TOKEN_REWARD_BASE = 1,

	MAX_BASE_EQUIP_SLOTS = 4,
	MAX_BASE_INVENTORY_SLOTS = 75,

	-- Creator Dashboard confirmed IDs
	GAME_PASSES = {
		VIP_PASS = 1923436403,
		SUPER_LUCK = 1924362417,
		PLUS_50_INVENTORY_SLOTS = 1924818406,
		AUTO_HATCH = 1925292405,
		CYBER_NEON_TRAIL = 1923484423,
		-- Pending Dashboard creation — design ready:
		FAIRYTALE_REALM_PASS = 0, -- Akses ke Fairytale Realm + 6 bioma + 25 asset eksklusif (299 R$)
		CELESTIAL_WINGS_BUNDLE = 0, -- Celestial Wings + Aura Trail + Name Tag eksklusif (499 R$)
		COVEN_GUILDMASTER = 0, -- Buat Coven, akses hideout + treasury voting + raid co-op (999 R$)
	},

	DEV_PRODUCTS = {
		GEMS_LARGE_PACK = 3611126995,
		COINS_LARGE_PACK = 3611126895,
		GEMS_SMALL_PACK = 3611126819,
		COINS_SMALL_PACK = 3611126655,
		AURA_BOOST_MEDIUM = 3612013293,
		CHRONO_SPARKS_PACK = 3612013298,
		INSTANT_EGG_HATCH = 3612013299,
		REBIRTH_SKIP_TOKEN = 3612013301,
		-- Pending Dashboard creation:
		FAIRY_DUST_PACK = 0, -- +500 Fairy Dust — material crafting Fairytale eksklusif (99 R$)
		ENCHANTED_ELIXIR = 0, -- +1 Enchanted Elixir — 30 menit 2x EXP + 50% luck (79 R$)
	},

	SUBSCRIPTION = {
		MONTHLY_ALCHEMIST_ID = 0, -- $4.99/bulan: 500 Gems/hari, 20% EXP boost, Spirit Fox eksklusif
		MONTHLY_PRICE_USD = 4.99,
		MONTHLY_GEMS_PER_DAY = 500,
		MONTHLY_EXP_BOOST = 0.2,
		MONTHLY_EXCLUSIVE_PET = "SP_FAIRY_FOX",
		MONTHLY_PERKS = {
			"500 Gems setiap login harian",
			"+20% EXP Boost",
			"Spirit Fox Companion eksklusif",
			"Golden Name Tag di chat",
			"Akses early ke event terbatas",
		},
	},
}

return table.freeze(EconomyConfig)
