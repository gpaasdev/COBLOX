--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local FallbackCodeGenerator = {}

export type GeneratedCode = {
	Source: string,
	FilePath: string,
	Dependencies: { string },
	Description: string,
}

function FallbackCodeGenerator.GenerateService(serviceName: string, tier: number): GeneratedCode
	local src = string.format([[
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local %s = {}
%s.ServiceStatus = "Experimental"
%s.Name = "%s"

function %s.Init(self)
	print("[%s] Initializing...")
	NetChannels.GetRemoteEvent("%s_Request")
	NetChannels.GetRemoteEvent("%s_Response")
end

function %s.Start(self)
	print("[%s] Started")

	local requestRemote = NetChannels.GetRemoteEvent("%s_Request")
	if requestRemote then
		requestRemote.OnServerEvent:Connect(function(player, ...)
			local args = { ... }
			print("[%s] Request from", player.Name, args)
		end)
	end
end

return %s
]], serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName, serviceName)

	return {
		Source = src,
		FilePath = string.format("src/Server/Services/%s.luau", serviceName),
		Dependencies = { "NetChannels" },
		Description = string.format("%s service (Tier %d) with NetChannels RemoteEvent scaffolding", serviceName, tier),
	}
end

function FallbackCodeGenerator.GenerateController(controllerName: string): GeneratedCode
	local src = string.format([[
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local %s = {}

function %s.Init(self, Registry)
	self.maid = require(ReplicatedStorage.Shared.Utility.Maid).new()
	self._remote = NetChannels.GetRemoteEvent("")
end

function %s.Start(self, Registry)
	print("[%s] Started")
end

function %s.Cleanup(self)
	if self.maid then
		self.maid:Destroy()
	end
end

return %s
]], controllerName, controllerName, controllerName, controllerName, controllerName, controllerName)

	return {
		Source = src,
		FilePath = string.format("src/Client/Controllers/%s.luau", controllerName),
		Dependencies = { "NetChannels", "Maid" },
		Description = string.format("%s controller with Maid lifecycle and NetChannels scaffolding", controllerName),
	}
end

function FallbackCodeGenerator.GenerateRemoteEventHandler(
	eventName: string,
	validatePlayer: boolean,
	handlerLogic: string
): GeneratedCode
	local validationCode = ""
	if validatePlayer then
		validationCode = [[
	local player = args[1]
	if typeof(player) ~= "Instance" or not player:IsA("Player") then
		warn("[Security] Invalid player argument on ]] .. eventName .. [["]
		return
	end
]]
	end

	local src = string.format([[
--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local function Setup%sHandler()
	local remote = NetChannels.GetRemoteEvent("%s")
	if not remote then
		warn("[%sHandler] RemoteEvent not found")
		return
	end

	remote.OnServerEvent:Connect(function(player, ...)
		local args = { ... }
		%s

		%s
	end)
end

return Setup%sHandler
]], eventName, eventName, eventName, validationCode, handlerLogic, eventName)

	return {
		Source = src,
		FilePath = string.format("src/Server/Handlers/%sHandler.luau", eventName),
		Dependencies = { "NetChannels" },
		Description = string.format("Server-side handler for %s with%s validation", eventName, if validatePlayer then "" else "out"),
	}
end

function FallbackCodeGenerator.GenerateDataStoreAccess(
	profileKey: string,
	fields: { [string]: string }
): GeneratedCode
	local fieldDefaults = ""
	for name, dtype in pairs(fields) do
		fieldDefaults ..= string.format("\tlocal %s = data.%s\n", name, name)
	end

	local src = string.format([[
--!strict

local ProfileStore = require(game:GetService("ServerScriptService").ServerPackages.ProfileStore)

local defaultData = {
%s
}

local profileStore = ProfileStore.New("%s", defaultData)

local function LoadProfile(userId: number): any
	local key = "COBLOX_" .. tostring(userId)
	local profile = profileStore:StartSessionAsync(key)
	if profile then
		profile:AddUserId(userId)
		profile:Reconcile()
		return profile
	end
	return nil
end

local function SaveProfile(profile: any): boolean
	local success, err = pcall(function()
		profile:EndSession()
	end)
	return success
end

return {
	LoadProfile = LoadProfile,
	SaveProfile = SaveProfile,
}
]], fieldDefaults, profileKey)

	return {
		Source = src,
		FilePath = "src/Server/Services/GeneratedDataAccess.luau",
		Dependencies = { "ProfileStore" },
		Description = string.format("ProfileStore-based data access for %s", profileKey),
	}
end

return FallbackCodeGenerator
