--!strict
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local localPlayer = Players.LocalPlayer

local VFXEngine = {}

-- 1. 3D Floating World Text (Anime Style Damage/Currency Popups)
function VFXEngine.CreateFloatingText(position: Vector3, text: string, color: Color3?)
	local part = Instance.new("Part")
	part.Size = Vector3.new(0.1, 0.1, 0.1)
	part.Position = position + Vector3.new(0, 2, 0)
	part.Transparency = 1
	part.CanCollide = false
	part.Anchored = true
	part.Parent = Workspace

	local bb = Instance.new("BillboardGui")
	bb.Size = UDim2.new(0, 200, 0, 50)
	bb.AlwaysOnTop = true
	bb.StudsOffset = Vector3.new(0, 0, 0)
	bb.Parent = part

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = color or Color3.fromRGB(245, 158, 11)
	label.Font = Enum.Font.FredokaOne
	label.TextSize = 22
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(15, 23, 42)
	label.Parent = bb

	-- Float up & Fade out tween
	local tweenInfo = TweenInfo.new(1.2, Enum.EasingStyle.OutQuad, Enum.EasingDirection.Out)
	local moveTween = TweenService:Create(part, tweenInfo, { Position = part.Position + Vector3.new(0, 4, 0) })
	local fadeTween = TweenService:Create(label, tweenInfo, { TextTransparency = 1, TextStrokeTransparency = 1 })

	moveTween:Play()
	fadeTween:Play()

	task.delay(1.2, function()
		part:Destroy()
	end)
end

-- 2. Environmental Cylindrical Shockwave Generator
function VFXEngine.CreateShockwave(position: Vector3, maxRadius: number?, color: Color3?)
	local radius = maxRadius or 25
	local wave = Instance.new("Part")
	wave.Shape = Enum.PartType.Cylinder
	wave.Size = Vector3.new(0.2, 2, 2)
	wave.CFrame = CFrame.new(position) * CFrame.Angles(0, 0, math.rad(90))
	wave.Material = Enum.Material.Neon
	wave.Color = color or Color3.fromRGB(245, 158, 11)
	wave.Transparency = 0.2
	wave.CanCollide = false
	wave.Anchored = true
	wave.Parent = Workspace

	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Cubic, Enum.EasingDirection.Out)
	local expandTween = TweenService:Create(wave, tweenInfo, {
		Size = Vector3.new(0.2, radius * 2, radius * 2),
		Transparency = 1
	})

	expandTween:Play()
	task.delay(0.8, function()
		wave:Destroy()
	end)
end

-- 3. Camera Shake Effect
function VFXEngine.PlayCameraShake(intensity: number?, duration: number?)
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local shakeIntensity = intensity or 0.3
	local shakeDuration = duration or 0.4
	local startTime = os.clock()

	task.spawn(function()
		while os.clock() - startTime < shakeDuration do
			local offsetX = (math.random() - 0.5) * shakeIntensity
			local offsetY = (math.random() - 0.5) * shakeIntensity
			camera.CFrame = camera.CFrame * CFrame.new(offsetX, offsetY, 0)
			task.wait(0.02)
		end
	end)
end

-- 4. Elastic Spring UI Animation
function VFXEngine.ApplySpringAnimation(button: GuiObject)
	local originalSize = button.Size
	
	button.MouseEnter:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(originalSize.X.Scale * 1.06, originalSize.X.Offset, originalSize.Y.Scale * 1.06, originalSize.Y.Offset)
		}):Play()
	end)

	button.MouseLeave:Connect(function()
		TweenService:Create(button, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = originalSize
		}):Play()
	end)

	if button:IsA("GuiButton") then
		button.MouseButton1Down:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				Size = UDim2.new(originalSize.X.Scale * 0.94, originalSize.X.Offset, originalSize.Y.Scale * 0.94, originalSize.Y.Offset)
			}):Play()
		end)

		button.MouseButton1Up:Connect(function()
			TweenService:Create(button, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = UDim2.new(originalSize.X.Scale * 1.06, originalSize.X.Offset, originalSize.Y.Scale * 1.06, originalSize.Y.Offset)
			}):Play()
		end)
	end
end

return VFXEngine
