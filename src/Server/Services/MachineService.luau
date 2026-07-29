--!strict
-- COBLOX SYSTEM 06: ENGINEERING
-- Purpose: Standardized architecture for all machines. Runs simulations based on Physics and Reactions.
-- RC-2: Added BoundedTick scheduler (max 10 machines/frame), Init/Start lifecycle, ServiceStatus metadata.

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MachineService = {}
MachineService.Name = "MachineService"
MachineService.ServiceStatus = "Production"

local MachineTypes = require(ReplicatedStorage.Shared.Types.MachineTypes)
local MachineConfig = require(ReplicatedStorage.Shared.Configuration.MachineConfig)
local ReactionEngine = require(script.Parent.ReactionEngine)
local MacroEconomyService = require(script.Parent.MacroEconomyService)

local ActiveMachines: { [string]: MachineTypes.MachineState } = {}

-- Bounded scheduler state
local _machineIds: { string } = {}
local _cursor = 1
local MAX_MACHINES_PER_FRAME = 10 -- tune: balance between simulation fidelity and frame budget

function MachineService.RegisterMachine(
	id: string,
	machineType: string,
	props: MachineTypes.MachineProperties,
	player: Player?
): MachineTypes.MachineState?
	local cost = MachineConfig.Costs[machineType]
	if cost and player then
		local EconomyService = require(script.Parent.EconomyService)
		if not EconomyService.HasCurrency(player, "Coins", cost.Coins) then
			return nil
		end
		if not EconomyService.HasCurrency(player, "Gems", cost.Gems) then
			return nil
		end
		EconomyService.DeductCurrency(player, "Coins", cost.Coins, "MachinePurchase")
		EconomyService.DeductCurrency(player, "Gems", cost.Gems, "MachinePurchase")
	end

	local machineDef = MachineConfig.Types[machineType]
	local startPower = if machineDef then MachineConfig.Defaults.StartPower else 0

	ActiveMachines[id] = {
		Id = id,
		Type = machineType,
		IsActive = false,
		CurrentHeat = 293,
		CurrentPower = startPower,
		Properties = props,
		Inventory = {},
		Waste = {},
		Condition = "Optimal",
	}
	MachineService._RebuildIndex()
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
	local machineDef = MachineConfig.Types[machine.Type]
	local powerConsumption = if machineDef then machineDef.PowerConsumption else machine.Properties.PowerConsumption
	local heatGeneration = if machineDef then machineDef.HeatGeneration else machine.Properties.HeatGeneration
	local maxHeat = if machineDef then machineDef.MaxHeat else machine.Properties.MaxHeat

	-- Fuel consumption: burn AuraEnergy from inventory to regenerate power
	local auraFuel = machine.Inventory["AuraEnergy"] or 0
	if auraFuel > 0 and machine.CurrentPower < MachineConfig.Defaults.MaxPower * 0.5 then
		local burnRate = 0.5 * deltaTime
		local fuelBurned = math.min(auraFuel, burnRate)
		machine.Inventory["AuraEnergy"] = auraFuel - fuelBurned
		machine.CurrentPower = math.min(
			machine.CurrentPower + fuelBurned * 10,
			MachineConfig.Defaults.MaxPower
		)
	end

	-- Rule: No Power -> Shutdown
	if machine.CurrentPower < powerConsumption * deltaTime then
		machine.IsActive = false
		machine.Condition = "NoPower"
		return
	end

	-- Consume Power
	machine.CurrentPower -= powerConsumption * deltaTime

	-- Generate Heat
	machine.CurrentHeat += heatGeneration * deltaTime

	-- Check Failure States
	if machine.CurrentHeat > maxHeat then
		machine.Condition = "Overheated"
		machine.IsActive = false
		machine.Properties.Durability -= 10 * deltaTime
		if machine.Properties.Durability <= 0 then
			machine.Condition = "Broken"
		end
		return
	end

	-- Passive waste decay
	for wasteItem, wasteQty in pairs(machine.Waste) do
		machine.Waste[wasteItem] = math.max(0, wasteQty - MachineConfig.Defaults.PassiveWasteDecay * deltaTime)
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

	-- Passive power regeneration when idle
	if not machine.IsActive and machine.CurrentPower < MachineConfig.Defaults.MaxPower then
		machine.CurrentPower = math.min(
			machine.CurrentPower + MachineConfig.Defaults.PowerRegenRate * deltaTime,
			MachineConfig.Defaults.MaxPower
		)
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
