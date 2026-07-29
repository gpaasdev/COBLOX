--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)

local LeaderboardService = {}
LeaderboardService.Name = "LeaderboardService"

local ODS_Gems = DataStoreService:GetOrderedDataStore("COBLOX_Leaderboard_Gems_v11")
local ODS_Coins = DataStoreService:GetOrderedDataStore("COBLOX_Leaderboard_Coins_v11")

function LeaderboardService.Init()
	print("[LeaderboardService] Initializing OrderedDataStore Leaderboard Engine...")
end

function LeaderboardService.Start()
	local lbFunc = NetChannels.GetRemoteFunction("GetLeaderboardData")
	if lbFunc then
		lbFunc.OnServerInvoke = function(player: Player, category: string?, count: number?)
			local cat = if typeof(category) == "string" and category ~= "" then category else "Gems"
			local maxCount = math.min(typeof(count) == "number" and count or 10, 50)
			local entries = if cat == "Gems"
				then LeaderboardService.GetTopGems(maxCount)
				else LeaderboardService.GetTopCoins(maxCount)
			local result: { { Name: string, Score: number } } = {}
			for _, e in ipairs(entries) do
				local p = Players:GetPlayerByUserId(tonumber(e.userId) or 0)
				table.insert(result, {
					Name = if p then p.Name else "Player " .. e.userId,
					Score = e.score,
				})
			end
			return result
		end
	end

	Players.PlayerRemoving:Connect(function(player: Player)
		local result = PlayerDataService.GetProfile(player)
		if not result or not result.Success or not result.Data then
			return
		end

		local wallet = result.Data.Wallet
		if not wallet then
			return
		end

		local gems = wallet.Gems or 0
		local coins = wallet.Coins or 0

		pcall(function()
			ODS_Gems:SetAsync(tostring(player.UserId), math.floor(gems))
		end)

		pcall(function()
			ODS_Coins:SetAsync(tostring(player.UserId), math.floor(coins))
		end)
	end)
end

function LeaderboardService.GetTopGems(count: number): { { userId: string, score: number } }
	local ok, pages = pcall(function()
		return ODS_Gems:GetSortedAsync(false, math.min(count, 100))
	end)
	if not ok or not pages then
		return {}
	end

	local results = {}
	for _, entry in ipairs(pages:GetCurrentPage()) do
		table.insert(results, { userId = tostring(entry.key), score = tonumber(entry.value) or 0 })
	end
	return results
end

return LeaderboardService
