--!strict

local ConfigService = game:GetService("ConfigService")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local RemoteConfigRepository = require(ServerScriptService.Server.Services.RemoteConfigRepository)

type ConfigSchema = RemoteConfigRepository.ConfigSchema

local RemoteConfigService = {}
RemoteConfigService.Name = "RemoteConfigService"
RemoteConfigService.ServiceStatus = "Production"

local activeConfig: ConfigSchema = RemoteConfigRepository.GetDefaultConfig()
local configSnapshot: any = nil

-- Experiment Registry
local EXPERIMENT_REGISTRY = {
	["EXP_FTUE_REWARD"] = {
		Status = "Active",
		Start = 1700000000,
		End = 1750000000,
		Owner = "ProductTeam",
		Description = "Tests if 2x FTUE reward improves D1 Retention",
		SuccessMetric = "ftue.completed rate",
		Rollback = "A",
	},
	["EXP_SHOP_PRICE"] = {
		Status = "Draft",
		Start = 1700000000,
		End = 1750000000,
		Owner = "EconomyTeam",
		Description = "Tests -20% shop price vs base price",
		SuccessMetric = "ARPDAU",
		Rollback = "A",
	},
}

local function getHash(str: string): number
	local hash = 5381
	for i = 1, #str do
		hash = ((hash * 33) + string.byte(str, i)) % 2147483648
	end
	return hash
end

function RemoteConfigService.Init()
	activeConfig = RemoteConfigRepository.LoadConfig()

	local ok, snapshot = false, nil
	if not RunService:IsStudio() then
		ok, snapshot = pcall(function()
			return ConfigService:GetConfigAsync()
		end)
	end

	if ok and snapshot then
		configSnapshot = snapshot
		pcall(function()
			configSnapshot.UpdateAvailable:Connect(function()
				pcall(function()
					configSnapshot:Refresh()
				end)
			end)
		end)
	end
end

function RemoteConfigService.Start()
end

function RemoteConfigService.GetTuningValue(key: string, fallback: number): number
	if configSnapshot then
		local val = nil
		pcall(function()
			val = configSnapshot:GetValue(key)
		end)
		if val ~= nil and type(val) == "number" then
			return val
		end
	end

	local val = activeConfig.Tuning[key]
	if val == nil then
		return fallback
	end
	return val
end

function RemoteConfigService.GetStringValue(key: string, fallback: string): string
	if configSnapshot then
		local val = nil
		pcall(function()
			val = configSnapshot:GetValue(key)
		end)
		if val ~= nil and type(val) == "string" then
			return val
		end
	end

	local val = activeConfig.StringConfig[key]
	if val == nil then
		return fallback
	end
	return val
end

function RemoteConfigService.GetBoolValue(key: string, fallback: boolean): boolean
	if configSnapshot then
		local val = nil
		pcall(function()
			val = configSnapshot:GetValue(key)
		end)
		if val ~= nil and type(val) == "boolean" then
			return val
		end
	end

	local val = activeConfig.BoolConfig[key]
	if val == nil then
		return fallback
	end
	return val
end

function RemoteConfigService.GetFeatureFlag(key: string, fallback: boolean): boolean
	if configSnapshot then
		local val = nil
		pcall(function()
			val = configSnapshot:GetValue(key)
		end)
		if val ~= nil and type(val) == "boolean" then
			return val
		end
	end

	local val = activeConfig.FeatureFlags[key]
	if val == nil then
		return fallback
	end
	return val
end

function RemoteConfigService.GetConfigForPlayer(player: Player): ConfigSchema
	return activeConfig
end

function RemoteConfigService.GetExperimentVariant(player: Player, experimentId: string): string
	local experiment = EXPERIMENT_REGISTRY[experimentId]
	if not experiment or experiment.Status ~= "Active" then
		return experiment and experiment.Rollback or "A"
	end

	local hashInput = tostring(player.UserId) .. experimentId
	local hashValue = getHash(hashInput)

	if hashValue % 2 == 0 then
		return "A"
	else
		return "B"
	end
end

function RemoteConfigService.GetAllConfig(): ConfigSchema
	return activeConfig
end

return RemoteConfigService
