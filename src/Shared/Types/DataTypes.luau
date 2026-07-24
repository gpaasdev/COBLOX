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
	Pets: { [string]: any },
	Spirits: { [string]: any },
	Items: { [string]: number },
	EquippedUUIDs: { string },
	MaxEquipSlots: number,
	MaxInventorySlots: number,
}

export type SanctumProfile = {
	UnlockedGridSize: number,
	PlacedStructures: { [string]: any },
	CozyRating: number,
	VaultData: { DepositedAmount: number, LastDepositTimestamp: number },
}

export type FTUEData = {
	Completed: boolean,
	Step: number, -- 0: Spawn Crystal, 1: Pod Hatch, 2: First Craft, 3: Full Access
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
}

export type PlayerProfileV2 = PlayerProfile

return {}
