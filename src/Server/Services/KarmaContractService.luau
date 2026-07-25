--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local GlobalBroadcastService = require(ServerScriptService.Server.Services.GlobalBroadcastService)
local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

local KarmaContractService = {}
KarmaContractService.Name = "KarmaContractService"

local RETRIBUTION_DIST_LIMIT = 15

type KarmaContract = {
	Victim: Player,
	Target: Player,
	PotionName: string,
	EstValue: number,
	IssuedAt: number,
}

-- Active Contracts: [Player (Victim)] -> KarmaContract
local activeContracts: { [Player]: KarmaContract } = {}

function KarmaContractService.Init()
	print("[KarmaContractService] Initializing Karma Contract & Retribution Engine...")
end

function KarmaContractService.Start()
	-- Pre-create RemoteEvent so client WaitForChild does not yield infinitely
	NetChannels.GetRemoteEvent("SyncKarmaContract")

	local karmaRemote = NetChannels.GetRemoteFunction("RequestKarmaContract")
	if karmaRemote then
		karmaRemote.OnServerInvoke = function(victim: Player, targetUserId: any)
			-- Zero-Trust Payload Validation
			local ok, validTargetUserId = PayloadValidator.Validate({targetUserId}, {"number"})
			if not ok then
				warn("[Security] Payload validation failed for RequestKarmaContract from", victim.Name)
				return { Success = false, Message = "Invalid payload", RetributionReward = nil }
			end

			return KarmaContractService.ExecuteRetribution(victim, validTargetUserId)
		end
	end

	Players.PlayerRemoving:Connect(function(player)
		activeContracts[player] = nil
	end)
end

function KarmaContractService.IssueContract(victim: Player, target: Player, potionName: string, value: number)
	local contract: KarmaContract = {
		Victim = victim,
		Target = target,
		PotionName = potionName,
		EstValue = value,
		IssuedAt = os.time(),
	}

	activeContracts[victim] = contract

	-- Notify Victim Client with Compass Tracking Target
	local syncKarmaRemote = NetChannels.GetRemoteEvent("SyncKarmaContract")
	if syncKarmaRemote then
		syncKarmaRemote:FireClient(victim, {
			Active = true,
			TargetUserId = target.UserId,
			TargetName = target.Name,
			PotionName = potionName,
			EstValue = value,
		})
	end

	print(string.format("[KarmaContractService] ⚖️ Issued Karma Contract for %s against %s (%s)", victim.Name, target.Name, potionName))
end

function KarmaContractService.ExecuteRetribution(victim: Player, targetUserId: number): { Success: boolean, Message: string, RetributionReward: number? }
	if not RateLimitService.CheckRateLimit(victim, "ExecuteRetribution", 1.0) then
		return { Success = false, Message = "Rate limit exceeded!", RetributionReward = nil }
	end

	local contract = activeContracts[victim]
	if not contract or contract.Target.UserId ~= targetUserId then
		return { Success = false, Message = "No active Karma Contract for this target!", RetributionReward = nil }
	end

	local target = contract.Target
	if not target or not target.Parent then
		return { Success = false, Message = "Target is no longer in the server!", RetributionReward = nil }
	end

	local victimChar = victim.Character
	local targetChar = target.Character
	if not victimChar or not targetChar or not victimChar.PrimaryPart or not targetChar.PrimaryPart then
		return { Success = false, Message = "Character missing!", RetributionReward = nil }
	end

	local dist = (victimChar.PrimaryPart.Position - targetChar.PrimaryPart.Position).Magnitude
	if dist > RETRIBUTION_DIST_LIMIT then
		return { Success = false, Message = string.format("Target is too far away! (%.1f > %d studs)", dist, RETRIBUTION_DIST_LIMIT), RetributionReward = nil }
	end

	-- Execute Karma Retribution: Award 1.5x Reward
	local reward = math.floor(contract.EstValue * 1.5)
	activeContracts[victim] = nil

	-- Deduct from Target's wallet
	local targetProfileRes = PlayerDataService.GetProfile(target)
	if targetProfileRes.Success and targetProfileRes.Data then
		local targetWallet = targetProfileRes.Data.Wallet
		local currentCoins = targetWallet.Coins or 0
		local deductAmount = math.min(currentCoins, reward)
		if deductAmount > 0 then
			EconomyService.DeductCoins(target, deductAmount, "KarmaPenaltyDeduction")
		end
	end

	-- Sync cleared status to victim
	local syncKarmaRemote = NetChannels.GetRemoteEvent("SyncKarmaContract")
	if syncKarmaRemote then
		syncKarmaRemote:FireClient(victim, { Active = false })
	end

	EconomyService.AddCurrency(victim, "Coins", reward, "KarmaRetributionReward")

	-- Global Broadcast
	GlobalBroadcastService.Broadcast(
		string.format("🎯 KENA KARMA! %s BERHASIL MEMBALAS BEGALAN DARI %s (+%d KOIN)!", victim.Name, target.Name, reward),
		255, 215, 0
	)

	print(string.format("[KarmaContractService] 🎯 %s successfully executed retribution against %s for %d Coins!", victim.Name, target.Name, reward))
	return { Success = true, Message = "Karma Retribution Executed!", RetributionReward = reward }
end

return KarmaContractService
