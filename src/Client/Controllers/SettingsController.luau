--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local SettingsController = {}
SettingsController.Name = "SettingsController"

local isOpen = false
local screenGui: ScreenGui?
local mainFrame: Frame?

function SettingsController.Init(self)
	self.maid = Maid.new()
end

function SettingsController.Start(self)
	ContextActionService:BindAction("SettingsAction", function()
		SettingsController:_Toggle()
	end, false, Enum.KeyCode.M, Enum.KeyCode.ButtonStart)
	ContextActionService:SetTitle("SettingsAction", "⚙ MENU [M]")
	ContextActionService:SetPosition("SettingsAction", UDim2.new(0.02, 0, 0.02, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("SettingsAction")
	end)

	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then return end
		if input.KeyCode == Enum.KeyCode.M and not UserInputService:GetFocusedTextBox() then
			SettingsController:_Toggle()
		end
	end))
end

function SettingsController:_Toggle()
	isOpen = not isOpen
	if isOpen then
		SettingsController:_CreateUI()
	else
		SettingsController:_DestroyUI()
	end
end

function SettingsController:_CreateUI()
	local player = Players.LocalPlayer
	if not player then return end
	if screenGui then screenGui:Destroy() end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SettingsGUI"
	screenGui.ResetOnSpawn = false
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local uiscale = Instance.new("UIScale")
	uiscale.Scale = 1
	uiscale.Parent = screenGui

	local safeInset = Instance.new("UISafeInsets")
	safeInset.Parent = screenGui

	local fullBg = Instance.new("Frame")
	fullBg.Size = UDim2.new(1, 0, 1, 0)
	fullBg.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	fullBg.BackgroundTransparency = 0.4
	fullBg.BorderSizePixel = 0
	fullBg.Parent = screenGui

	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 350, 0, 420)
	mainFrame.Position = UDim2.new(0.5, -175, 0.5, -210)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 44)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	title.BorderSizePixel = 0
	title.Text = "⚙ Settings"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame
	Instance.new("UICorner", title).CornerRadius = UDim.new(0, 12)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -38, 0, 6)
	closeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = mainFrame
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	closeBtn.MouseButton1Click:Connect(function()
		SettingsController:_Toggle()
	end)

	local list = Instance.new("ScrollingFrame")
	list.Size = UDim2.new(1, -20, 1, -56)
	list.Position = UDim2.new(0, 10, 0, 48)
	list.BackgroundTransparency = 1
	list.BorderSizePixel = 0
	list.ScrollBarThickness = 4
	list.AutomaticCanvasSize = Enum.AutomaticSize.Y
	list.CanvasSize = UDim2.new(0, 0, 0, 0)
	list.Parent = mainFrame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list

	local settingToggles = {
		{ label = "Music Volume", key = "MusicVolume", type = "slider", default = 0.7 },
		{ label = "SFX Volume", key = "SFXVolume", type = "slider", default = 1.0 },
		{ label = "Damage Numbers", key = "ShowDamageNumbers", type = "toggle", default = true },
		{ label = "Camera Shake", key = "CameraShake", type = "toggle", default = true },
		{ label = "Auto-Attack", key = "AutoAttack", type = "toggle", default = false },
		{ label = "Performance Mode", key = "PerformanceMode", type = "toggle", default = false },
	}

	for _, setting in settingToggles do
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 0, 48)
		card.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		card.BorderSizePixel = 0
		card.Parent = list
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.6, 0, 1, 0)
		label.Position = UDim2.new(0, 12, 0, 0)
		label.BackgroundTransparency = 1
		label.Text = setting.label
		label.TextColor3 = Color3.fromRGB(255, 255, 255)
		label.TextSize = 15
		label.Font = Enum.Font.Gotham
		label.TextXAlignment = Enum.TextXAlignment.Left
		label.Parent = card

		local currentVal = Players.LocalPlayer:GetAttribute(setting.key) or setting.default

		if setting.type == "toggle" then
			local toggleBtn = Instance.new("TextButton")
			toggleBtn.Size = UDim2.new(0, 50, 0, 30)
			toggleBtn.Position = UDim2.new(1, -60, 0.5, -15)
			toggleBtn.BackgroundColor3 = if currentVal then Color3.fromRGB(100, 200, 100) else Color3.fromRGB(80, 80, 80)
			toggleBtn.Text = if currentVal then "ON" else "OFF"
			toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			toggleBtn.TextSize = 13
			toggleBtn.Font = Enum.Font.GothamBold
			toggleBtn.Parent = card
			Instance.new("UICorner", toggleBtn).CornerRadius = UDim.new(0, 6)
			toggleBtn.MouseButton1Click:Connect(function()
				local newVal = not (currentVal or false)
				currentVal = newVal
				Players.LocalPlayer:SetAttribute(setting.key, newVal)
				toggleBtn.BackgroundColor3 = if newVal then Color3.fromRGB(100, 200, 100) else Color3.fromRGB(80, 80, 80)
				toggleBtn.Text = if newVal then "ON" else "OFF"
			end)
		elseif setting.type == "slider" then
			local val = currentVal or setting.default
			local sliderBg = Instance.new("Frame")
			sliderBg.Size = UDim2.new(0, 120, 0, 8)
			sliderBg.Position = UDim2.new(1, -130, 0.5, -4)
			sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 75)
			sliderBg.BorderSizePixel = 0
			sliderBg.Parent = card
			Instance.new("UICorner", sliderBg).CornerRadius = UDim.new(0, 4)

			local fill = Instance.new("Frame")
			fill.Size = UDim2.new(val, 0, 1, 0)
			fill.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
			fill.BorderSizePixel = 0
			fill.Parent = sliderBg
			Instance.new("UICorner", fill).CornerRadius = UDim.new(0, 4)
		end
	end

	local keyGuideBtn = Instance.new("TextButton")
	keyGuideBtn.Size = UDim2.new(1, 0, 0, 40)
	keyGuideBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	keyGuideBtn.Text = "⌨ View Keybinds"
	keyGuideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyGuideBtn.TextSize = 15
	keyGuideBtn.Font = Enum.Font.GothamBold
	keyGuideBtn.Parent = list
	Instance.new("UICorner", keyGuideBtn).CornerRadius = UDim.new(0, 8)
	keyGuideBtn.MouseButton1Click:Connect(function()
		SettingsController:_DestroyUI()
		local KeyGuideController = require(script.Parent:WaitForChild("KeyGuideController"))
		KeyGuideController.Open()
	end)
end

function SettingsController:_DestroyUI()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
	mainFrame = nil
end

return SettingsController
