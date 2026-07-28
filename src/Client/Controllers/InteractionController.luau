--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local InteractionController = {}
InteractionController.Name = "InteractionController"

local MAX_GRAB_DISTANCE = 15
local CAMERA = workspace.CurrentCamera

local isHolding = false
local currentTarget: BasePart? = nil
local chargeStartTime = 0

local controllerMaid = Maid.new()

function InteractionController.Init()
	print("[InteractionController] Initializing Client Dynamic Physics Interaction Engine...")
end

function InteractionController.Start()
	ContextActionService:BindAction(
		"InteractAction",
		InteractionController._HandleInput,
		false,
		Enum.UserInputType.MouseButton1,
		Enum.KeyCode.E
	)
end

function InteractionController._HandleInput(
	actionName: string,
	inputState: Enum.UserInputState,
	inputObject: InputObject
)
	if inputState == Enum.UserInputState.Begin then
		if isHolding then
			-- Start charge throw
			chargeStartTime = tick()
		else
			-- Try Grab
			InteractionController._TryGrab()
		end
	elseif inputState == Enum.UserInputState.End then
		if isHolding and chargeStartTime > 0 then
			-- Execute throw
			local chargeDuration = tick() - chargeStartTime
			local maxChargeTime = 2.0
			local throwPower = math.clamp(chargeDuration / maxChargeTime, 0.2, 1.0)

			if chargeDuration < 0.2 then
				-- Just a quick toss/drop
				InteractionController._RequestThrow(0.1)
			else
				InteractionController._RequestThrow(throwPower)
			end
			chargeStartTime = 0
		end
	end
end

function InteractionController._TryGrab()
	local mousePos = game:GetService("UserInputService"):GetMouseLocation()
	local rayRadius = CAMERA:ViewportPointToRay(mousePos.X, mousePos.Y)

	local raycastParams = RaycastParams.new()
	raycastParams.FilterType = Enum.RaycastFilterType.Exclude
	raycastParams.FilterDescendantsInstances = { Players.LocalPlayer.Character }

	local raycastResult = workspace:Raycast(rayRadius.Origin, rayRadius.Direction * MAX_GRAB_DISTANCE, raycastParams)

	if raycastResult and raycastResult.Instance then
		local part = raycastResult.Instance
		if CollectionService:HasTag(part, "Interactable") then
			local grabRemote = NetChannels.GetRemoteFunction("RequestGrab")
			if grabRemote then
				local res = grabRemote:InvokeServer(part)
				if res and res.Success then
					isHolding = true
					currentTarget = part
					InteractionController._StartHoldingLoop()
				else
					print("Grab failed:", res and res.Message)
				end
			end
		end
	end
end

function InteractionController._RequestThrow(chargePower: number)
	local throwRemote = NetChannels.GetRemoteFunction("RequestThrow")
	if throwRemote then
		local res = throwRemote:InvokeServer(chargePower)
		if res and res.Success then
			isHolding = false
			currentTarget = nil
			controllerMaid:DoCleaning()
		end
	end
end

function InteractionController._StartHoldingLoop()
	local char = Players.LocalPlayer.Character
	if not char or not char.PrimaryPart then
		return
	end

	local holdAttachment = char.PrimaryPart:WaitForChild("HoldAttachment", 5) :: Attachment
	if not holdAttachment then
		return
	end

	-- 1. Setup Client Camera Tracking
	controllerMaid:GiveTask(RunService.RenderStepped:Connect(function()
		if isHolding and currentTarget then
			local lookVector = CAMERA.CFrame.LookVector
			local offset = Vector3.new(0, 0, -4) -- 4 studs in front

			-- We update the attachment CFrame based on camera view
			-- Since attachment is inside HumanoidRootPart, we need to map World to Object space
			local targetWorldPos = CAMERA.CFrame.Position + (lookVector * 6)
			holdAttachment.WorldCFrame = CFrame.new(targetWorldPos) * CFrame.Angles(0, CAMERA.CFrame.Rotation.Y, 0)
		end
	end))

	-- 2. Setup Inverse Kinematics (IK) for realism
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		local ikControl = Instance.new("IKControl")
		ikControl.Name = "InteractionIK"
		ikControl.Type = Enum.IKControlType.Transform
		ikControl.EndEffector = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
		ikControl.ChainRoot = char:FindFirstChild("RightUpperArm") or char:FindFirstChild("Right Arm")
		ikControl.Target = currentTarget
		ikControl.Weight = 0.8
		ikControl.Parent = humanoid

		controllerMaid:GiveTask(ikControl)

		-- Also for Left Arm (Optional based on R6 vs R15)
		local ikControlLeft = Instance.new("IKControl")
		ikControlLeft.Name = "InteractionIKLeft"
		ikControlLeft.Type = Enum.IKControlType.Transform
		ikControlLeft.EndEffector = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
		ikControlLeft.ChainRoot = char:FindFirstChild("LeftUpperArm") or char:FindFirstChild("Left Arm")
		ikControlLeft.Target = currentTarget
		ikControlLeft.Weight = 0.8
		ikControlLeft.Parent = humanoid

		controllerMaid:GiveTask(ikControlLeft)
	end
end

return InteractionController
