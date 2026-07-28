--!strict

export type ErrorCategory = "Recoverable" | "Retryable" | "Fatal" | "Security" | "Validation" | "Infrastructure"

export type ServiceResult<T> = {
	Success: boolean,
	Category: ErrorCategory?,
	ErrorCode: string?,
	Message: string?,
	Data: T?,
	Retryable: boolean,
}

export type WalletData = {
	Coins: number,
	Gems: number,
	RebirthTokens: number,
	AuraEnergy: number,
	ChronoSparks: number,
	QuantumBadges: number,
}

export type InventoryData = {
	PityCounter: number, -- Gacha pity counter
	Pets: { [string]: any },
	Spirits: { [string]: any },
	Items: { [string]: number },
	LootDrops: { [string]: number }, -- New loot drops field for mobs
	EquippedUUIDs: { string },
	MaxEquipSlots: number,
	MaxInventorySlots: number,
	MaxPetStorage: number, -- Max pet storage cap
}

export type SanctumProfile = {
	UnlockedGridSize: number,
	PlacedStructures: { [string]: any },
	CozyRating: number,
	VaultData: { DepositedAmount: number, LastDepositTimestamp: number },
}

export type FTUEState =
	"WELCOME"
	| "HARVEST"
	| "CRAFT"
	| "COMBAT"
	| "HATCH"
	| "BIOME"
	| "QUEST"
	| "SANCTUM"
	| "RESEARCH"
	| "COVEN"
	| "COMPLETE"

export type FTUEData = {
	Completed: boolean,
	State: FTUEState,
	Step: number,
	FirstCraftTimestamp: number,
}

export type QuestProgress = {
	LastReset: number, -- Midnight UTC timestamp: os.time() - (os.time() % 86400)
	Streak: number,
	Completed: { [string]: boolean },
	Progress: { [string]: number },
	ActiveQuests: { string },
}

export type MonetizationProfile = {
	SeasonXP: number,
	SeasonTier: number,
	PremiumUnlocked: boolean,
	ClaimedTiers: { [number]: boolean },
}

export type LedgerEntry = {
	TimestampUTC: string,
	TransactionId: string,
	AmountChange: number,
	FinalBalance: number,
	Reason: string,
}

export type PlayerProfile = {
	SchemaVersion: number,
	Wallet: WalletData,
	Inventory: InventoryData,
	Sanctum: SanctumProfile,
	FTUE: FTUEData,
	DailyQuests: QuestProgress,
	Monetization: MonetizationProfile,
	Settings: {
		AudioVolume: number,
		TradeRequestsEnabled: boolean,
	},
	Analytics: {
		FirstJoin: number,
		TotalPlayTimeSeconds: number,
	},
	Ledger: { LedgerEntry }?, -- rolling 100 entries max
	AdminFlagged: boolean?, -- security flag for suspicious accounts
	CombatStats: {
		TotalMobsKilled: number,
		TotalDamageDealt: number,
	}?,
}

export type PlayerProfileV2 = PlayerProfile

return {}
