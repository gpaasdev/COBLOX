--!strict

export type TradeState =
	"Idle"
	| "Invited"
	| "Stage1_Confirming"
	| "Stage2_FinalAccept"
	| "Executing"
	| "Completed"
	| "Cancelled"

export type TradeOffer = {
	Coins: number,
	Gems: number,
	PetUUIDs: { string },
}

export type TradeSession = {
	SessionId: string,
	PlayerA: Player,
	PlayerB: Player,
	OfferA: TradeOffer,
	OfferB: TradeOffer,
	Stage1_A: boolean,
	Stage1_B: boolean,
	Stage2_A: boolean,
	Stage2_B: boolean,
	State: TradeState,
	CreatedTimestamp: number,
}

return {}
