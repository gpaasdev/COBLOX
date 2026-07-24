--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Stats = game:GetService("Stats")

local FeatureFlagService = require(script.Parent.FeatureFlagService)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local AdminDashboardService = {}
AdminDashboardService.Name = "AdminDashboardService"

function AdminDashboardService.Init()
	print("[AdminDashboardService] Initializing Real-Time Diagnostic Dashboard...")
end

function AdminDashboardService.Start()
	local reqRemote = NetChannels.GetRemoteFunction("GetAdminDashboardData")
	if reqRemote then
		reqRemote.OnServerInvoke = function(player: Player)
			if not FeatureFlagService.IsDeveloper(player.UserId) then
				return { error = "Unauthorized" }
			end
			
			local memMb = gcinfo() / 1024
			
			return {
				health = {
					uptime = workspace.DistributedGameTime,
					ccu = #Players:GetPlayers(),
					memoryMB = string.format("%.2f", memMb),
					ping = "TBD", -- Ping relies on client-server echo
				},
				liveOps = {
					tradingSystem = FeatureFlagService.GetState("tradingSystem"),
					economySystem = FeatureFlagService.GetState("economySystem"),
					guildRaid = FeatureFlagService.GetState("guildRaid"),
					maintenanceMode = FeatureFlagService.IsBooleanFlagEnabled("maintenanceMode")
				},
				telemetry = {
					-- These would ideally be fetched from AnalyticsService metrics
					queueSize = 0,
					flushSuccess = "100%",
					errorCount = 0
				}
			}
		end
	end
end

return AdminDashboardService
