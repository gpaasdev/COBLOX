--!strict
-- COBLOX DATA-DRIVEN CONTENT REGISTRY: MACHINES
-- Modular registry for all industrial reactors, turbines, coolers, and conveyor automation.

local MachineTypes = require(script.Parent.Parent.Types.MachineTypes)

export type MachineDefinition = {
	Id: string,
	Name: string,
	Category: string, -- "Reactor", "Turbine", "Cooler", "Automator", "Storage"
	BaseCost: number,
	DefaultProperties: MachineTypes.MachineProperties,
}

local MachineRegistry_data: { [string]: MachineDefinition } = {}
local MachineRegistry = {}

function MachineRegistry.RegisterMachine(def: MachineDefinition)
	if MachineRegistry_data[def.Id] then
		warn(string.format("⚠️ [MachineRegistry] Duplicate machine registration for '%s'. Overwriting.", def.Id))
	end
	MachineRegistry_data[def.Id] = def
end

function MachineRegistry.GetMachine(id: string): MachineDefinition?
	return MachineRegistry_data[id]
end

function MachineRegistry.GetAllMachines(): { [string]: MachineDefinition }
	return MachineRegistry_data
end

-- Default Data-Driven Machine Content
MachineRegistry.RegisterMachine({
	Id = "FusionReactor_v1",
	Name = "Fusion Reactor v1",
	Category = "Reactor",
	BaseCost = 5000,
	DefaultProperties = {
		PowerConsumption = 50,
		HeatGeneration = 12,
		MaxHeat = 3200,
		Efficiency = 0.85,
		Durability = 100,
		MaxDurability = 100,
	},
})

MachineRegistry.RegisterMachine({
	Id = "CryoCooler_v1",
	Name = "Cryo Cooler v1",
	Category = "Cooler",
	BaseCost = 2500,
	DefaultProperties = {
		PowerConsumption = 30,
		HeatGeneration = -25,
		MaxHeat = 1500,
		Efficiency = 0.95,
		Durability = 80,
		MaxDurability = 80,
	},
})

MachineRegistry.RegisterMachine({
	Id = "SteamTurbine_v1",
	Name = "Steam Turbine v1",
	Category = "Turbine",
	BaseCost = 4000,
	DefaultProperties = {
		PowerConsumption = 0, -- Generates power
		HeatGeneration = 5,
		MaxHeat = 2000,
		Efficiency = 0.90,
		Durability = 120,
		MaxDurability = 120,
	},
})

return MachineRegistry
