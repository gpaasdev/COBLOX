--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Utility.Signal)

export type State<T> = {
	Value: T,
	Get: (self: State<T>) -> T,
	Set: (self: State<T>, newValue: T) -> (),
	OnChange: (self: State<T>, listener: (newValue: T) -> ()) -> { Disconnect: () -> () },
}

local ReactiveState = {}

function ReactiveState.CreateState<T>(initialValue: T): State<T>
	local value = initialValue
	local changedSignal = Signal.new()

	local self = {}
	self.Value = value

	function self:Get(): T
		return value
	end

	function self:Set(newValue: T)
		if value ~= newValue then
			value = newValue
			self.Value = newValue
			changedSignal:Fire(newValue)
		end
	end

	function self:OnChange(listener: (newValue: T) -> ())
		return changedSignal:Connect(listener)
	end

	return self
end

function ReactiveState.CreateComputed<T, U>(sourceState: State<T>, computeFn: (T) -> U): State<U>
	local computedState = ReactiveState.CreateState(computeFn(sourceState:Get()))
	sourceState:OnChange(function(val)
		computedState:Set(computeFn(val))
	end)
	return computedState
end

return ReactiveState
