--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)

local AnnouncementService = {}
AnnouncementService.Name = "AnnouncementService"

function AnnouncementService.Init()
	print("[AnnouncementService] Initializing Runtime Server Broadcasts...")
end

function AnnouncementService.Start()
	-- Listens to commands from an Admin or a Remote API (MessagingService) to broadcast
end

-- Broadcasts a message to all connected players in this specific server
function AnnouncementService.BroadcastToServer(message: string, duration: number?)
	duration = duration or 5.0
	DomainEventBus.Publish("ServerAnnouncement", nil, {
		message = message,
		duration = duration
	})
	print(string.format("[Announcement] %s", message))
end

-- Ideally, we would have a function BroadcastToAllServers using MessagingService
-- to relay the announcement globally.

return AnnouncementService
