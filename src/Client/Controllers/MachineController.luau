--!strict

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")

local MachineController = {}
MachineController.Name = "MachineController"

local _machineEvent: RemoteEvent?

function MachineController.Init()
	local sharedEvents = ReplicatedStorage:FindFirstChild("Shared")
		and ReplicatedStorage.Shared:FindFirstChild("Events")
	if sharedEvents then
		local machineEvents = sharedEvents:FindFirstChild("MachineEvents")
		if machineEvents then
			_machineEvent = machineEvents:FindFirstChild("MachineInteraction") :: RemoteEvent?
		end
	end
	print("[MachineController] Initialized machine status viewer.")
end

function MachineController.Start()
	local localPlayer = Players.LocalPlayer

	local function setupMachineHUD(machinePart: BasePart)
		if not machinePart:IsA("BasePart") then
			return
		end

		local bb = Instance.new("BillboardGui")
		bb.Name = "MachineHUD"
		bb.Size = UDim2.new(0, 200, 0, 100)
		bb.StudsOffset = Vector3.new(0, 4, 0)
		bb.MaxDistance = 30
		bb.AlwaysOnTop = false
		bb.Enabled = false
		bb.Parent = machinePart

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, 0, 1, 0)
		card.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
		card.BackgroundTransparency = 0.15
		card.BorderSizePixel = 0
		card.Parent = bb

		local uiCorner = Instance.new("UICorner")
		uiCorner.CornerRadius = UDim.new(0, 8)
		uiCorner.Parent = card

		local uiStroke = Instance.new("UIStroke")
		uiStroke.Color = Color3.fromRGB(56, 189, 248)
		uiStroke.Thickness = 1.5
		uiStroke.Parent = card

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Name = "MachineName"
		nameLbl.Size = UDim2.new(1, -8, 0, 22)
		nameLbl.Position = UDim2.new(0, 4, 0, 2)
		nameLbl.BackgroundTransparency = 1
		nameLbl.TextColor3 = Color3.fromRGB(245, 248, 255)
		nameLbl.TextScaled = true
		nameLbl.Font = Enum.Font.GothamBold
		nameLbl.Text = machinePart.Name
		nameLbl.Parent = card

		local statusLbl = Instance.new("TextLabel")
		statusLbl.Name = "Status"
		statusLbl.Size = UDim2.new(1, -8, 0, 18)
		statusLbl.Position = UDim2.new(0, 4, 0, 24)
		statusLbl.BackgroundTransparency = 1
		statusLbl.TextColor3 = Color3.fromRGB(134, 239, 172)
		statusLbl.TextScaled = true
		statusLbl.Font = Enum.Font.GothamMedium
		statusLbl.Text = "Status: Optimal"
		statusLbl.Parent = card

		local powerLbl = Instance.new("TextLabel")
		powerLbl.Name = "Power"
		powerLbl.Size = UDim2.new(1, -8, 0, 18)
		powerLbl.Position = UDim2.new(0, 4, 0, 42)
		powerLbl.BackgroundTransparency = 1
		powerLbl.TextColor3 = Color3.fromRGB(56, 189, 248)
		powerLbl.TextScaled = true
		powerLbl.Font = Enum.Font.GothamMedium
		powerLbl.Text = "Power: 0%"
		powerLbl.Parent = card

		local heatLbl = Instance.new("TextLabel")
		heatLbl.Name = "Heat"
		heatLbl.Size = UDim2.new(1, -8, 0, 18)
		heatLbl.Position = UDim2.new(0, 4, 0, 60)
		heatLbl.BackgroundTransparency = 1
		heatLbl.TextColor3 = Color3.fromRGB(251, 146, 60)
		heatLbl.TextScaled = true
		heatLbl.Font = Enum.Font.GothamMedium
		heatLbl.Text = "Heat: 0%"
		heatLbl.Parent = card

		local healthLbl = Instance.new("TextLabel")
		healthLbl.Name = "Health"
		healthLbl.Size = UDim2.new(1, -8, 0, 18)
		healthLbl.Position = UDim2.new(0, 4, 0, 78)
		healthLbl.BackgroundTransparency = 1
		healthLbl.TextColor3 = Color3.fromRGB(74, 222, 128)
		healthLbl.TextScaled = true
		healthLbl.Font = Enum.Font.GothamMedium
		healthLbl.Text = "Durability: 100%"
		healthLbl.Parent = card

		machinePart:SetAttribute("MachineHUD_Ready", true)
	end

	CollectionService:GetInstanceAddedSignal("MachinePart"):Connect(setupMachineHUD)
	for _, part in ipairs(CollectionService:GetTagged("MachinePart")) do
		task.spawn(setupMachineHUD, part)
	end

	task.spawn(function()
		while true do
			task.wait(0.3)
			local char = localPlayer.Character
			if not char or not char.PrimaryPart then
				continue
			end
			local playerPos = char.PrimaryPart.Position
			local tagged = CollectionService:GetTagged("MachinePart")
			local nearby: { { Part: BasePart, Dist: number, Gui: BillboardGui } } = {}

			for _, part in ipairs(tagged) do
				if not part:IsA("BasePart") then
					continue
				end
				local gui = part:FindFirstChild("MachineHUD") :: BillboardGui?
				if not gui then
					continue
				end
				local dist = (part.Position - playerPos).Magnitude
				if dist <= 15 then
					table.insert(nearby, { Part = part, Dist = dist, Gui = gui })
				else
					gui.Enabled = false
				end
			end

			table.sort(nearby, function(a, b)
				return a.Dist < b.Dist
			end)

			for i, item in ipairs(nearby) do
				if i <= 3 then
					item.Gui.Enabled = true
				else
					item.Gui.Enabled = false
				end
			end
		end
	end)
end

function MachineController.RefuelMachine(machinePart: BasePart)
	if _machineEvent then
		_machineEvent:FireServer("Refuel", machinePart)
	end
end

function MachineController.RepairMachine(machinePart: BasePart)
	if _machineEvent then
		_machineEvent:FireServer("Repair", machinePart)
	end
end

return MachineController
