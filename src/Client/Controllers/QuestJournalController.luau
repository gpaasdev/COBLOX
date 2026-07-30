--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local QuestJournalController = {}
QuestJournalController.Name = "QuestJournalController"

local isOpen = false
local screenGui: ScreenGui?
local mainFrame: Frame?

function QuestJournalController.Init(self)
	self.maid = Maid.new()
end

function QuestJournalController.Start(self)
	ContextActionService:BindAction("QuestJournalAction", function()
		QuestJournalController:_Toggle()
	end, false, Enum.KeyCode.J, Enum.KeyCode.ButtonR2)
	ContextActionService:SetTitle("QuestJournalAction", "📋 QUESTS [J]")
	ContextActionService:SetPosition("QuestJournalAction", UDim2.new(0.85, 0, 0.95, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("QuestJournalAction")
	end)

	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(input, processed)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.J and not UserInputService:GetFocusedTextBox() then
			QuestJournalController:_Toggle()
		end
	end))

	local QuestController = require(script.Parent:WaitForChild("QuestController"))
	self.maid:GiveTask(QuestController.QuestProgressUpdated:Connect(function(questNode)
		if mainFrame and isOpen then
			QuestJournalController:_Render()
		end
	end))
end

function QuestJournalController:_Toggle()
	isOpen = not isOpen
	if isOpen then
		QuestJournalController:_CreateUI()
	else
		QuestJournalController:_DestroyUI()
	end
end

function QuestJournalController:_CreateUI()
	local player = Players.LocalPlayer
	if not player then
		return
	end
	if screenGui then
		screenGui:Destroy()
	end

	screenGui = Instance.new("ScreenGui")
	screenGui.Name = "QuestJournalGUI"
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
	mainFrame.Size = UDim2.new(0, 400, 0, 500)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	mainFrame.BackgroundTransparency = 0.1
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = screenGui

	local uicorner = Instance.new("UICorner")
	uicorner.CornerRadius = UDim.new(0, 12)
	uicorner.Parent = mainFrame

	local titleBar = Instance.new("Frame")
	titleBar.Size = UDim2.new(1, 0, 0, 40)
	titleBar.BackgroundColor3 = Color3.fromRGB(40, 40, 55)
	titleBar.BorderSizePixel = 0
	titleBar.Parent = mainFrame
	Instance.new("UICorner", titleBar).CornerRadius = UDim.new(0, 12)
	local titleBarStrip = Instance.new("Frame")
	titleBarStrip.Size = UDim2.new(1, 0, 0, 4)
	titleBarStrip.Position = UDim2.new(0, 0, 0, 36)
	titleBarStrip.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
	titleBarStrip.BorderSizePixel = 0
	titleBarStrip.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 1, 0)
	title.BackgroundTransparency = 1
	title.Text = "📋 Quest Journal"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.TextSize = 20
	title.Font = Enum.Font.GothamBold
	title.Parent = titleBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 32, 0, 32)
	closeBtn.Position = UDim2.new(1, -36, 0, 4)
	closeBtn.BackgroundColor3 = Color3.fromRGB(60, 40, 40)
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = mainFrame
	Instance.new("UICorner", closeBtn).CornerRadius = UDim.new(0, 6)
	closeBtn.MouseButton1Click:Connect(function()
		QuestJournalController:_Toggle()
	end)

	local listFrame = Instance.new("ScrollingFrame")
	listFrame.Size = UDim2.new(1, -20, 1, -56)
	listFrame.Position = UDim2.new(0, 10, 0, 46)
	listFrame.BackgroundTransparency = 1
	listFrame.BorderSizePixel = 0
	listFrame.ScrollBarThickness = 4
	listFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	listFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
	listFrame.Parent = mainFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = listFrame

	QuestJournalController:_Render()
end

function QuestJournalController:_Render()
	if not mainFrame then
		return
	end
	local listFrame = mainFrame:FindFirstChildOfClass("ScrollingFrame")
	if not listFrame then
		return
	end

	for _, child in listFrame:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local QuestService = require(ReplicatedStorage.Shared.Configuration.GeneratedQuestRegistry)
	local quests = QuestService.GetAll()
	local player = Players.LocalPlayer
	local profileData = player and player:FindFirstChild("ProfileData")

	-- Fake FTUE quest if no real data
	local questNodes = {}
	if profileData and profileData:GetAttribute("Quests") then
		questNodes = profileData:GetAttribute("Quests")
	end

	if next(quests) == nil then
		local empty = Instance.new("TextLabel")
		empty.Size = UDim2.new(1, -20, 0, 60)
		empty.BackgroundTransparency = 1
		empty.Text = "No quests available yet.\nCheck back soon!"
		empty.TextColor3 = Color3.fromRGB(180, 180, 200)
		empty.TextSize = 16
		empty.Font = Enum.Font.Gotham
		empty.TextWrapped = true
		empty.Parent = listFrame
		return
	end

	for id, questData in quests do
		local node = questNodes and questNodes[id]
		local progress = (node and node.Progress) or 0
		local target = questData.Target or 1
		local pct = math.min(progress / target, 1)

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -10, 0, 80)
		card.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		card.BorderSizePixel = 0
		card.Parent = listFrame
		Instance.new("UICorner", card).CornerRadius = UDim.new(0, 8)

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.7, 0, 0, 24)
		nameLabel.Position = UDim2.new(0, 12, 0, 8)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = questData.Name or id
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextSize = 16
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = card

		local descLabel = Instance.new("TextLabel")
		descLabel.Size = UDim2.new(0.7, 0, 0, 18)
		descLabel.Position = UDim2.new(0, 12, 0, 34)
		descLabel.BackgroundTransparency = 1
		descLabel.Text = questData.Description or ""
		descLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
		descLabel.TextSize = 13
		descLabel.Font = Enum.Font.Gotham
		descLabel.TextXAlignment = Enum.TextXAlignment.Left
		descLabel.Parent = card

		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Size = UDim2.new(0.7, 0, 0, 16)
		rewardLabel.Position = UDim2.new(0, 12, 0, 56)
		rewardLabel.BackgroundTransparency = 1
		local rewardStr = questData.Reward and ("Reward: " .. questData.Reward) or ""
		rewardLabel.Text = rewardStr
		rewardLabel.TextColor3 = Color3.fromRGB(255, 200, 100)
		rewardLabel.TextSize = 12
		rewardLabel.Font = Enum.Font.Gotham
		rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
		rewardLabel.Parent = card

		local pctLabel = Instance.new("TextLabel")
		pctLabel.Size = UDim2.new(0, 56, 0, 20)
		pctLabel.Position = UDim2.new(1, -64, 0, 8)
		pctLabel.BackgroundTransparency = 1
		pctLabel.Text = string.format("%d%%", math.floor(pct * 100))
		pctLabel.TextColor3 = if pct >= 1 then Color3.fromRGB(100, 255, 100) else Color3.fromRGB(255, 200, 100)
		pctLabel.TextSize = 14
		pctLabel.Font = Enum.Font.GothamBold
		pctLabel.Parent = card

		local barBg = Instance.new("Frame")
		barBg.Size = UDim2.new(0, 120, 0, 8)
		barBg.Position = UDim2.new(1, -130, 0, 34)
		barBg.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
		barBg.BorderSizePixel = 0
		barBg.Parent = card
		Instance.new("UICorner", barBg).CornerRadius = UDim.new(0, 4)

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(pct, 0, 1, 0)
		bar.BackgroundColor3 = if pct >= 1 then Color3.fromRGB(100, 255, 100) else Color3.fromRGB(255, 180, 50)
		bar.BorderSizePixel = 0
		bar.Parent = barBg
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

		local progressLabel = Instance.new("TextLabel")
		progressLabel.Size = UDim2.new(0, 120, 0, 16)
		progressLabel.Position = UDim2.new(1, -130, 0, 46)
		progressLabel.BackgroundTransparency = 1
		progressLabel.Text = string.format("%d / %d", progress, target)
		progressLabel.TextColor3 = Color3.fromRGB(180, 180, 200)
		progressLabel.TextSize = 12
		progressLabel.Font = Enum.Font.Gotham
		progressLabel.Parent = card

		if pct >= 1 then
			local claimBtn = Instance.new("TextButton")
			claimBtn.Size = UDim2.new(0, 80, 0, 28)
			claimBtn.Position = UDim2.new(1, -90, 0, 46)
			claimBtn.BackgroundColor3 = Color3.fromRGB(255, 180, 50)
			claimBtn.Text = "CLAIM"
			claimBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
			claimBtn.TextSize = 13
			claimBtn.Font = Enum.Font.GothamBold
			claimBtn.Parent = card
			Instance.new("UICorner", claimBtn).CornerRadius = UDim.new(0, 6)
			claimBtn.MouseButton1Click:Connect(function()
				local QuestController = require(script.Parent:WaitForChild("QuestController"))
				QuestController.ClaimReward(id)
				claimBtn.Text = "✓"
				claimBtn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
				claimBtn.Active = false
			end)
		end
	end
end

function QuestJournalController:_DestroyUI()
	if screenGui then
		screenGui:Destroy()
		screenGui = nil
	end
	mainFrame = nil
end

return QuestJournalController
