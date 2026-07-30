--!strict

local Maid = require(game:GetService("ReplicatedStorage").Shared.Utility.Maid)

local AvatarRiggingFixer = {}

function AvatarRiggingFixer.AddAccessoryPhysics(character: Model, accessories: { BasePart }): Maid
	local maid = Maid.new()
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then
		return maid
	end

	local rootPart = character:FindFirstChild("HumanoidRootPart")
	if not rootPart then
		return maid
	end

	local lastVelocity = Vector3.new()

	maid:GiveTask(game:GetService("RunService").Heartbeat:Connect(function()
		if not character.Parent then
			return
		end

		local currentVelocity = rootPart.AssemblyLinearVelocity
		local accel = currentVelocity - lastVelocity
		lastVelocity = currentVelocity

		local speed = currentVelocity.Magnitude
		local normalizedVel = if speed > 0.1 then currentVelocity / speed else Vector3.new()

		for _, part in ipairs(accessories) do
			if not part.Parent then
				continue
			end

			local swayOffset = Vector3.new(-normalizedVel.X * 0.3, math.abs(accel.Y) * -0.02, math.abs(accel.X) * 0.02)

			local basePos = rootPart.Position + Vector3.new(0, -1, 0)
			part.Position = basePos + swayOffset
		end
	end))

	return maid
end

function AvatarRiggingFixer.AttachHangingAccessory(
	character: Model,
	meshPart: MeshPart,
	attachmentPoint: string,
	anchorOffset: Vector3
): Maid
	local maid = Maid.new()
	local targetPart = character:FindFirstChild(attachmentPoint, true)
	if not targetPart or not targetPart:IsA("BasePart") then
		return maid
	end

	meshPart.Anchored = false
	meshPart.CanCollide = false
	meshPart.Parent = character

	local attachment0 = Instance.new("Attachment")
	attachment0.Name = "AccessoryAnchor"
	attachment0.Position = anchorOffset
	attachment0.Parent = targetPart

	local attachment1 = Instance.new("Attachment")
	attachment1.Name = "AccessoryAttach"
	attachment1.Parent = meshPart

	local spring = Instance.new("SpringConstraint")
	spring.Attachment0 = attachment0
	spring.Attachment1 = attachment1
	spring.Stiffness = 0.5
	spring.Damping = 0.8
	spring.FreeLength = 1
	spring.MaxForce = 5000
	spring.Parent = targetPart

	maid:GiveTask(spring)
	maid:GiveTask(attachment0)
	maid:GiveTask(attachment1)
	maid:GiveTask(meshPart)

	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if humanoid then
		maid:GiveTask(humanoid.Running:Connect(function(speed: number)
			spring.Stiffness = if speed > 8 then 0.3 else 0.5
			spring.Damping = if speed > 8 then 0.6 else 0.8
		end))
	end

	return maid
end

function AvatarRiggingFixer.AttachPhysicsAccessory(
	character: Model,
	meshPart: MeshPart,
	attachmentPartName: string
): Maid
	local maid = Maid.new()
	local targetPart = character:FindFirstChild(attachmentPartName, true)
	if not targetPart or not targetPart:IsA("BasePart") then
		return maid
	end

	meshPart.Anchored = false
	meshPart.CanCollide = false
	meshPart.Parent = character

	local weld = Instance.new("WeldConstraint")
	weld.Name = "PhysicsWeld_" .. meshPart.Name
	weld.Part0 = targetPart
	weld.Part1 = meshPart
	weld.Parent = meshPart

	maid:GiveTask(weld)
	maid:GiveTask(meshPart)

	return maid
end

return AvatarRiggingFixer
