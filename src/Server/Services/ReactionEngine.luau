--!strict
-- COBLOX SYSTEM 04: CHEMICAL REACTION ENGINE
-- Purpose: Executes dynamic chemical/alchemical reactions based on ReactionRegistry data.
-- Dependencies: ReactionRegistry, PhysicsEngine, MaterialRegistry, DiscoveryService

local ReactionEngine = {}
local ReactionRegistry = require(game:GetService("ReplicatedStorage").Shared.Config.ReactionRegistry)
local MaterialRegistry = require(game:GetService("ReplicatedStorage").Shared.Config.MaterialRegistry)
local ReactionTypes = require(game:GetService("ReplicatedStorage").Shared.Types.ReactionTypes)
local MathUtil = require(game:GetService("ReplicatedStorage").Shared.Utility.MathUtil)
local DiscoveryService = require(script.Parent.DiscoveryService)

function ReactionEngine.SimulateReaction(input: ReactionTypes.ReactionInput): ReactionTypes.ReactionOutput
	local output: ReactionTypes.ReactionOutput = {
		Success = false,
		Products = {},
		Waste = {},
		GasEmitted = 0,
		HeatGenerated = 0,
		Entropy = 0,
	}

	-- Rule: Low purity -> lower quality output or failure
	if input.Purity < 0.2 then
		output.FailureReason = "Purity too low, reaction collapsed into slag."
		output.Waste["Slag"] = 10
		output.Entropy = 50
		return output
	end

	-- Rule: High temperature without proper pressure -> Explosion (Entropy)
	if input.Temperature > 3000 and input.Pressure < 5 then
		output.FailureReason = "Temperature exceeded structural limits at current pressure. Explosion imminent."
		output.Entropy = MathUtil.DifficultyCurve(input.Temperature / 1000, 2) * 100
		output.HeatGenerated = input.Temperature * 1.5
		output.GasEmitted = 500
		return output
	end

	-- Query Data-Driven ReactionRegistry dynamically
	local matchedReaction = nil
	for _, reactionDef in pairs(ReactionRegistry.GetAllReactions()) do
		local hasMaterials = true
		for matId, reqAmount in pairs(reactionDef.RequiredMaterials) do
			if (input.Materials[matId] or 0) < reqAmount then
				hasMaterials = false
				break
			end
		end

		if hasMaterials then
			if input.Temperature >= reactionDef.MinTemperature and input.Temperature <= reactionDef.MaxTemperature and input.Pressure >= reactionDef.MinPressure then
				matchedReaction = reactionDef
				break
			end
		end
	end

	if matchedReaction then
		output.Success = true
		output.Products[matchedReaction.Product] = matchedReaction.YieldRatio
		
		-- GAMEPLAY INTEGRATION: Trigger Discovery Loop
		if input.Initiator then
			pcall(function()
				DiscoveryService.RecordDiscovery(input.Initiator, "Material", matchedReaction.Product)
			end)
		end
		
		-- Conservation of Mass (Equivalent Exchange)
		local inputMass = 0
		for mat, amt in pairs(input.Materials) do
			inputMass += amt
		end
		
		if inputMass > matchedReaction.YieldRatio then
			output.Waste["Slag"] = inputMass - matchedReaction.YieldRatio
		end

		output.HeatGenerated = (input.Temperature * 0.1) + (input.Energy * 0.05)
		output.Entropy = matchedReaction.EntropyGenerated * input.Temperature
	else
		output.FailureReason = "Reaction stabilized into unknown compound."
		output.Success = true
		output.Products["UnknownCompound"] = 1
		output.Entropy = 20
		output.HeatGenerated = input.Temperature * 0.05
	end

	return output
end

return ReactionEngine
