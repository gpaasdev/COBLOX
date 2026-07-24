--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local QuestRegistry = require(ReplicatedStorage.Shared.Configuration.QuestRegistry)

local QuestManager = {}

function QuestManager.Init()
	print("[QuestManager] Initializing Daily Quest Engine...")
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
