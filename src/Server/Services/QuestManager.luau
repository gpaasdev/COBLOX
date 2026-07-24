--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local QuestRegistry = require(ReplicatedStorage.Shared.Configuration.QuestRegistry)
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local QuestManager = {}

function QuestManager.Init()
	print("[QuestManager] Initializing Daily Quest Engine...")
	NetChannels.GetRemoteFunction("ClaimQuest")
	NetChannels.GetRemoteEvent("SyncQuest")
end

function QuestManager.Start()
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
		QuestManager.IncrementProgress(player, craftType, amount)
	end)

	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local claimRemote = NetChannels.GetRemoteFunction("ClaimQuest")
	claimRemote.OnServerInvoke = function(player, questId)
		return QuestManager.ClaimQuest(player, questId)
	end
    
    -- Automated Daily Quest Rotation Engine
    task.spawn(function()
        while true do
            -- Rotate quests every 24 hours (simulated as 1 hour for testing)
            task.wait(3600)
            print("[QuestManager] Rotating Daily Quests for all active players...")
            for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
                local res = PlayerDataService.GetProfile(player)
                if res.Success and res.Data then
                    -- Reset daily quest progress
                    res.Data.DailyQuests.Progress = {}
                    res.Data.DailyQuests.Completed = {}
                    -- In a full implementation, we'd pick new random quests from QuestRegistry
                    QuestManager.SyncClient(player, res.Data.DailyQuests)
                end
            end
            local GlobalBroadcastService = require(game:GetService("ServerScriptService").Server.Services.GlobalBroadcastService)
            GlobalBroadcastService.Broadcast("📜 Daily Quests have been reset!", 147, 197, 253)
        end
    end)
end

function QuestManager.IncrementProgress(player: Player, questType: string, amount: number)
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then return end

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
					PlayerDataService.AddCurrency(player, "AuraEnergy", questDef.Reward.AuraEnergy)
				end
				if questDef.Reward.SeasonXP then
					profile.Monetization.SeasonXP += questDef.Reward.SeasonXP
				end
			end
		end
	end

	QuestManager.SyncClient(player, profile.DailyQuests)
end

function QuestManager.SyncClient(player: Player, questData: any)
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local syncRemote = NetChannels.GetRemoteEvent("SyncQuest")
	syncRemote:FireClient(player, questData)
end

function QuestManager.ClaimQuest(player: Player, questId: string)
	-- Automatic claim happens in IncrementProgress, this just returns true if completed
	local res = PlayerDataService.GetProfile(player)
	if not res.Success or not res.Data then return false end
	local profile = res.Data
	if profile.DailyQuests.Completed[questId] then
		return true
	end
	return false
end

return QuestManager
