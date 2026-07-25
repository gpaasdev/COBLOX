--!strict
-- COBLOX Client Telemetry Controller
-- Responsibilities: Collects client performance, controller health, and feature usage telemetry.

local TelemetryController = {
	Name = "TelemetryController"
}

type TelemetryEvent = {
	Category: string,
	Action: string,
	Label: string?,
	Value: number?,
	Timestamp: number,
}

local buffer: { TelemetryEvent } = {}
local MAX_BUFFER_SIZE = 100

function TelemetryController.Init(Registry: any)
	print("[TelemetryController] Initialized.")
end

function TelemetryController.Start(Registry: any)
	print("[TelemetryController] Started tracking telemetry.")
end

function TelemetryController.Track(category: string, action: string, label: string?, value: number?)
	local event: TelemetryEvent = {
		Category = category,
		Action = action,
		Label = label,
		Value = value,
		Timestamp = tick(),
	}
	table.insert(buffer, event)
	if #buffer >= MAX_BUFFER_SIZE then
		TelemetryController.Flush()
	end
end

function TelemetryController.Flush()
	if #buffer == 0 then return end
	-- In production, this batch payload is sent to a server RemoteEvent or HTTP endpoint
	-- print(string.format("[TelemetryController] Flushed %d events to telemetry pipeline.", #buffer))
	table.clear(buffer)
end

function TelemetryController.Stop()
	TelemetryController.Flush()
end

return TelemetryController
