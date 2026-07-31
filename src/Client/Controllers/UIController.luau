--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local localPlayer = Players.LocalPlayer
local clientFolder = script.Parent.Parent
local uiModules = clientFolder:WaitForChild("Modules"):WaitForChild("UI")

local UIButtonAnimator = require(uiModules:WaitForChild("UIButtonAnimator") :: any)
local UIEffectPool = require(uiModules:WaitForChild("UIEffectPool") :: any)
local VFXEngine = require(uiModules:WaitForChild("VFXEngine") :: any)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local UIHUDController = require(script.Parent.UI.UIHUDController)
local WalletUIController = require(script.Parent.UI.WalletUIController)
local WeaponShopUIController = require(script.Parent.UI.WeaponShopUIController)
local NotificationController = require(script.Parent.UI.NotificationController)
local LiveOpsUIController = require(script.Parent.UI.LiveOpsUIController)
local HotbarController = require(script.Parent.UI.HotbarController)

local UIController = {}
UIController.Name = "UIController"

local playerGui: PlayerGui? = nil
local mainScreenGui: ScreenGui
local sideDrawer: Frame

-- LGBOS v11.0 Sci-Fantasy Palette (Quantum Indigo #1E1B4B, Aura Gold #F59E0B, Spark Cyan #06B6D4)
local COLOR_BG_DARK = Color3.fromRGB(30, 27, 75)
local COLOR_AURA_GOLD = Color3.fromRGB(245, 158, 11)
local COLOR_SPARK_CYAN = Color3.fromRGB(6, 182, 212)
local COLOR_ACCENT_PURPLE = Color3.fromRGB(139, 92, 246)
local COLOR_TEXT_WHITE = Color3.fromRGB(255, 255, 255)

function UIController.Init(self)
	self.maid = Maid.new()
	print("[UIController] Initializing Gen Z & Gen Alpha Visual-First HUD & Side Drawer (MaxWidth = 180px)...")

	UIController:_CreateHUD()
end

function UIController.ShowNotification(self, msg: string)
	if self.notificationController then
		self.notificationController:Show(msg)
	end
end

function UIController.Start(self)
	local syncRemote = NetChannels.GetRemoteEvent("SyncEconomy")
	if syncRemote then
		self.maid:GiveTask(
			syncRemote.OnClientEvent:Connect(
				function(data: { Coins: number, Gems: number, AuraEnergy: number?, ChronoSparks: number? })
					local aura = data.AuraEnergy or 0
					local sparks = data.ChronoSparks or 0
					local coins = data.Coins or 0
					local gems = data.Gems or 0
					if self.walletController then
						self.walletController:UpdateWallet(aura, sparks, coins, gems)
					end
				end
			)
		)
	end

	-- Trigger configurable LiveOps Join Popup & TopBar Banner
	if self.liveOpsController then
		self.liveOpsController:CheckOverlays()
	end

	-- Realm Selection Guide
	task.delay(5, function()
		if self.notificationController then
			self.notificationController:Show(LocalizationController.Get("NOTIF_REALM_SELECT"))
		end
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

function UIController._CreateHUD(self)
	if not playerGui then
		playerGui = localPlayer:WaitForChild("PlayerGui") :: PlayerGui
	end

	mainScreenGui = Instance.new("ScreenGui")
	mainScreenGui.Name = "COBLOX_AlchemyHUD"
	mainScreenGui.ResetOnSpawn = false
	mainScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	mainScreenGui.Parent = playerGui
	UIController.maid:GiveTask(mainScreenGui)

	-- Initialize UI Particle ImageLabel Pool
	UIEffectPool.Init(mainScreenGui)

	-- Create sub-controllers
	self.notificationController = NotificationController.new(mainScreenGui, self.maid)

	local notify = function(msg)
		if self.notificationController then
			self.notificationController:Show(msg)
		end
	end

	self.hudController = UIHUDController.new(mainScreenGui, self.maid, notify)
	self.walletController = WalletUIController.new(mainScreenGui, self.maid)
	self.weaponShopController = WeaponShopUIController.new(mainScreenGui, self.maid, notify)
	self.liveOpsController = LiveOpsUIController.new(mainScreenGui, self.maid, notify)
	self.hotbarController = HotbarController.new(mainScreenGui, self.maid, notify)

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
	sideDrawer.Visible = false
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
			local text = btn.Text
			if
				btnName == "Lab Racik"
				or text == "Lab Racik"
				or text == "Alchemist Lab"
				or text == "Synthesis Vessel"
			then
				local SynthesisController = require(script.Parent:WaitForChild("SynthesisController") :: any)
				SynthesisController.ToggleModal()
			elseif
				btnName == "Panggil Spirit"
				or text == "Panggil Spirit"
				or text == "Hatch Spirit"
				or text == "Hatch Telur Pet"
				or text == "Spirit Hatchery"
			then
				local EggRenderController = require(script.Parent:WaitForChild("EggRenderController") :: any)
				EggRenderController.ToggleModal()
			elseif
				btnName == "Klan Player"
				or text == "Klan Player"
				or text == "Player Clan"
				or text == "Clan Alkemis"
				or text == "Coven Order"
			then
				local CovenController = require(script.Parent:WaitForChild("CovenController") :: any)
				CovenController.ToggleModal()
			elseif
				btnName == "Buku Resep & Spirit"
				or text == "Buku Resep & Spirit"
				or text == "Recipe Codex"
				or text == "Codex"
			then
				local CodexController = require(script.Parent:WaitForChild("CodexController") :: any)
				CodexController.ToggleModal()
			elseif
				btnName == "Markas Saya"
				or text == "Markas Saya"
				or text == "My Sanctum"
				or text == "Sanctum Grid"
			then
				local PlacementController = require(script.Parent:WaitForChild("PlacementController") :: any)
				PlacementController.TogglePlacementMode()
			elseif btnName == "Senjata" or text == "Senjata" or text == "Weapon Shop" or text == "Sword" then
				self.weaponShopController:Open()
			elseif
				btnName == "Toko Premium"
				or text == "Toko Premium"
				or text == "Premium Store"
				or text == "Store"
			then
				local StoreController = require(script.Parent:WaitForChild("StoreController") :: any)
				StoreController.ToggleModal()
			else
				self.notificationController:Show(LocalizationController.Get("NOTIF_SIDE_DRAWER", text))
			end
		end)
	end
end

return UIController
