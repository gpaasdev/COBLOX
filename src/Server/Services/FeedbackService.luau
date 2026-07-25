--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)

local FeedbackService = {}
FeedbackService.Name = "FeedbackService"

local feedbackQueue = {}
local BATCH_FLUSH_INTERVAL = 30.0
local MAX_QUEUE_SIZE = 50

-- Webhook URL should be stored in secrets, using a placeholder for now
local DISCORD_WEBHOOK_URL = "https://discord.com/api/webhooks/1530317961330425857/SJeWebeyB5fDhZZMYGQSpNAPoQpmIyDGnyS2xsJ_TTd4Yy1WO-PNJWau6yjeD0Nsm_eN"

function FeedbackService.Init()
	print("[FeedbackService] Initializing Player Feedback Pipeline...")
end

function FeedbackService.Start()
	local submitRemote = NetChannels.GetRemoteEvent("SubmitFeedback")
	if submitRemote then
		submitRemote.OnServerEvent:Connect(function(player: Player, data: any)
			-- Rate limit could be added here (e.g., 1 per 3 mins)
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
	if type(rawData) ~= "table" then return end
	
	local validCategories = {
		Bug = true, Suggestion = true, Balance = true, Exploit = true,
		UI = true, Performance = true, Translation = true, Other = true
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
		timestamp = os.time()
	}
	
	-- Publish locally via DomainEventBus
	DomainEventBus.Publish("FeedbackSubmitted", player, feedbackPayload)
end

function FeedbackService.FlushQueue()
	if #feedbackQueue == 0 then return end
	
	local batch = feedbackQueue
	feedbackQueue = {}
	
	task.spawn(function()
		-- Send to Webhook in fail-safe manner
		if RunService:IsStudio() then
			print(string.format("[FeedbackService] Flushed %d feedbacks in Studio.", #batch))
			return
		end
		
		local ENABLE_WEBHOOK = true -- Webhook is now active
		if not ENABLE_WEBHOOK or DISCORD_WEBHOOK_URL:find("PLACEHOLDER") then
			print(string.format("[FeedbackService] Webhook disabled or URL placeholder. Processed %d feedbacks locally.", #batch))
			return
		end

		local ok, err = pcall(function()
			for _, item in ipairs(batch) do
				local payload = {
					content = string.format("**[%s]** from %s (ID: %d)\n**Message:** %s\n**Device:** %s | **Platform:** %s | **Version:** %s\n**Screenshot:** %s",
						item.category, item.playerName, item.playerId, item.message, item.device, item.platform, item.gameVersion, item.screenshotId)
				}
				
				HttpService:PostAsync(
					DISCORD_WEBHOOK_URL,
					HttpService:JSONEncode(payload),
					Enum.HttpContentType.ApplicationJson
				)
			end
		end)
		
		if not ok then
			warn("[FeedbackService] Webhook Delivery Failed. Gameplay continues securely. Error: ", err)
		end
	end)
end

return FeedbackService
