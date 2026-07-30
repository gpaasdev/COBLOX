--!strict

local AIPrompt = {}

AIPrompt.Version = "11.1.0"
AIPrompt.Architecture = "LGBOS v11.0 Server-Authoritative Zero-Trust"

local function _BuildSystemPrompt(sections: { string }): string
	return table.concat(sections, "\n\n")
end

local CORE_IDENTITY =
	[[You are RAEA (Roblox AI Engine Architect), a specialized autonomous software engineer for COBLOX: Multiverse Alchemy Sanctum.
Architecture: LGBOS v11.0 Server-Authoritative Zero-Trust.
Language: Luau --!strict with task lifecycle (task.wait, task.spawn, task.defer).
Persistence: ProfileStore (session-locked DataStore).
Cleanup: Maid/Janitor pattern.
UI: Fusion or Roact (legacy).
Tooling: Rojo + Aftman + Selene + StyLua.]]

local MODE1_STUDIO_MCP = [[Execution Mode: DIRECT STUDIO MCP.
You have access to robloxstudio-mcp tools. Use execute_luau to inject code, start_stop_play to test, and inspect output logs.
Error recovery: parse stack trace -> refactor -> re-execute until zero errors.]]

local MODE2_HEADLESS = [[Execution Mode: HEADLESS OPEN CLOUD API.
Use HttpService to call Open Cloud REST endpoints. Rate limit: 30 req/min.
Endpoints: Assets API, DataStore API, Messaging API.
Validate all payloads with pcall before sending.]]

local MODE3_FALLBACK = [[Execution Mode: HUMAN FALLBACK.
No direct API/MCP access. Output clean Luau code blocks with numbered step-by-step instructions.
Provide copy-paste prompts for Roblox Studio Assistant.
Each output must include: file path suggestion, dependencies required, expected behavior.]]

local SECURITY_RULES = [[Security Rules (Zero-Trust):
1. ALL RemoteEvent.OnServerEvent must validate player argument first.
2. NEVER trust client position/damage/inventory counts.
3. Validate all DataStore keys with typeof before read/write.
4. Use pcall around every Http request and DataStore operation.
5. Max interaction distance: 15 studs (server-validated).
6. DropRate values in config are strings ("1.5%") — parse with tonumber(gsub("%%","")).]]

function AIPrompt.GetSystemPrompt(mode: "studio_mcp" | "headless" | "fallback"): string
	local modePrompt = if mode == "studio_mcp"
		then MODE1_STUDIO_MCP
		elseif mode == "headless" then MODE2_HEADLESS
		else MODE3_FALLBACK

	return _BuildSystemPrompt({ CORE_IDENTITY, modePrompt, SECURITY_RULES })
end

function AIPrompt.GetServiceTemplate(serviceName: string): string
	return string.format(
		[[
--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local %s = {}
%s.ServiceStatus = "Experimental"
%s.Name = "%s"

function %s.Init(self)
	print("[%s] Initializing...")
end

function %s.Start(self)
	print("[%s] Started")
end

return %s
]],
		serviceName,
		serviceName,
		serviceName,
		serviceName,
		serviceName,
		serviceName,
		serviceName,
		serviceName,
		serviceName
	)
end

function AIPrompt.GetControllerTemplate(controllerName: string): string
	return string.format(
		[[
--!strict
local %s = {}

function %s.Init(self, Registry)
	self.maid = require(game:GetService("ReplicatedStorage").Shared.Utility.Maid).new()
end

function %s.Start(self, Registry)
	print("[%s] Started")
end

return %s
]],
		controllerName,
		controllerName,
		controllerName,
		controllerName,
		controllerName
	)
end

function AIPrompt.GetApiCallExample(apiName: string): string
	local examples = {
		GetAsset = [[local MCPBridge = require(path.to.MCPBridge)
local result = MCPBridge.GetAssetDetails(assetId, { ApiKey = "key" })
if result.Success then
	print(result.Body)
end]],
		UploadAsset = [[local MCPBridge = require(path.to.MCPBridge)
local result = MCPBridge.UploadAsset(fileContent, "name", "Model", { ApiKey = "key" })]],

		DataStore = [[local MCPBridge = require(path.to.MCPBridge)
local result = MCPBridge.GetDataStoreEntry("DataStoreName", "entryKey", config)]],

		Messaging = [[local MCPBridge = require(path.to.MCPBridge)
local result = MCPBridge.PublishMessagingTopic("topicName", { data = "value" }, config)]],
	}

	return examples[apiName] or "-- No example available for " .. apiName
end

return table.freeze(AIPrompt)
