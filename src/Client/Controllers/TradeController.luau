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
	if tradeRemote then
		tradeRemote:InvokeServer(targetPlayer.Name)
		print("[TradeController] Sent trade request to " .. targetPlayer.Name)
	else
		warn("[TradeController] RequestTrade remote not available")
	end
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

	-- 2-Step Anti-Scam Trade Action Container
	local actionContainer = Instance.new("Frame")
	actionContainer.Size = UDim2.new(0.92, 0, 0.14, 0)
	actionContainer.Position = UDim2.new(0.04, 0, 0.83, 0)
	actionContainer.BackgroundTransparency = 1
	actionContainer.Parent = modalFrame

	local lockBtn = Instance.new("TextButton")
	lockBtn.Size = UDim2.new(0.48, 0, 1, 0)
	lockBtn.Position = UDim2.new(0, 0, 0, 0)
	lockBtn.BackgroundColor3 = Color3.fromRGB(234, 179, 8) -- Yellow 500
	lockBtn.Text = "🔒 KUNCI PENAWARAN"
	lockBtn.TextColor3 = Color3.fromRGB(15, 23, 42)
	lockBtn.Font = Enum.Font.FredokaOne
	lockBtn.TextSize = 14
	lockBtn.Parent = actionContainer

	local lockCorner = Instance.new("UICorner")
	lockCorner.CornerRadius = UDim.new(0, 8)
	lockCorner.Parent = lockBtn

	local acceptBtn = Instance.new("TextButton")
	acceptBtn.Size = UDim2.new(0.48, 0, 1, 0)
	acceptBtn.Position = UDim2.new(0.52, 0, 0, 0)
	acceptBtn.BackgroundColor3 = Color3.fromRGB(71, 85, 105) -- Disabled slate
	acceptBtn.Text = "✅ KONFIRMASI FINAL"
	acceptBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
	acceptBtn.Font = Enum.Font.FredokaOne
	acceptBtn.TextSize = 14
	acceptBtn.Active = false
	acceptBtn.Parent = actionContainer

	local acceptCorner = Instance.new("UICorner")
	acceptCorner.CornerRadius = UDim.new(0, 8)
	acceptCorner.Parent = acceptBtn

	local isLocked = false
	local isCountingDown = false

	lockBtn.MouseButton1Click:Connect(function()
		if isCountingDown then
			return
		end

		isLocked = not isLocked
		if isLocked then
			lockBtn.Text = "🔓 BUKA KUNCI"
			lockBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68) -- Red to unlock

			isCountingDown = true
			for remaining = 3, 1, -1 do
				acceptBtn.Text = string.format("⏳ TUNGGU (%ds)", remaining)
				task.wait(1)
			end
			isCountingDown = false

			acceptBtn.Text = "✅ KONFIRMASI FINAL"
			acceptBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94) -- Active Green
			acceptBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
			acceptBtn.Active = true
		else
			lockBtn.Text = "🔒 KUNCI PENAWARAN"
			lockBtn.BackgroundColor3 = Color3.fromRGB(234, 179, 8)
			acceptBtn.Text = "✅ KONFIRMASI FINAL"
			acceptBtn.BackgroundColor3 = Color3.fromRGB(71, 85, 105)
			acceptBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
			acceptBtn.Active = false
		end
	end)

	acceptBtn.MouseButton1Click:Connect(function()
		if not isLocked or not acceptBtn.Active then
			return
		end

		print("[TradeController] Trade confirmed! Executing secure trade exchange...")
		local AudioController = require(script.Parent:WaitForChild("AudioController") :: any)
		pcall(function()
			AudioController.PlaySound("rbxassetid://138677306", 1.0)
		end)

		TradeController.ToggleModal()
	end)
end

return TradeController
