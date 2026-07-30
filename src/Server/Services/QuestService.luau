--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local QuestRegistry = require(ReplicatedStorage.Shared.Configuration.QuestRegistry)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local QuestService = { Name = "QuestService", ServiceStatus = "Production" }

function QuestService.Init()
	print("[QuestService] Initializing Daily Quest Engine...")
	NetChannels.GetRemoteFunction("ClaimQuest")
	NetChannels.GetRemoteEvent("SyncQuest")
end

function QuestService.Start()
	local signalsFolder = ReplicatedStorage:FindFirstChild("Signals")
	if not signalsFolder then
		signalsFolder = Instance.new("Folder")
		signalsFolder.Name = "Signals"
		signalsFolder.Parent = ReplicatedStorage
	end

	local craftSignal = Instance.new("BindableEvent")
	craftSignal.Name = "CraftCompletedSignal"
	craftSignal.Parent = signalsFolder

	craftSignal.Event:Connect(function(player: Player, craftType: string, amount: number)
		QuestService.IncrementProgress(player, craftType, amount)
	end)

	local RateLimitService = require(game:GetService("ServerScriptService").Server.Services.RateLimitService)
	local claimRemote = NetChannels.GetRemoteFunction("ClaimQuest")
	claimRemote.OnServerInvoke = function(player, questId)
		if type(questId) ~= "string" then
			return false
		end
		if not RateLimitService.CheckRateLimit(player, "ClaimQuest", 0.5) then
			return false
		end
		return QuestService.ClaimQuest(player, questId)
	end

	-- Automated Daily Quest Rotation Engine
	task.spawn(function()
		while true do
			-- Rotate quests every 24 hours (simulated as 1 hour for testing)
			task.wait(3600)
			print("[QuestService] Rotating Daily Quests for all active players...")
			local ProfileStoreAdapter = require(ServerScriptService.Server.Services.ProfileStoreAdapter)
			for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
				local res = PlayerDataService.GetProfile(player)
				if res.Success and res.Data then
					-- Reset daily quest progress (atomic mutation)
					ProfileStoreAdapter.SafeUpdateProfile(player, function(data)
						data.DailyQuests.Progress = {}
						data.DailyQuests.Completed = {}
					end)
					-- In a full implementation, we'd pick new random quests from QuestRegistry
					QuestService.SyncClient(player, res.Data.DailyQuests)
				end
			end
			local GlobalBroadcastService =
				require(game:GetService("ServerScriptService").Server.Services.GlobalBroadcastService)
			GlobalBroadcastService.Broadcast("📜 Daily Quests have been reset!", 147, 197, 253)
		end
	end)
end

function QuestService.IncrementProgress(player: Player, questType: string, amount: number)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return
	end

	local profile = res.Data

	for _, questId in ipairs(profile.DailyQuests.ActiveQuests) do
		local questDef = QuestRegistry[questId]
		if questDef and not profile.DailyQuests.Completed[questId] then
			local currentProgress = profile.DailyQuests.Progress[questId] or 0
			currentProgress += amount
			profile.DailyQuests.Progress[questId] = currentProgress

			if currentProgress >= questDef.Target then
				profile.DailyQuests.Completed[questId] = true
				if questDef.Reward.AuraEnergy then
					EconomyService.AddCurrency(player, "AuraEnergy", questDef.Reward.AuraEnergy)
				end
				if questDef.Reward.ChronoSparks then
					EconomyService.AddCurrency(player, "ChronoSparks", questDef.Reward.ChronoSparks)
				end
				if questDef.Reward.Coins then
					EconomyService.AddCurrency(player, "Coins", questDef.Reward.Coins)
				end
				if questDef.Reward.Gems then
					EconomyService.AddCurrency(player, "Gems", questDef.Reward.Gems)
				end
				if questDef.Reward.SeasonXP then
					profile.Monetization.SeasonXP += questDef.Reward.SeasonXP
				end
			end
		end
	end

	QuestService.SyncClient(player, profile.DailyQuests)
end

function QuestService.SyncClient(player: Player, questData: any)
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local syncRemote = NetChannels.GetRemoteEvent("SyncQuest")
	syncRemote:FireClient(player, questData)
end

function QuestService.ClaimQuest(player: Player, questId: string)
	-- Automatic claim happens in IncrementProgress, this just returns true if completed
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then
		return false
	end
	local profile = res.Data
	if profile.DailyQuests.Completed[questId] then
		return true
	end
	return false
end

return QuestService
