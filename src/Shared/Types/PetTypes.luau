--!strict

export type RarityTier = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret" | "GodTier"

export type PetConfig = {
	Id: string,
	Name: string,
	Rarity: RarityTier,
	BaseMultiplier: number,
	ModelAssetId: number,
	Description: string?,
	IsVIPExclusive: boolean?,
}

export type PetInstance = {
	UUID: string,
	PetId: string,
	Level: number,
	XP: number,
	Equipped: boolean,
	AcquiredTimestamp: number,
}

return {}
