--!strict
-- COBLOX SYSTEM 04: CHEMICAL REACTION ENGINE (TYPES)

local MaterialTypes = require(script.Parent.MaterialTypes)

export type ReactionInput = {
	Materials: { [string]: number }, -- MaterialId -> Amount (Mass)
	Catalyst: string?, -- MaterialId
	Temperature: number, -- Kelvin
	Pressure: number, -- Atmospheres (atm)
	Purity: number, -- 0.0 to 1.0
	Energy: number, -- Aether Energy input
	ReactionTime: number, -- Seconds
	Initiator: Player?, -- Player who initiated the reaction (for Discovery tracking)
}

export type ReactionOutput = {
	Success: boolean,
	Products: { [string]: number }, -- MaterialId -> Amount
	Waste: { [string]: number }, -- MaterialId -> Amount
	GasEmitted: number, -- Volume of gas
	HeatGenerated: number, -- Thermal energy released
	Entropy: number, -- Instability/Damage potential
	FailureReason: string?,
}

return {}
