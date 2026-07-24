--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local localPlayer = Players.LocalPlayer
local clientFolder = script.Parent.Parent
local uiModules = clientFolder:WaitForChild("Modules"):WaitForChild("UI")

local UIButtonAnimator = require(uiModules:WaitForChild("UIButtonAnimator") :: any)
local UIEffectPool = require(uiModules:WaitForChild("UIEffectPool") :: any)
local VFXEngine = require(uiModules:WaitForChild("VFXEngine") :: any)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)

local UIController = {}
UIController.Name = "UIController"

local playerGui: PlayerGui? = nil
local mainScreenGui: ScreenGui
local walletAuraLabel: TextLabel
local walletSparksLabel: TextLabel
local notificationLabel: TextLabel
local sideDrawer: Frame
local liveOpsBanner: TextLabel

-- LGBOS v11.0 Sci-Fantasy Palette (Quantum Indigo #1E1B4B, Aura Gold #F59E0B, Spark Cyan #06B6D4)
local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_ACCENT_PURPLE = Color3.fromRGB(139, 92, 246)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

function UIController.Init()
	print("[UIController] Initializing Gen Z & Gen Alpha Visual-First HUD & Side Drawer (MaxWidth = 180px)...")
	
	UIController._CreateHUD()

	-- Connect economy listener
	task.spawn(function()
		local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
		if syncRemote then
			syncRemote.OnClientEvent:Connect(function(data: { Coins: number, Gems: number })
				UIController.UpdateWallet(data.Coins, data.Gems)
			end)
		end
	end)
end

function UIController.Start()
	local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
	if syncRemote then
		syncRemote.OnClientEvent:Connect(function(data: { Coins: number, Gems: number })
			UIController.UpdateWallet(data.Coins, data.Gems)
		end)
	end

	-- Trigger configurable LiveOps Join Popup & TopBar Banner
	UIController.CheckLiveOpsOverlays()

	-- Instantiate 3D Procedural Alchemical Core at Sanctum Altar Center
	task.spawn(function()
		local proceduralFolder = clientFolder:WaitForChild("Modules"):WaitForChild("Procedural")
		local ProceduralAlchemicalCore = require(proceduralFolder:WaitForChild("ProceduralAlchemicalCore") :: any)
		ProceduralAlchemicalCore.new(workspace, Vector3.new(0, 12, -20), {
			CoreColor = Color3.fromRGB(56, 189, 248),
			RingColor = Color3.fromRGB(168, 85, 247),
			Scale = 1.2,
			EnableCameraShake = true,
		})
	end)
end

function UIController._CreateHUD()
	if not playerGui then
		playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
	end

	mainScreenGui = Instance.new("ScreenGui")
	mainScreenGui.Name = "COBLOX_AlchemyHUD"
	mainScreenGui.ResetOnSpawn = false
	mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainScreenGui.Parent = playerGui

	-- Initialize UI Particle ImageLabel Pool
	UIEffectPool.Init(mainScreenGui)

	-- 0. Main Quest Banner (Top-Left Onboarding & Objective HUD)
	local questBanner = Instance.new("Frame")
	questBanner.Name = "QuestBanner"
	questBanner.Size = UDim2.new(0.26, 0, 0.12, 0)
	questBanner.AnchorPoint = Vector2.new(1, 0)
	questBanner.Position = UDim2.new(0.99, 0, 0.20, 0) -- Top-Right, avoiding Roblox leaderboard
	questBanner.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	questBanner.BorderSizePixel = 0
	questBanner.ZIndex = 55
	questBanner.Parent = mainScreenGui

	local questCorner = Instance.new("UICorner")
	questCorner.CornerRadius = UDim.new(0, 10)
	questCorner.Parent = questBanner

	local questStroke = Instance.new("UIStroke")
	questStroke.Color = COLOR_AURA_GOLD
	questStroke.Thickness = 2
	questStroke.Parent = questBanner

	local questTitle = Instance.new("TextLabel")
	questTitle.Name = "QuestTitle"
	questTitle.Size = UDim2.new(0.9, 0, 0.45, 0)
	questTitle.Position = UDim2.new(0.05, 0, 0.08, 0)
	questTitle.BackgroundTransparency = 1
	questTitle.Text = LocalizationController.Get("FTUE_CLAIM_PLOT")
	questTitle.TextColor3 = COLOR_AURA_GOLD
	questTitle.Font = Enum.Font.FredokaOne
	questTitle.TextSize = 14
	questTitle.TextXAlignment = Enum.TextXAlignment.Left
	questTitle.Parent = questBanner

	local questDesc = Instance.new("TextLabel")
	questDesc.Name = "QuestDesc"
	questDesc.Size = UDim2.new(0.9, 0, 0.4, 0)
	questDesc.Position = UDim2.new(0.05, 0, 0.52, 0)
	questDesc.BackgroundTransparency = 1
	questDesc.Text = "🎯 Kunjungi Markas & Racik Ramuan Pertamamu!"
	questDesc.TextColor3 = COLOR_SPARK_CYAN
	questDesc.Font = Enum.Font.GothamMedium
	questDesc.TextSize = 11
	questDesc.TextXAlignment = Enum.TextXAlignment.Left
	questDesc.Parent = questBanner

	-- 1. Top Bar (Aura Energy & Chrono Sparks)
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(0.4, 0, 0.08, 0)
	topBar.Position = UDim2.new(0.3, 0, 0.02, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topBar.BorderSizePixel = 0
	topBar.ZIndex = 50
	topBar.Parent = mainScreenGui

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 12)
	uiCorner.Parent = topBar
	
	local topBarGradient = Instance.new("UIGradient")
	topBarGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, COLOR_BG_DARK),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(49, 46, 129)) -- Lighter indigo
	})
	topBarGradient.Rotation = 0
	topBarGradient.Parent = topBar

	local topBarStroke = Instance.new("UIStroke")
	topBarStroke.Color = COLOR_ACCENT_PURPLE
	topBarStroke.Thickness = 2
	topBarStroke.Parent = topBar

	walletAuraLabel = Instance.new("TextLabel")
	walletAuraLabel.Name = "AuraLabel"
	walletAuraLabel.Size = UDim2.new(0.5, 0, 1, 0)
	walletAuraLabel.BackgroundTransparency = 1
	walletAuraLabel.TextColor3 = COLOR_AURA_GOLD
	walletAuraLabel.Font = Enum.Font.FredokaOne
	walletAuraLabel.TextSize = 20
	walletAuraLabel.Text = LocalizationController.Get("HUD_AURA", 0)
	walletAuraLabel.Parent = topBar

	walletSparksLabel = Instance.new("TextLabel")
	walletSparksLabel.Name = "SparksLabel"
	walletSparksLabel.Size = UDim2.new(0.5, 0, 1, 0)
	walletSparksLabel.Position = UDim2.new(0.5, 0, 0, 0)
	walletSparksLabel.BackgroundTransparency = 1
	walletSparksLabel.TextColor3 = COLOR_SPARK_CYAN
	walletSparksLabel.Font = Enum.Font.FredokaOne
	walletSparksLabel.TextSize = 20
	walletSparksLabel.Text = LocalizationController.Get("HUD_SPARKS", 0)
	walletSparksLabel.Parent = topBar

	-- LiveOps TopBar Event Indicator Banner
	liveOpsBanner = Instance.new("TextLabel")
	liveOpsBanner.Name = "LiveOpsBanner"
	liveOpsBanner.Size = UDim2.new(0.4, 0, 0.03, 0)
	liveOpsBanner.Position = UDim2.new(0.3, 0, 0.105, 0)
	liveOpsBanner.BackgroundColor3 = COLOR_AURA_GOLD
	liveOpsBanner.TextColor3 = COLOR_BG_DARK
	liveOpsBanner.Font = Enum.Font.GothamBold
	liveOpsBanner.TextSize = 12
	liveOpsBanner.Text = LocalizationController.Get("LIVEOPS_BOOST_ACTIVE")
	liveOpsBanner.Visible = false
	liveOpsBanner.Parent = mainScreenGui

	local bannerCorner = Instance.new("UICorner")
	bannerCorner.CornerRadius = UDim.new(0, 6)
	bannerCorner.Parent = liveOpsBanner

	local isMobile = UserInputService.TouchEnabled

	-- Mobile Hamburger Toggle Button
	if isMobile then
		local menuBtn = Instance.new("TextButton")
		menuBtn.Name = "MobileMenuBtn"
		menuBtn.Size = UDim2.new(0, 44, 0, 44)
		menuBtn.Position = UDim2.new(0.01, 0, 0.25, 0)
		menuBtn.BackgroundColor3 = COLOR_ACCENT_PURPLE
		menuBtn.TextColor3 = COLOR_TEXT_WHITE
		menuBtn.Font = Enum.Font.FredokaOne
		menuBtn.TextSize = 22
		menuBtn.Text = "☰"
		menuBtn.ZIndex = 50
		menuBtn.Parent = mainScreenGui

		local menuCorner = Instance.new("UICorner")
		menuCorner.CornerRadius = UDim.new(0, 10)
		menuCorner.Parent = menuBtn

		UIButtonAnimator.BindButton(menuBtn, { "Click", "Audio" }, function()
			if sideDrawer then
				sideDrawer.Visible = not sideDrawer.Visible
			end
		end)
	end

	-- 2. Side Drawer (Max Width 180px Collapsible)
	sideDrawer = Instance.new("Frame")
	sideDrawer.Name = "SideDrawer"
	sideDrawer.Size = UDim2.new(0, 160, 0.60, 0)
	sideDrawer.Position = isMobile and UDim2.new(0.01, 50, 0.25, 0) or UDim2.new(0.01, 0, 0.25, 0)
	sideDrawer.BackgroundColor3 = COLOR_BG_DARK
	sideDrawer.BorderSizePixel = 0
	sideDrawer.ZIndex = 40
	sideDrawer.Visible = not isMobile
	sideDrawer.Parent = mainScreenGui

	local drawerCorner = Instance.new("UICorner")
	drawerCorner.CornerRadius = UDim.new(0, 12)
	drawerCorner.Parent = sideDrawer

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = sideDrawer

	local drawerButtons = { "Markas Saya", "Lab Racik", "Panggil Spirit", "Klan Player", "Buku Resep & Spirit" }
	local drawerKeys = {
		["Markas Saya"] = "SIDE_SANCTUM_GRID",
		["Lab Racik"] = "SIDE_SYNTHESIS_VESSEL",
		["Panggil Spirit"] = "SIDE_SPIRIT_HATCHERY",
		["Klan Player"] = "SIDE_COVEN_ORDER",
		["Buku Resep & Spirit"] = "SIDE_CODEX",
	}

	for i, btnName in ipairs(drawerButtons) do
		local btn = Instance.new("TextButton")
		btn.Name = "Btn_" .. btnName
		btn.Size = UDim2.new(0.9, 0, 0, 36)
		btn.LayoutOrder = i
		btn.BackgroundColor3 = COLOR_ACCENT_PURPLE
		btn.TextColor3 = COLOR_TEXT_WHITE
		btn.Font = Enum.Font.GothamBold
		btn.TextSize = 14
		btn.Text = LocalizationController.Get(drawerKeys[btnName] or btnName)
		btn.Parent = sideDrawer

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 8)
		btnCorner.Parent = btn

		VFXEngine.ApplySpringAnimation(btn)

		-- Bind modular button animator with Hover, Click, Audio, and Spark plugins
		UIButtonAnimator.BindButton(btn, { "Hover", "Click", "Audio", "Spark" }, function()
			local controllersFolder = script.Parent
			local text = btn.Text
			if btnName == "Lab Racik" or text == "Lab Racik" or text == "Alchemist Lab" or text == "Synthesis Vessel" then
				local SynthesisController = require(controllersFolder:WaitForChild("SynthesisController") :: any)
				SynthesisController.ToggleModal()
			elseif btnName == "Panggil Spirit" or text == "Panggil Spirit" or text == "Hatch Spirit" or text == "Hatch Telur Pet" or text == "Spirit Hatchery" then
				local EggRenderController = require(controllersFolder:WaitForChild("EggRenderController") :: any)
				EggRenderController.ToggleModal()
			elseif btnName == "Klan Player" or text == "Klan Player" or text == "Player Clan" or text == "Clan Alkemis" or text == "Coven Order" then
				local CovenController = require(controllersFolder:WaitForChild("CovenController") :: any)
				CovenController.ToggleModal()
			elseif btnName == "Buku Resep & Spirit" or text == "Buku Resep & Spirit" or text == "Recipe Codex" or text == "Codex" then
				local CodexController = require(controllersFolder:WaitForChild("CodexController") :: any)
				CodexController.ToggleModal()
			elseif btnName == "Markas Saya" or text == "Markas Saya" or text == "My Sanctum" or text == "Sanctum Grid" then
				local PlacementController = require(controllersFolder:WaitForChild("PlacementController") :: any)
				PlacementController.TogglePlacementMode()
			else
				UIController.ShowNotification("Buka: " .. text)
			end
		end)
	end

	-- 3. Notification Banner (Toast)
	notificationLabel = Instance.new("TextLabel")
	notificationLabel.Name = "NotificationBanner"
	notificationLabel.Size = UDim2.new(0.48, 0, 0.055, 0)
	notificationLabel.Position = UDim2.new(0.26, 0, 0.14, 0)
	notificationLabel.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	notificationLabel.TextColor3 = COLOR_AURA_GOLD
	notificationLabel.Font = Enum.Font.FredokaOne
	notificationLabel.TextSize = 15
	notificationLabel.ZIndex = 300 -- Always on top of all modals
	notificationLabel.Text = "Welcome to Multiverse Alchemy Sanctum!"
	notificationLabel.Visible = false
	notificationLabel.Parent = mainScreenGui

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notificationLabel

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = COLOR_AURA_GOLD
	notifStroke.Thickness = 2
	notifStroke.Parent = notificationLabel

	-- 4. Bottom Viral Action Hotbar & Inventory Slots HUD (Grow a Garden / Pet Sim Benchmark)
	local bottomBar = Instance.new("Frame")
	bottomBar.Name = "BottomActionHotbar"
	bottomBar.Size = UDim2.new(0.55, 0, 0.12, 0)
	bottomBar.Position = UDim2.new(0.225, 0, 0.86, 0)
	bottomBar.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	bottomBar.BackgroundTransparency = 0.2
	bottomBar.BorderSizePixel = 0
	bottomBar.ZIndex = 60
	bottomBar.Parent = mainScreenGui

	local bottomCorner = Instance.new("UICorner")
	bottomCorner.CornerRadius = UDim.new(0, 14)
	bottomCorner.Parent = bottomBar

	local bottomStroke = Instance.new("UIStroke")
	bottomStroke.Color = COLOR_AURA_GOLD
	bottomStroke.Thickness = 2.5
	bottomStroke.Parent = bottomBar

	-- Action Pill Buttons Row (SEEDS / GARDEN / PETS / SELL)
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
		{ Name = "⚡ DASH", Color = Color3.fromRGB(14, 165, 233) }, -- New Dash Button for Travel Time
		{ Name = "🌱 ELEMEN", Color = Color3.fromRGB(34, 197, 94) },
		{ Name = "🏰 MARKAS", Color = Color3.fromRGB(168, 85, 247) },
		{ Name = "🐶 PETS", Color = Color3.fromRGB(249, 115, 22) },
		{ Name = "💰 JUAL", Color = Color3.fromRGB(234, 179, 8) },
	}

	for _, act in ipairs(quickActions) do
		local pill = Instance.new("TextButton")
		pill.Name = "Pill_" .. act.Name
		pill.Size = UDim2.new(0.18, 0, 1, 0) -- Scaled down slightly to fit 5 pills
		pill.BackgroundColor3 = act.Color
		pill.TextColor3 = COLOR_TEXT_WHITE
		pill.Font = Enum.Font.FredokaOne
		pill.TextSize = 12
		pill.Text = act.Name
		pill.Parent = actionRow

		local pillCorner = Instance.new("UICorner")
		pillCorner.CornerRadius = UDim.new(0, 8)
		pillCorner.Parent = pill

		local isMounted = false
		UIButtonAnimator.BindButton(pill, { "Hover", "Click", "Audio" }, function()
			local controllersFolder = script.Parent
			if act.Name == "⚡ DASH" then
				local char = localPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local hrp = char.HumanoidRootPart
					hrp.Velocity = hrp.CFrame.LookVector * 100 -- Propel forward
					
					-- Tactile Audio & Visual Polish
					local AudioController = require(controllersFolder:WaitForChild("AudioController") :: any)
					pcall(function()
						AudioController.PlaySound("rbxassetid://6023565860", 0.8) -- Valid Dash swoosh SFX
					end)
					
					UIController.ShowNotification("⚡ Dash Activated!")
				end
			elseif act.Name == "🐶 PETS" then
				isMounted = not isMounted
				local PetRenderController = require(controllersFolder:WaitForChild("PetRenderController") :: any)
				PetRenderController.MountNeonCrocodile(isMounted)
				UIController.ShowNotification(isMounted and "🐊 Menunggangi Giant Neon Alligator Mount (+75% Speed)!" or "🚶 Dismounted Neon Mount.")
			elseif act.Name == "🌱 ELEMEN" then
				local SynthesisController = require(controllersFolder:WaitForChild("SynthesisController") :: any)
				SynthesisController.ToggleModal()
			elseif act.Name == "🏰 MARKAS" then
				local PlacementController = require(controllersFolder:WaitForChild("PlacementController") :: any)
				PlacementController.TogglePlacementMode()
			else
				UIController.ShowNotification("Aksi Cepat: " .. act.Name)
			end
		end)
	end

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
	hotbarSlotsData = {}
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
		iconLbl.Size = UDim2.new(1, 0, 1, 0)
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = slotIcons[slotIdx]
		iconLbl.TextSize = 18
		iconLbl.Parent = slotBtn

		hotbarSlotsData[slotIdx] = {
			Button = slotBtn,
			IconLabel = iconLbl,
			ItemName = nil,
			ItemType = nil,
		}

		slotBtn.MouseButton1Click:Connect(function()
			local slotData = hotbarSlotsData[slotIdx]
			if slotData and slotData.ItemName then
				local controllersFolder = script.Parent
				if slotData.ItemType == "Structure" then
					local PlacementController = require(controllersFolder:WaitForChild("PlacementController") :: any)
					PlacementController.StartPlacementForStructure(slotData.ItemName)
					UIController.ShowNotification("🏗️ Mode Pasang: " .. slotData.ItemName)
				elseif slotData.ItemType == "Consumable" then
					UIController.ShowNotification("🧪 Minum " .. slotData.ItemName .. " (+100% Aura Buff 60s)!")
					slotData.ItemName = nil
					slotData.ItemType = nil
					iconLbl.Text = slotIcons[slotIdx]
				end
			end
		end)
	end
end

local hotbarSlotsData: {{[string]: any}} = {}

function UIController.AddItemToHotbar(itemName: string, itemType: string)
	local iconMap = {
		["QuartzAltar_Tier1"] = "⛩️",
		["AstralGenerator_Tier2"] = "⚡",
		["PyroBuffPotion_Tier2"] = "🧪",
		["AuraElixir_Tier1"] = "🧪",
	}
	local icon = iconMap[itemName] or (itemType == "Structure" and "🏰" or "🧪")

	for i = 1, 5 do
		local slotData = hotbarSlotsData[i]
		if slotData and not slotData.ItemName then
			slotData.ItemName = itemName
			slotData.ItemType = itemType
			slotData.IconLabel.Text = icon .. " " .. string.sub(itemName, 1, 6)
			UIController.ShowNotification("🎒 Item masuk ke Hotbar Slot " .. i .. ": " .. itemName)
			return true
		end
	end
	UIController.ShowNotification("⚠️ Hotbar Penuh! Kosongkan slot terlebih dahulu.")
	return false
end

function UIController.CheckLiveOpsOverlays()
	-- Display join popup and topbar banner
	task.delay(1, function()
		if liveOpsBanner then
			liveOpsBanner.Visible = true
		end
		UIController.ShowNotification("🎉 LiveOps Boost Event Active!")
	end)
end

function UIController.UpdateWallet(aura: number, sparks: number)
	if walletAuraLabel then
		walletAuraLabel.Text = LocalizationController.Get("HUD_AURA", aura)
	end
	if walletSparksLabel then
		walletSparksLabel.Text = LocalizationController.Get("HUD_SPARKS", sparks)
	end
end

function UIController.ShowNotification(msg: string)
	if notificationLabel then
		notificationLabel.Text = msg
		notificationLabel.Visible = true
		task.delay(3, function()
			notificationLabel.Visible = false
		end)
	end
end

function UIController.RequestFlexEffect(effectType: string)
	local flexRemoteFunc = NetChannels.GetRemoteFunction("RequestFlexEffect")
	if flexRemoteFunc then
		local res = flexRemoteFunc:InvokeServer(effectType)
		if res and res.Message then
			UIController.ShowNotification(res.Message)
		end
		return res
	end
	return { Success = false, Message = "RemoteFunction missing" }
end

return UIController
