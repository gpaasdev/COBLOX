--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local Camera = Workspace.CurrentCamera
local BlockConfig = require(ReplicatedStorage.Shared.Configuration.BlockConfig)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local BlockBuilderController = {}
BlockBuilderController.Name = "BlockBuilderController"

local GetPlaceBlockRemotes = ReplicatedStorage:FindFirstChild("BlockBuilder_Request") :: RemoteFunction
local selectedBlockType = "Stone"
local ghostPart: Part? = nil
local isBuilding = false
local snapSize = BlockConfig.Grid.SnapSize

local function createGhost()
	if ghostPart then ghostPart:Destroy() end
	ghostPart = Instance.new("Part")
	ghostPart.Size = Vector3.new(snapSize, snapSize, snapSize)
	ghostPart.Anchored = true
	ghostPart.CanCollide = false
	ghostPart.Transparency = 0.5
	ghostPart.Material = Enum.Material.Glass
	ghostPart.Color = Color3.fromRGB(56, 189, 248)
	ghostPart.Parent = Workspace
end

local function snapPosition(position: Vector3): Vector3
	local x = math.floor(position.X / snapSize + 0.5) * snapSize
	local y = math.floor(position.Y / snapSize + 0.5) * snapSize
	local z = math.floor(position.Z / snapSize + 0.5) * snapSize
	return Vector3.new(x, y, z)
end

local function getTargetPosition(): Vector3?
	local mouse = Players.LocalPlayer:GetMouse()
	local unitRay = Camera:ViewportPointToRay(mouse.X, mouse.Y)
	local raycastResult = Workspace:Raycast(unitRay.Origin, unitRay.Direction * 500)
	if raycastResult then
		return snapPosition(raycastResult.Position + raycastResult.Normal * (snapSize / 2))
	end
	return nil
end

function BlockBuilderController.ToggleBuildMode()
	isBuilding = not isBuilding
	if isBuilding then
		createGhost()
	else
		if ghostPart then
			ghostPart:Destroy()
			ghostPart = nil
		end
	end
end

function BlockBuilderController.SetBlockType(blockType: string)
	if BlockConfig.Palette[blockType] then
		selectedBlockType = blockType
		if ghostPart and BlockConfig.Palette[blockType] then
			local def = BlockConfig.Palette[blockType]
			ghostPart.Color = def.Color
			ghostPart.Material = def.Material
		end
	end
end

function BlockBuilderController.Init()
	self.maid = Maid.new()
	self.maid:GiveTask(RunService.RenderStepped:Connect(function()
		if not isBuilding or not ghostPart then return end
		local pos = getTargetPosition()
		if pos then
			ghostPart.Position = pos
			ghostPart.Visible = true
		else
			ghostPart.Visible = false
		end
	end))

	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed or not isBuilding then return end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local pos = getTargetPosition()
			if pos then
				task.spawn(function()
					local success, err = GetPlaceBlockRemotes:InvokeServer("PlaceBlock", selectedBlockType, pos)
				end)
			end
		elseif input.UserInputType == Enum.UserInputType.MouseButton2 then
			local pos = getTargetPosition()
			if pos then
				task.spawn(function()
					GetPlaceBlockRemotes:InvokeServer("RemoveBlock", pos)
				end)
			end
		elseif input.KeyCode == Enum.KeyCode.B then
			BlockBuilderController.ToggleBuildMode()
		end
	end))
end

return BlockBuilderController
