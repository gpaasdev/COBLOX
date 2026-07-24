--!strict

local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)

local TradeController = {}
TradeController.Name = "TradeController"

local modalFrame: Frame? = nil
local isVisible = false
local isLocked = false
local countdownLabel: TextLabel? = nil

function TradeController.Init()
	print("[TradeController] Initializing Client Trade prompt & UI controller...")
end

function TradeController.Start()
	-- Connect trade invitation remotes
end

function TradeController.ToggleModal()
	if not modalFrame then
		TradeController._CreateTradeModal()
	end

	if modalFrame then
		isVisible = not isVisible
		modalFrame.Visible = isVisible
	end
end

function TradeController.RequestTradeWith(targetPlayer: Player)
	local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)
	local tradeRemote = ClientRemotes.RequestTrade
	tradeRemote:InvokeServer(targetPlayer.Name)
	print("[TradeController] Sent trade request to " .. targetPlayer.Name)
	TradeController.ToggleModal()
end

function TradeController._CreateTradeModal()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "TradeModal"
	modalFrame.Size = UDim2.new(0.65, 0, 0.7, 0)
	modalFrame.Position = UDim2.new(0.175, 0, 0.15, 0)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Slate 900
	modalFrame.BorderSizePixel = 0
	modalFrame.ZIndex = 100
	modalFrame.Visible = false
	modalFrame.Parent = mainHUD

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(6, 182, 212) -- Cyan Accent
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	-- Header Title
	local header = Instance.new("TextLabel")
	header.Size = UDim2.new(0.8, 0, 0.1, 0)
	header.Position = UDim2.new(0.05, 0, 0.04, 0)
	header.BackgroundTransparency = 1
	header.Text = LocalizationController.Get("TRADE_TITLE")
	header.TextColor3 = Color3.fromRGB(6, 182, 212)
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

	closeBtn.MouseButton1Click:Connect(function()
		TradeController.ToggleModal()
	end)

	-- My Offer Container (Left)
	local myOfferFrame = Instance.new("Frame")
	myOfferFrame.Size = UDim2.new(0.44, 0, 0.65, 0)
	myOfferFrame.Position = UDim2.new(0.04, 0, 0.16, 0)
	myOfferFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	myOfferFrame.BorderSizePixel = 0
	myOfferFrame.Parent = modalFrame

	local myCorner = Instance.new("UICorner")
	myCorner.CornerRadius = UDim.new(0, 8)
	myCorner.Parent = myOfferFrame

	local myLabel = Instance.new("TextLabel")
	myLabel.Size = UDim2.new(1, 0, 0.15, 0)
	myLabel.BackgroundTransparency = 1
	myLabel.Text = LocalizationController.Get("TRADE_MY_OFFER")
	myLabel.TextColor3 = Color3.fromRGB(248, 250, 252)
	myLabel.Font = Enum.Font.GothamBold
	myLabel.TextSize = 16
	myLabel.Parent = myOfferFrame

	-- Partner Offer Container (Right)
	local partnerOfferFrame = Instance.new("Frame")
	partnerOfferFrame.Size = UDim2.new(0.44, 0, 0.65, 0)
	partnerOfferFrame.Position = UDim2.new(0.52, 0, 0.16, 0)
	partnerOfferFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	partnerOfferFrame.BorderSizePixel = 0
	partnerOfferFrame.Parent = modalFrame

	local partnerCorner = Instance.new("UICorner")
	partnerCorner.CornerRadius = UDim.new(0, 8)
	partnerCorner.Parent = partnerOfferFrame

	local partnerLabel = Instance.new("TextLabel")
	partnerLabel.Size = UDim2.new(1, 0, 0.15, 0)
	partnerLabel.BackgroundTransparency = 1
	partnerLabel.Text = LocalizationController.Get("TRADE_PARTNER_OFFER")
	partnerLabel.TextColor3 = Color3.fromRGB(248, 250, 252)
	partnerLabel.Font = Enum.Font.GothamBold
	partnerLabel.TextSize = 16
	partnerLabel.Parent = partnerOfferFrame

	-- Countdown Display removed for Quick Accept
	
	-- Quick Accept Trade Button (Replaces Lock & Confirm)
	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.new(0.92, 0, 0.12, 0)
	confirmBtn.Position = UDim2.new(0.04, 0, 0.84, 0)
	confirmBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
	confirmBtn.Text = "⚡ QUICK ACCEPT"
	confirmBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	confirmBtn.Font = Enum.Font.GothamBold
	confirmBtn.TextSize = 16
	confirmBtn.Parent = modalFrame

	local confirmCorner = Instance.new("UICorner")
	confirmCorner.CornerRadius = UDim.new(0, 8)
	confirmCorner.Parent = confirmBtn

	confirmBtn.MouseButton1Click:Connect(function()
		print("[TradeController] Quick Accept! Firing server verification...")
		
		-- Play Tactile Audio Feedback
		local AudioController = require(script.Parent:WaitForChild("AudioController") :: any)
		AudioController.PlaySound("rbxassetid://138677306", 1.0) -- Success Chime
		
		TradeController.ToggleModal()
	end)
end

return TradeController
