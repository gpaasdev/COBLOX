--!strict
-- COBLOX SYSTEM 12: POLITICAL SYSTEM
-- Purpose: Global server variables influenced by factions and events.

local PoliticalService = {}
local SocialSimulationService = require(script.Parent.SocialSimulationService)

local ServerState = {
	DominantFaction = "Preservationists",
	BaseTaxRate = 0.05,
	SecurityLevel = 100,
	ResearchFunding = 50,
	PollutionLevel = 0,
}

function PoliticalService.UpdatePolitics()
	local pres = SocialSimulationService.GetFactionData("Preservationists")
	local ind = SocialSimulationService.GetFactionData("Industrialists")
	local void = SocialSimulationService.GetFactionData("VoidWalkers")
	
	if not pres or not ind or not void then return end
	
	-- Determine dominant faction
	if ind.Influence > pres.Influence and ind.Influence > void.Influence then
		ServerState.DominantFaction = "Industrialists"
		ServerState.BaseTaxRate = 0.02
		ServerState.PollutionLevel += 10
	elseif void.Influence > pres.Influence and void.Influence > ind.Influence then
		ServerState.DominantFaction = "VoidWalkers"
		ServerState.SecurityLevel -= 10
		ServerState.BaseTaxRate = 0.10
	else
		ServerState.DominantFaction = "Preservationists"
		ServerState.PollutionLevel = math.max(0, ServerState.PollutionLevel - 10)
		ServerState.BaseTaxRate = 0.05
	end
end

function PoliticalService.GetTaxRate(): number
	return ServerState.BaseTaxRate
end

function PoliticalService.GetSecurityLevel(): number
	return ServerState.SecurityLevel
end

return PoliticalService
