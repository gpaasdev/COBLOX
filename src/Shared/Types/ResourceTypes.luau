--!strict

export type ResourceNodeType = "Herb" | "Ore" | "Crystal" | "Boss"
export type ToolTypeRequirement = "None" | "Pickaxe" | "Sickle"

export type LootEntry = {
	ItemId: string,
	Chance: number, -- 0 to 100
	MinQuantity: number,
	MaxQuantity: number,
}

export type ResourceNodeDef = {
	Id: string,
	Name: string,
	Type: ResourceNodeType,
	MaxHealth: number,
	RespawnTime: number, -- in seconds
	RequiredToolType: ToolTypeRequirement,
	RequiredToolTier: number,
	LootTable: { LootEntry },
	HitSFX: string?,
	DestroyVFX: string?,
}

export type ActiveNodeState = {
	NodeId: string,
	CurrentHealth: number,
	IsDepleted: boolean,
	Position: Vector3,
}

export type HarvestRequestPayload = {
	NodeInstanceId: string,
	HitPosition: Vector3,
}

export type HarvestResponsePayload = {
	Success: boolean,
	ErrorCode: string?,
	NodeInstanceId: string,
	ItemsObtained: { [string]: number }?,
}

return {}
