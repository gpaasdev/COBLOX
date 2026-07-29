--!strict
-- COBLOX PHASE 1: COVEN CONFIGURATION
-- Alchemist Coven (Guild System) parameters

local CovenConfig = {}

-- Creation
CovenConfig.CREATION_COST = 10000 -- Coins
CovenConfig.MIN_NAME_LENGTH = 3
CovenConfig.MAX_NAME_LENGTH = 20
CovenConfig.MAX_MEMBERS = 20

-- Treasury & Leveling (GDD §4.4 — Logarithmic Formula)
-- Level = max(1, floor(5 × ln(Treasury / 5000)))
CovenConfig.TREASURY_BASE = 5000
CovenConfig.LEVEL_COEFFICIENT = 5

-- Global Multiplier Buff (GDD §4.4)
-- Buff = 1 + (0.15 × ln(Level + 1))
CovenConfig.BUFF_COEFFICIENT = 0.15

-- Donation limits
CovenConfig.MIN_DONATION = 100
CovenConfig.MAX_DONATION_PER_TRANSACTION = 500000
CovenConfig.DONATION_COOLDOWN = 5 -- seconds between donations

-- Roles
CovenConfig.ROLES = {
	Founder = { CanInvite = true, CanKick = true, CanDonate = true, CanManageTreasury = true },
	Officer = { CanInvite = true, CanKick = false, CanDonate = true, CanManageTreasury = false },
	Member = { CanInvite = false, CanKick = false, CanDonate = true, CanManageTreasury = false },
}

-- Utility functions
function CovenConfig.GetLevel(treasury: number): number
	local base = math.max(1, math.floor(5 * math.log(treasury / CovenConfig.TREASURY_BASE)))
	return base
end

function CovenConfig.GetMultiplierBuff(level: number): number
	return 1 + (CovenConfig.BUFF_COEFFICIENT * math.log(level + 1))
end

return CovenConfig
