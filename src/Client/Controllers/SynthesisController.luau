--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)
local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)

local localPlayer = Players.LocalPlayer
local SynthesisController = {}
SynthesisController.Name = "SynthesisController"

local modalFrame: Frame? = nil
local isVisible = false

local COLOR_BG_DARK = Color3.fromRGB(15, 23, 42) -- Slate 900
local COLOR_CARD_BG = Color3.fromRGB(30, 41, 59) -- Slate 800
local COLOR_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

local gridSlots: { [number]: TextButton } = {}
local gridData: { [number]: string } = { "", "", "", "", "", "", "", "", "" }
local resultPreviewLabel: TextLabel? = nil
local selectedMaterial = "Quartz" -- Default selected material for placement

function SynthesisController.Init()
	print("[SynthesisController] Initializing 3x3 Alchemist Crafting & Synthesis Vessel UI...")
end

function SynthesisController.Start()
	-- Initialization hooks
end

function SynthesisController.ToggleModal()
	if not modalFrame then
		SynthesisController._CreateModal()
	end

	if modalFrame then
		isVisible = not isVisible
		if isVisible then
			modalFrame.Size = UDim2.new(0, 0, 0, 0)
			modalFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
			modalFrame.Visible = true
			
			local openTween = TweenService:Create(modalFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(0.65, 0, 0.75, 0),
				Position = UDim2.new(0.175, 0, 0.125, 0)
			})
			openTween:Play()
		else
			local closeTween = TweenService:Create(modalFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0),
				Position = UDim2.new(0.5, 0, 0.5, 0)
			})
			closeTween:Play()
			closeTween.Completed:Wait()
			modalFrame.Visible = false
		end
	end
end

function SynthesisController._CreateModal()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "SynthesisVesselModal"
	modalFrame.Size = UDim2.new(0, 0, 0, 0) -- Starts small for tween
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
	stroke.Color = COLOR_CYAN
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	-- Title Header
	local header = Instance.new("TextLabel")
	header.Name = "Header"
	header.Size = UDim2.new(0.8, 0, 0.08, 0)
	header.Position = UDim2.new(0.04, 0, 0.03, 0)
	header.BackgroundTransparency = 1
	header.Text = "🧪 Lab Racik (Crafting Alkemis)"
	header.TextColor3 = COLOR_GOLD
	header.Font = Enum.Font.FredokaOne
	header.TextSize = 24
	header.TextXAlignment = Enum.TextXAlignment.Left
	header.Parent = modalFrame

	local headerPadding = Instance.new("UIPadding")
	headerPadding.PaddingLeft = UDim.new(0, 10)
	headerPadding.Parent = header

	-- Close Button (Tap target >= 44x44)
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
		SynthesisController.ToggleModal()
	end)

	-- 1. 3x3 Grid Frame (Left Container)
	local gridContainer = Instance.new("Frame")
	gridContainer.Name = "GridContainer"
	gridContainer.Size = UDim2.new(0.48, 0, 0.6, 0)
	gridContainer.Position = UDim2.new(0.04, 0, 0.15, 0)
	gridContainer.BackgroundColor3 = COLOR_CARD_BG
	gridContainer.BorderSizePixel = 0
	gridContainer.Parent = modalFrame

	local gridCorner = Instance.new("UICorner")
	gridCorner.CornerRadius = UDim.new(0, 12)
	gridCorner.Parent = gridContainer

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.3, 0, 0.3, 0)
	gridLayout.CellPadding = UDim2.new(0.03, 0, 0.03, 0)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	gridLayout.Parent = gridContainer

	-- Create 9 slots
	for i = 1, 9 do
		local slotBtn = Instance.new("TextButton")
		slotBtn.Name = "Slot_" .. tostring(i)
		slotBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
		slotBtn.Text = "+"
		slotBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
		slotBtn.Font = Enum.Font.GothamBold
		slotBtn.TextSize = 16
		slotBtn.Parent = gridContainer

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 8)
		slotCorner.Parent = slotBtn

		slotBtn.MouseButton1Click:Connect(function()
			if gridData[i] == "" then
				gridData[i] = selectedMaterial
				slotBtn.Text = selectedMaterial
				slotBtn.TextColor3 = COLOR_CYAN
				slotBtn.BackgroundColor3 = Color3.fromRGB(51, 65, 85)
			else
				gridData[i] = ""
				slotBtn.Text = "+"
				slotBtn.TextColor3 = Color3.fromRGB(148, 163, 184)
				slotBtn.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
			end
		end)

		gridSlots[i] = slotBtn
	end

	-- 2. Result Preview Frame (Right Container)
	local resultContainer = Instance.new("Frame")
	resultContainer.Name = "ResultContainer"
	resultContainer.Size = UDim2.new(0.4, 0, 0.6, 0)
	resultContainer.Position = UDim2.new(0.56, 0, 0.15, 0)
	resultContainer.BackgroundColor3 = COLOR_CARD_BG
	resultContainer.BorderSizePixel = 0
	resultContainer.Parent = modalFrame

	local resultCorner = Instance.new("UICorner")
	resultCorner.CornerRadius = UDim.new(0, 12)
	resultCorner.Parent = resultContainer

	resultPreviewLabel = Instance.new("TextLabel")
	resultPreviewLabel.Name = "ResultLabel"
	resultPreviewLabel.Size = UDim2.new(1, 0, 0.4, 0)
	resultPreviewLabel.Position = UDim2.new(0, 0, 0.1, 0)
	resultPreviewLabel.BackgroundTransparency = 1
	resultPreviewLabel.Text = "Pilih & tempatkan bahan di slot 3x3\nuntuk melihat hasil racikan!"
	resultPreviewLabel.TextColor3 = COLOR_TEXT_WHITE
	resultPreviewLabel.Font = Enum.Font.GothamMedium
	resultPreviewLabel.TextSize = 13
	resultPreviewLabel.TextWrapped = true
	resultPreviewLabel.Parent = resultContainer
	
	local previewPadding = Instance.new("UIPadding")
	previewPadding.PaddingLeft = UDim.new(0, 15)
	previewPadding.PaddingRight = UDim.new(0, 15)
	previewPadding.Parent = resultPreviewLabel

	-- Transmute Action Button
	local transmuteBtn = Instance.new("TextButton")
	transmuteBtn.Name = "TransmuteBtn"
	transmuteBtn.Size = UDim2.new(0.8, 0, 0.25, 0)
	transmuteBtn.Position = UDim2.new(0.1, 0, 0.65, 0)
	transmuteBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- White for UIGradient
	transmuteBtn.Text = "⚡ RACIK SEKARANG!"
	transmuteBtn.TextColor3 = COLOR_BG_DARK
	transmuteBtn.Font = Enum.Font.FredokaOne
	transmuteBtn.TextSize = 18
	transmuteBtn.Parent = resultContainer

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 10)
	btnCorner.Parent = transmuteBtn
	
	local btnGradient = Instance.new("UIGradient")
	btnGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_GOLD),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(251, 191, 36)) -- Lighter gold
	})
	btnGradient.Rotation = 45
	btnGradient.Parent = transmuteBtn

	local btnShadow = Instance.new("UIStroke")
	btnShadow.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	btnShadow.Color = Color3.fromRGB(180, 83, 9) -- Dark orange shadow
	btnShadow.Thickness = 3
	btnShadow.Parent = transmuteBtn

	local isCrafting = false
	local lastCraftTime = 0
	local CRAFT_COOLDOWN = 1.5

	transmuteBtn.MouseButton1Click:Connect(function()
		if isCrafting then return end
		
		local currentTime = os.clock()
		if currentTime - lastCraftTime < CRAFT_COOLDOWN then
			local controllersFolder = script.Parent
			local UIController = require(controllersFolder:WaitForChild("UIController") :: any)
			UIController.ShowNotification(string.format("⚠️ Harap tunggu %.1fs sebelum meracik lagi!", CRAFT_COOLDOWN - (currentTime - lastCraftTime)))
			return
		end
		lastCraftTime = currentTime
		
		-- Check if grid has at least 1 material
		local hasMaterial = false
		for i = 1, 9 do
			if gridData[i] ~= "" then
				hasMaterial = true
				break
			end
		end

		if not hasMaterial then
			if resultPreviewLabel then
				resultPreviewLabel.Text = "⚠️ Letakkan minimal 1 bahan alkimia pada grid 3x3!"
			end
			return
		end

		isCrafting = true
		transmuteBtn.Text = "⏳ MERACIK..."

		local response = nil
		pcall(function()
			response = ClientRemotes.RequestCraft:InvokeServer(gridData)
		end)

		isCrafting = false
		transmuteBtn.Text = "⚡ RACIK SEKARANG!"

		if response and response.Success and response.Data then
			local resultItem = response.Data.ItemResult
			local itemType = response.Data.ItemType or "Consumable"
			local multiplier = response.Data.YieldMultiplier or 1.0

			-- Play CraftSuccess Chime
			local controllersFolder = script.Parent
			local AudioController = require(controllersFolder:WaitForChild("AudioController") :: any)
			pcall(function()
				AudioController.PlaySound("rbxassetid://138677306", 1.0)
			end)

			-- Format technical name
			local cleanName = tostring(resultItem):gsub("_", " "):gsub("(%l)(%w*)", function(a,b) return a:upper()..b end)

			if resultPreviewLabel then
				resultPreviewLabel.Text = string.format("🎉 Berhasil Meracik:\n%s\n(Bonus Elemen: %.1fx)", cleanName, multiplier)
			end

			-- Notify UIController to put item into Hotbar & show top toast notification
			local UIController = require(controllersFolder:WaitForChild("UIController") :: any)
			UIController.AddItemToHotbar(resultItem, itemType)
			UIController.ShowNotification("✨ Berhasil Meracik: " .. cleanName .. "!")

			for i = 1, 9 do
				gridData[i] = ""
				if gridSlots[i] then
					gridSlots[i].Text = "+"
					gridSlots[i].TextColor3 = Color3.fromRGB(148, 163, 184)
					gridSlots[i].BackgroundColor3 = Color3.fromRGB(15, 23, 42)
				end
			end
		else
			if resultPreviewLabel then
				resultPreviewLabel.Text = LocalizationController.Get("SYNTHESIS_FAILED")
			end
		end
	end)

	-- 3. Material Selector Bar (Bottom Bar)
	local selectorContainer = Instance.new("Frame")
	selectorContainer.Name = "SelectorContainer"
	selectorContainer.Size = UDim2.new(0.92, 0, 0.16, 0)
	selectorContainer.Position = UDim2.new(0.04, 0, 0.79, 0)
	selectorContainer.BackgroundColor3 = COLOR_CARD_BG
	selectorContainer.BorderSizePixel = 0
	selectorContainer.Parent = modalFrame

	local selectorCorner = Instance.new("UICorner")
	selectorCorner.CornerRadius = UDim.new(0, 10)
	selectorCorner.Parent = selectorContainer

	local selectorLayout = Instance.new("UIListLayout")
	selectorLayout.FillDirection = Enum.FillDirection.Horizontal
	selectorLayout.Padding = UDim.new(0.02, 0)
	selectorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	selectorLayout.VerticalAlignment = Enum.VerticalAlignment.Center
	selectorLayout.Parent = selectorContainer

	local materials = { "Quartz", "AstralIron", "PyroEssence", "HydroCrystal" }
	for _, mat in ipairs(materials) do
		local matBtn = Instance.new("TextButton")
		matBtn.Name = "Mat_" .. mat
		matBtn.Size = UDim2.new(0.22, 0, 0.7, 0)
		matBtn.BackgroundColor3 = (selectedMaterial == mat) and COLOR_CYAN or Color3.fromRGB(15, 23, 42)
		matBtn.Text = mat
		matBtn.TextColor3 = COLOR_TEXT_WHITE
		matBtn.Font = Enum.Font.GothamBold
		matBtn.TextSize = 12
		matBtn.Parent = selectorContainer

		local matCorner = Instance.new("UICorner")
		matCorner.CornerRadius = UDim.new(0, 6)
		matCorner.Parent = matBtn

		matBtn.MouseButton1Click:Connect(function()
			selectedMaterial = mat
			for _, child in ipairs(selectorContainer:GetChildren()) do
				if child:IsA("TextButton") then
					child.BackgroundColor3 = (child.Name == "Mat_" .. mat) and COLOR_CYAN or Color3.fromRGB(15, 23, 42)
				end
			end
		end)
	end
end

return SynthesisController
