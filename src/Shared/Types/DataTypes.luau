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

export type GridCell = {
	X: number,
	Z: number,
	StructureId: string,
	Level: number,
}

export type SanctumGridData = {
	Cells: { [string]: GridCell },
	PlotBounds: {
		MinX: number,
		MaxX: number,
		MinZ: number,
		MaxZ: number,
	},
}

export type CovenMembershipData = {
	CovenId: string?,
	Role: "Founder" | "Officer" | "Member"?,
	TotalDonated: number,
}

export type TransportState = "IDLE" | "TRANSPORTING" | "DEPOSITING"

export type HatchCooldownData = {
	LastHatchTimestamp: number,
	CooldownSeconds: number,
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
	SanctumGrid: SanctumGridData?,
	CovenMembership: CovenMembershipData?,
	HatchCooldown: HatchCooldownData?,
	TransportState: TransportState?,
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
	Ledger: { LedgerEntry }?,
	AdminFlagged: boolean?,
	CombatStats: {
		TotalMobsKilled: number,
		TotalDamageDealt: number,
	}?,
	Avatar: AvatarConfigData?,
}

export type AvatarConfigData = {
	SkinTone: Color3?,
	HeadMeshId: string?,
	ClothingAssetIds: { string },
	PBRSkinTextureId: string?,
	EnableProceduralIK: boolean,
}

export type PlayerProfileV2 = PlayerProfile

return {}
