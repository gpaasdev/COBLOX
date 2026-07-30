--!strict

local R6ToR15Adapter = {}

export type BoneMapping = {
	R6Name: string,
	R15Name: string,
	JointType: "Motor6D" | "Weld",
	Parent: string,
}

local BONE_MAP: { BoneMapping } = {
	{ R6Name = "Head", R15Name = "Head", JointType = "Motor6D", Parent = "UpperTorso" },
	{ R6Name = "Torso", R15Name = "UpperTorso", JointType = "Motor6D", Parent = "LowerTorso" },
	{ R6Name = nil, R15Name = "LowerTorso", JointType = "Motor6D", Parent = "HumanoidRootPart" },
	{ R6Name = "Left Arm", R15Name = "LeftUpperArm", JointType = "Motor6D", Parent = "UpperTorso" },
	{ R6Name = nil, R15Name = "LeftLowerArm", JointType = "Motor6D", Parent = "LeftUpperArm" },
	{ R6Name = nil, R15Name = "LeftHand", JointType = "Motor6D", Parent = "LeftLowerArm" },
	{ R6Name = "Right Arm", R15Name = "RightUpperArm", JointType = "Motor6D", Parent = "UpperTorso" },
	{ R6Name = nil, R15Name = "RightLowerArm", JointType = "Motor6D", Parent = "RightUpperArm" },
	{ R6Name = nil, R15Name = "RightHand", JointType = "Motor6D", Parent = "RightLowerArm" },
	{ R6Name = "Left Leg", R15Name = "LeftUpperLeg", JointType = "Motor6D", Parent = "LowerTorso" },
	{ R6Name = nil, R15Name = "LeftLowerLeg", JointType = "Motor6D", Parent = "LeftUpperLeg" },
	{ R6Name = nil, R15Name = "LeftFoot", JointType = "Motor6D", Parent = "LeftLowerLeg" },
	{ R6Name = "Right Leg", R15Name = "RightUpperLeg", JointType = "Motor6D", Parent = "LowerTorso" },
	{ R6Name = nil, R15Name = "RightLowerLeg", JointType = "Motor6D", Parent = "RightUpperLeg" },
	{ R6Name = nil, R15Name = "RightFoot", JointType = "Motor6D", Parent = "RightLowerLeg" },
}

local R15_PART_SIZE = {
	Head = Vector3.new(2, 1, 1.5),
	UpperTorso = Vector3.new(2, 1.5, 1.5),
	LowerTorso = Vector3.new(2, 1, 1.5),
	LeftUpperArm = Vector3.new(0.75, 1.5, 0.75),
	LeftLowerArm = Vector3.new(0.75, 1.25, 0.75),
	LeftHand = Vector3.new(0.75, 0.5, 0.5),
	RightUpperArm = Vector3.new(0.75, 1.5, 0.75),
	RightLowerArm = Vector3.new(0.75, 1.25, 0.75),
	RightHand = Vector3.new(0.75, 0.5, 0.5),
	LeftUpperLeg = Vector3.new(1, 1.5, 1),
	LeftLowerLeg = Vector3.new(1, 1.25, 1),
	LeftFoot = Vector3.new(1, 0.5, 1.5),
	RightUpperLeg = Vector3.new(1, 1.5, 1),
	RightLowerLeg = Vector3.new(1, 1.25, 1),
	RightFoot = Vector3.new(1, 0.5, 1.5),
	HumanoidRootPart = Vector3.new(2, 2, 1),
}

function R6ToR15Adapter.GetBoneMapping(): { BoneMapping }
	return BONE_MAP
end

function R6ToR15Adapter.MapR6ToR15(r6Name: string): string?
	for _, mapping in ipairs(BONE_MAP) do
		if mapping.R6Name == r6Name then
			return mapping.R15Name
		end
	end
	return nil
end

function R6ToR15Adapter.MapR15ToR6(r15Name: string): string?
	for _, mapping in ipairs(BONE_MAP) do
		if mapping.R15Name == r15Name then
			return mapping.R6Name
		end
	end
	return nil
end

function R6ToR15Adapter.ConvertRig(r6Model: Model): Model?
	if not r6Model then
		return nil
	end

	local r6Parts: { [string]: BasePart? } = {}
	for _, bone in ipairs(BONE_MAP) do
		if bone.R6Name then
			r6Parts[bone.R6Name] = r6Model:FindFirstChild(bone.R6Name, true) :: BasePart?
		end
	end

	local r15Model = Instance.new("Model")
	r15Model.Name = r6Model.Name .. "_R15"

	local originalHumanoid = r6Model:FindFirstChildOfClass("Humanoid")
	local humanoidRootPart = r6Model:FindFirstChild("HumanoidRootPart")

	local newParts: { [string]: BasePart } = {}
	local seenParts: { [BasePart]: boolean } = {}

	for _, mapping in ipairs(BONE_MAP) do
		local r6Part = mapping.R6Name and r6Parts[mapping.R6Name]
		local partName = mapping.R15Name
		local partSize = R15_PART_SIZE[partName] or Vector3.new(1, 1, 1)

		local part: BasePart
		if r6Part and not seenParts[r6Part] then
			part = r6Part:Clone()
			part.Name = partName
			part.Size = partSize
			seenParts[r6Part] = true
			r6Part.Transparency = 1
		else
			part = Instance.new("Part")
			part.Name = partName
			part.Size = partSize
			part.Shape = Enum.PartType.Block
			part.Anchored = false
			part.CanCollide = false
			part.BrickColor = r6Parts["Torso"] and r6Parts["Torso"].BrickColor or BrickColor.new("Bright blue")
		end

		part.Parent = r15Model
		newParts[partName] = part
	end

	for _, mapping in ipairs(BONE_MAP) do
		local part = newParts[mapping.R15Name]
		local parentPart = newParts[mapping.Parent]
		if not part or not parentPart then
			continue
		end

		local joint = Instance.new("Motor6D")
		joint.Name = mapping.R15Name
		joint.Part0 = parentPart
		joint.Part1 = part

		if mapping.R15Name == "Head" then
			joint.C0 = CFrame.new(0, 1.5, 0)
			joint.C1 = CFrame.new(0, 0.5, 0)
		elseif mapping.R15Name == "UpperTorso" then
			joint.C0 = CFrame.new(0, 0.5, 0)
			joint.C1 = CFrame.new(0, -0.5, 0)
		elseif string.find(mapping.R15Name, "UpperArm") then
			local isRight = string.find(mapping.R15Name, "Right") ~= nil
			joint.C0 = CFrame.new(if isRight then 1.5 else -1.5, 0.5, 0)
			joint.C1 = CFrame.new(0, 0.75, 0)
		elseif string.find(mapping.R15Name, "LowerArm") or string.find(mapping.R15Name, "LowerLeg") then
			joint.C0 = CFrame.new(0, -0.75, 0)
			joint.C1 = CFrame.new(0, 0.625, 0)
		elseif mapping.R15Name == "LeftHand" or mapping.R15Name == "RightHand" then
			joint.C0 = CFrame.new(0, -0.625, 0)
			joint.C1 = CFrame.new(0, 0.25, 0)
		elseif string.find(mapping.R15Name, "UpperLeg") then
			local isRight = string.find(mapping.R15Name, "Right") ~= nil
			joint.C0 = CFrame.new(if isRight then 0.75 else -0.75, -0.5, 0)
			joint.C1 = CFrame.new(0, 0.75, 0)
		elseif mapping.R15Name == "LeftFoot" or mapping.R15Name == "RightFoot" then
			joint.C0 = CFrame.new(0, -0.625, 0)
			joint.C1 = CFrame.new(0, 0.25, -0.25)
		end

		joint.Parent = parentPart
	end

	if not humanoidRootPart then
		local rootPart = Instance.new("Part")
		rootPart.Name = "HumanoidRootPart"
		rootPart.Size = R15_PART_SIZE.HumanoidRootPart
		rootPart.Anchored = false
		rootPart.CanCollide = false
		rootPart.Transparency = 1
		rootPart.Parent = r15Model

		local rootJoint = Instance.new("Motor6D")
		rootJoint.Name = "RootJoint"
		rootJoint.Part0 = rootPart
		rootJoint.Part1 = newParts.LowerTorso
		rootJoint.C0 = CFrame.new(0, 0, 0)
		rootJoint.C1 = CFrame.new(0, 0, 0)
		rootJoint.Parent = rootPart
		newParts.HumanoidRootPart = rootPart
	end

	if originalHumanoid then
		local newHumanoid = Instance.new("Humanoid")
		newHumanoid.Name = "Humanoid"
		newHumanoid.RigType = Enum.HumanoidRigType.R15
		if originalHumanoid.DisplayName then
			newHumanoid.DisplayName = originalHumanoid.DisplayName
		end
		newHumanoid.Parent = r15Model
	end

	return r15Model
end

function R6ToR15Adapter.RetargetKeyframes(keyframes: { any }): { any }
	local retargeted = {}
	for _, kf in ipairs(keyframes) do
		local pose = kf.Pose
		if not pose then
			continue
		end

		local r15Name = R6ToR15Adapter.MapR6ToR15(kf.Name)
		if r15Name then
			local newPose = pose:Clone()
			newPose.Name = r15Name
			table.insert(retargeted, {
				Name = r15Name,
				Pose = newPose,
				Time = kf.Time,
			})
		end
	end
	return retargeted
end

return R6ToR15Adapter
