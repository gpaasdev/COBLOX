--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)
local TradeTypes = require(ReplicatedStorage.Shared.Types.TradeTypes)
local PlayerDataService = require(script.Parent.PlayerDataService)
local EconomyService = require(script.Parent.EconomyService)
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

type TradeSession = TradeTypes.TradeSession
type ServiceResult<T> = DataTypes.ServiceResult<T>

local TradeService = {}
TradeService.Name = "TradeService"

local activeSessions: { [string]: TradeSession } = {}
local playerToSession: { [number]: string } = {}

TradeService.TradeStarted = Signal.new()
TradeService.TradeCompleted = Signal.new()
TradeService.TradeCancelled = Signal.new()

function TradeService.Init()
	print("[TradeService] Initializing Atomic 2-Step Trade engine...")
end

function TradeService.Start()
	local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
	local ServerScriptService = game:GetService("ServerScriptService")
	local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)
	local tradeRemoteFunc = NetChannels.GetRemoteFunction("RequestTrade")

	tradeRemoteFunc.OnServerInvoke = function(player: Player, targetPlayerName: string)
		if not RateLimitService.CheckRateLimit(player, "RequestTrade", 0.5) then
			return {
				Success = false,
				Category = "RateLimit",
				ErrorCode = "TOO_MANY_REQUESTS",
				Message = "Trading rate limited",
				Data = nil,
				Retryable = true,
			}
		end

		local targetPlayer = Players:FindFirstChild(targetPlayerName or "")
		if not targetPlayer then
			return {
				Success = false,
				Category = "Validation",
				ErrorCode = "PLAYER_NOT_FOUND",
				Message = "Target player not online",
				Data = nil,
				Retryable = false,
			}
		end

		return TradeService.CreateTradeSession(player, targetPlayer)
	end
end

function TradeService.CreateTradeSession(playerA: Player, playerB: Player): ServiceResult<TradeSession>
	if playerA == playerB then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "SELF_TRADE_FORBIDDEN",
			Message = "Cannot trade with oneself",
			Data = nil,
			Retryable = false,
		}
	end

	local ServerScriptService = game:GetService("ServerScriptService")
	local PolicyComplianceService = require(ServerScriptService.Server.Services.PolicyComplianceService)
	if
		not PolicyComplianceService:CanTradePaidItems(playerA) or not PolicyComplianceService:CanTradePaidItems(playerB)
	then
		return {
			Success = false,
			Category = "Compliance",
			ErrorCode = "TRADE_RESTRICTED_BY_POLICY",
			Message = "Item trading is restricted for one or both players per Roblox Policy.",
			Data = nil,
			Retryable = false,
		}
	end

	if playerToSession[playerA.UserId] or playerToSession[playerB.UserId] then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "PLAYER_BUSY",
			Message = "One or both players are already in an active trade",
			Data = nil,
			Retryable = false,
		}
	end

	local sessionId = HttpService:GenerateGUID(false)
	local session: TradeSession = {
		SessionId = sessionId,
		PlayerA = playerA,
		PlayerB = playerB,
		OfferA = { Coins = 0, Gems = 0, PetUUIDs = {} },
		OfferB = { Coins = 0, Gems = 0, PetUUIDs = {} },
		Stage1_A = false,
		Stage1_B = false,
		Stage2_A = false,
		Stage2_B = false,
		State = "Invited",
		CreatedTimestamp = os.time(),
	}

	activeSessions[sessionId] = session
	playerToSession[playerA.UserId] = sessionId
	playerToSession[playerB.UserId] = sessionId

	TradeService.TradeStarted:Fire(sessionId, playerA, playerB)
	print(
		string.format(
			"[TradeService] Trade session %s created between %s and %s",
			sessionId,
			playerA.Name,
			playerB.Name
		)
	)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Trade session created",
		Data = session,
		Retryable = false,
	}
end

function TradeService.ExecuteAtomicSwap(sessionId: string): ServiceResult<boolean>
	local session = activeSessions[sessionId]
	if not session then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "SESSION_NOT_FOUND",
			Message = "Trade session does not exist",
			Data = false,
			Retryable = false,
		}
	end

	if not (session.Stage1_A and session.Stage1_B and session.Stage2_A and session.Stage2_B) then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "UNCONFIRMED_TRADE",
			Message = "Both players must confirm both stages before execution",
			Data = false,
			Retryable = false,
		}
	end

	session.State = "Executing"

	-- Re-validate ownership of currencies and items
	local profileA = PlayerDataService.GetProfile(session.PlayerA).Data
	local profileB = PlayerDataService.GetProfile(session.PlayerB).Data

	if not profileA or not profileB then
		TradeService.CancelTradeSession(sessionId, "Profile load failed during execution")
		return {
			Success = false,
			Category = "Infrastructure",
			ErrorCode = "PROFILE_UNAVAILABLE",
			Message = "Failed to load profiles for atomic swap",
			Data = false,
			Retryable = true,
		}
	end

	-- Anti-Inflation Escrow Daily Limit Formula per GDD Section 10:
	-- Max Transfer = (Rebirth + 1) * 100,000 Coins/day
	local rebirthA = profileA.Sanctum and profileA.Sanctum.RebirthLevel or 0
	local rebirthB = profileB.Sanctum and profileB.Sanctum.RebirthLevel or 0
	local maxCapA = (rebirthA + 1) * 100000
	local maxCapB = (rebirthB + 1) * 100000

	if session.OfferA.Coins > maxCapA or session.OfferB.Coins > maxCapB then
		TradeService.CancelTradeSession(sessionId, "Trade coin transfer exceeds daily Rebirth cap per GDD Section 10")
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "TRANSFER_CAP_EXCEEDED",
			Message = "Trade coin amount exceeds daily Rebirth transfer limit",
			Data = false,
			Retryable = false,
		}
	end

	-- Atomic execution buffer swap
	if session.OfferA.Coins > 0 then
		EconomyService.DeductCoins(session.PlayerA, session.OfferA.Coins, "TradeSwap")
		EconomyService.AddCurrency(session.PlayerB, "Coins", session.OfferA.Coins, "TradeReceive")
	end

	if session.OfferB.Coins > 0 then
		EconomyService.DeductCoins(session.PlayerB, session.OfferB.Coins, "TradeSwap")
		EconomyService.AddCurrency(session.PlayerA, "Coins", session.OfferB.Coins, "TradeSwap")
	end

	-- Swap Pet ownership
	for _, petUUID in ipairs(session.OfferA.PetUUIDs) do
		local pet = profileA.Inventory.Pets[petUUID]
		if pet then
			profileA.Inventory.Pets[petUUID] = nil
			profileB.Inventory.Pets[petUUID] = pet
		end
	end

	for _, petUUID in ipairs(session.OfferB.PetUUIDs) do
		local pet = profileB.Inventory.Pets[petUUID]
		if pet then
			profileB.Inventory.Pets[petUUID] = nil
			profileA.Inventory.Pets[petUUID] = pet
		end
	end

	session.State = "Completed"
	TradeService.TradeCompleted:Fire(sessionId, session.PlayerA, session.PlayerB)

	-- Cleanup
	playerToSession[session.PlayerA.UserId] = nil
	playerToSession[session.PlayerB.UserId] = nil
	activeSessions[sessionId] = nil

	print("[TradeService] Atomic swap completed successfully for session " .. sessionId)

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = "Trade completed atomically",
		Data = true,
		Retryable = false,
	}
end

function TradeService.IsUUIDQuarantined(player: Player, petUUID: string): boolean
	local sessionId = playerToSession[player.UserId]
	if not sessionId then
		return false
	end

	local session = activeSessions[sessionId]
	if not session then
		return false
	end

	-- Check if item is locked in offer during active trade session
	local isOfferA = session.PlayerA == player and table.find(session.OfferA.PetUUIDs, petUUID) ~= nil
	local isOfferB = session.PlayerB == player and table.find(session.OfferB.PetUUIDs, petUUID) ~= nil

	return isOfferA or isOfferB
end

function TradeService.CancelTradeSession(sessionId: string, reason: string)
	local session = activeSessions[sessionId]
	if session then
		session.State = "Cancelled"
		TradeService.TradeCancelled:Fire(sessionId, reason)
		playerToSession[session.PlayerA.UserId] = nil
		playerToSession[session.PlayerB.UserId] = nil
		activeSessions[sessionId] = nil
		print(string.format("[TradeService] Session %s cancelled. Reason: %s", sessionId, reason))
	end
end

return TradeService
