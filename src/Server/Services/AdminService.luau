--!strict

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local EconomyService = require(ServerScriptService.Server.Services.EconomyService)
local LiveOpsService = require(ServerScriptService.Server.Services.LiveOpsService)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local DataTypes = require(ReplicatedStorage.Shared.Types.DataTypes)

type ServiceResult<T> = DataTypes.ServiceResult<T>

local AdminService = {}
AdminService.Name = "AdminService"

-- Configured Admin UserIds or Group Rank checks (Adonis pattern)
local ADMIN_USER_IDS: { [number]: boolean } = {
	[1] = true, -- Studio Creator Placeholder
}

function AdminService.Init()
	print("[AdminService] Initializing Server-Authoritative Moderation & Admin Command Engine...")
end

function AdminService.Start()
	-- Connect Chat commands or RemoteFunction endpoints
end

function AdminService.IsPlayerAdmin(player: Player): boolean
	if ADMIN_USER_IDS[player.UserId] or player.UserId <= 0 or (game.CreatorId > 0 and player.UserId == game.CreatorId) then
		return true
	end
	return false
end

function AdminService.ExecuteCommand(sender: Player, commandName: string, targetPlayerName: string, param: number?): ServiceResult<string>
	if not AdminService.IsPlayerAdmin(sender) then
		warn(string.format("[AdminService Security Violation] Non-admin player %s attempted to run command %s", sender.Name, commandName))
		return {
			Success = false,
			Category = "Security",
			ErrorCode = "PERMISSION_DENIED",
			Message = "You do not have permission to execute admin commands.",
			Data = nil,
			Retryable = false,
		}
	end

	local targetPlayer = Players:FindFirstChild(targetPlayerName)
	if not targetPlayer then
		return {
			Success = false,
			Category = "Validation",
			ErrorCode = "PLAYER_NOT_FOUND",
			Message = "Target player is not in the server: " .. tostring(targetPlayerName),
			Data = nil,
			Retryable = false,
		}
	end

	local amount = param or 1000

	if commandName == "grantcoins" then
		EconomyService.AddCurrency(targetPlayer, "Coins", amount, "AdminCommand_" .. sender.Name)
	elseif commandName == "grantgems" then
		EconomyService.AddCurrency(targetPlayer, "Gems", amount, "AdminCommand_" .. sender.Name)
	elseif commandName == "rebirth" then
		EconomyService.ProcessRebirth(targetPlayer)
	elseif commandName == "kick" then
		targetPlayer:Kick("Kicked by Server Admin: " .. sender.Name)
	elseif commandName == "ban" then
		local ok, err = pcall(function()
			Players:BanAsync({
				UserIds = { targetPlayer.UserId },
				Duration = (param or 24) * 3600, -- default 24 hours
				DisplayReason = "Banned by Server Admin",
				PrivateReason = "Banned via AdminService by: " .. sender.Name,
				ExcludeAltAccounts = false,
				ApplyToUniverse = true,
			})
		end)
		if not ok then
			warn("[AdminService] BanAsync failed:", err)
		end
	end

	DomainEventBus.Publish("AdminCommandExecuted", sender, {
		Command = commandName,
		Target = targetPlayerName,
		Amount = amount,
	})

	print(string.format("[AdminService Audit] Admin %s executed command '%s' on %s (Param: %d)", sender.Name, commandName, targetPlayerName, amount))

	return {
		Success = true,
		Category = nil,
		ErrorCode = nil,
		Message = string.format("Command '%s' executed successfully on %s", commandName, targetPlayerName),
		Data = commandName,
		Retryable = false,
	}
end

return AdminService
