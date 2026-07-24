--!strict

type Connection = {
	Disconnect: (self: Connection) -> (),
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, fn: (T...) -> ()) -> Connection,
	Fire: (self: Signal<T...>, T...) -> (),
	Destroy: (self: Signal<T...>) -> (),
}

local SignalImpl = {}
SignalImpl.__index = SignalImpl

function SignalImpl.new<T...>(): Signal<T...>
	local self = setmetatable({}, SignalImpl)
	self._listeners = {}
	return (self :: any) :: Signal<T...>
end

function SignalImpl:Connect(fn: (...any) -> ()): Connection
	table.insert(self._listeners, fn)
	return {
		Disconnect = function()
			local idx = table.find(self._listeners, fn)
			if idx then
				table.remove(self._listeners, idx)
			end
		end,
	}
end

function SignalImpl:Fire(...: any)
	for _, fn in ipairs(self._listeners) do
		task.spawn(fn, ...)
	end
end

function SignalImpl:Destroy()
	table.clear(self._listeners)
end

return SignalImpl
