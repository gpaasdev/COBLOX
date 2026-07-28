--!strict

local MessagingService = game:GetService("MessagingService")

local CrossServerMessagingService = {}
CrossServerMessagingService.Name = "CrossServerMessagingService"
CrossServerMessagingService.ServiceStatus = "Production"

local TOPIC_GLOBAL_BROADCAST = "COBLOX_GlobalBroadcast"

function CrossServerMessagingService.Init()
	print("[CrossServerMessagingService] Initializing Cross-Server Messaging Infrastructure...")

	local success, err = pcall(function()
		MessagingService:SubscribeAsync(TOPIC_GLOBAL_BROADCAST, function(message)
			CrossServerMessagingService.OnGlobalMessageReceived(message.Data)
		end)
	end)

	if not success then
		warn("[CrossServerMessagingService] Failed to subscribe to global broadcast:", err)
	end
end

function CrossServerMessagingService.BroadcastLegendaryCraft(playerName: string, itemName: string, rarity: string)
	local payload = {
		PlayerName = playerName,
		ItemName = itemName,
		Rarity = rarity,
		Timestamp = os.time(),
	}

	pcall(function()
		MessagingService:PublishAsync(TOPIC_GLOBAL_BROADCAST, payload)
	end)
end

function CrossServerMessagingService.OnGlobalMessageReceived(data: any)
	if typeof(data) == "table" and data.PlayerName and data.ItemName then
		print(
			string.format(
				"[CrossServer] GLOBAL ANNOUNCEMENT: Player %s just crafted [%s]!",
				data.PlayerName,
				data.ItemName
			)
		)
	end
end

return CrossServerMessagingService
