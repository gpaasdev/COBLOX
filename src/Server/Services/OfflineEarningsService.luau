--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(script.Parent.PlayerDataService :: any)

local OfflineEarningsService = {}
OfflineEarningsService.ServiceStatus = "Production"
OfflineEarningsService.Name = "OfflineEarningsService"

local pendingOfflineEarnings: { [Player]: number } = {}
local MAX_OFFLINE_SECONDS = 86400 -- 24 Hours Cap
local BASE_IDLE_RATE_PER_SEC = 5 -- 5 Coins/sec base idle earnings

function OfflineEarningsService.Init()
	print("[OfflineEarningsService] Initializing Millennial AFK Progression Engine...")

	local claimRemoteFunc = NetChannels.GetRemoteFunction("ClaimOfflineEarnings")
	if claimRemoteFunc then
		claimRemoteFunc.OnServerInvoke = function(player: Player)
			local pending = pendingOfflineEarnings[player] or 0
			if pending > 0 then
				EconomyService.AddCurrency(player, "Coins", pending)
				pendingOfflineEarnings[player] = 0
				print(string.format("[OfflineEarningsService] %s claimed %d AFK Coins!", player.Name, pending))
				return { Success = true, ClaimedCoins = pending }
			end
			return { Success = false, ClaimedCoins = 0 }
		end
	end

	local statusRemoteFunc = NetChannels.GetRemoteFunction("RequestOfflineEarningsStatus")
	if statusRemoteFunc then
		statusRemoteFunc.OnServerInvoke = function(player: Player): { Success: boolean, PendingCoins: number }
			local pending = OfflineEarningsService.GetPendingEarnings(player)
			return { Success = true, PendingCoins = pending }
		end
	end
end

function OfflineEarningsService.Start()
	Players.PlayerAdded:Connect(function(player)
		local res = PlayerDataService.GetProfile(player)
		local lastSeen = 0
		if res.Success and res.Data then
			lastSeen = res.Data.LastSeen or 0
		end
		local now = os.time()
		local offlineSeconds = if lastSeen > 0 then math.min(now - lastSeen, MAX_OFFLINE_SECONDS) else 0
		local totalEarnings = offlineSeconds * BASE_IDLE_RATE_PER_SEC

		pendingOfflineEarnings[player] = totalEarnings
		if totalEarnings > 0 then
			print(string.format("[OfflineEarningsService] %s was offline for %d seconds, earned %d AFK Coins!", player.Name, offlineSeconds, totalEarnings))
		end
	end)

	Players.PlayerRemoving:Connect(function(player)
		local profileStore = require(script.Parent.ProfileStoreAdapter)
		profileStore.SafeUpdateProfile(player, function(data)
			data.LastSeen = os.time()
		end)
		pendingOfflineEarnings[player] = nil
	end)
end

function OfflineEarningsService.GetPendingEarnings(player: Player): number
	return pendingOfflineEarnings[player] or 0
end

return OfflineEarningsService
