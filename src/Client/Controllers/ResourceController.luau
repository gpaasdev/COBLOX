--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Shared = ReplicatedStorage:WaitForChild("Shared")
local NetChannels = require(Shared:WaitForChild("Network"):WaitForChild("NetChannels"))

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local ResourceController = {}
ResourceController.__index = ResourceController

local localPlayer = Players.LocalPlayer

function ResourceController.Init(self)
	print("[ResourceController] Initializing Client Resource Interaction & Visual Controller...")
	self.maid = Maid.new()

	local responseRemote = NetChannels.GetRemoteEvent("HarvestResourceResponse")
	if responseRemote then
		self.maid:GiveTask(responseRemote.OnClientEvent:Connect(function(payload: any)
			ResourceController.OnHarvestResponse(payload)
		end))
	end
end

function ResourceController.RequestHarvest(nodeInstanceId: string, hitPosition: Vector3)
	local harvestRemote = NetChannels.GetRemoteEvent("HarvestResourceRequest")
	if harvestRemote then
		harvestRemote:FireServer({
			NodeInstanceId = nodeInstanceId,
			HitPosition = hitPosition,
		})
	end
end

function ResourceController.PlayHitAnimation(self, nodePart: BasePart)
	if not nodePart then
		return
	end

	local originalSize = nodePart.Size
	local expandTween =
		TweenService:Create(nodePart, TweenInfo.new(0.08, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = originalSize * 1.15,
		})

	local resetTween =
		TweenService:Create(nodePart, TweenInfo.new(0.15, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
			Size = originalSize,
		})

	expandTween:Play()
	self.maid:GiveTask(expandTween.Completed:Connect(function()
		resetTween:Play()
	end))
end

function ResourceController.OnHarvestResponse(payload: any)
	if not payload or not payload.Success or not payload.ItemsObtained then
		return
	end

	print("[ResourceController] Loot Received!")
	for itemId, qty in pairs(payload.ItemsObtained) do
		print(string.format("  + %d %s", qty, itemId))
		-- In a full implementation, this triggers 3D Floating Billboard Text above the player's head
	end
end

return ResourceController
