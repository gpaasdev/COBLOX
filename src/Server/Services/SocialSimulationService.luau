--!strict
-- COBLOX SYSTEM 09: SOCIAL SIMULATION
-- Purpose: Simulates persistent social relationships and faction dynamics.

local SocialSimulationService = {}
SocialSimulationService.Name = "SocialSimulationService"
SocialSimulationService.ServiceStatus = "Production" -- Core faction data ready; no heavy loop deps

export type FactionData = {
	Id: string,
	Influence: number,
	Stability: number,
	Wealth: number,
}

local Factions: { [string]: FactionData } = {
	["Preservationists"] = { Id = "Preservationists", Influence = 50, Stability = 80, Wealth = 40 },
	["Industrialists"] = { Id = "Industrialists", Influence = 70, Stability = 60, Wealth = 90 },
	["VoidWalkers"] = { Id = "VoidWalkers", Influence = 30, Stability = 20, Wealth = 50 },
}

-- Player standing with factions
local PlayerReputation: { [number]: { [string]: number } } = {}

function SocialSimulationService.InitializePlayer(player: Player)
	PlayerReputation[player.UserId] = {
		["Preservationists"] = 0,
		["Industrialists"] = 0,
		["VoidWalkers"] = 0,
	}
end

function SocialSimulationService.ModifyReputation(player: Player, factionId: string, amount: number)
	if PlayerReputation[player.UserId] then
		PlayerReputation[player.UserId][factionId] = (PlayerReputation[player.UserId][factionId] or 0) + amount

		-- Faction influence shifts slightly based on player actions
		if Factions[factionId] then
			Factions[factionId].Influence += (amount * 0.01)
		end
	end
end

function SocialSimulationService.GetFactionData(factionId: string): FactionData?
	return Factions[factionId]
end

function SocialSimulationService.GetPlayerReputation(player: Player, factionId: string): number
	if PlayerReputation[player.UserId] then
		return PlayerReputation[player.UserId][factionId] or 0
	end
	return 0
end

function SocialSimulationService.Init()
	print("[SocialSimulationService] Initialized — Faction simulation ready.")
end

function SocialSimulationService.Start()
	-- Faction dynamics updated via events; no active heartbeat loop
end

return SocialSimulationService
