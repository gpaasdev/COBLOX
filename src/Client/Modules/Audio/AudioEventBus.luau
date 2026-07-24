--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

local AudioEventBus = {}
local eventSignal = Signal.new()

function AudioEventBus.Publish(soundId: string, volume: number?)
	eventSignal:Fire(soundId, volume or 1.0)
end

function AudioEventBus.Subscribe(listener: (soundId: string, volume: number) -> ())
	return eventSignal:Connect(listener)
end

return AudioEventBus
