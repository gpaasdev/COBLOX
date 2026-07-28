--!strict
-- COBLOX SYSTEM 06: ENGINEERING
-- Purpose: Standardized architecture for all machines. Runs simulations based on Physics and Reactions.
-- RC-2: Added BoundedTick scheduler (max 10 machines/frame), Init/Start lifecycle, ServiceStatus metadata.

local RunService = game:GetService("RunService")

local MachineService = {}
MachineService.Name = "MachineService"
MachineService.ServiceStatus = "Experimental" -- BoundedTick added; validate in Studio before enabling

local MachineTypes = require(game:GetService("ReplicatedStorage").Shared.Types.MachineTypes)
local ReactionEngine = require(script.Parent.ReactionEngine)
local MacroEconomyService = require(script.Parent.MacroEconomyService)

local ActiveMachines: { [string]: MachineTypes.MachineState } = {}

-- Bounded scheduler state
local _machineIds: { string } = {}
local _cursor = 1
local MAX_MACHINES_PER_FRAME = 10 -- tune: balance between simulation fidelity and frame budget

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
	MachineService._RebuildIndex() -- keep index current
	return ActiveMachines[id]
end

-- Rebuild round-robin index (call when machines are added/removed)
function MachineService._RebuildIndex()
	_machineIds = {}
	for id in pairs(ActiveMachines) do
		table.insert(_machineIds, id)
	end
	_cursor = 1
end

-- Tick logic for a single machine (extracted for clarity)
function MachineService._TickSingle(machine: MachineTypes.MachineState, deltaTime: number)
	-- Rule: No Power -> Shutdown
	if machine.CurrentPower < machine.Properties.PowerConsumption * deltaTime then
		machine.IsActive = false
		machine.Condition = "NoPower"
		return
	end

	-- Consume Power
	machine.CurrentPower -= machine.Properties.PowerConsumption * deltaTime

	-- Generate Heat
	machine.CurrentHeat += machine.Properties.HeatGeneration * deltaTime

	-- Check Failure States
	if machine.CurrentHeat > machine.Properties.MaxHeat then
		machine.Condition = "Overheated"
		machine.IsActive = false
		machine.Properties.Durability -= 10 * deltaTime
		if machine.Properties.Durability <= 0 then
			machine.Condition = "Broken"
		end
		return
	end

	-- Clogged condition (Waste buffer full)
	local wasteAmount = 0
	for _, w in pairs(machine.Waste) do
		wasteAmount += w
	end
	if wasteAmount > 100 then
		machine.Condition = "Clogged"
		machine.IsActive = false
		return
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
				MacroEconomyService.RecordTrade(product, amount, false)
			end
			for wasteItem, wasteQty in pairs(output.Waste) do
				machine.Waste[wasteItem] = (machine.Waste[wasteItem] or 0) + wasteQty
			end
		end
	end
end

-- BoundedTick: process at most MAX_MACHINES_PER_FRAME machines per Heartbeat (O(1) per frame)
-- Full rotation completes every ceil(N/MAX) frames (~0.16s at 10/frame, 60fps, 100 machines)
function MachineService.BoundedTick(deltaTime: number)
	local total = #_machineIds
	if total == 0 then
		return
	end

	local processed = 0
	local startCursor = _cursor
	while processed < MAX_MACHINES_PER_FRAME do
		local id = _machineIds[_cursor]
		if id then
			local machine = ActiveMachines[id]
			if machine and machine.IsActive then
				MachineService._TickSingle(machine, deltaTime)
			end
		end
		_cursor = (_cursor % total) + 1
		processed += 1
		if _cursor == startCursor then
			break
		end
	end
end

function MachineService.Init()
	print(
		"[MachineService] Initializing Bounded Machine Simulation Scheduler (max "
			.. MAX_MACHINES_PER_FRAME
			.. " machines/frame)..."
	)
	MachineService._RebuildIndex()
	RunService.Heartbeat:Connect(MachineService.BoundedTick)
end

function MachineService.Start()
	-- Machine registration happens externally via WorldAssemblyService
end

return MachineService
