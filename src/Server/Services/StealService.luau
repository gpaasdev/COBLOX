--!strict
-- Server/Services/StealService.luau
-- Server Service for Begal Aura & Karma Contract Mechanics

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local StealService = {}
StealService.Name = "StealService"

function StealService.Init()
	print("[StealService] Initializing Server-Authoritative Begal Aura & Karma Engine...")
end

function StealService.Start()
	local stealRemote = NetChannels.GetRemoteEvent("StealAuraEvent")
	if stealRemote then
		stealRemote.OnServerEvent:Connect(function(player: Player, targetPlayer: Player)
			if not RateLimitService.CheckRateLimit(player, "StealAura", 1.0) then return end
			if not targetPlayer or targetPlayer == player then return end

			-- Zero-Trust Distance Check (<= 15 studs)
			if player.Character and targetPlayer.Character and player.Character.PrimaryPart and targetPlayer.Character.PrimaryPart then
				local dist = (player.Character.PrimaryPart.Position - targetPlayer.Character.PrimaryPart.Position).Magnitude
				if dist > 15 then
					warn("[StealService] Distance check failed for steal attempt:", dist)
					return
				end
			end

			print(string.format("[StealService] %s attempted to steal aura from %s", player.Name, targetPlayer.Name))
		end)
	end
end

return StealService
