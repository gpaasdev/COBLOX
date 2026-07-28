--!strict

local Players = game:GetService("Players")

local DailyLoginService = {}
DailyLoginService.Name = "DailyLoginService"
DailyLoginService.ServiceStatus = "Stub"

local LOGIN_REWARDS = {
	[1] = { Coins = 100, Gems = 0 },
	[2] = { Coins = 250, Gems = 5 },
	[3] = { Coins = 500, Gems = 10 },
	[4] = { Coins = 1000, Gems = 20 },
	[5] = { Coins = 2500, Gems = 50 },
	[6] = { Coins = 5000, Gems = 100 },
	[7] = { Coins = 10000, Gems = 250, Item = "Ramuan Aura Murni" },
}

function DailyLoginService.Init()
	print("[DailyLoginService] Initializing Consecutive Login Rewards Tracker...")

	Players.PlayerAdded:Connect(function(player)
		DailyLoginService.CheckDailyReward(player)
	end)
end

function DailyLoginService.CheckDailyReward(player: Player)
	-- In production, fetches last login timestamp from ProfileStore and calculates consecutive streak
	print(string.format("[DailyLoginService] Checking daily login streak for player: %s", player.Name))
end

return DailyLoginService
