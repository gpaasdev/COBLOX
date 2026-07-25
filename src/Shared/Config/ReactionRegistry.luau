--!strict
-- COBLOX DATA-DRIVEN CONTENT REGISTRY: REACTIONS
-- Defines all chemical and alchemical reactions independently of the ReactionEngine.

local ReactionTypes = require(script.Parent.Parent.Types.ReactionTypes)

export type ReactionDefinition = {
	Id: string,
	Name: string,
	RequiredMaterials: { [string]: number }, -- MaterialId -> Amount (Mass)
	Catalyst: string?,
	MinTemperature: number, -- Kelvin
	MaxTemperature: number,
	MinPressure: number,    -- Atmospheres (atm)
	Product: string,         -- MaterialId
	YieldRatio: number,
	EnergyRequired: number,
	EntropyGenerated: number,
	DiscoveryRequirement: string?,
}

local ReactionRegistry: { [string]: ReactionDefinition } = {}

function ReactionRegistry.RegisterReaction(def: ReactionDefinition)
	if ReactionRegistry[def.Id] then
		warn(string.format("⚠️ [ReactionRegistry] Duplicate reaction registration for '%s'. Overwriting.", def.Id))
	end
	ReactionRegistry[def.Id] = def
end

function ReactionRegistry.GetReaction(id: string): ReactionDefinition?
	return ReactionRegistry[id]
end

function ReactionRegistry.GetAllReactions(): { [string]: ReactionDefinition }
	return ReactionRegistry
end

local GeneratedReactionRegistry = require(script.Parent.GeneratedReactionRegistry)

-- Default Data-Driven Reactions (Now loaded from generated pipeline)
for id, def in pairs(GeneratedReactionRegistry.GetAll()) do
	ReactionRegistry.RegisterReaction(def)
end

return ReactionRegistry
