--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)

type PlayerProfile = DataTypes.PlayerProfile

local RetentionService = {}
RetentionService.Name = "RetentionService"

local SECONDS_PER_DAY = 86400
local MAX_OFFLINE_SYNTHESIS_HOURS = 12

function RetentionService.Init()
	print("[RetentionService] Initializing Retention Bounded Context with Grow a Garden Offline Growth Engine...")
end

function RetentionService.Start()
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local retentionEvent = NetChannels.GetRemoteEvent("RetentionEvent")
	local RateLimitService = require(game:GetService("ServerScriptService").Server.Services.RateLimitService)

	retentionEvent.OnServerEvent:Connect(function(player: Player, action: string)
		if type(action) ~= "string" then
			return
		end
		if action == "SpinWheel" then
			if not RateLimitService.CheckRateLimit(player, "Retention_SpinWheel", 60) then
				return
			end
			local profile = PlayerDataService.GetPlayerProfile(player)
			if not profile then
				return
			end
			local rewardGems = math.random(5, 50)
			profile.Wallet.ChronoSparks += rewardGems
			print(
				string.format("[RetentionService] Player %s spun the wheel and won %d Gems!", player.Name, rewardGems)
			)
		end
	end)

	PlayerDataService.ProfileLoaded:Connect(function(player: Player, profile: PlayerProfile)
		RetentionService.ProcessLoginRewards(player, profile)
		RetentionService.CalculateOfflineSynthesis(player, profile)
	end)
end

function RetentionService.ShouldResetDaily(lastResetTimestamp: number): boolean
	local now = os.time()
	local todayMidnight = now - (now % SECONDS_PER_DAY)
	return lastResetTimestamp < todayMidnight
end

function RetentionService.CalculateStreak(currentStreak: number, lastResetTimestamp: number): (number, boolean)
	local now = os.time()
	local timeDiff = now - lastResetTimestamp

	-- If logged in within 48 hours, streak continues, otherwise reset to 1
	if timeDiff > (SECONDS_PER_DAY * 2) then
		return 1, true -- Reset streak
	elseif timeDiff >= SECONDS_PER_DAY then
		return currentStreak + 1, false -- Incremented streak
	end

	return currentStreak, false -- Same day login
end

local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)

function RetentionService.ProcessLoginRewards(player: Player, profile: PlayerProfile)
	local dq = profile.DailyQuests
	if RetentionService.ShouldResetDaily(dq.LastReset) then
		local newStreak, resetOccurred = RetentionService.CalculateStreak(dq.Streak, dq.LastReset)
		dq.Streak = newStreak
		dq.LastReset = os.time() - (os.time() % SECONDS_PER_DAY)
		dq.Completed = {}
		dq.Progress = {}

		DomainEventBus.Publish("DailyLoginProcessed", player, {
			Streak = newStreak,
			ResetOccurred = resetOccurred,
		})

		print(
			string.format(
				"[RetentionService] Processed daily login for %s | New Streak: %d (Reset: %s)",
				player.Name,
				newStreak,
				tostring(resetOccurred)
			)
		)
	end
end

function RetentionService.CalculateOfflineSynthesis(player: Player, profile: PlayerProfile): number
	local now = os.time()
	local lastLogout = (profile and (profile :: any).Metadata and (profile :: any).Metadata.LastLogoutTimestamp)
		or (profile and profile.Analytics and profile.Analytics.FirstJoin)
		or now
	local timeElapsed = math.max(0, now - lastLogout)

	local cappedSeconds = math.min(timeElapsed, MAX_OFFLINE_SYNTHESIS_HOURS * 3600)
	local hoursOffline = cappedSeconds / 3600

	-- Base offline energy yield per hour
	local offlineAuraYield = math.floor(hoursOffline * 250)
	if offlineAuraYield > 0 then
		profile.Wallet.Coins += offlineAuraYield
		print(
			string.format(
				"[RetentionService] Offline Synthesis applied for %s | Hours: %.2f | Aura Claimed: +%d",
				player.Name,
				hoursOffline,
				offlineAuraYield
			)
		)
	end

	return offlineAuraYield
end

function RetentionService.GetRetentionMultiplier(streak: number): number
	-- Curved Daily Streak Multiplier: Min 1.0x, Max 2.5x
	return math.min(2.5, 1.0 + (streak - 1) * 0.15)
end

return RetentionService
