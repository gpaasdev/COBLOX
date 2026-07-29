--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local HapticService = game:GetService("HapticService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local localPlayer = Players.LocalPlayer
local clientFolder = script.Parent.Parent
local uiModules = clientFolder:WaitForChild("Modules"):WaitForChild("UI")

local UIButtonAnimator = require(uiModules:WaitForChild("UIButtonAnimator") :: any)
local UIEffectPool = require(uiModules:WaitForChild("UIEffectPool") :: any)
local UIAnimationEngine = require(uiModules:WaitForChild("UIAnimationEngine") :: any)
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
local hotbarSlotsData: {{[string]: any}} = {}

-- LGBOS v11.0 Sci-Fantasy Palette (Quantum Indigo #1E1B4B, Aura Gold #F59E0B, Spark Cyan #06B6D4)
local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_ACCENT_PURPLE = Color3.fromRGB(139, 92, 246)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

function UIController.Init()
	print("[UIController] Initializing Gen Z & Gen Alpha Visual-First HUD & Side Drawer (MaxWidth = 180px)...")
	
	UIController._CreateHUD()

end

function UIController.Start()
	local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
	if syncRemote then
		syncRemote.OnClientEvent:Connect(function(data: { Coins: number, Gems: number, AuraEnergy: number?, ChronoSparks: number? })
			local aura = data.AuraEnergy or data.Coins or 0
			local sparks = data.ChronoSparks or data.Gems or 0
			UIController.UpdateWallet(aura, sparks)
		end)
	end

	-- Trigger configurable LiveOps Join Popup & TopBar Banner
	UIController.CheckLiveOpsOverlays()

	-- Realm Selection Guide
	task.delay(5, function()
		UIController.ShowNotification("Press [R] to open Realm Selection — explore the Fairytale Realm!")
	end)

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
	questBanner.Position = UDim2.new(0.99, 0, 0.15, 0) -- Top-Right, avoiding TopBar
	questBanner.BackgroundColor3 = COLOR_BG_DARK
	questBanner.BackgroundTransparency = 0.4
	questBanner.BorderSizePixel = 0
	questBanner.ZIndex = 55
	questBanner.Parent = mainScreenGui

	local questGradient = Instance.new("UIGradient")
	questGradient.Rotation = 90
	questGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, COLOR_BG_DARK), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110))})
	questGradient.Parent = questBanner

	local questPadding = Instance.new("UIPadding")
	questPadding.PaddingLeft = UDim.new(0, 10)
	questPadding.PaddingRight = UDim.new(0, 10)
	questPadding.Parent = questBanner

	local questCorner = Instance.new("UICorner")
	questCorner.CornerRadius = UDim.new(0, 10)
	questCorner.Parent = questBanner

	local questStroke = Instance.new("UIStroke")
	questStroke.Color = COLOR_AURA_GOLD
	questStroke.Thickness = 2
	questStroke.Parent = questBanner

	local questAspect = Instance.new("UIAspectRatioConstraint")
	questAspect.AspectRatio = 3.5
	questAspect.Parent = questBanner

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
	questTitle.TextStrokeTransparency = 0.4
	questTitle.Parent = questBanner

	local questDesc = Instance.new("TextLabel")
	questDesc.Name = "QuestDesc"
	questDesc.Size = UDim2.new(0.9, 0, 0.4, 0)
	questDesc.Position = UDim2.new(0.05, 0, 0.52, 0)
	questDesc.BackgroundTransparency = 1
	questDesc.Text = LocalizationController.Get("FTUE_VISIT_SANCTUM")
	questDesc.TextColor3 = COLOR_SPARK_CYAN
	questDesc.Font = Enum.Font.GothamMedium
	questDesc.TextSize = 12
	questDesc.TextXAlignment = Enum.TextXAlignment.Left
	questDesc.TextStrokeTransparency = 0.35
	questDesc.Parent = questBanner

	-- 1. Top Bar (Aura Energy & Chrono Sparks)
	-- Aura Pill
	local auraBar = Instance.new("Frame")
	auraBar.Name = "AuraBar"
	auraBar.Size = UDim2.new(0.18, 0, 0.05, 0)
	auraBar.AnchorPoint = Vector2.new(1, 0)
	auraBar.Position = UDim2.new(0.99, 0, 0.02, 0)
	auraBar.BackgroundColor3 = COLOR_BG_DARK
	auraBar.BackgroundTransparency = 0.4
	auraBar.BorderSizePixel = 0
	auraBar.ZIndex = 50
	auraBar.Parent = mainScreenGui

	local auraGradient = Instance.new("UIGradient")
	auraGradient.Rotation = 90
	auraGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, COLOR_BG_DARK), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110))})
	auraGradient.Parent = auraBar

	local auraCorner = Instance.new("UICorner")
	auraCorner.CornerRadius = UDim.new(0, 12)
	auraCorner.Parent = auraBar
	
	local auraStroke = Instance.new("UIStroke")
	auraStroke.Color = COLOR_AURA_GOLD
	auraStroke.Thickness = 1.5
	auraStroke.Parent = auraBar

	walletAuraLabel = Instance.new("TextLabel")
	walletAuraLabel.Name = "AuraLabel"
	walletAuraLabel.Size = UDim2.new(1, 0, 1, 0)
	walletAuraLabel.BackgroundTransparency = 1
	walletAuraLabel.TextColor3 = COLOR_AURA_GOLD
	walletAuraLabel.Font = Enum.Font.FredokaOne
	walletAuraLabel.TextSize = 16
	walletAuraLabel.Text = LocalizationController.Get("HUD_AURA", 0)
	walletAuraLabel.Parent = auraBar

	local auraTextStroke = Instance.new("UIStroke")
	auraTextStroke.Color = Color3.fromRGB(0, 0, 0)
	auraTextStroke.Thickness = 1.5
	auraTextStroke.Parent = walletAuraLabel

	-- Sparks Pill
	local sparksBar = Instance.new("Frame")
	sparksBar.Name = "SparksBar"
	sparksBar.Size = UDim2.new(0.15, 0, 0.05, 0)
	sparksBar.AnchorPoint = Vector2.new(1, 0)
	sparksBar.Position = UDim2.new(0.80, 0, 0.02, 0)
	sparksBar.BackgroundColor3 = COLOR_BG_DARK
	sparksBar.BackgroundTransparency = 0.4
	sparksBar.BorderSizePixel = 0
	sparksBar.ZIndex = 50
	sparksBar.Parent = mainScreenGui

	local sparksGradient = Instance.new("UIGradient")
	sparksGradient.Rotation = 90
	sparksGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, COLOR_BG_DARK), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110))})
	sparksGradient.Parent = sparksBar

	local sparksCorner = Instance.new("UICorner")
	sparksCorner.CornerRadius = UDim.new(0, 12)
	sparksCorner.Parent = sparksBar
	
	local sparksStroke = Instance.new("UIStroke")
	sparksStroke.Color = COLOR_SPARK_CYAN
	sparksStroke.Thickness = 1.5
	sparksStroke.Parent = sparksBar

	walletSparksLabel = Instance.new("TextLabel")
	walletSparksLabel.Name = "SparksLabel"
	walletSparksLabel.Size = UDim2.new(1, 0, 1, 0)
	walletSparksLabel.BackgroundTransparency = 1
	walletSparksLabel.TextColor3 = COLOR_SPARK_CYAN
	walletSparksLabel.Font = Enum.Font.FredokaOne
	walletSparksLabel.TextSize = 16
	walletSparksLabel.Text = LocalizationController.Get("HUD_SPARKS", 0)
	walletSparksLabel.Parent = sparksBar

	local sparksTextStroke = Instance.new("UIStroke")
	sparksTextStroke.Color = Color3.fromRGB(0, 0, 0)
	sparksTextStroke.Thickness = 1.5
	sparksTextStroke.Parent = walletSparksLabel

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

	local bannerStroke = Instance.new("UIStroke")
	bannerStroke.Color = Color3.fromRGB(0, 0, 0)
	bannerStroke.Thickness = 1.2
	bannerStroke.Parent = liveOpsBanner

	-- Hamburger Toggle Button
	local menuBtn = Instance.new("TextButton")
	menuBtn.Name = "MobileMenuBtn"
	menuBtn.Size = UDim2.new(0, 44, 0, 44)
	menuBtn.Position = UDim2.new(0.01, 0, 0.70, 0)
	menuBtn.BackgroundColor3 = COLOR_BG_DARK
	menuBtn.BackgroundTransparency = 0.4
	menuBtn.TextColor3 = COLOR_TEXT_WHITE
	menuBtn.Font = Enum.Font.FredokaOne
	menuBtn.TextSize = 22
	menuBtn.Text = "☰"
	menuBtn.ZIndex = 50
	menuBtn.Parent = mainScreenGui

	local menuCorner = Instance.new("UICorner")
	menuCorner.CornerRadius = UDim.new(0, 10)
	menuCorner.Parent = menuBtn
	
	local menuStroke = Instance.new("UIStroke")
	menuStroke.Color = COLOR_ACCENT_PURPLE
	menuStroke.Thickness = 1.5
	menuStroke.Parent = menuBtn

	UIButtonAnimator.BindButton(menuBtn, { "Click", "Audio" }, function()
		if sideDrawer then
			sideDrawer.Visible = not sideDrawer.Visible
		end
	end)

	-- 2. Side Drawer (Max Width 160px Collapsible)
	sideDrawer = Instance.new("Frame")
	sideDrawer.Name = "SideDrawer"
	sideDrawer.Size = UDim2.new(0, 160, 0.60, 0)
	sideDrawer.Position = UDim2.new(0.01, 50, 0.15, 0)
	sideDrawer.BackgroundColor3 = COLOR_BG_DARK
	sideDrawer.BackgroundTransparency = 0.4
	sideDrawer.BorderSizePixel = 0
	sideDrawer.ZIndex = 40
	sideDrawer.Visible = false -- Always collapsed by default
	sideDrawer.Parent = mainScreenGui

	local drawerCorner = Instance.new("UICorner")
	drawerCorner.CornerRadius = UDim.new(0, 12)
	drawerCorner.Parent = sideDrawer

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = sideDrawer

	local drawerButtons = { "Markas Saya", "Lab Racik", "Panggil Spirit", "Klan Player", "Senjata", "Toko Premium" }
	local drawerKeys = {
		["Markas Saya"] = "SIDE_SANCTUM_GRID",
		["Lab Racik"] = "SIDE_SYNTHESIS_VESSEL",
		["Panggil Spirit"] = "SIDE_SPIRIT_HATCHERY",
		["Klan Player"] = "SIDE_COVEN_ORDER",
		["Senjata"] = "SIDE_WEAPON_SHOP",
		["Toko Premium"] = "SIDE_STORE",
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

		local btnTextStroke = Instance.new("UIStroke")
		btnTextStroke.Color = Color3.fromRGB(0, 0, 0)
		btnTextStroke.Thickness = 1.5
		btnTextStroke.Parent = btn

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
			elseif btnName == "Senjata" or text == "Senjata" or text == "Weapon Shop" or text == "Sword" then
				UIController._OpenWeaponShop()
			elseif btnName == "Toko Premium" or text == "Toko Premium" or text == "Premium Store" or text == "Store" then
				local StoreController = require(controllersFolder:WaitForChild("StoreController") :: any)
				StoreController.ToggleModal()
			else
				UIController.ShowNotification("Buka: " .. text)
			end
		end)
	end

	-- 2.75 Weapon Shop Modal (Hidden by default)
	UIController._CreateWeaponShopUI()

	-- 3. Notification Banner (Toast)
	notificationLabel = Instance.new("TextLabel")
	notificationLabel.Name = "NotificationBanner"
	notificationLabel.Size = UDim2.new(0.48, 0, 0.055, 0)
	notificationLabel.Position = UDim2.new(0.26, 0, 0.14, 0)
	notificationLabel.BackgroundColor3 = COLOR_BG_DARK
	notificationLabel.BackgroundTransparency = 0.4
	notificationLabel.TextColor3 = COLOR_TEXT_WHITE
	notificationLabel.Font = Enum.Font.FredokaOne
	notificationLabel.TextSize = 15
	notificationLabel.ZIndex = 300 -- Always on top of all modals
	notificationLabel.Text = "Welcome to Multiverse Alchemy Sanctum!"
	notificationLabel.Visible = false
	notificationLabel.Parent = mainScreenGui

	local notifGradient = Instance.new("UIGradient")
	notifGradient.Rotation = 90
	notifGradient.Color = ColorSequence.new({ColorSequenceKeypoint.new(0, COLOR_BG_DARK), ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 40, 110))})
	notifGradient.Parent = notificationLabel

	local notifCorner = Instance.new("UICorner")
	notifCorner.CornerRadius = UDim.new(0, 10)
	notifCorner.Parent = notificationLabel

	local notifStroke = Instance.new("UIStroke")
	notifStroke.Color = Color3.fromRGB(0, 0, 0) -- High-contrast solid black stroke
	notifStroke.Thickness = 2.5
	notifStroke.Parent = notificationLabel

	-- 4. Bottom Viral Action Hotbar & Inventory Slots HUD (Grow a Garden / Pet Sim Benchmark)
	local bottomBar = Instance.new("Frame")
	bottomBar.Name = "BottomActionHotbar"
	bottomBar.Size = UDim2.new(0.65, 0, 0.10, 0)
	bottomBar.Position = UDim2.new(0.175, 0, 0.88, 0)
	bottomBar.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Dark Glassmorphism base
	bottomBar.BackgroundTransparency = 0.2
	bottomBar.BorderSizePixel = 0
	bottomBar.ZIndex = 60
	bottomBar.Parent = mainScreenGui

	local bottomCorner = Instance.new("UICorner")
	bottomCorner.CornerRadius = UDim.new(0, 14)
	bottomCorner.Parent = bottomBar

	local bottomStroke = Instance.new("UIStroke")
	bottomStroke.Color = COLOR_SPARK_CYAN -- Neon Cyan accent
	bottomStroke.Thickness = 1.5
	bottomStroke.Parent = bottomBar

	local bottomAspect = Instance.new("UIAspectRatioConstraint")
	bottomAspect.AspectRatio = 4.5
	bottomAspect.Parent = bottomBar

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
		{ Name = "⚡ DASH", Color = Color3.fromRGB(14, 165, 233) },
		{ Name = "🌱 ELEMEN", Color = Color3.fromRGB(34, 197, 94) },
		{ Name = "🏰 MARKAS", Color = Color3.fromRGB(168, 85, 247) },
		{ Name = "🐣 SPIRIT", Color = Color3.fromRGB(249, 115, 22) },
		{ Name = "💰 JUAL", Color = Color3.fromRGB(234, 179, 8) },
	}

	for _, act in ipairs(quickActions) do
		local pill = Instance.new("TextButton")
		pill.Name = "Pill_" .. act.Name
		pill.Size = UDim2.new(0.17, 0, 1, 0)
		pill.BackgroundColor3 = Color3.fromRGB(30, 41, 59) -- Lighter slate for inner buttons
		pill.BackgroundTransparency = 0.3
		pill.TextColor3 = act.Color
		pill.Font = Enum.Font.FredokaOne
		pill.TextSize = 12
		pill.Text = act.Name
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

		local isMounted = false
		UIButtonAnimator.BindButton(pill, { "Hover", "Click", "Audio" }, function()
			local controllersFolder = script.Parent
			if act.Name == "⚡ DASH" then
				local char = localPlayer.Character
				if char and char:FindFirstChild("HumanoidRootPart") then
					local hrp = char.HumanoidRootPart
					hrp.AssemblyLinearVelocity = hrp.CFrame.LookVector * 100 -- Propel forward
					
					-- Tactile Audio & Visual Polish
					local AudioController = require(controllersFolder:WaitForChild("AudioController") :: any)
					pcall(function()
						AudioController.PlaySound("rbxassetid://12222204", 0.8) -- Valid Dash swoosh SFX
					end)
					
					UIController.ShowNotification("⚡ Dash Activated!")
				end
			elseif act.Name == "🐶 PETS" then
				UIController.ShowNotification("Menu Inventory Pet akan segera hadir!")
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

	-- 4.5 Realm Key Hint
	local realmHint = Instance.new("TextLabel")
	realmHint.Name = "RealmKeyHint"
	realmHint.Size = UDim2.new(0, 140, 0, 24)
	realmHint.Position = UDim2.new(0.5, -70, 0.78, 0)
	realmHint.BackgroundTransparency = 1
	realmHint.Text = "[R] Realm Selection"
	realmHint.TextColor3 = COLOR_ACCENT_PURPLE
	realmHint.Font = Enum.Font.GothamBold
	realmHint.TextSize = 13
	realmHint.TextStrokeTransparency = 0.3
	realmHint.Parent = mainScreenGui

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

local weaponShopGui: ScreenGui? = nil
local weaponShopOpen = false

function UIController._CreateWeaponShopUI()
	weaponShopGui = Instance.new("ScreenGui")
	weaponShopGui.Name = "WeaponShop"
	weaponShopGui.Enabled = false
	weaponShopGui.IgnoreGuiInset = true
	weaponShopGui.Parent = playerGui

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.6
	backdrop.Parent = weaponShopGui

	backdrop.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.Touch or input.UserInputType == Enum.UserInputType.MouseButton1 then
			UIController._ToggleWeaponShop()
		end
	end)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 380, 0, 320)
	container.Position = UDim2.new(0.5, -190, 0.5, -160)
	container.BackgroundColor3 = Color3.fromRGB(30, 27, 75)
	container.BackgroundTransparency = 0.1
	container.BorderSizePixel = 0
	container.Parent = weaponShopGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 36)
	title.Position = UDim2.new(0, 0, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = "Weapon Shop"
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = container

	local weapons = {
		{ Name = "Fist", DMG = 10, Range = 8, Cost = "Free", Color = Color3.fromRGB(148, 163, 184) },
		{ Name = "Iron Sword", DMG = 25, Range = 14, Cost = "5,000 Coins", Color = Color3.fromRGB(168, 162, 158) },
		{ Name = "Flame Saber", DMG = 45, Range = 16, Cost = "25,000 Coins / 79 R$", Color = Color3.fromRGB(251, 146, 60) },
		{ Name = "Aether Blade", DMG = 75, Range = 18, Cost = "100,000 Coins / 199 R$", Color = Color3.fromRGB(56, 189, 248) },
		{ Name = "Void Greatsword", DMG = 120, Range = 22, Cost = "500,000 Coins / 499 R$", Color = Color3.fromRGB(139, 92, 246) },
	}

	local yOff = 50
	for _, w in ipairs(weapons) do
		local row = Instance.new("Frame")
		row.Size = UDim2.new(0.92, 0, 0, 44)
		row.Position = UDim2.new(0.04, 0, 0, yOff)
		row.BackgroundColor3 = w.Color
		row.BackgroundTransparency = 0.7
		row.Parent = container

		local rCorner = Instance.new("UICorner")
		rCorner.CornerRadius = UDim.new(0, 8)
		rCorner.Parent = row

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0.35, 0, 1, 0)
		nameLbl.Position = UDim2.new(0, 8, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = w.Name
		nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.TextSize = 14
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Parent = row

		local statsLbl = Instance.new("TextLabel")
		statsLbl.Size = UDim2.new(0.35, 0, 1, 0)
		statsLbl.Position = UDim2.new(0.35, 0, 0, 0)
		statsLbl.BackgroundTransparency = 1
		statsLbl.Text = string.format("DMG:%d RNG:%d", w.DMG, w.Range)
		statsLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
		statsLbl.Font = Enum.Font.GothamMedium
		statsLbl.TextSize = 12
		statsLbl.TextXAlignment = Enum.TextXAlignment.Center
		statsLbl.Parent = row

		local costLbl = Instance.new("TextLabel")
		costLbl.Size = UDim2.new(0.3, 0, 1, 0)
		costLbl.Position = UDim2.new(0.7, 0, 0, 0)
		costLbl.BackgroundTransparency = 1
		costLbl.Text = w.Cost
		costLbl.TextColor3 = Color3.fromRGB(255, 215, 0)
		costLbl.Font = Enum.Font.GothamBold
		costLbl.TextSize = 11
		costLbl.TextXAlignment = Enum.TextXAlignment.Center
		costLbl.Parent = row

		yOff += 50
	end
end

function UIController._ToggleWeaponShop()
	weaponShopOpen = not weaponShopOpen
	if weaponShopGui then
		weaponShopGui.Enabled = weaponShopOpen
	end
	UIController.ShowNotification(if weaponShopOpen then "🔪 Weapon Shop opened" else "Weapon Shop closed")
end

function UIController._OpenWeaponShop()
	UIController._ToggleWeaponShop()
end

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
		
		-- Spring Physics Popup Bounce
		UIAnimationEngine.AnimateScale(notificationLabel, 1.1)
		task.delay(0.1, function()
			UIAnimationEngine.AnimateScale(notificationLabel, 1.0)
		end)
		
		-- Audio Chime
		local controllersFolder = script.Parent
		local AudioController = require(controllersFolder:WaitForChild("AudioController") :: any)
		pcall(function()
			AudioController.PlaySound("rbxassetid://12222076", 1.0) -- Crisp UI pop chime
		end)
        
        -- Haptic Feedback (Juiciness)
        if UserInputService.TouchEnabled then
            pcall(function()
                if HapticService:IsMotorSupported(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small) then
                    HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0.5)
                    task.delay(0.1, function()
                        HapticService:SetMotor(Enum.UserInputType.Gamepad1, Enum.VibrationMotor.Small, 0)
                    end)
                end
            end)
        end

		task.delay(3, function()
			UIAnimationEngine.AnimateScale(notificationLabel, 0.8)
			task.delay(0.15, function()
				notificationLabel.Visible = false
				UIAnimationEngine.AnimateScale(notificationLabel, 1.0)
			end)
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
