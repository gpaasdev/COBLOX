--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local RateLimitService = require(script.Parent.RateLimitService :: any)
local EconomyService = require(game:GetService("ServerScriptService").Server.Services.EconomyService)
local PlayerDataService = require(script.Parent.PlayerDataService :: any)
local PotionVaultService = require(script.Parent.PotionVaultService :: any)
local GlobalBroadcastService = require(script.Parent.GlobalBroadcastService :: any)
local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)

local ShadowRaidService = {}
ShadowRaidService.Name = "ShadowRaidService"

local MAX_RAID_DISTANCE = 15 -- studs (Zero-Trust Security)

-- Active Raiders carrying stolen Aura/Potions [Player] -> PotionName
local activeRaiders: { [Player]: string } = {}

function ShadowRaidService.Init()
	print("[ShadowRaidService] Initializing Zero-Trust Shadow Raid Engine...")

	local raidRemoteFunc = NetChannels.GetRemoteFunction("RequestShadowRaid")
	if raidRemoteFunc then
		raidRemoteFunc.OnServerInvoke = function(raider: Player, victimUserId: any, slotIndex: any)
			-- [NEW] PvE Boss Raid Check
			if victimUserId == "BOSS_RAID" then
				-- Calculate dynamic scaling based on server player count
				local activePlayersCount = #Players:GetPlayers()
				local bossHealth = 10000 + (activePlayersCount * 5000)
				local bossDamage = 50 + (activePlayersCount * 10)

				GlobalBroadcastService.Broadcast(
					string.format("⚠️ BOSS RAID SHADOW DRAGON MUNCUL! HP: %d", bossHealth),
					255,
					69,
					0
				)

				return { Success = true, IsBossRaid = true, BossHealth = bossHealth, BossDamage = bossDamage }
			end

			-- Zero-Trust Payload Validation
			local ok, vId, sIdx = PayloadValidator.Validate({ victimUserId, slotIndex }, { "number", "number" })
			if not ok then
				warn("[Security] Payload validation failed for RequestShadowRaid from", raider.Name)
				return { Success = false, Message = "Invalid payload!" }
			end

			-- 1. RateLimit Check
			if not RateLimitService.CheckRateLimit(raider, "RequestShadowRaid", 1.5) then
				return { Success = false, Message = "Rate limit exceeded!" }
			end

			-- 2. Validate Victim
			local victim = Players:GetPlayerByUserId(vId)
			if not victim or victim == raider then
				return { Success = false, Message = "Invalid target player!" }
			end

			-- 3. Distance Check (<= 15 studs)
			local raiderChar = raider.Character
			local victimChar = victim.Character
			if not raiderChar or not victimChar then
				return { Success = false, Message = "Player character missing!" }
			end

			local raiderRoot = raiderChar:FindFirstChild("HumanoidRootPart") :: BasePart?
			local victimRoot = victimChar:FindFirstChild("HumanoidRootPart") :: BasePart?

			if not raiderRoot or not victimRoot then
				return { Success = false, Message = "HumanoidRootPart missing!" }
			end

			local dist = (raiderRoot.Position - victimRoot.Position).Magnitude
			if dist > MAX_RAID_DISTANCE then
				return {
					Success = false,
					Message = string.format("Too far away! (%.1f > %d studs)", dist, MAX_RAID_DISTANCE),
				}
			end

			-- 4. Check Vault Slot
			local victimVault = PotionVaultService.GetVault(victim)
			local potionStolen = victimVault[sIdx]
			if not potionStolen or potionStolen == "" then
				return { Success = false, Message = "Pedestal is empty!" }
			end

			-- Perform Raid Transfer
			PotionVaultService.SetSlot(victim, sIdx, "")
			activeRaiders[raider] = potionStolen

			-- Issue Karma Contract to victim against raider
			local KarmaContractService = require(ServerScriptService.Server.Services.KarmaContractService)
			KarmaContractService.IssueContract(victim, raider, potionStolen, 5000)

			-- Apply Encumbered Movement Penalty (-15% speed)
			local humanoid = raiderChar:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = math.max(10, humanoid.WalkSpeed * 0.85)
			end

			-- Broadcast Event
			GlobalBroadcastService.Broadcast(
				string.format("🥷 %s BARU SAJA MEMBEGAL AURA MILIK %s!", raider.Name, victim.Name),
				239,
				68,
				68
			)

			print(
				string.format("[ShadowRaidService] 🥷 %s raided %s from %s!", raider.Name, potionStolen, victim.Name)
			)
			return { Success = true, PotionName = potionStolen }
		end
	end

	local claimRaidRewardRemoteFunc = NetChannels.GetRemoteFunction("ClaimRaidReward")
	if claimRaidRewardRemoteFunc then
		claimRaidRewardRemoteFunc.OnServerInvoke = function(raider: Player)
			if not RateLimitService.CheckRateLimit(raider, "ClaimRaidReward", 0.5) then
				return { Success = false, Message = "Rate limit exceeded!" }
			end
			local stolenPotion = activeRaiders[raider]
			if stolenPotion then
				activeRaiders[raider] = nil

				-- Restore WalkSpeed
				local raiderChar = raider.Character
				if raiderChar then
					local humanoid = raiderChar:FindFirstChildOfClass("Humanoid")
					if humanoid then
						humanoid.WalkSpeed = 16
					end
				end

				-- Award Raid Bonus Coins (5,000 Coins)
				EconomyService.AddCurrency(raider, "Coins", 5000)
				return { Success = true, BonusCoins = 5000 }
			end
			return { Success = false }
		end
	end
end

function ShadowRaidService.Start()
	Players.PlayerRemoving:Connect(function(player)
		activeRaiders[player] = nil
	end)

	task.spawn(function()
		local syncShieldStatusRemote = NetChannels.GetUnreliableRemoteEvent("SyncShieldStatus") -- Fase 10: visual-only sync
		while true do
			task.wait(5)
			for _, player in ipairs(Players:GetPlayers()) do
				syncShieldStatusRemote:FireClient(player, { ShieldActive = true, RemainingTime = 3600 })
			end
		end
	end)
end

return ShadowRaidService
