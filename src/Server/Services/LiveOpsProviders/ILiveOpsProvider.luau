--!strict

export type LiveOpsModifiers = {
	CoinsMultiplier: number?,
	XPMultiplier: number?,
	AuraMultiplier: number?,
	HatchLuckMultiplier: number?,
}

export type ILiveOpsProvider = {
	Name: string,
	IsActive: (self: ILiveOpsProvider) -> boolean,
	GetPriority: (self: ILiveOpsProvider) -> number,
	GetModifiers: (self: ILiveOpsProvider) -> LiveOpsModifiers,
	GetRewards: (self: ILiveOpsProvider) -> { [string]: any },
	GetBanner: (self: ILiveOpsProvider) -> string?,
	GetNotifications: (self: ILiveOpsProvider) -> { string }?,
	GetTheme: (self: ILiveOpsProvider) -> string?,
}

return {}
