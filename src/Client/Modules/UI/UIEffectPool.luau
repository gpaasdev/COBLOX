--!strict
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local UIEffectPool = {}

local pool: { ImageLabel } = {}
local POOL_SIZE = 30

function UIEffectPool.Init(containerGui: ScreenGui)
	for i = 1, POOL_SIZE do
		local spark = Instance.new("ImageLabel")
		spark.Name = "SparkEffect_" .. tostring(i)
		spark.Size = UDim2.new(0, 16, 0, 16)
		spark.BackgroundTransparency = 1
		spark.Image = "rbxassetid://6031075931" -- Gold Spark Star Asset
		spark.ImageColor3 = Color3.fromRGB(245, 158, 11)
		spark.Visible = false
		spark.Parent = containerGui
		table.insert(pool, spark)
	end
end

function UIEffectPool.EmitSparks(originObject: GuiObject, count: number?)
	local sparkCount = count or 6
	local originPos = originObject.AbsolutePosition
	local originSize = originObject.AbsoluteSize
	local center = Vector2.new(originPos.X + originSize.X / 2, originPos.Y + originSize.Y / 2)

	local emitted = 0
	for _, spark in ipairs(pool) do
		if not spark.Visible then
			emitted += 1
			spark.Position = UDim2.new(0, center.X, 0, center.Y)
			spark.ImageTransparency = 0
			spark.Visible = true

			local angle = math.rad((360 / sparkCount) * emitted)
			local distance = math.random(40, 80)
			local targetX = center.X + math.cos(angle) * distance
			local targetY = center.Y + math.sin(angle) * distance

			local tween =
				TweenService:Create(spark, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
					Position = UDim2.new(0, targetX, 0, targetY),
					ImageTransparency = 1,
				})

			tween:Play()
			tween.Completed:Connect(function()
				spark.Visible = false
			end)

			if emitted >= sparkCount then
				break
			end
		end
	end
end

return UIEffectPool
