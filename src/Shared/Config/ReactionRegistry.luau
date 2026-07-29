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
	MinPressure: number, -- Atmospheres (atm)
	Product: string, -- MaterialId
	YieldRatio: number,
	EnergyRequired: number,
	EntropyGenerated: number,
	DiscoveryRequirement: string?,
}

local ReactionRegistry: { [string]: ReactionDefinition } = {}
local ReactionRegistry_data: { [string]: ReactionDefinition } = {}

function ReactionRegistry.RegisterReaction(def: ReactionDefinition)
	if ReactionRegistry_data[def.Id] then
		warn(string.format("⚠️ [ReactionRegistry] Duplicate reaction registration for '%s'. Overwriting.", def.Id))
	end
	ReactionRegistry_data[def.Id] = def
end

function ReactionRegistry.GetReaction(id: string): ReactionDefinition?
	return ReactionRegistry_data[id]
end

function ReactionRegistry.GetAllReactions(): { [string]: ReactionDefinition }
	return ReactionRegistry_data
end

local GeneratedReactionRegistry = require(script.Parent.GeneratedReactionRegistry)

-- Default Data-Driven Reactions (Now loaded from generated pipeline)
for id, def in pairs(GeneratedReactionRegistry.GetAll()) do
	if type(def) == "table" and (def :: any).Id then
		ReactionRegistry.RegisterReaction(def :: ReactionDefinition)
	end
end

return ReactionRegistry
