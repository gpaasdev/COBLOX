--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)

local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local PotionVaultController = {}
PotionVaultController.Name = "PotionVaultController"

local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local modalFrame: Frame? = nil
local isVisible = false
local vaultSlots: { Frame } = {}

local VAULT_SLOT_COLORS = {
	Color3.fromRGB(251, 191, 36),
	Color3.fromRGB(34, 197, 94),
	Color3.fromRGB(56, 189, 248),
	Color3.fromRGB(168, 85, 247),
	Color3.fromRGB(239, 68, 68),
	Color3.fromRGB(244, 114, 182),
}

function PotionVaultController.Init() end

function PotionVaultController.Start(self)
	self.maid = Maid.new()
	local vaultSync = NetChannels.GetRemoteEvent("SyncPotionVault")
	if vaultSync then
		self.maid:GiveTask(vaultSync.OnClientEvent:Connect(function(slots: { { ItemId: string, Yield: number } })
			PotionVaultController.UpdateVault(slots)
		end))
	end
end

function PotionVaultController.ToggleModal()
	if not modalFrame then
		PotionVaultController._CreateUI()
	end
	if modalFrame then
		isVisible = not isVisible
		modalFrame.Visible = isVisible
	end
end

function PotionVaultController._CreateUI(self)
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "PotionVaultModal"
	modalFrame.Size = UDim2.new(0.55, 0, 0.6, 0)
	modalFrame.Position = UDim2.new(0.225, 0, 0.2, 0)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	modalFrame.BorderSizePixel = 0
	modalFrame.Visible = false
	modalFrame.ZIndex = 50
	modalFrame.Parent = mainHUD
	self.maid:GiveTask(modalFrame)

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(168, 85, 247)
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0.8, 0, 0.1, 0)
	title.Position = UDim2.new(0.1, 0, 0.04, 0)
	title.BackgroundTransparency = 1
	title.Text = LocalizationController.Get("VAULT_TITLE")
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextScaled = true
	title.Parent = modalFrame

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Vertical
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 12)
	layout.Parent = modalFrame

	for i = 1, 6 do
		local slot = Instance.new("Frame")
		slot.Name = "VaultSlot_" .. i
		slot.Size = UDim2.new(0.85, 0, 0.12, 0)
		slot.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
		slot.BorderSizePixel = 0
		slot.Parent = modalFrame

		local sCorner = Instance.new("UICorner")
		sCorner.CornerRadius = UDim.new(0, 8)
		sCorner.Parent = slot

		local sStroke = Instance.new("UIStroke")
		sStroke.Color = VAULT_SLOT_COLORS[i]
		sStroke.Thickness = 1.5
		sStroke.Parent = slot

		local icon = Instance.new("TextLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0.2, 0, 1, 0)
		icon.BackgroundTransparency = 1
		icon.Text = "⚗️"
		icon.TextSize = 24
		icon.Parent = slot

		local info = Instance.new("TextLabel")
		info.Name = "Info"
		info.Size = UDim2.new(0.5, 0, 1, 0)
		info.Position = UDim2.new(0.2, 0, 0, 0)
		info.BackgroundTransparency = 1
		info.Text = LocalizationController.Get("VAULT_EMPTY")
		info.TextColor3 = Color3.fromRGB(148, 163, 184)
		info.Font = Enum.Font.GothamBold
		info.TextSize = 16
		info.Parent = slot

		local yieldLbl = Instance.new("TextLabel")
		yieldLbl.Name = "Yield"
		yieldLbl.Size = UDim2.new(0.3, 0, 1, 0)
		yieldLbl.Position = UDim2.new(0.7, 0, 0, 0)
		yieldLbl.BackgroundTransparency = 1
		yieldLbl.Text = LocalizationController.Get("VAULT_YIELD_ZERO")
		yieldLbl.TextColor3 = Color3.fromRGB(34, 197, 94)
		yieldLbl.Font = Enum.Font.FredokaOne
		yieldLbl.TextSize = 18
		yieldLbl.Parent = slot

		table.insert(vaultSlots, slot)
	end

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0.3, 0, 0.08, 0)
	closeBtn.Position = UDim2.new(0.35, 0, 0.88, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	closeBtn.Text = LocalizationController.Get("CLOSE_BUTTON")
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextSize = 14
	closeBtn.Parent = modalFrame
	self.maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		PotionVaultController.ToggleModal()
	end))

	local cCorner = Instance.new("UICorner")
	cCorner.CornerRadius = UDim.new(0, 8)
	cCorner.Parent = closeBtn
end

function PotionVaultController.UpdateVault(slots: { { ItemId: string, Yield: number } })
	for i, slotFrame in ipairs(vaultSlots) do
		local info = slotFrame:FindFirstChild("Info")
		local yieldLbl = slotFrame:FindFirstChild("Yield")
		local slotData = slots[i]
		if slotData and slotData.ItemId and slotData.ItemId ~= "" then
			if info then
				info.Text = slotData.ItemId
				info.TextColor3 = Color3.fromRGB(255, 255, 255)
			end
			if yieldLbl then
				yieldLbl.Text = tostring(slotData.Yield) .. "/s"
			end
		else
			if info then
				info.Text = LocalizationController.Get("VAULT_EMPTY")
				info.TextColor3 = Color3.fromRGB(148, 163, 184)
			end
			if yieldLbl then
				yieldLbl.Text = LocalizationController.Get("VAULT_YIELD_ZERO")
			end
		end
	end
end

return PotionVaultController
