--!strict
local ServerScriptService = game:GetService("ServerScriptService")
local LiveOpsService = require(ServerScriptService.Server.Services.LiveOpsService)
local RemoteConfigService = require(ServerScriptService.Server.Services.RemoteConfigService)
local ILiveOpsProvider = require(ServerScriptService.Server.Services.LiveOpsProviders.ILiveOpsProvider)

type LiveOpsModifiers = ILiveOpsProvider.LiveOpsModifiers

local EventCalendarService = {}
EventCalendarService.Name = "EventCalendarService"
EventCalendarService.ServiceStatus = "Production"

local activeEvents: { [string]: any } = {}

function EventCalendarService.GetActiveEvents(): { [string]: any }
	local events: { [string]: any } = {}
	local osTime = os.time()
	local calendar = RemoteConfigService.GetAllConfig().StringConfig
	for key, value in pairs(calendar) do
		if string.find(key, "Event_") == 1 then
			table.insert(events, { id = key, data = value })
		end
	end
	return events
end

function EventCalendarService.GetActiveEventModifiers(): LiveOpsModifiers?
	local events = EventCalendarService.GetActiveEvents()
	if #events == 0 then
		return nil
	end
	return LiveOpsService.GetActiveModifiers()
end

function EventCalendarService.Init()
	print("[EventCalendarService] Initialized")
end

function EventCalendarService.Start() end

return EventCalendarService
