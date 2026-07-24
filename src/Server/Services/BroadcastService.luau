--!strict

local RunService = game:GetService("RunService")
local MessagingService = game:GetService("MessagingService")

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
		MessagingService:SubscribeAsync(CHANNELS.GlobalAnnounce, function(message)
			print("[GlobalServerEvent] " .. tostring(message.Data))
		end)
	end)

	pcall(function()
		MessagingService:SubscribeAsync(CHANNELS.LiveOpsUpdate, function(message)
			print("[LiveOpsUpdate Channel] Received payload:", tostring(message.Data))
		end)
	end)
end

function BroadcastService.AnnounceSecretHatch(playerName: string, petName: string)
	local payload = string.format("%s just hatched a Secret %s!", playerName, petName)
	pcall(function()
		MessagingService:PublishAsync(CHANNELS.SecretHatch, payload)
	end)
end

function BroadcastService.BroadcastLiveOpsUpdate(eventData: { EventType: string, Value: any })
	local jsonPayload = HttpService:JSONEncode(eventData)
	pcall(function()
		MessagingService:PublishAsync(CHANNELS.LiveOpsUpdate, jsonPayload)
	end)
end

return BroadcastService
