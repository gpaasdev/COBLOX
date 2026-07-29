--!strict
-- COBLOX PHASE 1: HATCHING CONFIGURATION
-- Genesis Pod hatching system with pity mechanics

local HatchConfig = {}

-- Genesis Pod types and costs
HatchConfig.POD_TYPES = {
	Basic = {
		Id = "Basic",
		Name = "Basic Genesis Pod",
		Cost = 500,
		Currency = "Coins",
	},
	Advanced = {
		Id = "Advanced",
		Name = "Advanced Genesis Pod",
		Cost = 2000,
		Currency = "Coins",
	},
	Mystic = {
		Id = "Mystic",
		Name = "Mystic Genesis Pod",
		Cost = 50,
		Currency = "ChronoSparks",
	},
}

-- Rarity base rates
HatchConfig.BASE_RATES = {
	Common = 0.60,
	Uncommon = 0.25,
	Rare = 0.10,
	Legendary = 0.04,
	Mythic = 0.01,
}

-- Pity system
HatchConfig.PITY_THRESHOLD = 100
HatchConfig.PITY_GUARANTEE = "Legendary"

-- Luck modifiers
HatchConfig.LUCK_STAT_MULTIPLIER = 0.02 -- per luck upgrade level
HatchConfig.MAX_LUCK_UPGRADES = 10
HatchConfig.GAMEPASS_SUPER_LUCK_BOOST = 0.25
HatchConfig.MAX_EFFECTIVE_RATE = 0.95

-- Cooldowns
HatchConfig.HATCH_COOLDOWN = 3 -- seconds between hatches
HatchConfig.ANIMATION_DURATION = 2.5 -- seconds for hatch animation

-- Inventory check
HatchConfig.REQUIRES_EMPTY_SLOT = true

-- Utility functions
function HatchConfig.GetEffectiveRate(
	baseRate: number,
	luckUpgrades: number,
	hasSuperLuck: boolean,
	covenBuff: number,
	liveOpsBuff: number
): number
	local luckStat = luckUpgrades * HatchConfig.LUCK_STAT_MULTIPLIER
	local gamePassBoost = hasSuperLuck and HatchConfig.GAMEPASS_SUPER_LUCK_BOOST or 0
	local effective = baseRate * (1 + luckStat + gamePassBoost + covenBuff + liveOpsBuff)
	return math.min(effective, HatchConfig.MAX_EFFECTIVE_RATE)
end

return HatchConfig
