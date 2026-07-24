--!strict

local LiveOpsConfig = {
	-- Active Weekend Event Flags
	WEEKEND_DOUBLE_LUCK_ENABLED = true,
	WEEKEND_DOUBLE_COINS_ENABLED = true,
	
	-- Multipliers
	LUCK_EVENT_MULTIPLIER = 2.0,
	COIN_EVENT_MULTIPLIER = 2.0,
	
	-- Season Pass Configuration
	ACTIVE_SEASON_ID = "Season_01_MythicRise",
	SEASON_XP_PER_HATCH = 10,
	SEASON_XP_PER_REBIRTH = 250,
	
	-- Banner Announcement
	GLOBAL_ANNOUNCEMENT_TEXT = "⚡ 2X LUCK & 2X COINS WEEKEND EVENT IS LIVE!",
}

return table.freeze(LiveOpsConfig)
