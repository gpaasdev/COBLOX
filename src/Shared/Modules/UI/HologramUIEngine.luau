--!strict
-- ReplicatedStorage/Shared/Modules/UI/HologramUIEngine.luau
-- Engine Pembuat & Pengelola Overhead UI Stylized Sci-Fi Hologram Glassmorphism

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local HologramUIEngine = {}
HologramUIEngine.__index = HologramUIEngine

export type HologramUIOptions = {
	Title: string,
	Subtitle: string?,
	AccentColor: Color3?,
	Size: UDim2?,
	StudsOffset: Vector3?,
}

function HologramUIEngine.Create(adornment: Instance, options: HologramUIOptions): BillboardGui
	local accentColor = options.AccentColor or Color3.fromRGB(0, 240, 255)

	-- 0. Check for Studio Template UI Prefab in ReplicatedStorage.Prefabs.UI
	local prefabsFolder = ReplicatedStorage:FindFirstChild("Prefabs")
	if prefabsFolder then
		local uiFolder = prefabsFolder:FindFirstChild("UI")
		if uiFolder then
			local template = uiFolder:FindFirstChild("HologramUITemplate")
			if template and template:IsA("BillboardGui") then
				local cloned = template:Clone() :: BillboardGui
				cloned.Adornee = adornment:IsA("PVInstance") and adornment or nil
				cloned.Parent = adornment

				local mainFrame = cloned:FindFirstChild("MainFrame") :: Frame?
				if mainFrame then
					local titleLabel = mainFrame:FindFirstChild("TitleLabel") :: TextLabel?
					if titleLabel then
						titleLabel.Text = options.Title
					end
					local subLabel = mainFrame:FindFirstChild("SubLabel") :: TextLabel?
					if subLabel and options.Subtitle then
						subLabel.Text = options.Subtitle
					end
				end
				return cloned
			end
		end
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "HologramUI"
	billboard.Size = options.Size or UDim2.new(0, 220, 0, 70)
	billboard.StudsOffset = options.StudsOffset or Vector3.new(0, 4.5, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 120
	billboard.Adornee = adornment:IsA("PVInstance") and adornment or nil
	billboard.Parent = adornment

	-- Base Frame (Glassmorphism Dark Cyan Card)
	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainFrame"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
	mainFrame.BackgroundTransparency = 0.25
	mainFrame.BorderSizePixel = 0
	mainFrame.Parent = billboard

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 10)
	uiCorner.Parent = mainFrame

	-- Neon Glowing Border (UIStroke)
	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = accentColor
	uiStroke.Thickness = 2
	uiStroke.Transparency = 0.2
	uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	uiStroke.Parent = mainFrame

	-- Gradient Overlay (Holographic Sheen)
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.5, accentColor),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 25, 45)),
	})
	uiGradient.Rotation = 45
	uiGradient.Parent = mainFrame

	-- Padding Internal
	local uiPadding = Instance.new("UIPadding")
	uiPadding.PaddingLeft = UDim.new(0, 12)
	uiPadding.PaddingRight = UDim.new(0, 12)
	uiPadding.PaddingTop = UDim.new(0, 8)
	uiPadding.PaddingBottom = UDim.new(0, 8)
	uiPadding.Parent = mainFrame

	-- Title Label
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, 0, 0.55, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = options.Title
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 14
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.Parent = mainFrame

	-- Subtitle Label (Optional)
	if options.Subtitle then
		local subLabel = Instance.new("TextLabel")
		subLabel.Name = "SubLabel"
		subLabel.Size = UDim2.new(1, 0, 0.45, 0)
		subLabel.Position = UDim2.new(0, 0, 0.55, 0)
		subLabel.BackgroundTransparency = 1
		subLabel.Font = Enum.Font.GothamMedium
		subLabel.Text = options.Subtitle
		subLabel.TextColor3 = accentColor
		subLabel.TextSize = 11
		subLabel.TextXAlignment = Enum.TextXAlignment.Center
		subLabel.Parent = mainFrame
	end

	-- Animasi Floating (Sine Wave Bobbing) & Pulse Glow (Hanya berjalan di Client)
	if RunService:IsClient() then
		local initialOffset = billboard.StudsOffset
		local tweenInfo = TweenInfo.new(1.8, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true)

		local bobbingTween = TweenService:Create(billboard, tweenInfo, {
			StudsOffset = initialOffset + Vector3.new(0, 0.4, 0),
		})

		local strokeTween = TweenService:Create(uiStroke, tweenInfo, {
			Transparency = 0.6,
		})

		bobbingTween:Play()
		strokeTween:Play()
	end

	return billboard
end

return HologramUIEngine
