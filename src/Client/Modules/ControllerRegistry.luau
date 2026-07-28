--!strict
-- COBLOX Client Controller Registry
-- Manages controller lifecycle, registration, dependency resolution, and circular dependency checks.

type Controller = {
	Name: string?,
	Init: ((Registry: any) -> ())?,
	Start: ((Registry: any) -> ())?,
	Stop: (() -> ())?,
	[string]: any,
}

local ControllerRegistry = {}

local registeredControllers: { [string]: Controller } = {}
local initializedControllers: { [string]: boolean } = {}
local startedControllers: { [string]: boolean } = {}
local initStack: { [string]: boolean } = {}

function ControllerRegistry.RegisterController(name: string, controller: Controller)
	if registeredControllers[name] then
		warn(string.format("⚠️ [ControllerRegistry] Duplicate registration detected for '%s'. Overwriting.", name))
	end
	controller.Name = name
	registeredControllers[name] = controller
end

function ControllerRegistry.GetController(name: string): Controller?
	local controller = registeredControllers[name]
	if not controller then
		warn(string.format("⚠️ [ControllerRegistry] Controller '%s' not found.", name))
	end
	return controller
end

function ControllerRegistry.Resolve(name: string): Controller
	local controller = ControllerRegistry.GetController(name)
	assert(controller ~= nil, string.format("[ControllerRegistry] Failed to resolve mandatory controller '%s'", name))
	return controller :: Controller
end

function ControllerRegistry.InitializeController(name: string)
	if initializedControllers[name] then
		return
	end
	if initStack[name] then
		error(
			string.format("⛔ [ControllerRegistry] Circular initialization dependency detected involving '%s'!", name)
		)
	end

	local controller = registeredControllers[name]
	if not controller then
		return
	end

	initStack[name] = true

	if controller.Init then
		local success, err = pcall(function()
			controller.Init(ControllerRegistry)
		end)
		if not success then
			warn(string.format("❌ [ControllerRegistry] Init failed for '%s': %s", name, tostring(err)))
		end
	end

	initStack[name] = nil
	initializedControllers[name] = true
end

function ControllerRegistry.InitializeAll(startupOrder: { string }?)
	if startupOrder then
		for _, name in ipairs(startupOrder) do
			if registeredControllers[name] then
				ControllerRegistry.InitializeController(name)
			end
		end
	end

	-- Initialize any remaining registered controllers not explicitly in startupOrder
	for name, _ in pairs(registeredControllers) do
		if not initializedControllers[name] then
			ControllerRegistry.InitializeController(name)
		end
	end
end

function ControllerRegistry.StartAll(startupOrder: { string }?)
	local function startController(name: string)
		if startedControllers[name] then
			return
		end
		local controller = registeredControllers[name]
		if controller and controller.Start then
			local success, err = pcall(function()
				controller.Start(ControllerRegistry)
			end)
			if not success then
				warn(string.format("❌ [ControllerRegistry] Start failed for '%s': %s", name, tostring(err)))
			end
		end
		startedControllers[name] = true
	end

	if startupOrder then
		for _, name in ipairs(startupOrder) do
			startController(name)
		end
	end

	for name, _ in pairs(registeredControllers) do
		startController(name)
	end
end

function ControllerRegistry.StopAll()
	for name, controller in pairs(registeredControllers) do
		if startedControllers[name] and controller.Stop then
			pcall(function()
				controller.Stop()
			end)
			startedControllers[name] = false
		end
	end
end

return ControllerRegistry
