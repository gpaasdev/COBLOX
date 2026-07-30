--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local MarketplaceService = game:GetService("MarketplaceService")
local AdService = game:GetService("AdService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local CommerceController = {}

local COMMERCE_PRODUCTS = {
	VIPPass = { id = 1923436403, name = "VIP Pass", type = "GamePass" },
	GemsSmall = { id = 3611126819, name = "Small Gem Pack", type = "DevProduct", price = 99 },
	GemsLarge = { id = 3611126995, name = "Large Gem Pack", type = "DevProduct", price = 499 },
	CoinsSmall = { id = 3611126655, name = "Small Coin Pack", type = "DevProduct", price = 99 },
	CoinsLarge = { id = 3611126895, name = "Large Coin Pack", type = "DevProduct", price = 499 },
}

function CommerceController.Init(self, Registry)
	self.maid = Maid.new()
	self._screenGui = nil
	self._isOpen = false
end

function CommerceController.Start(self, Registry)
	self.maid:GiveTask(MarketplaceService.ProcessReceipt:Connect(function(receiptInfo: ReceiptInfo)
		return CommerceController._HandleReceipt(self, receiptInfo)
	end))

	UserInputService.InputBegan:Connect(function(input: InputObject, processed: boolean)
		if processed then
			return
		end
		if input.KeyCode == Enum.KeyCode.Comma and input.UserInputType == Enum.UserInputType.Keyboard then
			CommerceController._ToggleShop(self)
		end
	end)

	print("[CommerceController] Shop ready — press ',' to open")

	self.maid:GiveTask(function()
		if self._screenGui then
			self._screenGui:Destroy()
		end
	end)
end

function CommerceController._ToggleShop(self)
	self._isOpen = not self._isOpen
	if self._isOpen then
		CommerceController._BuildUI(self)
	elseif self._screenGui then
		self._screenGui:Destroy()
		self._screenGui = nil
	end
end

function CommerceController._BuildUI(self)
	if self._screenGui then
		self._screenGui:Destroy()
	end

	local playerGui = Players.LocalPlayer and Players.LocalPlayer:FindFirstChild("PlayerGui")
	if not playerGui then
		return
	end

	self._screenGui = Instance.new("ScreenGui")
	self._screenGui.Name = "CommerceShop"
	self._screenGui.ResetOnSpawn = false
	self._screenGui.Parent = playerGui

	local mainFrame = Instance.new("Frame")
	mainFrame.Size = UDim2.fromOffset(400, 500)
	mainFrame.Position = UDim2.new(0.5, -200, 0.5, -250)
	mainFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = self._screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = mainFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(51, 65, 85)
	stroke.Thickness = 1
	stroke.Parent = mainFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 50)
	title.BackgroundTransparency = 1
	title.Text = "COBLOX Shop"
	title.TextColor3 = Color3.fromRGB(248, 250, 252)
	title.TextSize = 22
	title.Font = Enum.Font.GothamBold
	title.Parent = mainFrame

	local scroll = Instance.new("ScrollingFrame")
	scroll.Size = UDim2.new(1, -20, 1, -70)
	scroll.Position = UDim2.fromOffset(10, 60)
	scroll.BackgroundTransparency = 1
	scroll.ScrollBarThickness = 4
	scroll.CanvasSize = UDim2.new(0, 0, 0, #COMMERCE_PRODUCTS * 80)
	scroll.Parent = mainFrame

	local yPos = 0
	for _, product in COMMERCE_PRODUCTS do
		local itemFrame = Instance.new("Frame")
		itemFrame.Size = UDim2.new(1, 0, 0, 70)
		itemFrame.Position = UDim2.fromOffset(0, yPos)
		itemFrame.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
		itemFrame.BorderSizePixel = 0
		itemFrame.Parent = scroll

		local itemCorner = Instance.new("UICorner")
		itemCorner.CornerRadius = UDim.new(0, 8)
		itemCorner.Parent = itemFrame

		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.6, 0, 1, 0)
		nameLabel.Position = UDim2.fromOffset(10, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = product.name
		nameLabel.TextColor3 = Color3.fromRGB(248, 250, 252)
		nameLabel.TextSize = 16
		nameLabel.Font = Enum.Font.Gotham
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = itemFrame

		local promptAd = Instance.new("TextButton")
		promptAd.Size = UDim2.new(0, 100, 0, 30)
		promptAd.Position = UDim2.new(1, -110, 0.5, -15)
		promptAd.Text = if product.type == "GamePass" then "Buy Pass" else string.format("$%.2f", product.price / 100)
		promptAd.BackgroundColor3 = Color3.fromRGB(59, 130, 246)
		promptAd.TextColor3 = Color3.fromRGB(255, 255, 255)
		promptAd.TextSize = 14
		promptAd.Font = Enum.Font.GothamBold
		promptAd.BorderSizePixel = 0
		promptAd.Parent = itemFrame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 6)
		btnCorner.Parent = promptAd

		local productId = product.id
		promptAd.MouseButton1Click:Connect(function()
			if product.type == "DevProduct" then
				MarketplaceService:PromptProductPurchase(Players.LocalPlayer, productId)
			elseif product.type == "GamePass" then
				MarketplaceService:PromptGamePassPurchase(Players.LocalPlayer, productId)
			end
		end)

		yPos += 80
	end

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 30, 0, 30)
	closeBtn.Position = UDim2.new(1, -40, 0, 10)
	closeBtn.Text = "X"
	closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextSize = 16
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.BorderSizePixel = 0
	closeBtn.Parent = mainFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		CommerceController._ToggleShop(self)
	end)
end

function CommerceController._HandleReceipt(self, receiptInfo: ReceiptInfo): Enum.ProductPurchaseDecision
	print(string.format("[CommerceController] Receipt processed: %s (ID: %d)", receiptInfo.ProductId, receiptInfo.PurchaseId))
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function CommerceController.ShowRewardedAd(self, adType: string, callback: (boolean) -> ())
	local success, result = pcall(function()
		return AdService:ShowRewardedVideoAdAsync(adType)
	end)

	if success and result then
		callback(true)
	else
		callback(false)
	end
end

function CommerceController.Cleanup(self)
	if self.maid then
		self.maid:Destroy()
	end
	if self._screenGui then
		self._screenGui:Destroy()
	end
end

return CommerceController
