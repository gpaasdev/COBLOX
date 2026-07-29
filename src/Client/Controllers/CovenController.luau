--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local localPlayer = Players.LocalPlayer
local CovenController = {}
CovenController.Name = "CovenController"

local modalFrame: Frame? = nil
local isVisible = false

local covenNameLabel: TextLabel
local levelLabel: TextLabel
local treasuryLabel: TextLabel
local buffLabel: TextLabel
local visitHideoutBtn: TextButton
local inviteGuestBtn: TextButton

function CovenController.Init()
	print("[CovenController] Initializing Coven (Guild) UI Engine with Hideout Controls...")
end

function CovenController.Start()
	self.maid = Maid.new()
	local covenRemote = NetChannels.GetRemoteEvent("CovenEvent")
	if covenRemote then
		self.maid:GiveTask(covenRemote.OnClientEvent:Connect(function(action: string, data: any)
			if action == "Sync" and type(data) == "table" then
				CovenController.UpdateCovenDisplay(data)
			elseif action == "GuestInviteReceived" and type(data) == "table" then
				print("[CovenController] Received Guest Invite to Coven: " .. tostring(data.CovenName))
			end
		end))
	end
end

function CovenController.ToggleModal()
	if not modalFrame then
		CovenController._CreateModal()
	end

	if modalFrame then
		isVisible = not isVisible
		modalFrame.Visible = isVisible
	end
end

function CovenController._CreateModal()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")

	modalFrame = Instance.new("Frame")
	modalFrame.Name = "CovenModal"
	modalFrame.Size = UDim2.new(0.5, 0, 0.7, 0)
	modalFrame.Position = UDim2.new(0.25, 0, 0.15, 0)
	modalFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Slate 900
	modalFrame.BorderSizePixel = 0
	modalFrame.ZIndex = 100
	modalFrame.Visible = false
	modalFrame.Parent = mainHUD

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modalFrame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(168, 85, 247) -- Purple Accent
	stroke.Thickness = 2
	stroke.Parent = modalFrame

	-- Header Title
	covenNameLabel = Instance.new("TextLabel")
	covenNameLabel.Size = UDim2.new(0.8, 0, 0.12, 0)
	covenNameLabel.Position = UDim2.new(0.05, 0, 0.04, 0)
	covenNameLabel.BackgroundTransparency = 1
	covenNameLabel.Text = LocalizationController.Get("COVEN_TITLE_DEFAULT")
	covenNameLabel.TextColor3 = Color3.fromRGB(248, 250, 252)
	covenNameLabel.Font = Enum.Font.GothamBold
	covenNameLabel.TextScaled = true
	covenNameLabel.Parent = modalFrame

	-- Close Button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0.08, 0, 0.08, 0)
	closeBtn.Position = UDim2.new(0.88, 0, 0.04, 0)
	closeBtn.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	closeBtn.Text = "X"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.TextScaled = true
	closeBtn.Parent = modalFrame

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	CovenController.maid:GiveTask(closeBtn.MouseButton1Click:Connect(function()
		CovenController.ToggleModal()
	end))

	-- Info Container
	levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(0.4, 0, 0.08, 0)
	levelLabel.Position = UDim2.new(0.05, 0, 0.18, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = LocalizationController.Get("COVEN_LEVEL", 1)
	levelLabel.TextColor3 = Color3.fromRGB(203, 213, 225)
	levelLabel.Font = Enum.Font.GothamMedium
	levelLabel.TextSize = 16
	levelLabel.Parent = modalFrame

	treasuryLabel = Instance.new("TextLabel")
	treasuryLabel.Size = UDim2.new(0.4, 0, 0.08, 0)
	treasuryLabel.Position = UDim2.new(0.5, 0, 0.18, 0)
	treasuryLabel.BackgroundTransparency = 1
	treasuryLabel.Text = LocalizationController.Get("COVEN_TREASURY", 0)
	treasuryLabel.TextColor3 = Color3.fromRGB(234, 179, 8)
	treasuryLabel.Font = Enum.Font.GothamMedium
	treasuryLabel.TextSize = 16
	treasuryLabel.Parent = modalFrame

	buffLabel = Instance.new("TextLabel")
	buffLabel.Size = UDim2.new(0.85, 0, 0.08, 0)
	buffLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
	buffLabel.BackgroundTransparency = 1
	buffLabel.Text = LocalizationController.Get("COVEN_BUFF", 0)
	buffLabel.TextColor3 = Color3.fromRGB(34, 197, 94)
	buffLabel.Font = Enum.Font.GothamBold
	buffLabel.TextSize = 18
	buffLabel.Parent = modalFrame

	-- Action 1: Create Coven
	local createBtn = Instance.new("TextButton")
	createBtn.Size = UDim2.new(0.42, 0, 0.12, 0)
	createBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
	createBtn.BackgroundColor3 = Color3.fromRGB(147, 51, 234)
	createBtn.Text = LocalizationController.Get("COVEN_BTN_CREATE")
	createBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	createBtn.Font = Enum.Font.GothamBold
	createBtn.TextSize = 14
	createBtn.Parent = modalFrame

	local createCorner = Instance.new("UICorner")
	createCorner.CornerRadius = UDim.new(0, 8)
	createCorner.Parent = createBtn

	CovenController.maid:GiveTask(createBtn.MouseButton1Click:Connect(function()
		local remote = NetChannels.GetRemoteEvent("CovenEvent")
		if remote then
			remote:FireServer("Create", localPlayer.Name .. "'s Order")
		end
	end))

	-- Action 2: Donate Treasury
	local donateBtn = Instance.new("TextButton")
	donateBtn.Size = UDim2.new(0.42, 0, 0.12, 0)
	donateBtn.Position = UDim2.new(0.51, 0, 0.42, 0)
	donateBtn.BackgroundColor3 = Color3.fromRGB(16, 185, 129)
	donateBtn.Text = LocalizationController.Get("COVEN_BTN_DONATE")
	donateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	donateBtn.Font = Enum.Font.GothamBold
	donateBtn.TextSize = 14
	donateBtn.Parent = modalFrame

	local donateCorner = Instance.new("UICorner")
	donateCorner.CornerRadius = UDim.new(0, 8)
	donateCorner.Parent = donateBtn

	CovenController.maid:GiveTask(donateBtn.MouseButton1Click:Connect(function()
		local remote = NetChannels.GetRemoteEvent("CovenEvent")
		if remote then
			remote:FireServer("Donate", 1000)
		end
	end))

	-- Action 3: Visit Instanced Hideout (NEW)
	visitHideoutBtn = Instance.new("TextButton")
	visitHideoutBtn.Size = UDim2.new(0.42, 0, 0.12, 0)
	visitHideoutBtn.Position = UDim2.new(0.05, 0, 0.6, 0)
	visitHideoutBtn.BackgroundColor3 = Color3.fromRGB(59, 130, 246) -- Blue
	visitHideoutBtn.Text = LocalizationController.Get("COVEN_VISIT_HIDEOUT")
	visitHideoutBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	visitHideoutBtn.Font = Enum.Font.GothamBold
	visitHideoutBtn.TextSize = 14
	visitHideoutBtn.Parent = modalFrame

	local visitCorner = Instance.new("UICorner")
	visitCorner.CornerRadius = UDim.new(0, 8)
	visitCorner.Parent = visitHideoutBtn

	CovenController.maid:GiveTask(visitHideoutBtn.MouseButton1Click:Connect(function()
		local remote = NetChannels.GetRemoteEvent("CovenEvent")
		if remote then
			remote:FireServer("TeleportToHideout")
		end
	end))

	-- Action 4: Invite Guest (NEW)
	inviteGuestBtn = Instance.new("TextButton")
	inviteGuestBtn.Size = UDim2.new(0.42, 0, 0.12, 0)
	inviteGuestBtn.Position = UDim2.new(0.51, 0, 0.6, 0)
	inviteGuestBtn.BackgroundColor3 = Color3.fromRGB(236, 72, 153) -- Pink Accent
	inviteGuestBtn.Text = LocalizationController.Get("COVEN_INVITE_GUEST")
	inviteGuestBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	inviteGuestBtn.Font = Enum.Font.GothamBold
	inviteGuestBtn.TextSize = 14
	inviteGuestBtn.Parent = modalFrame

	local inviteCorner = Instance.new("UICorner")
	inviteCorner.CornerRadius = UDim.new(0, 8)
	inviteCorner.Parent = inviteGuestBtn

	CovenController.maid:GiveTask(inviteGuestBtn.MouseButton1Click:Connect(function()
		-- Fire to server with the local player's own UserId as the invitee target.
		-- The server validates that the sender is a Coven leader before sending the invite.
		local remote = NetChannels.GetRemoteEvent("CovenEvent")
		if remote then
			-- Pass 0 as sentinel: server will use the targetted player selected in UI.
			-- Real target selection requires a player-picker UI (future feature).
			remote:FireServer("InviteGuest", 0)
		end
	end))
end

function CovenController.UpdateCovenDisplay(data: {
	Name: string,
	Level: number,
	TreasuryCoins: number,
	HideoutPlaceId: number?,
})
	if covenNameLabel then
		covenNameLabel.Text = "🏰 " .. data.Name
	end
	if levelLabel then
		levelLabel.Text = LocalizationController.Get("COVEN_LEVEL", data.Level)
	end
	if treasuryLabel then
		treasuryLabel.Text = LocalizationController.Get("COVEN_TREASURY", data.TreasuryCoins)
	end
	if buffLabel then
		local buffPercent = (data.Level - 1) * 5
		buffLabel.Text = LocalizationController.Get("COVEN_BUFF", buffPercent)
	end
end

return CovenController
