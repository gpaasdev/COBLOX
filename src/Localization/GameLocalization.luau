--!strict

local LocalizationTable = {
	["en-us"] = {
		-- HUD & Currencies
		["HUD_AURA"] = "⚡ Energy: %d",
		["HUD_SPARKS"] = "✨ Gems: %d",
		["HUD_COINS"] = "Coins",
		["HUD_GEMS"] = "Gems",
		["INSUFFICIENT_COINS"] = "Not enough coins!",
		["LIVEOPS_BOOST_ACTIVE"] = "🎉 2X WEEKEND COINS & XP BOOST LIVE!",

		-- SideDrawer (ASEAN & Global Friendly)
		["SIDE_SANCTUM_GRID"] = "🏡 My Base",
		["SIDE_SYNTHESIS_VESSEL"] = "🧪 Crafting Lab",
		["SIDE_SPIRIT_HATCHERY"] = "💫 Summon Spirit",
		["SIDE_COVEN_ORDER"] = "🏰 Player Clan",
		["SIDE_CODEX"] = "📖 Recipe & Spirit Index",
		["SIDE_TRADING_HUB"] = "🤝 Trading Market",
		["SIDE_REBIRTH"] = "🌟 Awakening Aura",
		["SIDE_SHOP"] = "🛒 Shop & Pass",

		-- Action & Slang Hype Remotes
		["ACTION_SETOR_AURA"] = "🚚 Deposit Cargo Aura",
		["ACTION_BEGAL_AURA"] = "🥷 Aura Raid",
		["ACTION_KENA_KARMA"] = "🎯 Target Karma Revenge!",
		["ACTION_FLEX_SHRINE"] = "🔥 Flexing Shrine",
		["ACTION_OVERCLOCK"] = "⚡ Overclock Mode",

		-- Coven Modal
		["COVEN_TITLE_DEFAULT"] = "🏰 Player Clan: No Clan Joined",
		["COVEN_LEVEL"] = "Clan Level: %d",
		["COVEN_TREASURY"] = "Clan Vault: %d Coins",
		["COVEN_BUFF"] = "✨ Global Multiplier Buff: +%d%%",
		["COVEN_BTN_CREATE"] = "Create Clan (10k Coins)",
		["COVEN_BTN_DONATE"] = "Donate 1,000 Coins",

		-- Codex Modal
		["CODEX_TITLE"] = "📖 Recipe & Spirit Collection Index",
		["CODEX_SELECT_PROMPT"] = "Select an item or spirit companion to inspect stats...",
		["CODEX_LOCKED_MSG"] = "🔒 Locked! Craft potion or summon spirit to discover this entry.",

		-- Trade Modal
		["TRADE_TITLE"] = "🤝 Secure Trading Market",
		["TRADE_MY_OFFER"] = "My Trade Offer",
		["TRADE_PARTNER_OFFER"] = "Partner's Offer",
		["TRADE_READY_LOCK"] = "Ready to Lock",
		["TRADE_LOCK_BTN"] = "🔒 Lock Offer",
		["TRADE_LOCKED_BTN"] = "🔒 Locked",
		["TRADE_CONFIRM_BTN"] = "✅ Confirm Trade",
		["TRADE_CONFIRMING_IN"] = "Confirming in %d...",
		["TRADE_PRESS_CONFIRM"] = "Press Confirm Trade!",

		-- FTUE Quests
		["FTUE_CLAIM_PLOT"] = "📜 QUEST 1: Claim Your Base Plot",
		["FTUE_BUY_UPGRADE"] = "📜 QUEST 2: Craft Potion in Lab",
		["FTUE_HATCH_EGG"] = "📜 QUEST 3: Summon First Spirit Companion",
	},

	["id-id"] = {
		-- HUD & Currencies
		["HUD_AURA"] = "⚡ Energi: %d",
		["HUD_SPARKS"] = "✨ Gems: %d",
		["HUD_COINS"] = "Koin",
		["HUD_GEMS"] = "Gems",
		["INSUFFICIENT_COINS"] = "Koin tidak cukup!",
		["LIVEOPS_BOOST_ACTIVE"] = "🎉 EVENT 2X KOIN & XP PEKAN INI AKTIF!",

		-- SideDrawer (Opsi B: Modern Casual Anime)
		["SIDE_SANCTUM_GRID"] = "🏡 Markas Saya",
		["SIDE_SYNTHESIS_VESSEL"] = "🧪 Lab Racik",
		["SIDE_SPIRIT_HATCHERY"] = "💫 Panggil Spirit",
		["SIDE_COVEN_ORDER"] = "🏰 Klan Player",
		["SIDE_CODEX"] = "📖 Buku Resep & Spirit",
		["SIDE_TRADING_HUB"] = "🤝 Pasar Trading",
		["SIDE_REBIRTH"] = "🌟 Awakening Aura",
		["SIDE_SHOP"] = "🛒 Toko & Gamepass",

		-- Action & Slang Hype Remotes (Gen Z / Alpha Slang)
		["ACTION_SETOR_AURA"] = "🚚 Setor Aura",
		["ACTION_BEGAL_AURA"] = "🥷 Begal Aura",
		["ACTION_KENA_KARMA"] = "🎯 Kena Karma!",
		["ACTION_FLEX_SHRINE"] = "🔥 Flexing Shrine",
		["ACTION_OVERCLOCK"] = "⚡ Overclock Mode",

		-- Coven Modal
		["COVEN_TITLE_DEFAULT"] = "🏰 Klan Player: Belum Gabung Klan",
		["COVEN_LEVEL"] = "Level Klan: %d",
		["COVEN_TREASURY"] = "Kas Klan: %d Koin",
		["COVEN_BUFF"] = "✨ Buff Pengali Koin Klan: +%d%%",
		["COVEN_BTN_CREATE"] = "Buat Klan (10k Koin)",
		["COVEN_BTN_DONATE"] = "Donasi 1.000 Koin",

		-- Codex Modal
		["CODEX_TITLE"] = "📖 Buku Resep & Koleksi Spirit",
		["CODEX_SELECT_PROMPT"] = "Pilih item atau spirit di sebelah kiri untuk lihat statistik...",
		["CODEX_LOCKED_MSG"] = "🔒 Belum Ditemukan! Racik ramuan atau panggil spirit untuk membuka.",

		-- Trade Modal
		["TRADE_TITLE"] = "🤝 Pasar Trading Spirit & Item",
		["TRADE_MY_OFFER"] = "Penawaran Saya",
		["TRADE_PARTNER_OFFER"] = "Penawaran Teman",
		["TRADE_READY_LOCK"] = "Siap Dikunci",
		["TRADE_LOCK_BTN"] = "🔒 Kunci Penawaran",
		["TRADE_LOCKED_BTN"] = "🔒 Terkunci",
		["TRADE_CONFIRM_BTN"] = "✅ Konfirmasi Trade",
		["TRADE_CONFIRMING_IN"] = "Konfirmasi dalam %d...",
		["TRADE_PRESS_CONFIRM"] = "Tekan Konfirmasi Trade!",

		-- FTUE Quests
		["FTUE_CLAIM_PLOT"] = "📜 MISI 1: Klaim Lahan Markas",
		["FTUE_BUY_UPGRADE"] = "📜 MISI 2: Racik Ramuan di Lab",
		["FTUE_HATCH_EGG"] = "📜 MISI 3: Panggil Spirit Pertama",
	},
}

return table.freeze(LocalizationTable)
