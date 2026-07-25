--!strict
-- COBLOX CLIENT: WIDGET RENDERER
-- Manages ScreenGui-based diagnostic widgets with specialized pools & WorldToViewportPoint projection.

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ScannerPipeline = require(script.Parent.ScannerPipeline)

local WidgetRenderer = {}

local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera

-- ScreenGui Container
local ScreenContainer: ScreenGui = nil

local function EnsureContainer(): ScreenGui
	if not ScreenContainer or not ScreenContainer.Parent then
		local playerGui = LocalPlayer:WaitForChild("PlayerGui")
		local existing = playerGui:FindFirstChild("ARLensScreenGui")
		if existing then
			ScreenContainer = existing :: ScreenGui
		else
			local gui = Instance.new("ScreenGui")
			gui.Name = "ARLensScreenGui"
			gui.ResetOnSpawn = false
			gui.DisplayOrder = 10
			gui.Parent = playerGui
			ScreenContainer = gui
		end
	end
	return ScreenContainer
end

-- Specialized Pools
local Pools = {
	NodeWidgetPool = {} :: { Frame },
	MachineWidgetPool = {} :: { Frame },
	MonsterWidgetPool = {} :: { Frame },
	NPCWidgetPool = {} :: { Frame },
	GenericWidgetPool = {} :: { Frame },
}

local function CreateWidgetFrame(entityType: ScannerPipeline.EntityType): Frame
	local poolName = entityType .. "WidgetPool"
	local pool = Pools[poolName] or Pools.GenericWidgetPool
	
	if #pool > 0 then
		local frame = table.remove(pool) :: Frame
		frame.Visible = true
		return frame
	end

	-- Build new Frame with Glassmorphism Techwear styling
	local frame = Instance.new("Frame")
	frame.Size = UDim2.fromOffset(240, 120)
	frame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	frame.BackgroundTransparency = 0.25
	frame.BorderSizePixel = 0

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	uiCorner.Parent = frame

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Thickness = 1.5
	uiStroke.Color = entityType == "Monster" and Color3.fromRGB(239, 68, 68) 
		or entityType == "Machine" and Color3.fromRGB(59, 130, 246)
		or Color3.fromRGB(16, 185, 129)
	uiStroke.Parent = frame

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -16, 0, 24)
	titleLabel.Position = UDim2.fromOffset(8, 6)
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextSize = 13
	titleLabel.TextColor3 = Color3.fromRGB(243, 244, 246)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.BackgroundTransparency = 1
	titleLabel.Parent = frame

	local contentLabel = Instance.new("TextLabel")
	contentLabel.Name = "ContentLabel"
	contentLabel.Size = UDim2.new(1, -16, 1, -36)
	contentLabel.Position = UDim2.fromOffset(8, 30)
	contentLabel.Font = Enum.Font.RobotoMono
	contentLabel.TextSize = 11
	contentLabel.TextColor3 = Color3.fromRGB(209, 213, 219)
	contentLabel.TextXAlignment = Enum.TextXAlignment.Left
	contentLabel.TextYAlignment = Enum.TextYAlignment.Top
	contentLabel.BackgroundTransparency = 1
	contentLabel.Parent = frame

	frame.Parent = EnsureContainer()
	return frame
end

function WidgetRenderer.RenderWidget(entityType: ScannerPipeline.EntityType, metadata: ScannerPipeline.TargetMetadata, worldPos: Vector3): Frame?
	if not CurrentCamera then return nil end
	
	local screenPos, onScreen = CurrentCamera:WorldToViewportPoint(worldPos)
	if not onScreen then return nil end

	local frame = CreateWidgetFrame(entityType)
	frame.Position = UDim2.fromOffset(screenPos.X - 120, screenPos.Y - 60)

	local titleLabel = frame:FindFirstChild("TitleLabel") :: TextLabel
	local contentLabel = frame:FindFirstChild("ContentLabel") :: TextLabel

	if titleLabel then
		titleLabel.Text = metadata.Title
	end

	if contentLabel then
		local lines = {}
		for k, v in pairs(metadata.Fields) do
			table.insert(lines, string.format("• %s: %s", k, v))
		end
		contentLabel.Text = table.concat(lines, "\n")
	end

	return frame
end

function WidgetRenderer.RecycleWidget(entityType: ScannerPipeline.EntityType, frame: Frame)
	frame.Visible = false
	local poolName = entityType .. "WidgetPool"
	local pool = Pools[poolName] or Pools.GenericWidgetPool
	table.insert(pool, frame)
end

return WidgetRenderer
