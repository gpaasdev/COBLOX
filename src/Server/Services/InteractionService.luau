--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local PayloadValidator = require(ReplicatedStorage.Shared.Network.PayloadValidator)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)
local PlayerDataService = require(ServerScriptService.Server.Services.PlayerDataService)
local RateLimitService = require(ServerScriptService.Server.Services.RateLimitService)

local InteractionService = {}
InteractionService.Name = "InteractionService"

-- Stores active grab maids per player
local activeGrabs: { [Player]: any } = {}
local MAX_GRAB_DISTANCE = 15

function InteractionService.Init()
	print("[InteractionService] Initializing Dynamic Physics Interaction Engine...")
end

function InteractionService.Start()
	local grabRemote = NetChannels.GetRemoteFunction("RequestGrab")
	local dropRemote = NetChannels.GetRemoteFunction("RequestDrop")
	local throwRemote = NetChannels.GetRemoteFunction("RequestThrow")

	if grabRemote then
		grabRemote.OnServerInvoke = InteractionService._OnRequestGrab
	end
	if dropRemote then
		dropRemote.OnServerInvoke = InteractionService._OnRequestDrop
	end
	if throwRemote then
		throwRemote.OnServerInvoke = InteractionService._OnRequestThrow
	end

	Players.PlayerRemoving:Connect(function(player)
		if activeGrabs[player] then
			activeGrabs[player]:Destroy()
			activeGrabs[player] = nil
		end
	end)
end

function InteractionService._CheckMassCapacity(player: Player, targetPart: BasePart): boolean
	local res = PlayerDataService.GetProfile(player)
	-- Default capacity: RebirthTokens/Level can increase it.
	-- If base is 50, and 1 token = 10 capacity.
	local capacity = 50 
	if res.Success and res.Data and res.Data.Wallet then
		capacity = capacity + ((res.Data.Wallet.RebirthTokens or 0) * 10)
	end

	-- Mass limit check
	return targetPart.Mass <= capacity
end

function InteractionService._OnRequestGrab(player: Player, targetPart: BasePart): { Success: boolean, Message: string }
	if not RateLimitService.CheckRateLimit(player, "RequestGrab", 0.5) then
		return { Success = false, Message = "Rate limited" }
	end

	-- Validation
	if typeof(targetPart) ~= "Instance" or not targetPart:IsA("BasePart") then
		return { Success = false, Message = "Invalid target" }
	end

	local char = player.Character
	if not char or not char.PrimaryPart then
		return { Success = false, Message = "Character missing" }
	end

	-- Spatial Validation
	local dist = (char.PrimaryPart.Position - targetPart.Position).Magnitude
	if dist > MAX_GRAB_DISTANCE then
		return { Success = false, Message = "Too far away" }
	end

	-- Ensure it's not already held by someone
	if targetPart:GetNetworkOwner() ~= nil then
		return { Success = false, Message = "Object is currently held by someone else" }
	end

	-- Mass Check
	if not InteractionService._CheckMassCapacity(player, targetPart) then
		return { Success = false, Message = "Object too heavy!" }
	end

	-- Clear previous grab if any
	if activeGrabs[player] then
		activeGrabs[player]:Destroy()
	end

	local maid = Maid.new()
	activeGrabs[player] = maid

	-- Network Ownership to player
	targetPart:SetNetworkOwner(player)

	-- Constraints setup
	local rootAttachment = Instance.new("Attachment")
	rootAttachment.Name = "HoldAttachment"
	-- Default front of the player. Client will update this position.
	rootAttachment.CFrame = CFrame.new(0, 0, -4) 
	rootAttachment.Parent = char.PrimaryPart
	maid:GiveTask(rootAttachment)

	local partAttachment = Instance.new("Attachment")
	partAttachment.Name = "ObjectHoldAttachment"
	partAttachment.Parent = targetPart
	maid:GiveTask(partAttachment)

	local alignPos = Instance.new("AlignPosition")
	alignPos.Attachment0 = partAttachment
	alignPos.Attachment1 = rootAttachment
	alignPos.Responsiveness = 150
	alignPos.MaxForce = math.huge
	alignPos.Parent = targetPart
	maid:GiveTask(alignPos)

	local alignOri = Instance.new("AlignOrientation")
	alignOri.Attachment0 = partAttachment
	alignOri.Attachment1 = rootAttachment
	alignOri.Responsiveness = 150
	alignOri.MaxTorque = math.huge
	alignOri.Parent = targetPart
	maid:GiveTask(alignOri)

	-- Custom NoCollisionConstraint between player and held object
	local noCollide = Instance.new("NoCollisionConstraint")
	noCollide.Part0 = char.PrimaryPart
	noCollide.Part1 = targetPart
	noCollide.Parent = targetPart
	maid:GiveTask(noCollide)
	
	-- Clean up network ownership when maid is destroyed
	maid:GiveTask(function()
		if targetPart and targetPart.Parent then
			targetPart:SetNetworkOwnershipAuto()
		end
	end)

	print(string.format("[InteractionService] %s grabbed %s", player.Name, targetPart.Name))
	return { Success = true, Message = "Grabbed" }
end

function InteractionService._OnRequestDrop(player: Player): { Success: boolean, Message: string }
	if not RateLimitService.CheckRateLimit(player, "RequestDrop", 0.5) then
		return { Success = false, Message = "Rate limited" }
	end

	if activeGrabs[player] then
		activeGrabs[player]:Destroy()
		activeGrabs[player] = nil
		return { Success = true, Message = "Dropped" }
	end
	
	return { Success = false, Message = "Nothing to drop" }
end

function InteractionService._OnRequestThrow(player: Player, chargePower: number): { Success: boolean, Message: string }
	if not RateLimitService.CheckRateLimit(player, "RequestThrow", 0.5) then
		return { Success = false, Message = "Rate limited" }
	end
	
	local ok, validCharge = PayloadValidator.Validate({chargePower}, {"number"})
	if not ok then return { Success = false, Message = "Invalid payload" } end

	local maid = activeGrabs[player]
	if not maid then
		return { Success = false, Message = "Nothing to throw" }
	end

	-- Extract the part before destroying constraints
	local targetPart = nil
	for _, task in pairs(maid._tasks) do
		if typeof(task) == "Instance" and task:IsA("Attachment") and task.Parent and task.Name == "ObjectHoldAttachment" then
			targetPart = task.Parent
			break
		end
	end

	local char = player.Character

	-- Destroy maid to free the object
	maid:Destroy()
	activeGrabs[player] = nil

	if targetPart and targetPart:IsA("BasePart") and char and char.PrimaryPart then
		-- Physics Math: Apply impulse
		local mass = targetPart.Mass
		-- chargePower is clamped between 0 and 1 from the client
		local throwPower = math.clamp(validCharge, 0, 1)
		
		-- p = mv
		-- base velocity desired is ~50 studs/sec for max throw
		local desiredVelocity = 50 * throwPower
		local impulseVector = char.PrimaryPart.CFrame.LookVector * (mass * desiredVelocity) + Vector3.new(0, mass * 15 * throwPower, 0)
		
		targetPart:ApplyImpulse(impulseVector)
		print(string.format("[InteractionService] %s threw %s with charge %f", player.Name, targetPart.Name, throwPower))
	end

	return { Success = true, Message = "Thrown" }
end

return InteractionService
