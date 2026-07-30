--!strict
-- QuestController.luau
-- Client-side controller for quest progression & reward claims in COBLOX (LGBOS v11.0).

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

type QuestNode = DataTypes.QuestNode
type ServiceResult<T> = DataTypes.ServiceResult<T>

local QuestController = {}
QuestController.Name = "QuestController"

QuestController.QuestProgressUpdated = Signal.new()
QuestController.RewardClaimed = Signal.new()

local claimQuestRemote: RemoteFunction
local syncQuestRemote: RemoteEvent

function QuestController.Init(self)
	print("[QuestController] Initializing Client Quest Controller...")
	claimQuestRemote = NetChannels.GetRemoteFunction("ClaimQuest")
	syncQuestRemote = NetChannels.GetRemoteEvent("SyncQuest")
end

function QuestController.Start(self)
	self.maid = Maid.new()
	self.maid:GiveTask(syncQuestRemote.OnClientEvent:Connect(function(questNode: QuestNode)
		print(
			string.format(
				"[QuestController] Quest Progress Updated: %s (%d/%d)",
				questNode.Id,
				questNode.Progress,
				questNode.Target
			)
		)
		QuestController.QuestProgressUpdated:Fire(questNode)
	end))
end

function QuestController.ClaimReward(questId: string): ServiceResult<any>
	local result = claimQuestRemote:InvokeServer(questId)
	if result and result.Success then
		print(string.format("[QuestController] Reward claimed for quest %s", questId))
		QuestController.RewardClaimed:Fire(questId, result.Data)
	end
	return result
end

return QuestController
