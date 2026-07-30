--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local HttpService = game:GetService("HttpService")
local MessagingService = game:GetService("MessagingService")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local MCPBridge = require(ReplicatedStorage.Shared.Modules.MCPBridge)

local AIPipelineService = {}
AIPipelineService.ServiceStatus = "Experimental"
AIPipelineService.Name = "AIPipelineService"

local ACTIVE_PIPELINES: { [string]: any } = {}
local PIPELINE_TOPIC = "COBLOX_AIPipeline"

function AIPipelineService.Init()
	print("[AIPipelineService] Initializing AI Pipeline Orchestrator...")
	NetChannels.GetRemoteEvent("Pipeline_Status")
	NetChannels.GetRemoteEvent("Pipeline_Request")
end

function AIPipelineService.Start()
	local requestRemote = NetChannels.GetRemoteEvent("Pipeline_Request")
	if requestRemote then
		requestRemote.OnServerEvent:Connect(function(player: Player, request: { [string]: any })
			AIPipelineService._HandlePipelineRequest(player, request)
		end)
	end

	pcall(function()
		MessagingService:SubscribeAsync(PIPELINE_TOPIC, function(message)
			local data = message.Data
			if typeof(data) == "table" and data.pipelineId then
				AIPipelineService._HandleCrossServerUpdate(data)
			end
		end)
	end)
end

function AIPipelineService._HandlePipelineRequest(player: Player, request: { [string]: any })
	if typeof(request) ~= "table" then
		return
	end

	local pipelineType = request.pipelineType :: string
	local params = request.params :: { [string]: any }

	local pipelineId = HttpService:GenerateGUID(false)
	local pipeline = {
		id = pipelineId,
		player = player,
		type = pipelineType,
		params = params,
		steps = {},
		currentStep = 0,
		status = "initialized",
		createdAt = os.time(),
	}

	ACTIVE_PIPELINES[pipelineId] = pipeline
	AIPipelineService._ExecutePipeline(pipeline)
end

function AIPipelineService._ExecutePipeline(pipeline: any)
	local steps = AIPipelineService._ResolveSteps(pipeline.type, pipeline.params)
	if #steps == 0 then
		AIPipelineService._CompletePipeline(pipeline, nil, "Unknown pipeline type: " .. pipeline.type)
		return
	end

	pipeline.steps = steps
	pipeline.status = "running"

	AIPipelineService._BroadcastPipelineStatus(pipeline)

	for i, step in ipairs(steps) do
		pipeline.currentStep = i
		AIPipelineService._BroadcastPipelineStatus(pipeline)

		local success, result = pcall(function()
			return AIPipelineService._ExecuteStep(step, pipeline)
		end)

		if not success then
			AIPipelineService._CompletePipeline(pipeline, nil, tostring(result))
			return
		end

		if result and result.abort then
			AIPipelineService._CompletePipeline(pipeline, nil, result.reason or "Step aborted")
			return
		end

		pipeline.params.lastResult = result
	end

	AIPipelineService._CompletePipeline(pipeline, pipeline.params.lastResult)
end

function AIPipelineService._ResolveSteps(pipelineType: string, params: any): { any }
	if pipelineType == "generate_asset" then
		return {
			{ name = "validate_prompt", description = "Validate input prompt" },
			{ name = "call_meshy_api", description = "Generate 3D mesh via Meshy API" },
			{ name = "upload_to_roblox", description = "Upload asset to Roblox" },
			{ name = "notify_complete", description = "Notify player and cross-server" },
		}
	elseif pipelineType == "generate_animation" then
		return {
			{ name = "validate_motion", description = "Validate motion source" },
			{ name = "call_deepmotion_api", description = "Process via DeepMotion API" },
			{ name = "retarget_rig", description = "Retarget to R15 rig" },
			{ name = "upload_keyframe", description = "Upload as KeyframeSequence" },
		}
	elseif pipelineType == "generate_audio" then
		return {
			{ name = "validate_audio_request", description = "Validate audio parameters" },
			{ name = "call_suno_api", description = "Generate via Suno AI" },
			{ name = "upload_audio", description = "Upload as Audio asset" },
		}
	end
	return {}
end

function AIPipelineService._ExecuteStep(step: any, pipeline: any): any
	if step.name == "validate_prompt" then
		local prompt = pipeline.params.prompt
		if type(prompt) ~= "string" or #prompt < 3 then
			return { abort = true, reason = "Prompt too short" }
		end
		return { validated = true }
	elseif step.name == "call_meshy_api" then
		local apiKey = AIPipelineService._GetApiKey("MESHY_API_KEY")
		if not apiKey then
			return { abort = true, reason = "Meshy API key not configured" }
		end
		local config = { ApiKey = apiKey }
		local result = MCPBridge._Request(
			"POST",
			"https://api.meshy.ai/v1/image-to-3d",
			{
				Authorization = "Bearer " .. apiKey,
				["Content-Type"] = "application/json",
			},
			HttpService:JSONEncode({
				image_url = pipeline.params.imageUrl,
				prompt = pipeline.params.prompt,
			})
		)
		return result
	elseif step.name == "call_deepmotion_api" then
		local apiKey = AIPipelineService._GetApiKey("DEEPMOTION_API_KEY")
		if not apiKey then
			return { abort = true, reason = "DeepMotion API key not configured" }
		end
		local config = { ApiKey = apiKey }
		local result = MCPBridge._Request(
			"POST",
			"https://api.deepmotion.com/v1/animations",
			{
				Authorization = "Bearer " .. apiKey,
				["Content-Type"] = "application/json",
			},
			HttpService:JSONEncode({
				video_url = pipeline.params.videoUrl,
			})
		)
		return result
	elseif step.name == "call_suno_api" then
		local apiKey = AIPipelineService._GetApiKey("SUNO_API_KEY")
		if not apiKey then
			return { abort = true, reason = "Suno API key not configured" }
		end
		local result = MCPBridge._Request(
			"POST",
			"https://api.suno.ai/v1/generate",
			{
				Authorization = "Bearer " .. apiKey,
				["Content-Type"] = "application/json",
			},
			HttpService:JSONEncode({
				prompt = pipeline.params.prompt,
				duration = pipeline.params.duration or 30,
			})
		)
		return result
	elseif step.name == "upload_to_roblox" or step.name == "upload_keyframe" or step.name == "upload_audio" then
		local apiKey = AIPipelineService._GetApiKey("OPEN_CLOUD_API_KEY")
		if not apiKey then
			return { abort = true, reason = "Open Cloud API key not configured" }
		end
		local result = MCPBridge._Request(
			"POST",
			"https://apis.roblox.com/assets/v1/assets",
			{
				["x-api-key"] = apiKey,
				["Content-Type"] = "application/json",
			},
			HttpService:JSONEncode({
				assetType = "Model",
				displayName = pipeline.params.name or "AI Generated Asset",
			})
		)
		return result
	elseif step.name == "retarget_rig" then
		print(string.format("[AIPipelineService] Retargeting animation for pipeline %s", pipeline.id))
		return { retargeted = true }
	elseif step.name == "notify_complete" then
		AIPipelineService._BroadcastPipelineStatus(pipeline)
		return { notified = true }
	elseif step.name == "validate_motion" or step.name == "validate_audio_request" then
		return { validated = true }
	end

	return { abort = true, reason = "Unknown step: " .. step.name }
end

function AIPipelineService._CompletePipeline(pipeline: any, result: any?, error: string?)
	pipeline.status = if error then "failed" else "completed"
	pipeline.result = result
	pipeline.error = error
	pipeline.completedAt = os.time()

	AIPipelineService._BroadcastPipelineStatus(pipeline)
	AIPipelineService._PublishCrossServerUpdate(pipeline)
end

function AIPipelineService._BroadcastPipelineStatus(pipeline: any)
	local remote = NetChannels.GetRemoteEvent("Pipeline_Status")
	if not remote or not pipeline.player then
		return
	end

	remote:FireClient(pipeline.player, {
		pipelineId = pipeline.id,
		status = pipeline.status,
		currentStep = pipeline.currentStep,
		totalSteps = #pipeline.steps,
		currentStepName = pipeline.steps[pipeline.currentStep] and pipeline.steps[pipeline.currentStep].name,
		error = pipeline.error,
		result = pipeline.result,
	})
end

function AIPipelineService._HandleCrossServerUpdate(data: { [string]: any })
	local pipelineId = data.pipelineId :: string
	local status = data.status :: string
	local existing = ACTIVE_PIPELINES[pipelineId]
	if existing then
		existing.status = status
		existing.crossServerUpdate = data
	end
end

function AIPipelineService._PublishCrossServerUpdate(pipeline: any)
	pcall(function()
		MessagingService:PublishAsync(PIPELINE_TOPIC, {
			pipelineId = pipeline.id,
			status = pipeline.status,
			type = pipeline.type,
			timestamp = os.time(),
		})
	end)
end

function AIPipelineService._GetApiKey(keyName: string): string?
	local success, result = pcall(function()
		return game:GetAttribute(keyName)
	end)
	if success and type(result) == "string" and #result > 0 then
		return result
	end
	return nil
end

return AIPipelineService
