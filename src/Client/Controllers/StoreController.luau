--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local StoreController = {}
StoreController.Name = "StoreController"

local modalFrame: Frame? = nil
local isVisible = false

local COLOR_BG_DARK = Color3.fromRGB(15, 23, 42)
local COLOR_CARD_BG = Color3.fromRGB(30, 41, 59)
local COLOR_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)
local COLOR_ROBUX = Color3.fromRGB(0, 184, 83)

function StoreController.Init()
	print("[StoreController] Initializing Premium Store UI...")
end

function StoreController.Start() end

function StoreController.ToggleModal()
	if not modalFrame then
		StoreController._CreateModal()
	end

	if modalFrame then
		isVisible = not isVisible
		if isVisible then
			modalFrame.Size = UDim2.new(0, 0, 0, 0)
			modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			modalFrame.Visible = true

			local openTween =
				TweenService:Create(modalFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
					Size = UDim2.new(0.65, 0, 0.75, 0),
					Position = UDim2.new(0.175, 0, 0.125, 0),
				})
			openTween:Play()
		else
			local closeTween =
				TweenService:Create(modalFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 0),
					Position = UDim2.new(0.5, 0, 0.5, 0),
				})
			closeTween:Play()
			closeTween.Completed:Wait()
			modalFrame.Visible = false
		end
	end
end

function StoreController._CreateModal()
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "StoreModal"
	modalFrame.Size = UDim2.new(0, 0, 0, 0)
	modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	modalFrame.BackgroundColor3 = COLOR_BG_DARK
	modalFrame.BorderSizePixel = 0
	modalFrame.ZIndex = 120
	modalFrame.Visible = false
	modalFrame.Parent = mainHUD

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = COLOR_GOLD
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	-- Title Header
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(0.8, 0, 0.08, 0)
	header.Position = UDim2.new(0.04, 0, 0.03, 0)
	header.BackgroundTransparency = 1
	header.Text = "💎 Toko Premium"
	header.TextColor3 = COLOR_GOLD
	header.Font = Enum.Font.FredokaOne
	header.TextSize = 24
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = modalFrame

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 44, 0, 44)
	closeBtn.Position = UDim2.new(0.92, 0, 0.03, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = COLOR_TEXT_WHITE
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 18
	closeBtn.Parent = modalFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		StoreController.ToggleModal()
	end)

	local contentScroll = Instance.new("ScrollingFrame")
	contentScroll.Name = "ContentScroll"
	contentScroll.Size = UDim2.new(0.92, 0, 0.8, 0)
	contentScroll.Position = UDim2.new(0.04, 0, 0.15, 0)
	contentScroll.BackgroundTransparency = 1
	contentScroll.BorderSizePixel = 0
	contentScroll.ScrollBarThickness = 6
	contentScroll.Parent = modalFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.FillDirection = Enum.FillDirection.Vertical
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = contentScroll

	-- Auto scale canvas
	listLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		contentScroll.CanvasSize = UDim2.new(0, 0, 0, listLayout.AbsoluteContentSize.Y + 20)
	end)

	StoreController._CreateSection(contentScroll, "👑 GamePasses Eksklusif", 1, {
		{
			Name = "VIP Pass (God-Tier Access)",
			Price = "499",
			Type = "Pass",
			Id = 1923436403,
			Icon = "⭐",
			Desc = "Akses Spirit God-Tier, Tag VIP, dan bonus harian!",
		},
		{
			Name = "Auto-Hatch",
			Price = "299",
			Type = "Pass",
			Id = 1925292405,
			Icon = "🥚",
			Desc = "Tetaskan telur otomatis tanpa batas!",
		},
		{
			Name = "Super Luck",
			Price = "399",
			Type = "Pass",
			Id = 1924362417,
			Icon = "🍀",
			Desc = "Gandakan peluang mendapatkan pet langka.",
		},
	})

	StoreController._CreateSection(contentScroll, "💎 Bundel Gems", 2, {
		{
			Name = "100 Gems (Kecil)",
			Price = "49",
			Type = "Product",
			Id = 3611126819,
			Icon = "💎",
			Desc = "Gems untuk menetaskan telur VIP.",
		},
		{
			Name = "1,000 Gems (Besar)",
			Price = "199",
			Type = "Product",
			Id = 3611126995,
			Icon = "💎",
			Desc = "Gems melimpah untuk pet langka.",
		},
	})

	StoreController._CreateSection(contentScroll, "💰 Bundel Koin", 3, {
		{
			Name = "5,000 Koin",
			Price = "25",
			Type = "Product",
			Id = 3611126655,
			Icon = "🪙",
			Desc = "Modal awal untuk alkemis pemula.",
		},
		{
			Name = "50,000 Koin",
			Price = "99",
			Type = "Product",
			Id = 3611126895,
			Icon = "🪙",
			Desc = "Koin untuk ekspansi Markas.",
		},
	})
end

function StoreController._CreateSection(parent: Instance, title: string, order: number, items: any)
	local sectionFrame = Instance.new("Frame")
	sectionFrame.Name = "Section_" .. order
	sectionFrame.Size = UDim2.new(1, 0, 0, 150) -- Will adapt
	sectionFrame.BackgroundTransparency = 1
	sectionFrame.LayoutOrder = order
	sectionFrame.Parent = parent

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Size = UDim2.new(1, 0, 0, 30)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = title
	titleLabel.TextColor3 = COLOR_TEXT_WHITE
	titleLabel.Font = Enum.Font.FredokaOne
	titleLabel.TextSize = 18
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = sectionFrame

	local titleStroke = Instance.new("UIStroke")
	titleStroke.Color = Color3.fromRGB(0, 0, 0)
	titleStroke.Thickness = 1.2
	titleStroke.Parent = titleLabel

	local gridContainer = Instance.new("Frame")
	gridContainer.Position = UDim2.new(0, 0, 0, 35)
	gridContainer.Size = UDim2.new(1, 0, 1, -35)
	gridContainer.BackgroundTransparency = 1
	gridContainer.Parent = sectionFrame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.31, 0, 0, 110)
	gridLayout.CellPadding = UDim2.new(0.02, 0, 0, 10)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = gridContainer

	for i, item in ipairs(items) do
		local card = Instance.new("Frame")
		card.BackgroundColor3 = COLOR_CARD_BG
		card.BorderSizePixel = 0
		card.Parent = gridContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = card

		local stroke = Instance.new("UIStroke")
		stroke.Color = COLOR_CYAN
		stroke.Thickness = 1
		stroke.Parent = card

		local iconLbl = Instance.new("TextLabel")
		iconLbl.Size = UDim2.new(1, 0, 0.4, 0)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = item.Icon
		iconLbl.TextSize = 30
		iconLbl.Parent = card

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.9, 0, 0.2, 0)
		nameLbl.Position = UDim2.new(0.05, 0, 0.4, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = item.Name
		nameLbl.TextColor3 = COLOR_GOLD
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextScaled = true
		nameLbl.Parent = card

		local descLbl = Instance.new("TextLabel")
		descLbl.Size = UDim2.new(0.9, 0, 0.2, 0)
		descLbl.Position = UDim2.new(0.05, 0, 0.6, 0)
		descLbl.BackgroundTransparency = 1
		descLbl.Text = item.Desc
		descLbl.TextColor3 = COLOR_TEXT_WHITE
		descLbl.Font = Enum.Font.GothamMedium
		descLbl.TextScaled = true
		descLbl.Parent = card

		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0.8, 0, 0.18, 0)
		buyBtn.Position = UDim2.new(0.1, 0, 0.8, 0)
		buyBtn.BackgroundColor3 = COLOR_ROBUX
		buyBtn.Text = "R$ " .. item.Price
		buyBtn.TextColor3 = COLOR_TEXT_WHITE
		buyBtn.Font = Enum.Font.FredokaOne
		buyBtn.TextSize = 14
		buyBtn.Parent = card

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 6)
		buyCorner.Parent = buyBtn

		buyBtn.MouseButton1Click:Connect(function()
			local MonetizationController = require(script.Parent:WaitForChild("MonetizationController") :: any)
			if item.Type == "Pass" then
				MonetizationController.PromptGamePass(item.Id)
			else
				MonetizationController.PromptProduct(item.Id)
			end
		end)
	end

	-- Calculate total height needed based on grid items
	local numRows = math.ceil(#items / 3)
	sectionFrame.Size = UDim2.new(1, 0, 0, 35 + (numRows * 110) + ((numRows - 1) * 10))
end

return StoreController
