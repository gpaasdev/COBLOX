--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)

local OfflineEarningsController = {}
OfflineEarningsController.Name = "OfflineEarningsController"

local localPlayer = Players.LocalPlayer
local modalFrame: Frame?
local isVisible = false

function OfflineEarningsController.Init()
	print("[OfflineEarningsController] Initializing AFK Earnings UI...")
end

function OfflineEarningsController.Start()
	task.delay(1.5, function()
		OfflineEarningsController.ShowWelcomeModal()
	end)
end

function OfflineEarningsController.ShowWelcomeModal()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:FindFirstChild("COBLOX_AlchemyHUD")
	if not mainHUD then
		return
	end

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "OfflineEarningsModal"
	modalFrame.Size = UDim2.new(0.5, 0, 0.45, 0)
	modalFrame.Position = UDim2.new(0.25, 0, 0.275, 0)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	modalFrame.BorderSizePixel = 0
	modalFrame.ZIndex = 150
	modalFrame.Parent = mainHUD

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(245, 158, 11) -- Gold
	stroke.Thickness = 3
	stroke.Parent = modalFrame

	-- Title Header
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(0.9, 0, 0.2, 0)
	header.Position = UDim2.new(0.05, 0, 0.08, 0)
	header.BackgroundTransparency = 1
	header.Text = "✨ BERKAH KAWAN SPIRIT"
	header.TextColor3 = Color3.fromRGB(245, 158, 11)
	header.Font = Enum.Font.FredokaOne
	header.TextSize = 22
	header.Parent = modalFrame

	local desc = Instance.new("TextLabel")
	desc.Size = UDim2.new(0.9, 0, 0.35, 0)
	desc.Position = UDim2.new(0.05, 0, 0.3, 0)
	desc.BackgroundTransparency = 1
	desc.Text =
		"Spirit Companion milikmu telah memanen Mana dan merawat tempat meracik ramuan saat kamu beristirahat!\n\nKamu mendapatkan +36,000 Koin Magis!"
	desc.TextColor3 = Color3.fromRGB(255, 255, 255)
	desc.Font = Enum.Font.GothamMedium
	desc.TextSize = 14
	desc.TextWrapped = true
	desc.Parent = modalFrame

	-- Claim Button
	local claimBtn = Instance.new("TextButton")
	claimBtn.Size = UDim2.new(0.7, 0, 0.22, 0)
	claimBtn.Position = UDim2.new(0.15, 0, 0.7, 0)
	claimBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	claimBtn.Text = "✨ KLAIM HASIL PANEN MAGIS"
	claimBtn.TextColor3 = Color3.fromRGB(15, 23, 42)
	claimBtn.Font = Enum.Font.FredokaOne
	claimBtn.TextSize = 20
	claimBtn.Parent = modalFrame

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = claimBtn

	local btnGradient = Instance.new("UIGradient")
	btnGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(245, 158, 11)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 191, 36)),
	})
	btnGradient.Rotation = 45
	btnGradient.Parent = claimBtn

	claimBtn.MouseButton1Click:Connect(function()
		if ClientRemotes.ClaimOfflineEarnings then
			ClientRemotes.ClaimOfflineEarnings:InvokeServer()
		end
		if modalFrame then
			modalFrame:Destroy()
			modalFrame = nil
		end
	end)
end

return OfflineEarningsController
