--!strict

local ServerScriptService = game:GetService("ServerScriptService")

local HealthService = {}
HealthService.ServiceStatus = "Production"
HealthService.Name = "HealthService"

local startTime = os.time()
local lastCheckTime = startTime
local checkCount = 0
local failureCount = 0

function HealthService.Init()
	print("[HealthService] Initializing health monitoring...")
end

function HealthService.Start()
	task.spawn(function()
		while true do
			task.wait(60)
			HealthService._RunCheck()
		end
	end)
end

function HealthService._RunCheck()
	checkCount += 1
	lastCheckTime = os.time()
	local ok = true

	local Stats = game:GetService("Stats")
	local ok1, mem = pcall(function()
		return Stats:GetTotalMemoryUsageMb()
	end)
	if ok1 then
		if mem > 2000 then
			warn(string.format("[HealthService] Memory high: %.0f MB", mem))
			failureCount += 1
			ok = false
		end
	end

	HealthService._lastStatus = {
		ok = ok,
		memoryMb = mem,
		uptimeSeconds = os.time() - startTime,
		checksPassed = checkCount - failureCount,
		checksFailed = failureCount,
		timestamp = os.time(),
	}
end

function HealthService.GetStatus(): { [string]: any }
	if not HealthService._lastStatus then
		return {
			ok = true,
			uptimeSeconds = os.time() - startTime,
			checksPassed = 0,
			checksFailed = 0,
			timestamp = os.time(),
		}
	end
	return HealthService._lastStatus
end

function HealthService.GetUptime(): number
	return os.time() - startTime
end

return HealthService
