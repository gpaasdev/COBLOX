--!strict
-- COBLOX SYSTEM 03: PHYSICS SIMULATION
-- Purpose: Simulates physical rules for machines and environments.
-- Rules: Heat increases pressure. Pressure powers turbines. Electricity powers machines. Cooling removes heat.

local PhysicsEngine = {}
local PhysicsTypes = require(game:GetService("ReplicatedStorage").Shared.Types.PhysicsTypes)

-- Gas constant for ideal gas law P * V = n * R * T -> P ~ T / V
local GAS_CONSTANT = 8.314

-- Simulates an enclosed volume (like a reactor or pipe)
function PhysicsEngine.UpdateEnclosure(state: PhysicsTypes.PhysicsState, volume: number, deltaTime: number)
	-- Heat increases pressure (Ideal Gas Law approximation if mass is constant)
	-- P = (Mass * R * Heat) / Volume
	if volume > 0 then
		state.Pressure = (state.Mass * GAS_CONSTANT * state.Heat) / volume
	end
	
	-- Cooling (Radiative heat loss to environment assuming 293K room temp)
	if state.Heat > 293 then
		local heatLoss = (state.Heat - 293) * 0.05 * deltaTime
		state.Heat -= heatLoss
	end
end

-- Simulates a turbine generating electricity from pressure
function PhysicsEngine.UpdateTurbine(state: PhysicsTypes.PhysicsState, efficiency: number, deltaTime: number)
	-- Pressure generates power
	if state.Pressure > 1 then
		local generatedPower = (state.Pressure - 1) * efficiency * 100 * deltaTime
		state.Electricity += generatedPower
		
		-- Turbine extracts energy, reducing pressure and heat slightly
		state.Pressure *= 0.95
		state.Heat *= 0.98
	end
end

-- Simulates active cooling system
function PhysicsEngine.ApplyCooling(state: PhysicsTypes.PhysicsState, coolingPower: number, deltaTime: number)
	if state.Heat > 293 then
		state.Heat -= coolingPower * deltaTime
		if state.Heat < 293 then
			state.Heat = 293
		end
	end
end

-- Simulates Thermal Conduction between two adjacent enclosures (Emergent Simulation)
function PhysicsEngine.TransferHeat(stateA: PhysicsTypes.PhysicsState, stateB: PhysicsTypes.PhysicsState, thermalConductivity: number, deltaTime: number)
	local tempDiff = stateA.Heat - stateB.Heat
	if math.abs(tempDiff) > 0.1 then
		local heatFlow = tempDiff * thermalConductivity * 0.1 * deltaTime
		stateA.Heat -= heatFlow
		stateB.Heat += heatFlow
	end
end

return PhysicsEngine
