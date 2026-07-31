--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local LogService = game:GetService("LogService")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
local AdminService = require(ServerScriptService.Server.Services.AdminService)

type Diagnosis = { pattern: string, severity: string, category: string, suggestion: string }

local SelfHealingService = {}
SelfHealingService.ServiceStatus = "Experimental"
SelfHealingService.Name = "SelfHealingService"

local ERROR_LOG: { { timestamp: number, message: string, stackTrace: string? } } = {}
local MAX_LOG = 500
local CORRECTION_ATTEMPTS: { [string]: number } = {}
local SCRIPT_FAILURES: { [string]: number } = {}
local RECOVERY_LOG: { { timestamp: number, category: string, script: string, fix: string } } = {}
local MAX_CORRECTIONS = 3
local MAX_SCRIPT_RETRIES = 5

local COMMON_ERROR_PATTERNS: { Diagnosis } = {
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

local function ParseErrorScript(message: string): string
	local scriptName = string.match(message, "Script '([^']+)'") or string.match(message, "LocalScript '([^']+)'")
	if scriptName then
		return scriptName
	end
	local moduleName = string.match(message, "ModuleScript '([^']+)'")
	if moduleName then
		return moduleName
	end
	return "Unknown"
end

function SelfHealingService.Init()
	print("[SelfHealingService] Initializing Self-Healing Protocol...")
	NetChannels.GetRemoteEvent("Healing_ErrorReport")
	local applyRemote = NetChannels.GetRemoteEvent("Healing_ApplyFix")
	if applyRemote then
		applyRemote.OnServerEvent:Connect(function(player: Player, request: any)
			SelfHealingService._ConsumeApplyFix(player, request)
		end)
	end
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
	if not diagnosis then
		return
	end

	local script = ParseErrorScript(message)
	SCRIPT_FAILURES[script] = (SCRIPT_FAILURES[script] or 0) + 1

	local errorKey = diagnosis.category .. "_" .. script
	CORRECTION_ATTEMPTS[errorKey] = (CORRECTION_ATTEMPTS[errorKey] or 0) + 1
	local attempts = CORRECTION_ATTEMPTS[errorKey]

	if attempts > MAX_CORRECTIONS then
		warn(
			string.format(
				"[SelfHealingService] Escalating %s (%d attempts) — manual review required for %s.",
				diagnosis.category,
				attempts,
				script
			)
		)
		DomainEventBus.Publish("SelfHealingEscalation", nil, {
			category = diagnosis.category,
			script = script,
			attempts = attempts,
			message = message,
		})
		return
	end

	local fix = SelfHealingService._GenerateFix(diagnosis)
	if not fix then
		return
	end

	table.insert(RECOVERY_LOG, {
		timestamp = os.time(),
		category = diagnosis.category,
		script = script,
		fix = fix,
	})

	warn(string.format("[SelfHealingService] Auto-fix %s for %s: %s", diagnosis.category, script, fix))

	DomainEventBus.Publish("SelfHealingRecovery", nil, {
		category = diagnosis.category,
		script = script,
		fix = fix,
		attempts = attempts,
	})

	if SCRIPT_FAILURES[script] > MAX_SCRIPT_RETRIES then
		warn(
			string.format(
				"[SelfHealingService] %s exceeded %d failures — flagging for restart review.",
				script,
				MAX_SCRIPT_RETRIES
			)
		)
		DomainEventBus.Publish("SelfHealingScriptFlagged", nil, {
			script = script,
			failures = SCRIPT_FAILURES[script],
		})
	end
end

function SelfHealingService._ConsumeApplyFix(player: Player, request: any)
	if type(request) ~= "table" or type(request.fixId) ~= "string" then
		warn("[SelfHealingService] Rejected malformed fix request from " .. tostring(player and player.Name))
		return
	end

	if not AdminService.IsPlayerAdmin(player) then
		warn(
			string.format(
				"[SelfHealingService Security] Non-admin %s attempted to apply fix %q",
				tostring(player and player.Name),
				request.fixId
			)
		)
		return
	end

	local fixId = request.fixId :: string
	local accepted = false

	if fixId == "clear_error_log" then
		table.clear(ERROR_LOG)
		accepted = true
	elseif fixId == "reset_corrections" then
		table.clear(CORRECTION_ATTEMPTS)
		table.clear(SCRIPT_FAILURES)
		accepted = true
	elseif fixId == "retry" then
		local script = type(request.script) == "string" and (request.script :: string) or "Unknown"
		SCRIPT_FAILURES[script] = 0
		accepted = true
	end

	local remote = NetChannels.GetRemoteEvent("Healing_ApplyFix")
	if remote then
		remote:FireClient(player, {
			fixId = fixId,
			applied = accepted,
			timestamp = os.time(),
		})
	end
end

function SelfHealingService._DiagnoseError(message: string): Diagnosis?
	for _, entry in ipairs(COMMON_ERROR_PATTERNS) do
		if string.find(message, entry.pattern, 1, true) then
			return entry
		end
	end
	return nil
end

function SelfHealingService._GenerateFix(diagnosis: Diagnosis): string?
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

function SelfHealingService.GetRecoveryLog(
	count: number
): { { timestamp: number, category: string, script: string, fix: string } }
	local recent = {}
	local start = math.max(1, #RECOVERY_LOG - count + 1)
	for i = start, #RECOVERY_LOG do
		table.insert(recent, RECOVERY_LOG[i])
	end
	return recent
end

return SelfHealingService
