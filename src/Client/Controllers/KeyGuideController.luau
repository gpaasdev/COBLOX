--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")

local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local KeyGuideController = {}
KeyGuideController.Name = "KeyGuideController"

local screenGui: ScreenGui?
local mainFrame: Frame?
local isOpen = false

local KEYBINDS = {
	{ key = "E", action = "Interact / Grab" },
	{ key = "LMB", action = "Attack" },
	{ key = "Q", action = "Dash" },
	{ key = "F", action = "Parry" },
	{ key = "X", action = "Switch Weapon" },
	{ key = "C", action = "Consume Potion" },
	{ key = "G", action = "Flex" },
	{ key = "J", action = "Quest Journal" },
	{ key = "M", action = "Settings / Menu" },
	{ key = "K", action = "Key Guide" },
	{ key = "N", action = "Shadow Raid" },
	{ key = "R", action = "Realm Select" },
	{ key = "T", action = "Fusion Demo" },
	{ key = "B", action = "Build Mode" },
	{ key = "L", action = "Leaderboard" },
	{ key = ",", action = "Shop" },
}

function KeyGuideController.Init(self)
	self.maid = Maid.new()
end

function KeyGuideController.Start(self)
	ContextActionService:BindAction("KeyGuideAction", function()
		KeyGuideController:_Toggle()
	end, false, Enum.KeyCode.K, Enum.KeyCode.DPadUp)
	ContextActionService:SetTitle("KeyGuideAction", "⌨ KEYS [K]")
	ContextActionService:SetPosition("KeyGuideAction", UDim2.new(0.02, 0, 0.9, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("KeyGuideAction")
	end)

	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.K and not UserInputService:GetFocusedTextBox() then
			KeyGuideController:_Toggle()
		end
	end))
end

function KeyGuideController.Open()
	if not isOpen then
		KeyGuideController:_CreateUI()
		isOpen = true
	end
end

function KeyGuideController:_Toggle()
	isOpen = not isOpen
	if isOpen then
		KeyGuideController:_CreateUI()
	else
		KeyGuideController:_DestroyUI()
	end
end

function KeyGuideController:_CreateUI()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	if screenGui then
		screenGui:Destroy()
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "KeyGuideGUI"
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
	fullBg.BackgroundTransparency = 0.35
	fullBg.BorderSizePixel = 0
	fullBg.Parent = screenGui

	mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(0, 360, 0, 440)
	mainFrame.Position = UDim2.new(0.5, -180, 0.5, -220)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	mainFrame.BackgroundTransparency = 0.05
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 44)
	title.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	title.BorderSizePixel = 0
	title.Text = "⌨ Keyboard & Controls"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 18
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
		KeyGuideController:_Toggle()
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
	layout.Padding = UDim.new(0, 6)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = list

	local grid = Instance.new("UIGridLayout")
	grid.FillDirection = Enum.FillDirection.Horizontal
	grid.CellSize = UDim2.new(0.5, -4, 0, 36)
	grid.CellPadding = UDim2.new(0, 8, 0, 6)
	grid.HorizontalAlignment = Enum.HorizontalAlignment.Center
	grid.Parent = list

	for _, bind in KEYBINDS do
		local row = Instance.new("Frame")
		row.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		row.BorderSizePixel = 0
		row.Parent = list
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

		local keyLabel = Instance.new("TextLabel")
		keyLabel.Size = UDim2.new(0, 50, 0, 28)
		keyLabel.Position = UDim2.new(0, 6, 0.5, -14)
		keyLabel.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		keyLabel.Text = bind.key
		keyLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		keyLabel.TextSize = 14
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.Parent = row
		Instance.new("UICorner", keyLabel).CornerRadius = UDim.new(0, 4)

		local actionLabel = Instance.new("TextLabel")
		actionLabel.Size = UDim2.new(1, -64, 1, 0)
		actionLabel.Position = UDim2.new(0, 62, 0, 0)
		actionLabel.BackgroundTransparency = 1
		actionLabel.Text = bind.action
		actionLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
		actionLabel.TextSize = 14
		actionLabel.Font = Enum.Font.Gotham
		actionLabel.TextXAlignment = Enum.TextXAlignment.Left
		actionLabel.Parent = row
	end
end

function KeyGuideController:_DestroyUI()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
	mainFrame = nil
end

return KeyGuideController
