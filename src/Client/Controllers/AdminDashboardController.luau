--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local AdminDashboardController = {}
AdminDashboardController.Name = "AdminDashboardController"

function AdminDashboardController.Init()
	-- Controller remains minimal until developer hits hotkey (e.g. F9 or specific sequence)
end

function AdminDashboardController.Start()
	-- Bind hotkey to FetchAndDisplayDashboard()
end

function AdminDashboardController.FetchAndDisplayDashboard()
	local reqRemote = NetChannels.GetRemoteFunction("GetAdminDashboardData")
	if not reqRemote then
		return
	end

	local ok, data = pcall(function()
		return reqRemote:InvokeServer()
	end)

	if ok and data and not data.error then
		-- Render simple text-based UI or output to console for now
		print("=== COBLOX ADMIN DASHBOARD ===")
		print("HEALTH | CCU:", data.health.ccu, " | Mem:", data.health.memoryMB, "MB")
		print("LIVEOPS | Trade:", data.liveOps.tradingSystem, "| Maintenance:", data.liveOps.maintenanceMode)
		print("TELEMETRY | Queue:", data.telemetry.queueSize, " | Errors:", data.telemetry.errorCount)
		print("==============================")
	elseif data and data.error then
		warn("Access Denied to Admin Dashboard")
	end
end

return AdminDashboardController
