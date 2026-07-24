--!strict

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)

local SessionService = {}
SessionService.Name = "SessionService"

type SessionData = {
	sessionId: string,
	start: number,
	device: string,
	serverId: string,
}

local activeSessions: { [number]: SessionData } = {}
local SERVER_ID = game.JobId ~= "" and game.JobId or "StudioSession"

function SessionService.Init()
	print("[SessionService] Initializing Session Tracking Engine...")
end

function SessionService.Start()
	Players.PlayerAdded:Connect(function(player: Player)
		local sessionId = HttpService:GenerateGUID(false)
		
		-- Simplified device detection based on UserInputService info (if forwarded), otherwise mock it
		-- In a real scenario, this involves a client handshake.
		local device = "Desktop" 
		
		activeSessions[player.UserId] = {
			sessionId = sessionId,
			start = os.time(),
			device = device,
			serverId = SERVER_ID
		}
		
		-- DomainEventBus.Publish handled by AnalyticsService mostly, but we can emit a rich session start here
		DomainEventBus.Publish("PlayerSessionStarted", player, {
			sessionId = sessionId,
			serverId = SERVER_ID
		})
	end)

	Players.PlayerRemoving:Connect(function(player: Player)
		local session = activeSessions[player.UserId]
		if session then
			local duration = os.time() - session.start
			
			DomainEventBus.Publish("PlayerSessionEnded", player, {
				sessionId = session.sessionId,
				duration = duration,
				serverId = SERVER_ID
			})
			
			activeSessions[player.UserId] = nil
		end
	end)
end

function SessionService.GetSession(userId: number): SessionData?
	return activeSessions[userId]
end

return SessionService
