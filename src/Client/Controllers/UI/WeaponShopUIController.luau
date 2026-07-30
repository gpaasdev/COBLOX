--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local WeaponShopUIController = {}
WeaponShopUIController.__index = WeaponShopUIController

function WeaponShopUIController.new(parentGui, maid, notify)
	local self = setmetatable({}, WeaponShopUIController)
	self:Init(parentGui, maid)
	self.notify = notify
	return self
end

function WeaponShopUIController.Init(self, parentGui, maid)
	self.maid = Maid.new()
	self.parentGui = parentGui
	self.weaponShopGui = nil
	self.weaponShopOpen = false

	if maid then
		maid:GiveTask(function()
			self.maid:Destroy()
		end)
	end

	self:_CreateWeaponShopUI()
end

function WeaponShopUIController._CreateWeaponShopUI(self)
	local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")

	self.weaponShopGui = Instance.new("ScreenGui")
	self.weaponShopGui.Name = "WeaponShop"
	self.weaponShopGui.Enabled = false
	self.weaponShopGui.IgnoreGuiInset = true
	self.weaponShopGui.Parent = playerGui
	self.maid:GiveTask(self.weaponShopGui)

	local backdrop = Instance.new("Frame")
	backdrop.Size = UDim2.new(1, 0, 1, 0)
	backdrop.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	backdrop.BackgroundTransparency = 0.6
	backdrop.Parent = self.weaponShopGui

	self.maid:GiveTask(backdrop.InputBegan:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.Touch
			or input.UserInputType == Enum.UserInputType.MouseButton1
		then
			self:Toggle()
		end
	end))

	local container = Instance.new("Frame")
	container.Size = UDim2.new(0, 380, 0, 320)
	container.Position = UDim2.new(0.5, -190, 0.5, -160)
	container.BackgroundColor3 = Color3.fromRGB(30, 27, 75)
	container.BackgroundTransparency = 0.1
	container.BorderSizePixel = 0
	container.Parent = self.weaponShopGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 14)
	corner.Parent = container

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(1, 0, 0, 36)
	title.Position = UDim2.new(0, 0, 0, 8)
	title.BackgroundTransparency = 1
	title.Text = LocalizationController.Get("WEAPON_SHOP_TITLE")
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 20
	title.Parent = container

	local weapons = {
		{
			Name = LocalizationController.Get("WEAPON_FIST"),
			Id = "Fist",
			DMG = 10,
			Range = 8,
			Cost = LocalizationController.Get("COST_FREE"),
			Color = Color3.fromRGB(148, 163, 184),
		},
		{
			Name = LocalizationController.Get("WEAPON_IRON_SWORD"),
			Id = "IronSword",
			DMG = 25,
			Range = 14,
			Cost = LocalizationController.Get("COST_IRON_SWORD"),
			Color = Color3.fromRGB(168, 162, 158),
		},
		{
			Name = LocalizationController.Get("WEAPON_FLAME_SABER"),
			Id = "FlameSaber",
			DMG = 45,
			Range = 16,
			Cost = LocalizationController.Get("COST_FLAME_SABER"),
			Color = Color3.fromRGB(251, 146, 60),
		},
		{
			Name = LocalizationController.Get("WEAPON_AETHER_BLADE"),
			Id = "AetherBlade",
			DMG = 75,
			Range = 18,
			Cost = LocalizationController.Get("COST_AETHER_BLADE"),
			Color = Color3.fromRGB(56, 189, 248),
		},
		{
			Name = LocalizationController.Get("WEAPON_VOID_GREATSWORD"),
			Id = "VoidGreatsword",
			DMG = 120,
			Range = 22,
			Cost = LocalizationController.Get("COST_VOID_GREATSWORD"),
			Color = Color3.fromRGB(139, 92, 246),
		},
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
		statsLbl.Text = string.format(LocalizationController.Get("WEAPON_STATS_FORMAT"), w.DMG, w.Range)
		statsLbl.TextColor3 = Color3.fromRGB(200, 200, 200)
		statsLbl.Font = Enum.Font.GothamMedium
		statsLbl.TextSize = 12
		statsLbl.TextXAlignment = Enum.TextXAlignment.Center
		statsLbl.Parent = row

		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0.3, 0, 1, 0)
		buyBtn.Position = UDim2.new(0.7, 0, 0, 0)
		buyBtn.BackgroundTransparency = 0.3
		buyBtn.BackgroundColor3 = Color3.fromRGB(34, 197, 94)
		buyBtn.Text = w.Cost
		buyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		buyBtn.Font = Enum.Font.GothamBold
		buyBtn.TextSize = 11
		buyBtn.TextXAlignment = Enum.TextXAlignment.Center
		buyBtn.Parent = row

		local buyCorner = Instance.new("UICorner")
		buyCorner.CornerRadius = UDim.new(0, 6)
		buyCorner.Parent = buyBtn

		self.maid:GiveTask(buyBtn.MouseButton1Click:Connect(function()
			local purchaseRemote = NetChannels.GetRemoteEvent("PurchaseWeaponRequest")
			if purchaseRemote then
				purchaseRemote:FireServer(w.Id, "Coins")
				self.notify("Purchasing " .. w.Name .. "...")
			end
		end))

		yOff += 50
	end
end

function WeaponShopUIController.Toggle(self)
	self.weaponShopOpen = not self.weaponShopOpen
	if self.weaponShopGui then
		self.weaponShopGui.Enabled = self.weaponShopOpen
	end
	self.notify(
		if self.weaponShopOpen
			then LocalizationController.Get("NOTIF_WEAPON_OPEN")
			else LocalizationController.Get("NOTIF_WEAPON_CLOSE")
	)
end

function WeaponShopUIController.Open(self)
	self:Toggle()
end

return WeaponShopUIController
