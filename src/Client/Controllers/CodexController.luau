--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local localPlayer = Players.LocalPlayer
local CodexController = {}
CodexController.Name = "CodexController"

local modalFrame: Frame? = nil
local isVisible = false
local typewriterLabel: TextLabel? = nil

local LORE_ITEMS = {
	{
		Id = "Tape_01",
		Title = "Sanctum Vault Incident",
		Text = LocalizationController.Get("CODEX_LORE_1"),
		Unlocked = true,
	},
	{
		Id = "Tape_02",
		Title = "Forbidden Transmutation",
		Text = LocalizationController.Get("CODEX_LORE_2"),
		Unlocked = false,
	},
	{
		Id = "Journal_01",
		Title = "Last Keeper Diary",
		Text = LocalizationController.Get("CODEX_LORE_3"),
		Unlocked = true,
	},
}

function CodexController.Init()
	print("[CodexController] Initializing Codex & Lore Reader UI Engine...")
end

function CodexController.Start()
	self.maid = Maid.new()
end

function CodexController.ToggleModal()
	if not modalFrame then
		CodexController._CreateModal()
	end

	if modalFrame then
		isVisible = not isVisible
		modalFrame.Visible = isVisible
	end
end

function CodexController._CreateModal()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "CodexModal"
	modalFrame.Size = UDim2.new(0.6, 0, 0.65, 0)
	modalFrame.Position = UDim2.new(0.2, 0, 0.18, 0)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Slate 900
	modalFrame.BorderSizePixel = 0
	modalFrame.ZIndex = 100
	modalFrame.Visible = false
	modalFrame.Parent = mainHUD
	self.maid:GiveTask(modalFrame)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(245, 158, 11) -- Gold Accent
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	-- Header
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(0.8, 0, 0.1, 0)
	header.Position = UDim2.new(0.05, 0, 0.04, 0)
	header.BackgroundTransparency = 1
	header.Text = LocalizationController.Get("CODEX_TITLE")
	header.TextColor3 = Color3.fromRGB(245, 158, 11)
	header.Font = Enum.Font.GothamBold
	header.TextScaled = true
	header.Parent = modalFrame

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0.06, 0, 0.08, 0)
	closeBtn.Position = UDim2.new(0.9, 0, 0.04, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextScaled = true
	closeBtn.Parent = modalFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	self.maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		CodexController.ToggleModal()
	end))

	-- List Frame (Left side)
	local listFrame = Instance.new("ScrollingFrame")
	listFrame.Size = UDim2.new(0.4, 0, 0.78, 0)
	listFrame.Position = UDim2.new(0.04, 0, 0.16, 0)
	listFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	listFrame.BorderSizePixel = 0
	listFrame.Parent = modalFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 6)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.Parent = listFrame

	-- Reader Frame (Right side)
	local readerFrame = Instance.new("Frame")
	readerFrame.Size = UDim2.new(0.5, 0, 0.78, 0)
	readerFrame.Position = UDim2.new(0.46, 0, 0.16, 0)
	readerFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	readerFrame.BorderSizePixel = 0
	readerFrame.Parent = modalFrame

	local readerCorner = Instance.new("UICorner")
	readerCorner.CornerRadius = UDim.new(0, 8)
	readerCorner.Parent = readerFrame

	typewriterLabel = Instance.new("TextLabel")
	typewriterLabel.Size = UDim2.new(0.9, 0, 0.9, 0)
	typewriterLabel.Position = UDim2.new(0.05, 0, 0.05, 0)
	typewriterLabel.BackgroundTransparency = 1
	typewriterLabel.TextColor3 = Color3.fromRGB(248, 250, 252)
	typewriterLabel.Font = Enum.Font.GothamMedium
	typewriterLabel.TextSize = 14
	typewriterLabel.TextWrapped = true
	typewriterLabel.TextYAlignment = Enum.TextYAlignment.Top
	typewriterLabel.Text = LocalizationController.Get("CODEX_SELECT_PROMPT")
	typewriterLabel.Parent = readerFrame

	-- Populate List
	for _, item in ipairs(LORE_ITEMS) do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.9, 0, 0, 40)
		btn.BackgroundColor3 = item.Unlocked and Color3.fromRGB(51, 65, 85) or Color3.fromRGB(15, 23, 42)
		btn.Text = (item.Unlocked and "🟢 " or "🔒 ") .. item.Title
		btn.TextColor3 = item.Unlocked and Color3.fromRGB(248, 250, 252) or Color3.fromRGB(148, 163, 184)
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 12
		btn.Parent = listFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = btn

		self.maid:GiveTask(btn.MouseButton1Click:Connect(function()
			if item.Unlocked then
				CodexController.PlayTypewriterText(item.Text)
			else
				if typewriterLabel then
					typewriterLabel.Text = LocalizationController.Get("CODEX_LOCKED_MSG")
				end
			end
		end))
	end
end

function CodexController.PlayTypewriterText(fullText: string)
	if not typewriterLabel then
		return
	end

	task.spawn(function()
		for i = 1, #fullText do
			typewriterLabel.Text = string.sub(fullText, 1, i)
			task.wait(0.03)
		end
	end)
end

return CodexController
