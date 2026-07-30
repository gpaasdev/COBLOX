--!strict
-- COBLOX SYSTEM 08: NPC PSYCHOLOGY
-- Purpose: Defines emotional states and decision-making logic for NPCs.

local NPCPsychologyService = {
	ServiceStatus = "Experimental",
	Name = "NPCPsychology",
}

function NPCPsychologyService.Init()
end

function NPCPsychologyService.Start()
end

export type NPCBrain = {
	Id: string,
	Trust: number,
	Fear: number,
	Greed: number,
	Stress: number,
	Curiosity: number,
	Loyalty: number,
	Aggression: number,
	Memory: { [string]: number }, -- PlayerId/EventId -> Impact Score
}

local ActiveNPCs: { [string]: NPCBrain } = {}

function NPCPsychologyService.RegisterNPC(id: string): NPCBrain
	ActiveNPCs[id] = {
		Id = id,
		Trust = 50,
		Fear = 20,
		Greed = 50,
		Stress = 10,
		Curiosity = 50,
		Loyalty = 30,
		Aggression = 20,
		Memory = {},
	}
	return ActiveNPCs[id]
end

function NPCPsychologyService.RecordEvent(npcId: string, eventId: string, impact: number)
	local npc = ActiveNPCs[npcId]
	if npc then
		npc.Memory[eventId] = (npc.Memory[eventId] or 0) + impact

		-- Logic hooks
		if impact < 0 then
			npc.Fear += math.abs(impact) * 0.1
			npc.Trust -= math.abs(impact) * 0.2
			npc.Stress += math.abs(impact) * 0.15
		else
			npc.Trust += impact * 0.2
			npc.Loyalty += impact * 0.1
		end

		-- Cap stats between 0 and 100
		npc.Fear = math.clamp(npc.Fear, 0, 100)
		npc.Trust = math.clamp(npc.Trust, 0, 100)
		npc.Stress = math.clamp(npc.Stress, 0, 100)
		npc.Loyalty = math.clamp(npc.Loyalty, 0, 100)
	end
end

function NPCPsychologyService.GetPriceModifier(npcId: string): number
	local npc = ActiveNPCs[npcId]
	if not npc then
		return 1.0
	end

	-- High greed + low trust = expensive
	local greedFactor = npc.Greed / 100
	local trustFactor = npc.Trust / 100

	-- Base 1.0. Greed adds up to +0.5. Trust reduces up to -0.3.
	return 1.0 + (greedFactor * 0.5) - (trustFactor * 0.3)
end

return NPCPsychologyService
