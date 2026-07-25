--!strict
-- COBLOX SYSTEM 07: DISCOVERY ENGINE
-- Purpose: Knowledge becomes progression. Tracks discoveries and streams live First Discoveries to OpenCloud & Web Companion.

local DiscoveryService = {}

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local PlayerDataService = require(script.Parent.PlayerDataService)
local ResearchRegistry = require(game:GetService("ReplicatedStorage").Shared.Config.ResearchRegistry)
local MacroEconomyService = require(script.Parent.MacroEconomyService)

local DiscoveryEvents = Instance.new("Folder")
DiscoveryEvents.Name = "DiscoveryEvents"
DiscoveryEvents.Parent = ReplicatedStorage.Shared.Events

local OnDiscoveryMade = Instance.new("RemoteEvent")
OnDiscoveryMade.Name = "OnDiscoveryMade"
OnDiscoveryMade.Parent = DiscoveryEvents

local GlobalDiscoveriesCache = {} 

-- Configuration for Web Companion Endpoint
local WEB_COMPANION_URL = "https://gpaasdev.github.io/COBLOX/api/webhook/roblox"
local WEBHOOK_SECRET = "fallback-secret-for-dev"

function DiscoveryService.RecordDiscovery(player: Player, discoveryType: string, id: string)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then return false end

	if not res.Data.Discoveries then
		res.Data.Discoveries = {}
	end

	-- Check if already discovered by this player
	if res.Data.Discoveries[id] then
		return false
	end

	-- Record for this player
	res.Data.Discoveries[id] = {
		Timestamp = DateTime.now():ToIsoDate(),
		Type = discoveryType,
	}

	-- Check global first discovery
	local isFirstDiscovery = false
	if not GlobalDiscoveriesCache[id] then
		GlobalDiscoveriesCache[id] = player.Name
		isFirstDiscovery = true
		
		print(string.format("[DISCOVERY] %s is the FIRST to discover %s!", player.Name, id))
		
		-- 1. Broadcast across all live Roblox server instances
		pcall(function()
			MessagingService:PublishAsync("GlobalDiscoveries", {
				PlayerName = player.Name,
				DiscoveryId = id,
				DiscoveryType = discoveryType
			})
		end)

		-- 2. Stream live First Discovery payload to Web Companion Platform (Task 1 & 2 Execution)
		task.spawn(function()
			pcall(function()
				local payload = HttpService:JSONEncode({
					eventType = "FIRST_DISCOVERY",
					playerName = player.Name,
					discoveryId = id,
					discoveryType = discoveryType,
					timestamp = DateTime.now():ToIsoDate()
				})
				
				HttpService:PostAsync(WEB_COMPANION_URL, payload, Enum.HttpContentType.ApplicationJson, false, {
					["x-coblox-secret"] = WEBHOOK_SECRET
				})
			end)
		end)
	end

	-- Fire client event for AR Lens UI update
	OnDiscoveryMade:FireClient(player, discoveryType, id, isFirstDiscovery)
	
	-- Grant Fame (Quantum Badges/Aura Energy)
	local EconomyService = require(script.Parent.EconomyService)
	local fameReward = isFirstDiscovery and 500 or 50
	EconomyService.AddCurrency(player, "QuantumBadges", fameReward, "DiscoveryReward")

	-- GAMEPLAY INTEGRATION: Auto-unlock research nodes
	if discoveryType == "Material" then
		for _, node in pairs(ResearchRegistry.GetAllResearch()) do
			-- Check if the node's dependencies or materials match this discovery
			-- Simple integration logic: if a node requires this material, check if we have enough
			-- For now, discovering it might immediately unlock it if no dependencies
			if node.MaterialRequirements[id] then
				-- We discovered a material needed for this research
				-- In a full implementation, we'd check quantity via EconomyService
				-- and dependencies, then unlock.
				print(string.format("[RESEARCH] %s contributed to research: %s", player.Name, node.Name))
				-- Tell MacroEconomyService to update global demand for this material
				MacroEconomyService.AdjustMarketDemand(id, 1.5)
			end
		end
	end

	return true
end

function DiscoveryService.HasDiscovered(player: Player, id: string): boolean
	local res = PlayerDataService.GetProfile(player)
	if res.Success and res.Data and res.Data.Discoveries then
		return res.Data.Discoveries[id] ~= nil
	end
	return false
end

function DiscoveryService.GetPlayerDiscoveries(player: Player)
	local res = PlayerDataService.GetProfile(player)
	if res.Success and res.Data then
		return res.Data.Discoveries or {}
	end
	return {}
end

return DiscoveryService
