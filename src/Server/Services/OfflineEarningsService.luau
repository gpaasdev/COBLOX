--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(script.Parent.PlayerDataService :: any)

local OfflineEarningsService = {}
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
end

function OfflineEarningsService.Start()
	Players.PlayerAdded:Connect(function(player)
		-- Compute sample offline earnings based on join timestamp
		local joinTime = os.time()
		-- For demo/simulation: simulate 2 hours (7200s) of offline earnings on first join
		local simulatedOfflineSeconds = 7200
		local totalEarnings = math.min(simulatedOfflineSeconds, MAX_OFFLINE_SECONDS) * BASE_IDLE_RATE_PER_SEC

		pendingOfflineEarnings[player] = totalEarnings
		print(string.format("[OfflineEarningsService] %s has %d pending AFK Coins!", player.Name, totalEarnings))
	end)

	Players.PlayerRemoving:Connect(function(player)
		pendingOfflineEarnings[player] = nil
	end)
end

function OfflineEarningsService.GetPendingEarnings(player: Player): number
	return pendingOfflineEarnings[player] or 0
end

return OfflineEarningsService
