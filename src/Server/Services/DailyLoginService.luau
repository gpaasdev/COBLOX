--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)

local DailyLoginService = {}
DailyLoginService.ServiceStatus = "Production"
DailyLoginService.Name = "DailyLoginService"

local LOGIN_REWARDS = {
	[1] = { Coins = 100, Gems = 0 },
	[2] = { Coins = 250, Gems = 5 },
	[3] = { Coins = 500, Gems = 10 },
	[4] = { Coins = 1000, Gems = 20 },
	[5] = { Coins = 2500, Gems = 50 },
	[6] = { Coins = 5000, Gems = 100 },
	[7] = { Coins = 10000, Gems = 250, Item = "Ramuan Aura Murni" },
}

local DAY_SECONDS = 86400

function DailyLoginService.Init()
	print("[DailyLoginService] Initializing Consecutive Login Rewards Tracker...")
end

function DailyLoginService.Start()
	Players.PlayerAdded:Connect(function(player)
		task.delay(3, function()
			DailyLoginService.CheckDailyReward(player)
		end)
	end)
end

function DailyLoginService.CheckDailyReward(player: Player)
	local result = PlayerDataService.GetProfile(player)
	if not result.Success or not result.Data then
		warn(string.format("[DailyLoginService] Cannot check daily login for %s: profile not loaded", player.Name))
		return
	end

	local now = os.time()

	if result.Data.DailyLogin and result.Data.DailyLogin.LastLoginTimestamp > 0
		and now - result.Data.DailyLogin.LastLoginTimestamp < DAY_SECONDS then
		print(string.format("[DailyLoginService] Player %s already claimed today.", player.Name))
		return
	end

	local timeSinceLastLogin = 0
	if result.Data.DailyLogin then
		timeSinceLastLogin = now - result.Data.DailyLogin.LastLoginTimestamp
	else
		result.Data.DailyLogin = {
			LastLoginTimestamp = 0,
			Streak = 0,
			LastClaimedDay = 0,
		}
	end

	ProfileStoreAdapter.SafeUpdateProfile(player, function(data: any)
		if timeSinceLastLogin > (DAY_SECONDS * 2) then
			data.DailyLogin.Streak = 0
		end

		data.DailyLogin.Streak = data.DailyLogin.Streak + 1
		if data.DailyLogin.Streak > 7 then
			data.DailyLogin.Streak = 1
		end

		local rewardDay = data.DailyLogin.Streak
		local reward = LOGIN_REWARDS[rewardDay]
		if not reward then
			return
		end

		if reward.Coins and reward.Coins > 0 then
			EconomyService.AddCurrency(player, "Coins", reward.Coins, "DailyLogin_Day_" .. rewardDay)
		end
		if reward.Gems and reward.Gems > 0 then
			EconomyService.AddCurrency(player, "Gems", reward.Gems, "DailyLogin_Day_" .. rewardDay)
		end

		data.DailyLogin.LastLoginTimestamp = now
		data.DailyLogin.LastClaimedDay = rewardDay

		print(string.format("[DailyLoginService] Player %s claimed Day %d reward: %d Coins, %d Gems",
			player.Name, rewardDay, reward.Coins or 0, reward.Gems or 0))
	end)
end

return DailyLoginService
