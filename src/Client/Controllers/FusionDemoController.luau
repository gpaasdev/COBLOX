--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local GlassPanel = require(script.Parent.Parent.Modules.FusionComponents.GlassPanel)
local FusionProvider = require(script.Parent.Parent.Modules.FusionComponents.FusionProvider)

local FusionDemoController = {}

function FusionDemoController.Init(self, Registry)
	self.maid = require(ReplicatedStorage.Shared.Utility.Maid).new()
	self._visible = false
	self._screenGui = nil
end

function FusionDemoController.Start(self, Registry)
	self._maid = require(ReplicatedStorage.Shared.Utility.Maid).new()

	self._fusion = FusionProvider.GetFusion()
	if not self._fusion then
		print("[FusionDemoController] Fusion not available — skipping demo")
		return
	end

	print("[FusionDemoController] Fusion ready — demo available via 'T' key")

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.T and input.UserInputType == Enum.UserInputType.Keyboard then
			self:_ToggleDemo()
		end
	end)

	self._maid:GiveTask(function()
		if self._screenGui then
			self._screenGui:Destroy()
			self._screenGui = nil
		end
	end)
end

function FusionDemoController._ToggleDemo(self)
	self._visible = not self._visible

	if self._visible then
		self:_BuildUI()
	elseif self._screenGui then
		self._screenGui:Destroy()
		self._screenGui = nil
	end
end

function FusionDemoController._BuildUI(self)
	if self._screenGui then
		self._screenGui:Destroy()
	end

	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	self._screenGui = Instance.new("ScreenGui")
	self._screenGui.Name = "FusionDemo"
	self._screenGui.ResetOnSpawn = false
	self._screenGui.Parent = playerGui

	local mainPanel = GlassPanel.New(self._fusion, {
		Size = UDim2.fromOffset(300, 200),
		Position = UDim2.new(0.5, -150, 0.5, -100),
		AnchorPoint = Vector2.new(0, 0),
		CornerRadius = UDim.new(0, 12),
		Children = {
			Instance.new("TextLabel"),
		},
	})
	mainPanel.Parent = self._screenGui

	local titleLabel = mainPanel:FindFirstChildOfClass("TextLabel")
	if titleLabel then
		titleLabel.Size = UDim2.new(1, 0, 0, 40)
		titleLabel.Position = UDim2.fromOffset(0, 10)
		titleLabel.BackgroundTransparency = 1
		titleLabel.Text = "COBLOX Fusion UI"
		titleLabel.TextColor3 = Color3.fromRGB(248, 250, 252)
		titleLabel.TextSize = 18
		titleLabel.Font = Enum.Font.GothamBold
		titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	end

	local statusText = Instance.new("TextLabel")
	statusText.Size = UDim2.new(1, -40, 0, 60)
	statusText.Position = UDim2.fromOffset(20, 60)
	statusText.BackgroundTransparency = 1
	statusText.Text = "Fusion v0.3.0 running\nPress F to toggle"
	statusText.TextColor3 = Color3.fromRGB(148, 163, 184)
	statusText.TextSize = 14
	statusText.Font = Enum.Font.Gotham
	statusText.TextXAlignment = Enum.TextXAlignment.Center
	statusText.TextYAlignment = Enum.TextYAlignment.Center
	statusText.Parent = mainPanel
end

function FusionDemoController.Cleanup(self)
	if self._maid then
		self._maid:Destroy()
	end
	if self._screenGui then
		self._screenGui:Destroy()
		self._screenGui = nil
	end
end

return FusionDemoController
