--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local LocalizationController = require(script.Parent.Parent:WaitForChild("LocalizationController") :: any)
local UIButtonAnimator = require(script.Parent.Parent.Parent:WaitForChild("Modules"):WaitForChild("UI"):WaitForChild("UIButtonAnimator") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local localPlayer = Players.LocalPlayer
local controllersFolder = script.Parent.Parent

local COLOR_ACCENT_PURPLE = Color3.fromRGB(139, 92, 246)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)

local HotbarController = {}
HotbarController.__index = HotbarController

function HotbarController.new(parentGui, maid, notify)
	local self = setmetatable({}, HotbarController)
	self:Init(parentGui, maid)
	self.notify = notify
	return self
end

function HotbarController.Init(self, parentGui, maid)
	self.maid = Maid.new()
	self.parentGui = parentGui
	self.hotbarSlotsData = {}

	if maid then
		maid:GiveTask(function() self.maid:Destroy() end)
	end

	-- 4. Bottom Viral Action Hotbar & Inventory Slots HUD
	local bottomBar = Instance.new("Frame")
	bottomBar.Name = "BottomActionHotbar"
	bottomBar.Size = UDim2.new(0.65, 0, 0.10, 0)
	bottomBar.Position = UDim2.new(0.175, 0, 0.88, 0)
	bottomBar.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	bottomBar.BackgroundTransparency = 0.2
	bottomBar.BorderSizePixel = 0
	bottomBar.ZIndex = 60
	bottomBar.Parent = parentGui

	local bottomCorner = Instance.new("UICorner")
	bottomCorner.CornerRadius = UDim.new(0, 14)
	bottomCorner.Parent = bottomBar

	local bottomStroke = Instance.new("UIStroke")
	bottomStroke.Color = COLOR_SPARK_CYAN
	bottomStroke.Thickness = 1.5
	bottomStroke.Parent = bottomBar

	local bottomAspect = Instance.new("UIAspectRatioConstraint")
	bottomAspect.AspectRatio = 4.5
	bottomAspect.Parent = bottomBar

	-- Action Pill Buttons Row
	local actionRow = Instance.new("Frame")
	actionRow.Name = "ActionPillsRow"
	actionRow.Size = UDim2.new(0.96, 0, 0.38, 0)
	actionRow.Position = UDim2.new(0.02, 0, 0.08, 0)
	actionRow.BackgroundTransparency = 1
	actionRow.Parent = bottomBar

	local pillLayout = Instance.new("UIListLayout")
	pillLayout.FillDirection = Enum.FillDirection.Horizontal
	pillLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	pillLayout.Padding = UDim.new(0.02, 0)
	pillLayout.Parent = actionRow

	local quickActions = {
		{ Name = "⚡ DASH", Color = Color3.fromRGB(14, 165, 233) },
		{ Name = "🌱 ELEMEN", Color = Color3.fromRGB(34, 197, 94) },
		{ Name = "🏰 MARKAS", Color = Color3.fromRGB(168, 85, 247) },
		{ Name = "🐣 SPIRIT", Color = Color3.fromRGB(249, 115, 22) },
		{ Name = "💰 JUAL", Color = Color3.fromRGB(234, 179, 8) },
	}

	local quickActionKeys = { "QUICK_DASH", "QUICK_ELEMEN", "QUICK_MARKAS", "QUICK_SPIRIT", "QUICK_JUAL" }

	for i, act in ipairs(quickActions) do
		local pill = Instance.new("TextButton")
		pill.Name = "Pill_" .. act.Name
		pill.Size = UDim2.new(0.17, 0, 1, 0)
		pill.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
		pill.BackgroundTransparency = 0.3
		pill.TextColor3 = act.Color
		pill.Font = Enum.Font.FredokaOne
		pill.TextSize = 12
		pill.Text = LocalizationController.Get(quickActionKeys[i])
		pill.Parent = actionRow

		local pillTextStroke = Instance.new("UIStroke")
		pillTextStroke.Color = Color3.fromRGB(0, 0, 0)
		pillTextStroke.Thickness = 1.2
		pillTextStroke.Parent = pill

		local pillCorner = Instance.new("UICorner")
		pillCorner.CornerRadius = UDim.new(0, 8)
		pillCorner.Parent = pill

		local pillStroke = Instance.new("UIStroke")
		pillStroke.Color = act.Color
		pillStroke.Thickness = 1
		pillStroke.Parent = pill

		UIButtonAnimator.BindButton(pill, { "Hover", "Click", "Audio" }, function()
			if act.Name == "⚡ DASH" then
				local char = localPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local hrp = char.HumanoidRootPart
					hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * 100

					local AudioController = require(controllersFolder:WaitForChild("AudioController") :: any)
					pcall(function()
						AudioController.PlaySound("rbxassetid://12222204", 0.8)
					end)

					self.notify(LocalizationController.Get("NOTIF_DASH"))
				end
			elseif act.Name == "🐣 SPIRIT" then
				local EggRenderController = require(controllersFolder:WaitForChild("EggRenderController") :: any)
				EggRenderController.ToggleModal()
			elseif act.Name == "🌱 ELEMEN" then
				local SynthesisController = require(controllersFolder:WaitForChild("SynthesisController") :: any)
				SynthesisController.ToggleModal()
			elseif act.Name == "🏰 MARKAS" then
				local PlacementController = require(controllersFolder:WaitForChild("PlacementController") :: any)
				PlacementController.TogglePlacementMode()
			else
				self.notify(LocalizationController.Get("NOTIF_QUICK_ACTION", act.Name))
			end
		end)
	end

	-- 4.5 Realm Key Hint
	local realmHint = Instance.new("TextButton")
	realmHint.Name = "RealmKeyHint"
	realmHint.Size = UDim2.new(0, 160, 0, 30)
	realmHint.Position = UDim2.new(0.5, -80, 0.78, 0)
	realmHint.BackgroundTransparency = 0.5
	realmHint.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	realmHint.Text = LocalizationController.Get("REALM_KEY_HINT")
	realmHint.TextColor3 = COLOR_ACCENT_PURPLE
	realmHint.Font = Enum.Font.GothamBold
	realmHint.TextSize = 13
	realmHint.TextStrokeTransparency = 0.3
	realmHint.AutoButtonColor = false
	realmHint.Parent = parentGui

	local realmCorner = Instance.new("UICorner")
	realmCorner.CornerRadius = UDim.new(0, 8)
	realmCorner.Parent = realmHint

	self.maid:GiveTask(realmHint.MouseButton1Click:Connect(function()
		local RealmEntryController = require(controllersFolder:WaitForChild("RealmEntryController") :: any)
		RealmEntryController:_CreateRealmSelectionUI()
	end))

	-- 5 Inventory Hotbar Slots (1..5)
	local slotsRow = Instance.new("Frame")
	slotsRow.Name = "InventorySlotsRow"
	slotsRow.Size = UDim2.new(0.96, 0, 0.46, 0)
	slotsRow.Position = UDim2.new(0.02, 0, 0.50, 0)
	slotsRow.BackgroundTransparency = 1
	slotsRow.Parent = bottomBar

	local slotLayout = Instance.new("UIListLayout")
	slotLayout.FillDirection = Enum.FillDirection.Horizontal
	slotLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	slotLayout.Padding = UDim.new(0.02, 0)
	slotLayout.Parent = slotsRow

	local slotIcons = { "🔮", "💧", "⚡", "🧪", "📜" }
	self.hotbarSlotsData = {}
	for slotIdx = 1, 5 do
		local slotBtn = Instance.new("TextButton")
		slotBtn.Name = "Slot_" .. slotIdx
		slotBtn.Size = UDim2.new(0.18, 0, 1, 0)
		slotBtn.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
		slotBtn.Text = ""
		slotBtn.Parent = slotsRow

		local slotCorner = Instance.new("UICorner")
		slotCorner.CornerRadius = UDim.new(0, 8)
		slotCorner.Parent = slotBtn

		local slotStroke = Instance.new("UIStroke")
		slotStroke.Color = Color3.fromRGB(71, 85, 105)
		slotStroke.Thickness = 1.5
		slotStroke.Parent = slotBtn

		local numBadge = Instance.new("TextLabel")
		numBadge.Size = UDim2.new(0, 16, 0, 16)
		numBadge.Position = UDim2.new(0, 3, 0, 3)
		numBadge.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
		numBadge.TextColor3 = COLOR_AURA_GOLD
		numBadge.Font = Enum.Font.FredokaOne
		numBadge.TextSize = 10
		numBadge.Text = tostring(slotIdx)
		numBadge.Parent = slotBtn

		local badgeCorner = Instance.new("UICorner")
		badgeCorner.CornerRadius = UDim.new(0, 4)
		badgeCorner.Parent = numBadge

		local iconLbl = Instance.new("TextLabel")
		iconLbl.Name = "IconLabel"
		iconLbl.Size = UDim2.new(1, 0, 0.6, 0)
		iconLbl.Position = UDim2.new(0, 0, 0, -4)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = slotIcons[slotIdx]
		iconLbl.TextSize = 18
		iconLbl.Parent = slotBtn

		local emptyLbl = Instance.new("TextLabel")
		emptyLbl.Name = "EmptyLabel"
		emptyLbl.Size = UDim2.new(1, 0, 0.3, 0)
		emptyLbl.Position = UDim2.new(0, 0, 0.6, 0)
		emptyLbl.BackgroundTransparency = 1
		emptyLbl.Text = LocalizationController.Get("HOTBAR_EMPTY")
		emptyLbl.TextColor3 = Color3.fromRGB(100, 116, 139)
		emptyLbl.Font = Enum.Font.Gotham
		emptyLbl.TextSize = 10
		emptyLbl.Parent = slotBtn

		self.hotbarSlotsData[slotIdx] = {
			Button = slotBtn,
			IconLabel = iconLbl,
			EmptyLabel = emptyLbl,
			ItemName = nil,
			ItemType = nil,
		}

		self.maid:GiveTask(slotBtn.MouseButton1Click:Connect(function()
			local slotData = self.hotbarSlotsData[slotIdx]
			if slotData and slotData.ItemName then
				if slotData.ItemType == "Structure" then
					local PlacementController = require(controllersFolder:WaitForChild("PlacementController") :: any)
					PlacementController.StartPlacementForStructure(slotData.ItemName)
					self.notify(LocalizationController.Get("NOTIF_PLACE_MODE", slotData.ItemName))
				elseif slotData.ItemType == "Consumable" then
					self.notify(LocalizationController.Get("NOTIF_CONSUME", slotData.ItemName))
					slotData.ItemName = nil
					slotData.ItemType = nil
					iconLbl.Text = slotIcons[slotIdx]
					if slotData.EmptyLabel then
						slotData.EmptyLabel.Visible = true
					end
				end
			end
		end))
	end
end

function HotbarController.AddItem(self, itemName: string, itemType: string)
	local iconMap = {
		["QuartzAltar_Tier1"] = "⛩️",
		["AstralGenerator_Tier2"] = "⚡",
		["PyroBuffPotion_Tier2"] = "🧪",
		["AuraElixir_Tier1"] = "🧪",
	}
	local icon = iconMap[itemName] or (itemType == "Structure" and "🏰" or "🧪")

	for i = 1, 5 do
		local slotData = self.hotbarSlotsData[i]
		if slotData and not slotData.ItemName then
			slotData.ItemName = itemName
			slotData.ItemType = itemType
			slotData.IconLabel.Text = icon .. " " .. string.sub(itemName, 1, 6)
			if slotData.EmptyLabel then
				slotData.EmptyLabel.Visible = false
			end
			self.notify(LocalizationController.Get("NOTIF_HOTBAR_ADD", i, itemName))
			return true
		end
	end
	self.notify(LocalizationController.Get("NOTIF_HOTBAR_FULL"))
	return false
end

return HotbarController
