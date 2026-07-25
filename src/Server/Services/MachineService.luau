--!strict
-- COBLOX SYSTEM 06: ENGINEERING
-- Purpose: Standardized architecture for all machines. Runs simulations based on Physics and Reactions.

local MachineService = {}
local MachineTypes = require(game:GetService("ReplicatedStorage").Shared.Types.MachineTypes)
local ReactionEngine = require(script.Parent.ReactionEngine)
local MacroEconomyService = require(script.Parent.MacroEconomyService)

local ActiveMachines: { [string]: MachineTypes.MachineState } = {}

function MachineService.RegisterMachine(id: string, machineType: string, props: MachineTypes.MachineProperties)
	ActiveMachines[id] = {
		Id = id,
		Type = machineType,
		IsActive = false,
		CurrentHeat = 293, -- Room temp in Kelvin
		CurrentPower = 0,
		Properties = props,
		Inventory = {},
		Waste = {},
		Condition = "Optimal",
	}
	return ActiveMachines[id]
end

function MachineService.Tick(deltaTime: number)
	for id, machine in pairs(ActiveMachines) do
		if not machine.IsActive then continue end

		-- Rule: No Power -> Shutdown
		if machine.CurrentPower < machine.Properties.PowerConsumption * deltaTime then
			machine.IsActive = false
			machine.Condition = "NoPower"
			continue
		end

		-- Consume Power
		machine.CurrentPower -= machine.Properties.PowerConsumption * deltaTime

		-- Generate Heat
		machine.CurrentHeat += machine.Properties.HeatGeneration * deltaTime

		-- Check Failure States
		if machine.CurrentHeat > machine.Properties.MaxHeat then
			machine.Condition = "Overheated"
			machine.IsActive = false
			-- Trigger explosion or damage logic here (SYSTEM 03 Physics hook)
			machine.Properties.Durability -= 10 * deltaTime
			if machine.Properties.Durability <= 0 then
				machine.Condition = "Broken"
			end
			continue
		end
		
		-- Clogged condition (Waste buffer full)
		local wasteAmount = 0
		for _, w in pairs(machine.Waste) do wasteAmount += w end
		if wasteAmount > 100 then
			machine.Condition = "Clogged"
			machine.IsActive = false
			continue
		end
		
		-- Execute Reaction if machine has inventory materials
		if machine.Type == "Reactor" or machine.Type == "Smelter" or machine.Type == "Furnace" then
			local rxnInput = {
				Materials = machine.Inventory,
				Catalyst = nil,
				Temperature = machine.CurrentHeat,
				Pressure = 1.0,
				Purity = 0.95,
				Energy = machine.CurrentPower,
				ReactionTime = deltaTime,
				Initiator = nil,
			}

			local output = ReactionEngine.SimulateReaction(rxnInput)
			if output.Success then
				for product, amount in pairs(output.Products) do
					-- Add to global supply in macro economy
					MacroEconomyService.RecordTrade(product, amount, false)
				end
				for wasteItem, wasteQty in pairs(output.Waste) do
					machine.Waste[wasteItem] = (machine.Waste[wasteItem] or 0) + wasteQty
				end
			end
		end
	end
end

-- Hook this to RunService.Heartbeat in a central server script
return MachineService
