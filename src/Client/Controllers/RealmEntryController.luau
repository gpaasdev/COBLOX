--!strict
-- RealmEntryController.luau
-- Client-side Realm Entry Portal UI
-- Shows realm selection screen and sends teleport request to server

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")

local RealmEntryController = {}
RealmEntryController.Name = "RealmEntryController"

local COLOR_PRIMARY = Color3.fromRGB(6, 182, 212)
local COLOR_ACCENT = Color3.fromRGB(139, 92, 246)
local COLOR_GOLD = Color3.fromRGB(245, 158, 11)
local realmSelectionOpen = false

function RealmEntryController.Init()
	print("[RealmEntryController] Initialized.")
end

function RealmEntryController._CreateRealmSelectionUI()
	if realmSelectionOpen then
		return
	end
	realmSelectionOpen = true

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "RealmSelection"
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = playerGui
	self.maid:GiveTask(screenGui)

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.6
	backdrop.Parent = screenGui

	self.maid:GiveTask(backdrop.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			screenGui:Destroy()
			realmSelectionOpen = false
		end
	end))

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 400, 0, 250)
	container.Position = UDim2.new(0.5, -200, 0.5, -125)
	container.BackgroundColor3 = Color3.fromRGB(30, 27, 75)
	container.BackgroundTransparency = 0.1
	container.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "Select Realm"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 22
	title.Parent = container

	-- Main Realm button
	local mainBtn = Instance.new("TextButton")
	mainBtn.Size = UDim2.new(0, 340, 0, 60)
	mainBtn.Position = UDim2.new(0.5, -170, 0, 60)
	mainBtn.BackgroundColor3 = COLOR_PRIMARY
	mainBtn.BackgroundTransparency = 0.2
	mainBtn.Text = "Multiverse Alchemy Sanctum\n(Cyber-Alchemist Realm)"
	mainBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	mainBtn.Font = Enum.Font.GothamBold
	mainBtn.TextSize = 16
	mainBtn.TextWrapped = true
	mainBtn.Parent = container

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = mainBtn

	self.maid:GiveTask(mainBtn.MouseButton1Click:Connect(function()
		local remote = NetChannels.GetRemoteEvent("RequestRealmTeleport")
		if remote then
			remote:FireServer("MAIN")
		end
		screenGui:Destroy()
		realmSelectionOpen = false
	end))

	-- Fairytale Realm button
	local fairyBtn = Instance.new("TextButton")
	fairyBtn.Size = UDim2.new(0, 340, 0, 60)
	fairyBtn.Position = UDim2.new(0.5, -170, 0, 135)
	fairyBtn.BackgroundColor3 = COLOR_ACCENT
	fairyBtn.BackgroundTransparency = 0.2
	fairyBtn.Text = "Fairytale Fantasy Realm\n(Enchanted — Coming Soon)"
	fairyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	fairyBtn.Font = Enum.Font.GothamBold
	fairyBtn.TextSize = 16
	fairyBtn.TextWrapped = true
	fairyBtn.TextTransparency = 0.3
	fairyBtn.Parent = container

	local fairyCorner = Instance.new("UICorner")
	fairyCorner.CornerRadius = UDim.new(0, 10)
	fairyCorner.Parent = fairyBtn

	self.maid:GiveTask(fairyBtn.MouseButton1Click:Connect(function()
		local remote = NetChannels.GetRemoteEvent("RequestRealmTeleport")
		if remote then
			remote:FireServer("FAIRYTALE")
		end
		screenGui:Destroy()
		realmSelectionOpen = false
	end))
end

function RealmEntryController._FindPortalInWorkspace(): BasePart?
	local map = Workspace:FindFirstChild("Map")
	if map then
		for _, child in ipairs(map:GetChildren()) do
			if child.Name == "RealmPortal" and child:IsA("BasePart") then
				return child :: BasePart
			end
		end
	end
	return nil
end

function RealmEntryController.Start(self)
	self.maid = Maid.new()
	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.R and not UserInputService:GetFocusedTextBox() then
			RealmEntryController._CreateRealmSelectionUI()
		end
	end))

	local ContextActionService = game:GetService("ContextActionService")
	self.maid:GiveTask(ContextActionService:BindAction("RealmSelectAction", function()
		RealmEntryController._CreateRealmSelectionUI()
	end, false, Enum.KeyCode.ButtonR3))
	ContextActionService:SetTitle("RealmSelectAction", "🌍 REALM")
	ContextActionService:SetPosition("RealmSelectAction", UDim2.new(0.02, 0, 0.5, 0))

	print("[RealmEntryController] Ready. Press 'R' or use mobile button to open realm selection.")
end

return RealmEntryController
