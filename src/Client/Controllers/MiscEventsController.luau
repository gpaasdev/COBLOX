--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local MiscEventsController = {}
MiscEventsController.Name = "MiscEventsController"

function MiscEventsController.Init()
	print("[MiscEventsController] Initializing miscellaneous event listeners...")
end

function MiscEventsController.Start()
	local expeditionRemote = NetChannels.GetRemoteEvent("ExpeditionEvent")
	if expeditionRemote then
		expeditionRemote.OnClientEvent:Connect(function(eventData)
			print("[MiscEventsController] Received ExpeditionEvent:", eventData)
		end)
	end

	local retentionRemote = NetChannels.GetRemoteEvent("RetentionEvent")
	if retentionRemote then
		retentionRemote.OnClientEvent:Connect(function(eventData)
			print("[MiscEventsController] Received RetentionEvent:", eventData)
		end)
	end
end

return MiscEventsController
