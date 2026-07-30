--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local FusionProvider = require(script.Parent.FusionProvider)

local GlassPanel = {}

function GlassPanel.New(
	fusion: any,
	props: {
		Size: UDim2?,
		Position: UDim2?,
		AnchorPoint: Vector2?,
		CornerRadius: UDim?,
		Children: { Instance }?,
	}
): Instance
	local panel = fusion.New("Frame")({
		Size = props.Size or UDim2.fromOffset(200, 100),
		Position = props.Position or UDim2.fromOffset(0, 0),
		AnchorPoint = props.AnchorPoint or Vector2.new(0, 0),
		BackgroundColor3 = Color3.fromRGB(15, 23, 42),
		BackgroundTransparency = 0.6,
		BorderSizePixel = 0,
		ClipsDescendants = false,
	})

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(51, 65, 85)
	uiStroke.Transparency = 0.5
	uiStroke.Thickness = 1
	uiStroke.Parent = panel

	if props.CornerRadius then
		local corner = Instance.new("UICorner")
		corner.CornerRadius = props.CornerRadius
		corner.Parent = panel
	else
		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 16)
		corner.Parent = panel
	end

	if props.Children then
		for _, child in ipairs(props.Children) do
			child.Parent = panel
		end
	end

	return panel
end

return GlassPanel
