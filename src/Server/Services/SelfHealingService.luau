--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local SelfHealingService = {}
SelfHealingService.ServiceStatus = "Experimental"
SelfHealingService.Name = "SelfHealingService"

local ERROR_LOG: { { timestamp: number, message: string, stackTrace: string? } } = {}
local MAX_LOG = 500
local CORRECTION_ATTEMPTS: { [string]: number } = {}

local COMMON_ERROR_PATTERNS = {
	{
		pattern = "attempt to index nil with",
		severity = "high",
		category = "NullReference",
		suggestion = "Check the value is not nil before indexing. Add nil check or default value.",
	},
	{
		pattern = "invalid argument",
		severity = "high",
		category = "TypeMismatch",
		suggestion = "Validate argument types with typeof() before use.",
	},
	{
		pattern = "Workspace.*not a valid member",
		severity = "medium",
		category = "MissingInstance",
		suggestion = "Use FindFirstChild or WaitForChild instead of direct access.",
	},
	{
		pattern = "DataStore",
		severity = "high",
		category = "DataStoreError",
		suggestion = "Wrap DataStore calls in pcall. Check DataStore availability.",
	},
	{
		pattern = "HttpService",
		severity = "high",
		category = "HttpError",
		suggestion = "Wrap HttpService calls in pcall. Check API endpoint availability.",
	},
	{
		pattern = "RemoteEvent",
		severity = "medium",
		category = "RemoteEvent",
		suggestion = "Verify RemoteEvent exists with FindFirstChild before calling FireClient.",
	},
	{
		pattern = "attempt to call a nil value",
		severity = "high",
		category = "NilFunction",
		suggestion = "Verify the function exists before calling. Check require paths.",
	},
}

function SelfHealingService.Init()
	print("[SelfHealingService] Initializing Self-Healing Protocol...")
	NetChannels.GetRemoteEvent("Healing_ErrorReport")
	NetChannels.GetRemoteEvent("Healing_ApplyFix")
end

function SelfHealingService.Start()
	LogService.MessageOut:Connect(function(message: string, messageType: Enum.MessageType)
		if messageType == Enum.MessageType.MessageError then
			SelfHealingService._HandleError(message)
		end
	end)

	Players.PlayerAdded:Connect(function(player: Player)
		local remote = NetChannels.GetRemoteEvent("Healing_ErrorReport")
		if remote then
			remote:FireClient(player, {
				systemStatus = "active",
				recentErrors = SelfHealingService.GetRecentErrors(5),
			})
		end
	end)
end

function SelfHealingService._HandleError(message: string)
	local entry = {
		timestamp = os.time(),
		message = message,
		stackTrace = debug.traceback(),
	}
	table.insert(ERROR_LOG, entry)
	if #ERROR_LOG > MAX_LOG then
		table.remove(ERROR_LOG, 1)
	end

	local diagnosis = SelfHealingService._DiagnoseError(message)
	if diagnosis then
		local errorKey = diagnosis.category .. "_" .. tostring(#ERROR_LOG)
		CORRECTION_ATTEMPTS[errorKey] = (CORRECTION_ATTEMPTS[errorKey] or 0) + 1

		if CORRECTION_ATTEMPTS[errorKey] <= 3 then
			local fix = SelfHealingService._GenerateFix(diagnosis)
			if fix then
				warn(string.format("[SelfHealingService] Auto-fix %s: %s", diagnosis.category, fix))
			end
		end
	end
end

function SelfHealingService._DiagnoseError(message: string): { pattern: string, severity: string, category: string, suggestion: string }?
	for _, entry in ipairs(COMMON_ERROR_PATTERNS) do
		if string.find(message, entry.pattern, 1, true) then
			return entry
		end
	end
	return nil
end

function SelfHealingService._GenerateFix(diagnosis: { [string]: any }): string?
	local fixes = {
		NullReference = "Add nil guard: if value then ... end",
		TypeMismatch = "Add typeof validation: if typeof(value) == 'table' then ... end",
		MissingInstance = "Replace direct access with WaitForChild: local obj = parent:WaitForChild('Name')",
		DataStoreError = "Ensure pcall wraps all DataStore operations. Check DataStore is enabled.",
		HttpError = "Wrap HttpService:RequestAsync in pcall. Verify API key validity.",
		RemoteEvent = "Use FindFirstChild to check RemoteEvent exists before firing.",
		NilFunction = "Verify require path resolves to a valid ModuleScript.",
	}
	return fixes[diagnosis.category]
end

function SelfHealingService.GetRecentErrors(count: number): { { timestamp: number, message: string } }
	local recent = {}
	local start = math.max(1, #ERROR_LOG - count + 1)
	for i = start, #ERROR_LOG do
		table.insert(recent, {
			timestamp = ERROR_LOG[i].timestamp,
			message = ERROR_LOG[i].message,
		})
	end
	return recent
end

function SelfHealingService.GetErrorStats(): { [string]: number }
	local stats: { [string]: number } = {}
	for _, entry in ipairs(ERROR_LOG) do
		local diagnosis = SelfHealingService._DiagnoseError(entry.message)
		local category = if diagnosis then diagnosis.category else "Unknown"
		stats[category] = (stats[category] or 0) + 1
	end
	return stats
end

return SelfHealingService
