--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local EventCalendarController = {}
EventCalendarController.Name = "EventCalendarController"

local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_ACCENT_PURPLE = Color3.fromRGB(139, 92, 246)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

local calendarGui: ScreenGui? = nil
local calendarOpen = false

local function fetchEventsFromServer(): { { [string]: any } }
	local remoteFunc = NetChannels.GetRemoteFunction("GetActiveEvents")
	if remoteFunc then
		local success, result = pcall(function()
			return remoteFunc:InvokeServer()
		end)
		if success and result then
			return result
		end
	end
	return {}
end

local function buildCalendarUI(self, events: { { [string]: any } })
	if calendarGui then
		calendarGui:Destroy()
	end

	calendarGui = Instance.new("ScreenGui")
	calendarGui.Name = "EventCalendar"
	calendarGui.ResetOnSpawn = false
	calendarGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	calendarGui.Parent = playerGui
	self.maid:GiveTask(calendarGui)

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.6
	backdrop.Parent = calendarGui

	self.maid:GiveTask(backdrop.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			self:ToggleCalendar()
		end
	end))

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 360, 0, 400)
	container.Position = UDim2.new(0.5, -180, 0.5, -200)
	container.BackgroundColor3 = COLOR_BG_DARK
	container.BackgroundTransparency = 0.1
	container.BorderSizePixel = 0
	container.Parent = calendarGui

	local containerCorner = Instance.new("UICorner")
	containerCorner.CornerRadius = UDim.new(0, 14)
	containerCorner.Parent = container

	local containerStroke = Instance.new("UIStroke")
	containerStroke.Color = COLOR_ACCENT_PURPLE
	containerStroke.Thickness = 2
	containerStroke.Parent = container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 40)
	title.Position = UDim2.new(0, 0, 0, 10)
	title.BackgroundTransparency = 1
	title.Text = "Event Calendar"
	title.TextColor3 = COLOR_AURA_GOLD
	title.Font = Enum.Font.FredokaOne
	title.TextSize = 22
	title.Parent = container

	local listFrame = Instance.new("Frame")
	listFrame.Size = UDim2.new(0.9, 0, 0, 300)
	listFrame.Position = UDim2.new(0.05, 0, 0, 55)
	listFrame.BackgroundTransparency = 1
	listFrame.Parent = container

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = listFrame

	if #events == 0 then
		local noEvents = Instance.new("TextLabel")
		noEvents.Size = UDim2.new(1, 0, 0, 40)
		noEvents.BackgroundTransparency = 1
		noEvents.Text = "No active events right now"
		noEvents.TextColor3 = COLOR_TEXT_WHITE
		noEvents.Font = Enum.Font.GothamMedium
		noEvents.TextSize = 14
		noEvents.Parent = listFrame
	end

	local now = os.time()
	for _, event in ipairs(events) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 60)
		row.BackgroundColor3 = Color3.fromRGB(45, 40, 110)
		row.BackgroundTransparency = 0.5
		row.Parent = listFrame

		local rowCorner = Instance.new("UICorner")
		rowCorner.CornerRadius = UDim.new(0, 8)
		rowCorner.Parent = row

		local rowStroke = Instance.new("UIStroke")
		rowStroke.Color = COLOR_SPARK_CYAN
		rowStroke.Thickness = 1
		rowStroke.Parent = row

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.9, 0, 0.5, 0)
		nameLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = event.data or event.id
		nameLabel.TextColor3 = COLOR_AURA_GOLD
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextSize = 16
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = row

		local statusLabel = Instance.new("TextLabel")
		statusLabel.Size = UDim2.new(0.9, 0, 0.4, 0)
		statusLabel.Position = UDim2.new(0.05, 0, 0.55, 0)
		statusLabel.BackgroundTransparency = 1
		statusLabel.Text = "Active"
		statusLabel.TextColor3 = COLOR_SPARK_CYAN
		statusLabel.Font = Enum.Font.GothamMedium
		statusLabel.TextSize = 12
		statusLabel.TextXAlignment = Enum.TextXAlignment.Left
		statusLabel.Parent = row
	end

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0.9, 0, 0, 36)
	closeBtn.Position = UDim2.new(0.05, 0, 0, 355)
	closeBtn.BackgroundColor3 = COLOR_ACCENT_PURPLE
	closeBtn.Text = "Close"
	closeBtn.TextColor3 = COLOR_TEXT_WHITE
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = container

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	self.maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		self:ToggleCalendar()
	end))
end

function EventCalendarController.ToggleCalendar(self)
	calendarOpen = not calendarOpen
	if calendarOpen then
		local events = fetchEventsFromServer()
		buildCalendarUI(self, events)
	else
		if calendarGui then
			calendarGui:Destroy()
			calendarGui = nil
		end
	end
end

function EventCalendarController.Init() end

function EventCalendarController.Start(self)
	self.maid = Maid.new()
end

return EventCalendarController
