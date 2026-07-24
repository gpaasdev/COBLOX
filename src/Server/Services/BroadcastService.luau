--!strict

local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")

local GlobalMessaging = {}
if not RunService:IsStudio() then
	function GlobalMessaging:SubscribeAsync(topic, callback)
		return MessagingService:SubscribeAsync(topic, callback)
	end
	function GlobalMessaging:PublishAsync(topic, message)
		return MessagingService:PublishAsync(topic, message)
	end
else
	local mockEvent = Instance.new("BindableEvent")
	function GlobalMessaging:SubscribeAsync(topic, callback)
		local connection = mockEvent.Event:Connect(function(t, m)
			if t == topic then
				task.spawn(callback, {Data = m})
			end
		end)
		return connection
	end
	function GlobalMessaging:PublishAsync(topic, message)
		mockEvent:Fire(topic, message)
	end
end
local HttpService = game:GetService("HttpService")

local BroadcastService = {}
BroadcastService.Name = "BroadcastService"

local CHANNELS = {
	GlobalAnnounce = "GlobalServerEvents",
	LiveOpsUpdate = "LiveOpsUpdate",
	SecretHatch = "SecretHatch",
}

function BroadcastService.Init()
	print("[BroadcastService] Initializing Typed Cross-Server Messaging Channels...")
end

function BroadcastService.Start()
	pcall(function()
		GlobalMessaging:SubscribeAsync(CHANNELS.GlobalAnnounce, function(message)
			print("[GlobalServerEvent] " .. tostring(message.Data))
		end)
	end)

	pcall(function()
		GlobalMessaging:SubscribeAsync(CHANNELS.LiveOpsUpdate, function(message)
			print("[LiveOpsUpdate Channel] Received payload:", tostring(message.Data))
		end)
	end)
end

function BroadcastService.AnnounceSecretHatch(playerName: string, petName: string)
	local payload = string.format("%s just hatched a Secret %s!", playerName, petName)
	pcall(function()
		GlobalMessaging:PublishAsync(CHANNELS.SecretHatch, payload)
	end)
end

function BroadcastService.BroadcastLiveOpsUpdate(eventData: { EventType: string, Value: any })
	local jsonPayload = HttpService:JSONEncode(eventData)
	pcall(function()
		GlobalMessaging:PublishAsync(CHANNELS.LiveOpsUpdate, jsonPayload)
	end)
end

return BroadcastService
