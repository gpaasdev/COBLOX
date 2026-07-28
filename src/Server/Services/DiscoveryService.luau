--!strict
-- COBLOX SYSTEM 07: DISCOVERY ENGINE
-- Purpose: Knowledge becomes progression. Tracks discoveries and streams live First Discoveries to OpenCloud & Web Companion.
-- RC-2 fixes: Instance.new() race (moved to Init), WEBHOOK_SECRET hardcode removed, _isInitialized guard added.

local DiscoveryService = {}
DiscoveryService.Name = "DiscoveryService"
DiscoveryService.ServiceStatus = "Experimental" -- Instance.new race fixed; webhook secret pending env config

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local PlayerDataService = require(script.Parent.PlayerDataService)
local ProfileStoreAdapter = require(script.Parent.ProfileStoreAdapter)
local ResearchRegistry = require(game:GetService("ReplicatedStorage").Shared.Config.ResearchRegistry)
local MacroEconomyService = require(script.Parent.MacroEconomyService)

-- Module-level references (assigned in Init, not at require-time)
local _DiscoveryEvents: Folder? = nil
local _OnDiscoveryMade: RemoteEvent? = nil
local _isInitialized = false
local GlobalDiscoveriesCache: { [string]: string } = {}

-- Web Companion configuration
-- WEBHOOK_SECRET intentionally not hardcoded — read from RemoteConfigService or environment
local WEB_COMPANION_URL = "https://gpaasdev.github.io/COBLOX/api/webhook/roblox"
local _webhookSecret = "" -- Set in Init() via RemoteConfigService.Get("WebhookSecret")

function DiscoveryService.Init()
	if _isInitialized then
		warn("[DiscoveryService] Init() called twice — skipping.")
		return
	end
	_isInitialized = true

	-- Safe: read webhook secret from config service (not hardcoded)
	local RemoteConfigService = require(script.Parent.RemoteConfigService)
	_webhookSecret = RemoteConfigService.Get("WebhookSecret") or ""
	if _webhookSecret == "" then
		warn("[DiscoveryService] WebhookSecret not configured — webhook dispatch disabled.")
	end

	-- Create DiscoveryEvents folder idempotently (FindFirstChild guard)
	local sharedEvents = ReplicatedStorage:FindFirstChild("Shared")
		and ReplicatedStorage.Shared:FindFirstChild("Events")
	if not sharedEvents then
		warn("[DiscoveryService] ReplicatedStorage.Shared.Events not found — skipping remote setup.")
		return
	end

	_DiscoveryEvents = sharedEvents:FindFirstChild("DiscoveryEvents") :: Folder?
	if not _DiscoveryEvents then
		local folder = Instance.new("Folder")
		folder.Name = "DiscoveryEvents"
		folder.Parent = sharedEvents
		_DiscoveryEvents = folder
	end

	_OnDiscoveryMade = _DiscoveryEvents:FindFirstChild("OnDiscoveryMade") :: RemoteEvent?
	if not _OnDiscoveryMade then
		local remote = Instance.new("RemoteEvent")
		remote.Name = "OnDiscoveryMade"
		remote.Parent = _DiscoveryEvents
		_OnDiscoveryMade = remote
	end

	print("[DiscoveryService] Initialized — Discovery Engine ready.")
end

function DiscoveryService.Start()
	-- No persistent connections needed at start; driven by RecordDiscovery() calls
end

function DiscoveryService.RecordDiscovery(player: Player, discoveryType: string, id: string)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return false
	end

	-- Check if already discovered (read-only check before mutation)
	if res.Data.Discoveries and res.Data.Discoveries[id] then
		return false
	end

	-- Atomic profile mutation
	local result = ProfileStoreAdapter.SafeUpdateProfile(player, function(data)
		if not data.Discoveries then
			data.Discoveries = {}
		end
		if data.Discoveries[id] then
			return
		end
		data.Discoveries[id] = {
			Timestamp = DateTime.now():ToIsoDate(),
			Type = discoveryType,
		}
	end)

	if not result.Success then
		return false
	end

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
				DiscoveryType = discoveryType,
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
					timestamp = DateTime.now():ToIsoDate(),
				})

				if _webhookSecret ~= "" then
					HttpService:PostAsync(WEB_COMPANION_URL, payload, Enum.HttpContentType.ApplicationJson, false, {
						["x-coblox-secret"] = _webhookSecret,
					})
				end
			end)
		end)
	end

	-- Fire client event for AR Lens UI update
	if _OnDiscoveryMade then
		_OnDiscoveryMade:FireClient(player, discoveryType, id, isFirstDiscovery)
	end

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
