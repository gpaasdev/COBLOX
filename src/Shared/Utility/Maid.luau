--!strict
-- Standard Maid pattern for memory management
local Maid = {}
Maid.__index = Maid

type Task = any

export type Maid = {
	GiveTask: (self: Maid, task: Task) -> number,
	DoCleaning: (self: Maid) -> (),
	Destroy: (self: Maid) -> (),
	[number]: Task,
	_tasks: {Task},
}

function Maid.new(): Maid
	return setmetatable({
		_tasks = {}
	}, Maid) :: any
end

function Maid:GiveTask(task: Task): number
	if not task then
		error("Task cannot be false or nil", 2)
	end
	
	local taskId = #self._tasks + 1
	self._tasks[taskId] = task
	
	return taskId
end

function Maid:DoCleaning()
	local tasks = self._tasks
	
	-- Disconnect all events first as we know this is safe
	for index, task in pairs(tasks) do
		if typeof(task) == "RBXScriptConnection" then
			tasks[index] = nil
			task:Disconnect()
		end
	end
	
	-- Clear out tasks table completely
	local index, task = next(tasks)
	while task ~= nil do
		tasks[index] = nil
		if type(task) == "function" then
			task()
		elseif typeof(task) == "RBXScriptConnection" then
			task:Disconnect()
		elseif typeof(task) == "Instance" or (type(task) == "table" and type(task.Destroy) == "function") then
			task:Destroy()
		elseif type(task) == "table" and type(task.DoCleaning) == "function" then
			task:DoCleaning()
		end
		index, task = next(tasks)
	end
end

function Maid:Destroy()
	self:DoCleaning()
end

return Maid
