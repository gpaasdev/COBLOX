--!strict

local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local RemoteConfig = require(ServerScriptService.Server.Services.RemoteConfig)

local FeedbackService = {}
FeedbackService.ServiceStatus = "Experimental"
FeedbackService.Name = "FeedbackService"

local feedbackQueue = {}
local BATCH_FLUSH_INTERVAL = 30.0
local MAX_QUEUE_SIZE = 50

function FeedbackService.Init()
	print("[FeedbackService] Initializing Zero-Trust User Feedback Engine...")
end

function FeedbackService.Start()
	local submitRemote = NetChannels.GetRemoteEvent("SubmitFeedback")
	local RateLimitService = require(script.Parent.RateLimitService)
	if submitRemote then
		submitRemote.OnServerEvent:Connect(function(player: Player, data: any)
			if not RateLimitService.CheckRateLimit(player, "SubmitFeedback", 180) then -- 1 per 3 minutes
				return
			end
			FeedbackService.ProcessFeedback(player, data)
		end)
	end

	-- Forward feedback from DomainEventBus to Webhook
	DomainEventBus.Subscribe(function(event)
		if event.Name == "FeedbackSubmitted" then
			table.insert(feedbackQueue, event.Data)
			if #feedbackQueue >= MAX_QUEUE_SIZE then
				FeedbackService.FlushQueue()
			end
		end
	end)

	-- Periodic batch flush
	task.spawn(function()
		while true do
			task.wait(BATCH_FLUSH_INTERVAL)
			FeedbackService.FlushQueue()
		end
	end)
end

function FeedbackService.ProcessFeedback(player: Player, rawData: any)
	if type(rawData) ~= "table" then
		return
	end

	local validCategories = {
		Bug = true,
		Suggestion = true,
		Balance = true,
		Exploit = true,
		UI = true,
		Performance = true,
		Translation = true,
		Other = true,
	}

	local category = rawData.category
	if not validCategories[category] then
		category = "Other"
	end

	-- Clean strings to prevent injection or massive payloads
	local message = tostring(rawData.message or ""):sub(1, 1000)
	local device = tostring(rawData.device or "Unknown"):sub(1, 50)
	local platform = tostring(rawData.platform or "Unknown"):sub(1, 50)
	local gameVersion = tostring(rawData.gameVersion or "Unknown"):sub(1, 50)
	local screenshotId = tostring(rawData.screenshotId or "")

	local feedbackPayload = {
		playerId = player.UserId,
		playerName = player.Name,
		category = category,
		message = message,
		device = device,
		platform = platform,
		gameVersion = gameVersion,
		screenshotId = screenshotId,
		timestamp = os.time(),
	}

	-- Publish locally via DomainEventBus
	DomainEventBus.Publish("FeedbackSubmitted", player, feedbackPayload)
end

function FeedbackService.FlushQueue()
	if #feedbackQueue == 0 then
		return
	end

	local batch = feedbackQueue
	feedbackQueue = {}

	task.spawn(function()
		-- Send to Webhook in fail-safe manner
		if RunService:IsStudio() then
			print(string.format("[FeedbackService] Flushed %d feedbacks in Studio.", #batch))
			return
		end

		local webhookUrl = RemoteConfig.Get("DiscordWebhookUrl") or ""
		if webhookUrl == "" or webhookUrl:find("PLACEHOLDER") then
			print(
				string.format(
					"[FeedbackService] Webhook disabled or URL not configured. Processed %d feedbacks locally.",
					#batch
				)
			)
			return
		end

		local ok, err = pcall(function()
			for _, item in ipairs(batch) do
				local payload = {
					content = string.format(
						"**[%s]** from %s (ID: %d)\n**Message:** %s\n**Device:** %s | **Platform:** %s | **Version:** %s\n**Screenshot:** %s",
						item.category,
						item.playerName,
						item.playerId,
						item.message,
						item.device,
						item.platform,
						item.gameVersion,
						item.screenshotId
					),
				}

				HttpService:PostAsync(webhookUrl, HttpService:JSONEncode(payload), Enum.HttpContentType.ApplicationJson)
			end
		end)

		if not ok then
			warn("[FeedbackService] Webhook Delivery Failed. Gameplay continues securely. Error: ", err)
		end
	end)
end

return FeedbackService
