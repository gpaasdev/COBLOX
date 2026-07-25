--!strict
-- COBLOX SYSTEM 06: ENGINEERING (TYPES)

export type MachineProperties = {
	PowerConsumption: number, -- Energy per second
	HeatGeneration: number,   -- Heat per second
	MaxHeat: number,          -- Overheat threshold
	Efficiency: number,       -- 0.0 to 1.0 multiplier
	Durability: number,       -- Current HP
	MaxDurability: number,    
}

export type MachineState = {
	Id: string,
	Type: string,
	IsActive: boolean,
	CurrentHeat: number,
	CurrentPower: number,
	Properties: MachineProperties,
	Inventory: { [string]: number }, -- MaterialId -> Amount
	Waste: { [string]: number },     -- MaterialId -> Amount
	Condition: string,               -- "Optimal", "Overheated", "Broken", "Clogged"
}

return {}
