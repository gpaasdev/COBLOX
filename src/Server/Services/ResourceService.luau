--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local ResourceConfig = require(Shared:WaitForChild("Configuration"):WaitForChild("ResourceConfig"))
local NetChannels = require(Shared:WaitForChild("Network"):WaitForChild("NetChannels"))

local ResourceService = {}
ResourceService.__index = ResourceService

local activeNodes: { [string]: { NodeId: string, CurrentHealth: number, Position: Vector3, IsDepleted: boolean } } = {}
local playerLastHarvestTime: { [number]: number } = {}

function ResourceService.Init()
	print("[ResourceService] Initializing Server-Authoritative Zero-Trust Resource Manager...")

	-- Setup Network Listeners
	local harvestRemote = NetChannels.GetRemoteEvent("HarvestResourceRequest")
	if harvestRemote then
		harvestRemote.OnServerEvent:Connect(function(player: Player, payload: any)
			ResourceService.ProcessHarvestRequest(player, payload)
		end)
	end
end

function ResourceService.RegisterNode(instanceId: string, nodeId: string, position: Vector3)
	local def = ResourceConfig.Nodes[nodeId]
	if not def then
		warn("[ResourceService] Invalid NodeId registered:", nodeId)
		return
	end

	activeNodes[instanceId] = {
		NodeId = nodeId,
		CurrentHealth = def.MaxHealth,
		Position = position,
		IsDepleted = false,
	}
end

function ResourceService.ProcessHarvestRequest(player: Player, payload: any)
	if typeof(payload) ~= "table" or typeof(payload.NodeInstanceId) ~= "string" or typeof(payload.HitPosition) ~= "Vector3" then
		warn("[ResourceService] Invalid payload received from player:", player.Name)
		return
	end

	local instanceId = payload.NodeInstanceId
	local hitPos = payload.HitPosition
	local nodeState = activeNodes[instanceId]

	if not nodeState or nodeState.IsDepleted then
		return
	end

	local nodeDef = ResourceConfig.Nodes[nodeState.NodeId]
	if not nodeDef then return end

	-- 1. Zero-Trust Security: Rate Limit Check (max 2 hits/sec)
	local now = os.clock()
	local lastHit = playerLastHarvestTime[player.UserId] or 0
	if now - lastHit < 0.4 then
		warn("[ResourceService] Rate limit exceeded for player:", player.Name)
		return
	end
	playerLastHarvestTime[player.UserId] = now

	-- 2. Zero-Trust Security: Physical Distance Check (<= 15 studs)
	local character = player.Character
	if not character or not character:FindFirstChild("HumanoidRootPart") then return end
	local rootPart = character.HumanoidRootPart :: BasePart
	local distance = (rootPart.Position - nodeState.Position).Magnitude
	if distance > 15 then
		warn(string.format("[ResourceService] Security Alert: Distance violation (%f studs) by %s", distance, player.Name))
		return
	end

	-- 3. Zero-Trust Security: Line of Sight Check (Raycast)
	local raycastParams = RaycastParams.new()
	raycastParams.FilterDescendantsInstances = { character }
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude

	local rayResult = workspace:Raycast(rootPart.Position, (nodeState.Position - rootPart.Position), raycastParams)
	if rayResult and rayResult.Instance and not rayResult.Instance:IsDescendantOf(workspace) then
		warn("[ResourceService] Security Alert: Line of Sight blocked for player:", player.Name)
		return
	end

	-- Deduct Health
	nodeState.CurrentHealth -= 1

	local isDepleted = nodeState.CurrentHealth <= 0
	if isDepleted then
		nodeState.IsDepleted = true

		-- Calculate Loot
		local itemsObtained: { [string]: number } = {}
		local yieldMultiplier = 1.0 -- Can be fetched from Player's equipped tool & pet luck bonus

		for _, loot in ipairs(nodeDef.LootTable) do
			local roll = math.random(1, 100)
			if roll <= loot.Chance then
				local baseQty = math.random(loot.MinQuantity, loot.MaxQuantity)
				local finalQty = math.floor(baseQty * yieldMultiplier)
				itemsObtained[loot.ItemId] = (itemsObtained[loot.ItemId] or 0) + math.max(1, finalQty)
			end
		end

		print(string.format("[ResourceService] Player %s harvested %s successfully!", player.Name, nodeDef.Name))

		-- Notify Client of Success
		local responseRemote = NetChannels.GetRemoteEvent("HarvestResourceResponse")
		if responseRemote then
			responseRemote:FireClient(player, {
				Success = true,
				NodeInstanceId = instanceId,
				ItemsObtained = itemsObtained,
			})
		end

		-- Broadcast Node State Change (Depleted)
		local stateRemote = NetChannels.GetRemoteEvent("ResourceStateChanged")
		if stateRemote then
			stateRemote:FireAllClients({
				NodeInstanceId = instanceId,
				IsDepleted = true,
			})
		end

		-- Schedule Respawn
		task.delay(nodeDef.RespawnTime, function()
			nodeState.CurrentHealth = nodeDef.MaxHealth
			nodeState.IsDepleted = false

			if stateRemote then
				stateRemote:FireAllClients({
					NodeInstanceId = instanceId,
					IsDepleted = false,
				})
			end
		end)
	end
end

return ResourceService
