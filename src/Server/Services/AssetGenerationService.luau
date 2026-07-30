--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local MCPBridge = require(ReplicatedStorage.Shared.Modules.MCPBridge)

local AssetGenerationService = {}
AssetGenerationService.ServiceStatus = "Experimental"
AssetGenerationService.Name = "AssetGenerationService"

local PENDING_JOBS: { [string]: any } = {}
local POLL_INTERVAL = 5

function AssetGenerationService.Init()
	print("[AssetGenerationService] Initializing AI Asset Generation...")
	NetChannels.GetRemoteEvent("AssetGen_JobStatus")
	NetChannels.GetRemoteEvent("AssetGen_SubmitRequest")
	NetChannels.GetRemoteEvent("AssetGen_Result")
end

function AssetGenerationService.Start()
	local submitRemote = NetChannels.GetRemoteEvent("AssetGen_SubmitRequest")
	if submitRemote then
		submitRemote.OnServerEvent:Connect(function(player: Player, params: { [string]: any })
			AssetGenerationService._HandleGenRequest(player, params)
		end)
	end

	task.spawn(function()
		while task.wait(POLL_INTERVAL) do
			AssetGenerationService._PollPendingJobs()
		end
	end)
end

function AssetGenerationService._HandleGenRequest(player: Player, params: { [string]: any })
	if typeof(params) ~= "table" then
		return
	end

	local prompt = params.prompt
	local genType = params.type or "mesh"
	if type(prompt) ~= "string" or #prompt < 3 then
		warn(string.format("[AssetGenerationService] Invalid prompt from %s", player.Name))
		return
	end

	local jobId = HttpService:GenerateGUID(false)
	PENDING_JOBS[jobId] = {
		player = player,
		prompt = prompt,
		genType = genType,
		status = "queued",
		createdAt = os.time(),
	}

	local statusRemote = NetChannels.GetRemoteEvent("AssetGen_JobStatus")
	if statusRemote then
		statusRemote:FireClient(player, {
			jobId = jobId,
			status = "queued",
			message = "Your asset generation request has been queued",
		})
	end

	task.spawn(function()
		AssetGenerationService._ExecuteGeneration(jobId)
	end)
end

function AssetGenerationService._ExecuteGeneration(jobId: string)
	local job = PENDING_JOBS[jobId]
	if not job then
		return
	end

	job.status = "processing"
	local statusRemote = NetChannels.GetRemoteEvent("AssetGen_JobStatus")
	if statusRemote and job.player then
		statusRemote:FireClient(job.player, {
			jobId = jobId,
			status = "processing",
			message = "Generating asset...",
		})
	end

	local openCloudKey = AssetGenerationService._GetApiKey("OPEN_CLOUD_API_KEY")
	if not openCloudKey then
		job.status = "failed"
		if statusRemote and job.player then
			statusRemote:FireClient(job.player, {
				jobId = jobId,
				status = "failed",
				message = "API key not configured",
			})
		end
		return
	end

	local config = {
		ApiKey = openCloudKey,
		BaseUrl = game.GameId,
	}

	local result = MCPBridge._Request(
		"POST",
		"https://apis.roblox.com/assets/v1/assets",
		{
			["x-api-key"] = openCloudKey,
			["Content-Type"] = "application/json",
		},
		HttpService:JSONEncode({
			assetType = "Model",
			displayName = job.prompt,
			description = "AI-generated: " .. job.prompt,
		})
	)

	if result.Success and result.StatusCode == 200 then
		job.status = "completed"
		if statusRemote and job.player then
			statusRemote:FireClient(job.player, {
				jobId = jobId,
				status = "completed",
				assetId = result.Body and result.Body.assetId,
				message = "Asset generated successfully",
			})
		end
	else
		job.status = "failed"
		if statusRemote and job.player then
			statusRemote:FireClient(job.player, {
				jobId = jobId,
				status = "failed",
				message = result.Error or "Unknown error",
			})
		end
	end
end

function AssetGenerationService._PollPendingJobs()
	for jobId, job in PENDING_JOBS do
		if job.status == "completed" or job.status == "failed" then
			if os.time() - job.createdAt > 300 then
				PENDING_JOBS[jobId] = nil
			end
		end
	end
end

function AssetGenerationService._GetApiKey(keyName: string): string?
	local success, result = pcall(function()
		return game:GetAttribute(keyName)
	end)
	if success and type(result) == "string" and #result > 0 then
		return result
	end
	return nil
end

return AssetGenerationService
