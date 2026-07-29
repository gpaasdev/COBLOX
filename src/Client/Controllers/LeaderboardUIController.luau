--!strict
-- LeaderboardUIController.luau — Client-side leaderboard display

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local LeaderboardUIController = {}
LeaderboardUIController.Name = "LeaderboardUIController"

local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
local leaderboardOpen = false
local leaderboardGui: ScreenGui? = nil

function LeaderboardUIController.Init()
	print("[LeaderboardUIController] Initialized.")
end

function LeaderboardUIController.Toggle()
	leaderboardOpen = not leaderboardOpen
	if not leaderboardGui then
		LeaderboardUIController._CreateUI()
	end
	if leaderboardGui then
		leaderboardGui.Enabled = leaderboardOpen
	end
end

function LeaderboardUIController._CreateUI()
	leaderboardGui = Instance.new("ScreenGui")
	leaderboardGui.Name = "LeaderboardUI"
	leaderboardGui.Enabled = false
	leaderboardGui.IgnoreGuiInset = true
	leaderboardGui.Parent = playerGui
	self.maid:GiveTask(leaderboardGui)

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(0, 280, 0, 360)
	frame.Position = UDim2.new(0.5, -140, 0.5, -180)
	frame.BackgroundColor3 = Color3.fromRGB(30, 27, 75)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Parent = leaderboardGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 32)
	title.Position = UDim2.new(0, 0, 0, 6)
	title.BackgroundTransparency = 1
	title.Text = "Leaderboard"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 18
	title.Parent = frame

	local leaderboardFunc = NetChannels.GetRemoteFunction("GetLeaderboardData")
	if leaderboardFunc then
		local data = leaderboardFunc:InvokeServer()
		if data and typeof(data) == "table" then
			local yPos = 44
			for i, entry in ipairs(data) do
				if i > 10 then
					break
				end
				local row = Instance.new("Frame")
				row.Size = UDim2.new(0.92, 0, 0, 26)
				row.Position = UDim2.new(0.04, 0, 0, yPos)
				row.BackgroundTransparency = 1
				row.Parent = frame

				local rankLbl = Instance.new("TextLabel")
				rankLbl.Size = UDim2.new(0.12, 0, 1, 0)
				rankLbl.BackgroundTransparency = 1
				rankLbl.Text = tostring(i)
				rankLbl.TextColor3 = Color3.fromRGB(245, 158, 11)
				rankLbl.Font = Enum.Font.GothamBold
				rankLbl.TextSize = 14
				rankLbl.Parent = row

				local nameLbl = Instance.new("TextLabel")
				nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
				nameLbl.Position = UDim2.new(0.12, 0, 0, 0)
				nameLbl.BackgroundTransparency = 1
				nameLbl.Text = entry.Name or "???"
				nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
				nameLbl.Font = Enum.Font.GothamMedium
				nameLbl.TextSize = 13
				nameLbl.TextXAlignment = Enum.TextXAlignment.Left
				nameLbl.Parent = row

				local scoreLbl = Instance.new("TextLabel")
				scoreLbl.Size = UDim2.new(0.33, 0, 1, 0)
				scoreLbl.Position = UDim2.new(0.67, 0, 0, 0)
				scoreLbl.BackgroundTransparency = 1
				scoreLbl.Text = tostring(entry.Score or 0)
				scoreLbl.TextColor3 = Color3.fromRGB(56, 189, 248)
				scoreLbl.Font = Enum.Font.GothamBold
				scoreLbl.TextSize = 13
				scoreLbl.Parent = row

				yPos += 30
			end
		end
	end
end

function LeaderboardUIController.Start()
	self.maid = Maid.new()
	local toggleRemote = NetChannels.GetRemoteEvent("ToggleLeaderboard")
	if toggleRemote then
		self.maid:GiveTask(toggleRemote.OnClientEvent:Connect(function()
			LeaderboardUIController.Toggle()
		end))
	end

	self.maid:GiveTask(game:GetService("UserInputService").InputBegan:Connect(function(input)
		if input.KeyCode == Enum.KeyCode.L and not game:GetService("UserInputService"):GetFocusedTextBox() then
			LeaderboardUIController.Toggle()
		end
	end))

	print("[LeaderboardUIController] Ready. Press [L] for leaderboard.")
end

return LeaderboardUIController
