--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

-- Create central RemoteEvent & RemoteFunction instances
local syncEconomyRemote = NetChannels.GetRemoteEvent("SyncEconomy")
local hatchRemoteFunc = NetChannels.GetRemoteFunction("RequestHatch")
local genesisPodRemoteFunc = NetChannels.GetRemoteFunction("RequestGenesisPod")
local buyUpgradeRemoteFunc = NetChannels.GetRemoteFunction("RequestBuyUpgrade")
local equipPetRemoteFunc = NetChannels.GetRemoteFunction("RequestEquipPet")
local requestTradeRemoteFunc = NetChannels.GetRemoteFunction("RequestTrade")
local requestPlacementRemote = NetChannels.GetRemoteEvent("RequestPlacement")
local requestCraftRemoteFunc = NetChannels.GetRemoteFunction("RequestCraft")

-- Professional Enterprise Remotes
local requestShadowRaidRemoteFunc = NetChannels.GetRemoteFunction("RequestShadowRaid")
local claimRaidRewardRemoteFunc = NetChannels.GetRemoteFunction("ClaimRaidReward")
local requestCrystalPurificationRemoteFunc = NetChannels.GetRemoteFunction("RequestCrystalPurification")
local requestKarmaContractRemoteFunc = NetChannels.GetRemoteFunction("RequestKarmaContract")
local syncKarmaContractRemote = NetChannels.GetRemoteEvent("SyncKarmaContract")

local requestConsumePotionRemoteFunc = NetChannels.GetRemoteFunction("RequestConsumePotion")
local requestFlexEffectRemoteFunc = NetChannels.GetRemoteFunction("RequestFlexEffect")
local syncShieldStatusRemote = NetChannels.GetUnreliableRemoteEvent("SyncShieldStatus") -- Fase 10: visual-only
local claimOfflineEarningsRemoteFunc = NetChannels.GetRemoteFunction("ClaimOfflineEarnings")
local requestOfflineEarningsStatusRemoteFunc = NetChannels.GetRemoteFunction("RequestOfflineEarningsStatus")
local broadcastServerMessageRemote = NetChannels.GetRemoteEvent("BroadcastServerMessage")
local eggHatchedVisualRemote = NetChannels.GetUnreliableRemoteEvent("EggHatchedVisual")

-- Dummy connection to prevent "invocation queue exhausted" warning
if syncShieldStatusRemote then
	syncShieldStatusRemote.OnClientEvent:Connect(function() end)
end

return setmetatable({
	SyncEconomy = syncEconomyRemote,
	RequestHatch = hatchRemoteFunc,
	RequestGenesisPod = genesisPodRemoteFunc,
	RequestBuyUpgrade = buyUpgradeRemoteFunc,
	RequestEquipPet = equipPetRemoteFunc,
	RequestTrade = requestTradeRemoteFunc,
	RequestPlacement = requestPlacementRemote,
	RequestCraft = requestCraftRemoteFunc,
	RequestShadowRaid = requestShadowRaidRemoteFunc,
	ClaimRaidReward = claimRaidRewardRemoteFunc,
	RequestCrystalPurification = requestCrystalPurificationRemoteFunc,
	RequestKarmaContract = requestKarmaContractRemoteFunc,
	SyncKarmaContract = syncKarmaContractRemote,
	RequestConsumePotion = requestConsumePotionRemoteFunc,
	RequestFlexEffect = requestFlexEffectRemoteFunc,
	SyncShieldStatus = syncShieldStatusRemote,
	ClaimOfflineEarnings = claimOfflineEarningsRemoteFunc,
	RequestOfflineEarningsStatus = requestOfflineEarningsStatusRemoteFunc,
	BroadcastServerMessage = broadcastServerMessageRemote,
	EggHatchedVisual = eggHatchedVisualRemote,
}, {
	__index = function(self, key)
		warn(
			string.format(
				"[ClientRemotes] WARNING: Remote '%s' is nil (server may not have created it yet)",
				tostring(key)
			)
		)
		return nil
	end,
})
