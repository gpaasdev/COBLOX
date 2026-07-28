--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local ScriptContext = game:GetService("ScriptContext")
local RobloxAnalytics = game:GetService("AnalyticsService")

local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
type DomainEvent = DomainEventBus.DomainEvent

local AnalyticsService = {}
AnalyticsService.Name = "AnalyticsService"

-- Build Metadata
local BUILD_METADATA = {
	releaseChannel = "ClosedAlpha",
	buildVersion = "0.1.0-alpha.1",
	buildDate = "2026-07-24",
	placeVersion = tostring(game.PlaceVersion),
}

-- Batch Queue Configuration
local eventBatchQueue = {}
local BATCH_FLUSH_INTERVAL = 10.0
local MAX_BATCH_SIZE = 100

-- Schemas
type AnalyticsSchema = {
	event: string,
	timestamp: number,
	playerId: number?,
	sessionId: string?,
	version: string,
	platform: string,
	payload: any,
}

function AnalyticsService.Init()
	print("[AnalyticsService] Initializing Telemetry Engine with Taxonomy & Batching...")
end

function AnalyticsService.Start()
	-- 1. Error Tracking (Crash & Stability Dashboard)
	ScriptContext.Error:Connect(function(message, stackTrace, scriptInstance)
		-- CoreGui errors are client-only, skip CoreGui checks on server
		if not RunService:IsServer() then
			local ok, isCore = pcall(function()
				local coreGui = game:GetService("CoreGui")
				return scriptInstance and scriptInstance:IsDescendantOf(coreGui)
			end)
			if ok and isCore then
				return
			end
		end

		AnalyticsService.LogEvent("system.error", {
			severity = "Error",
			message = message,
			stack = stackTrace,
			script = scriptInstance and scriptInstance:GetFullName() or "Unknown",
			memory = gcinfo(),
			uptime = workspace.DistributedGameTime,
		})
	end)

	function AnalyticsService._HandleFTUEStep(player: Player, stepIndex: number, stepName: string)
		AnalyticsService.LogEvent("ftue.step", {
			step = stepIndex,
			name = stepName,
		}, player.UserId)
	end

	-- 2. DomainEventBus Hooks (Event Taxonomy Mapping)
	DomainEventBus.Subscribe(function(event: DomainEvent)
		local payload = event.Data or {}
		local playerId = event.Player and event.Player.UserId or nil
		local sessionId = nil -- Will be populated by SessionService later

		local taxonomyMap = {
			["PlayerJoined"] = "session.started",
			["PlayerLeft"] = "session.ended",
			["AdvanceFTUE"] = "ftue.started",
			["FTUECompleted"] = "ftue.completed",
			["PurchaseCompleted"] = "purchase.completed",
			["CovenDonated"] = "guild.donated",
		}

		local safeName = event.Name or "unknown"
		local eventName = taxonomyMap[safeName] or safeName:lower()
		AnalyticsService.LogEvent(eventName, payload, playerId)
	end)

	-- 3. Economy Service Hooks
	local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
	EconomyService.CoinsChanged:Connect(function(player: Player, balance: number, delta: number, reason: string)
		if delta == 0 then
			return
		end
		AnalyticsService.LogEvent("economy.transaction", {
			currency = "Coins",
			delta = delta,
			balance = balance,
			reason = reason,
		}, player.UserId)
	end)

	EconomyService.RebirthCompleted:Connect(function(player: Player, tokenCount: number)
		AnalyticsService.LogEvent("rebirth.completed", {
			tokens = tokenCount,
		}, player.UserId)
	end)

	-- 4. Trade Service Hooks
	local TradeService = require(ServerScriptService.Server.Services.TradeService)
	TradeService.TradeCompleted:Connect(function(sessionId: string, playerA: Player, playerB: Player)
		AnalyticsService.LogEvent("trade.completed", { tradeId = sessionId }, playerA.UserId)
		AnalyticsService.LogEvent("trade.completed", { tradeId = sessionId }, playerB.UserId)
	end)

	-- Periodic Batch Flush Loop
	task.spawn(function()
		while true do
			task.wait(BATCH_FLUSH_INTERVAL)
			AnalyticsService.FlushBatchQueue()
		end
	end)
end

function AnalyticsService.LogEvent(eventName: string, payload: any, playerId: number?)
	-- Construct Canonical Schema
	local eventData: AnalyticsSchema = {
		event = eventName,
		timestamp = os.time(),
		playerId = playerId,
		sessionId = "TBD", -- Integrated with SessionService
		version = BUILD_METADATA.buildVersion,
		platform = "Unknown", -- Server cannot easily know client platform without handshake, will be augmented by SessionService
		payload = payload,
	}

	table.insert(eventBatchQueue, eventData)

	if #eventBatchQueue >= MAX_BATCH_SIZE then
		AnalyticsService.FlushBatchQueue()
	end
end

function AnalyticsService.FlushBatchQueue()
	if #eventBatchQueue == 0 then
		return
	end

	local batchToFlush = eventBatchQueue
	eventBatchQueue = {} -- Reset queue

	-- Fail-safe HTTP execution
	task.spawn(function()
		local ok, err = pcall(function()
			-- In a real production scenario, this sends to a Data Lake (e.g. AWS Kinesis/PlayFab)
			-- For now, we simulate flushing the batched schema to RobloxAnalytics Custom Event as JSON (to bypass field limits)

			if RunService:IsStudio() then
				print(string.format("[Telemetry] Flushed %d events to Sink", #batchToFlush))
				return
			end

			-- We only sample the first event into Roblox Analytics due to their API limits,
			-- but a real external sink would accept the full JSON batch array.
			local sample = batchToFlush[1]
			if sample.playerId then
				local player = Players:GetPlayerByUserId(sample.playerId)
				if player then
					local jsonPayload = HttpService:JSONEncode(sample.payload)
					RobloxAnalytics:LogCustomEvent(player, sample.event, 1, {
						Version = sample.version,
						PayloadData = string.sub(jsonPayload, 1, 100), -- Roblox restricts custom string lengths
					})
				end
			end
		end)

		if not ok then
			warn("[AnalyticsService] Failed to flush telemetry batch. Gameplay continues securely. Err: ", err)
		end
	end)
end

return AnalyticsService
