--!strict

export type RarityTier = "Common" | "Uncommon" | "Rare" | "Epic" | "Legendary" | "Mythic" | "Secret"

export type PetConfig = {
	Id: string,
	Name: string,
	Rarity: RarityTier,
	BaseMultiplier: number,
	ModelAssetId: number,
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
