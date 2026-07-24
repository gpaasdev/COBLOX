--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

export type DomainEvent = {
	EventName: string,
	Timestamp: number,
	Player: Player?,
	Data: { [string]: any },
}

local DomainEventBus = {}
local eventSignal = Signal.new()

function DomainEventBus.Publish(eventName: string, player: Player?, data: { [string]: any }?)
	local event: DomainEvent = {
		EventName = eventName,
		Timestamp = os.time(),
		Player = player,
		Data = data or {},
	}
	eventSignal:Fire(event)

	-- Asynchronous AnalyticsService Telemetry
	task.spawn(function()
		local AnalyticsService = game:GetService("AnalyticsService")
		pcall(function()
			if player and eventName == "PurchaseCompleted" then
				AnalyticsService:LogEconomyEvent(player, Enum.AnalyticsEconomyFlowType.Sink, "RobuxPurchase", data.Amount or 0, 1, "DevProduct")
			elseif player and eventName == "DailyLoginProcessed" then
				AnalyticsService:LogCustomEvent(player, "DailyLogin", data.Streak or 1)
			end
		end)
	end)
end

function DomainEventBus.Subscribe(listener: (DomainEvent) -> ())
	return eventSignal:Connect(listener)
end

return DomainEventBus
