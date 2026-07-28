--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local ClientRemotes = require(script.Parent.Parent:WaitForChild("Network"):WaitForChild("ClientRemotes") :: any)

local BroadcastBannerController = {}
BroadcastBannerController.Name = "BroadcastBannerController"

local localPlayer = Players.LocalPlayer
local bannerFrame: Frame?
local bannerText: TextLabel?

function BroadcastBannerController.Init()
	print("[BroadcastBannerController] Initializing Server Broadcast UI...")
end

function BroadcastBannerController.Start()
	local remote = ClientRemotes.BroadcastServerMessage
	if remote then
		remote.OnClientEvent:Connect(function(text: string, r: number, g: number, b: number)
			BroadcastBannerController.ShowAnnouncement(text, Color3.fromRGB(r or 255, g or 215, b or 0))
		end)
	end
end

function BroadcastBannerController.ShowAnnouncement(messageText: string, color: Color3)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:FindFirstChild("COBLOX_AlchemyHUD")
	if not mainHUD then
		return
	end

	if not bannerFrame then
		bannerFrame = Instance.new("Frame")
		bannerFrame.Name = "GlobalBroadcastBanner"
		bannerFrame.Size = UDim2.new(0.6, 0, 0.06, 0)
		bannerFrame.Position = UDim2.new(0.2, 0, 0.11, 0)
		bannerFrame.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
		bannerFrame.BorderSizePixel = 0
		bannerFrame.ZIndex = 200
		bannerFrame.Parent = mainHUD

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = bannerFrame

		local stroke = Instance.new("UIStroke")
		stroke.Name = "BannerStroke"
		stroke.Color = color
		stroke.Thickness = 2
		stroke.Parent = bannerFrame

		bannerText = Instance.new("TextLabel")
		bannerText.Name = "AnnouncementText"
		bannerText.Size = UDim2.new(1, 0, 1, 0)
		bannerText.BackgroundTransparency = 1
		bannerText.TextColor3 = color
		bannerText.Font = Enum.Font.FredokaOne
		bannerText.TextSize = 16
		bannerText.Parent = bannerFrame
	end

	if bannerText and bannerFrame then
		bannerText.Text = messageText
		bannerFrame.Visible = true

		local stroke = bannerFrame:FindFirstChild("BannerStroke") :: UIStroke?
		if stroke then
			stroke.Color = color
		end

		task.delay(5, function()
			if bannerFrame then
				bannerFrame.Visible = false
			end
		end)
	end
end

return BroadcastBannerController
