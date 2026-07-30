--!strict

local Players = game:GetService("Players")

local FeatureFlagService = {}
FeatureFlagService.ServiceStatus = "Experimental"
FeatureFlagService.Name = "FeatureFlagService"

-- 3-State Kill Switch Enums
export type SwitchState = "ENABLED" | "READ_ONLY" | "DISABLED"

-- Feature Flag & Kill Switch Registry
local FLAGS: { [string]: SwitchState | boolean } = {
	-- Kill Switches (3 States)
	tradingSystem = "ENABLED",
	economySystem = "ENABLED",
	marketplace = "ENABLED",
	guildRaid = "DISABLED", -- Disabled by default until Season 2

	-- Global Toggles (Boolean)
	maintenanceMode = false,
}

function FeatureFlagService.Init()
	print("[FeatureFlagService] Initializing 3-State Kill Switches & Maintenance Mode...")
end

function FeatureFlagService.Start()
	-- Intercept new logins if Maintenance Mode is active
	Players.PlayerAdded:Connect(function(player)
		if FLAGS.maintenanceMode == true then
			-- Allow developers to bypass maintenance
			if not FeatureFlagService.IsDeveloper(player.UserId) then
				player:Kick("Server is currently under maintenance. Please check back shortly!")
			end
		end
	end)
end

function FeatureFlagService.GetState(flagName: string): SwitchState
	local state = FLAGS[flagName]
	if state == nil then
		return "DISABLED" -- Fail secure
	end
	return state :: SwitchState
end

function FeatureFlagService.IsBooleanFlagEnabled(flagName: string): boolean
	local flag = FLAGS[flagName]
	if type(flag) == "boolean" then
		return flag
	end
	return false
end

function FeatureFlagService.IsDeveloper(userId: number): boolean
	-- Always grant developer access to the universe creator
	if userId <= 0 then
		return false
	end
	if game.CreatorId > 0 and userId == game.CreatorId then
		return true
	end
	-- Authorised developer user IDs for COBLOX
	local devIds: { [number]: boolean } = {
		[11329819428] = true, -- gpaasdev (primary developer)
	}
	return devIds[userId] == true
end

return FeatureFlagService
