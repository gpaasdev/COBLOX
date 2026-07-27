--!strict

local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")
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
	Players.PlayerRemoving:Connect(function(player: Player)
		local profile = PlayerDataService.GetProfile(player)
		if not profile then return end

		local gems = profile.Data.Wallet.Gems or 0
		local coins = profile.Data.Wallet.Coins or 0

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
	if not ok or not pages then return {} end

	local results = {}
	for _, entry in ipairs(pages:GetCurrentPage()) do
		table.insert(results, { userId = tostring(entry.key), score = tonumber(entry.value) or 0 })
	end
	return results
end

return LeaderboardService
