--!strict

local ConfigService = game:GetService("ConfigService")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)

local ExperimentService = {}
ExperimentService.Name = "ExperimentService"

local playerSnapshots: { [number]: any } = {}

function ExperimentService.Init()
	print("[ExperimentService] Initializing A/B Testing & Player-Specific Experiment Engine...")
	Players.PlayerRemoving:Connect(function(player: Player)
		ExperimentService.ClearPlayer(player)
	end)
end

function ExperimentService.Start()
	-- Ready
end

function ExperimentService.GetVariantValue(player: Player, key: string, fallback: any): any
	if playerSnapshots[player.UserId] == nil then
		local snap = RemoteConfigService.GetConfigForPlayer(player)
		playerSnapshots[player.UserId] = snap or false -- false sentinel if nil
	end

	local snap = playerSnapshots[player.UserId]
	if snap and snap ~= false then
		local val = nil
		pcall(function()
			val = snap:GetValue(key)
		end)
		if val ~= nil then
			return val
		end
	end

	return RemoteConfigService.GetTuningValue(key, fallback)
end

function ExperimentService.ClearPlayer(player: Player)
	playerSnapshots[player.UserId] = nil
end

return ExperimentService
