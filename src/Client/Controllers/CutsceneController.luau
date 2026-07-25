--!strict

local TweenService = game:GetService("TweenService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local WorldConfig = require(ReplicatedStorage.Shared.Configuration.WorldConfig)

local CutsceneController = {}
CutsceneController.Name = "CutsceneController"

local camera = Workspace.CurrentCamera
local localPlayer = Players.LocalPlayer

function CutsceneController.Init()
	print("[CutsceneController] Initializing Camera Manipulation & Atmospheric Vignette FX Engine...")
end

function CutsceneController.Start()
	local remote = NetChannels.GetRemoteEvent("PlaySpiritMemory")
	if remote then
		remote.OnClientEvent:Connect(function(elementType)
			CutsceneController.PlaySpiritMemory(elementType)
		end)
	end
	
	local storyRemote = NetChannels.GetRemoteEvent("StoryEvent")
	if storyRemote then
		storyRemote.OnClientEvent:Connect(function(chapterId)
			print("[CutsceneController] StoryEvent triggered for chapter: " .. tostring(chapterId))
			-- Implement story visuals here when ready
		end)
	end
end

function CutsceneController.TransitionBiomeLighting(zoneId: string, transitionDuration: number?)
	local zoneData = WorldConfig.Zones[zoneId]
	if not zoneData or not zoneData.AmbientLighting then return end
	
	local lightingData = zoneData.AmbientLighting
	local duration = transitionDuration or 2.5
	
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)
	
	local props = {
		Brightness = lightingData.Brightness,
		ClockTime = lightingData.ClockTime,
		OutdoorAmbient = lightingData.OutdoorAmbient,
		FogColor = lightingData.FogColor,
		FogEnd = lightingData.FogEnd
	}
	
	local lightingTween = TweenService:Create(Lighting, tweenInfo, props)
	lightingTween:Play()
	print("[CutsceneController] Transitioning Biome Lighting to: " .. zoneId)
end

function CutsceneController.PlayChapterIntroCutscene(targetCFrame: CFrame, durationSeconds: number, onComplete: () -> ()?)
	if not camera then return end

	camera.CameraType = Enum.CameraType.Scriptable
	local startCFrame = camera.CFrame
	
	local tweenInfo = TweenInfo.new(durationSeconds, Enum.EasingStyle.Cubic, Enum.EasingDirection.InOut)
	local tween = TweenService:Create(camera, tweenInfo, { CFrame = targetCFrame })

	tween:Play()
	tween.Completed:Connect(function()
		camera.CameraType = Enum.CameraType.Custom
		if onComplete then
			onComplete()
		end
	end)
end

function CutsceneController.PlaySpiritMemory(elementType: string)
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	if not camera then return end
	
	-- Darken screen
	local vignette = Instance.new("Frame")
	vignette.Size = UDim2.new(1, 0, 1, 0)
	vignette.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	vignette.BackgroundTransparency = 1
	vignette.Parent = playerGui:WaitForChild("COBLOX_MainHUD")
	
	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(0.8, 0, 0.2, 0)
	textLabel.Position = UDim2.new(0.1, 0, 0.4, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Font = Enum.Font.GothamMedium
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextScaled = true
	textLabel.Text = ""
	textLabel.Parent = vignette
	
	local tweenIn = TweenService:Create(vignette, TweenInfo.new(1), {BackgroundTransparency = 0.2})
	tweenIn:Play()
	tweenIn.Completed:Wait()
	
	-- Typewriter effect
	local loreText = "The ancient spirits whisper..."
	if elementType == "Pyro" then loreText = "Flames forged in the heart of the first volcano..."
	elseif elementType == "Hydro" then loreText = "Tides that washed away the old world..."
	elseif elementType == "Void" then loreText = "An emptiness that hungers for existence..."
	end
	
	for i = 1, #loreText do
		textLabel.Text = string.sub(loreText, 1, i)
		task.wait(0.05)
	end
	
	task.wait(2)
	
	local tweenOut = TweenService:Create(vignette, TweenInfo.new(1), {BackgroundTransparency = 1})
	local textOut = TweenService:Create(textLabel, TweenInfo.new(1), {TextTransparency = 1})
	tweenOut:Play()
	textOut:Play()
	tweenOut.Completed:Wait()
	vignette:Destroy()
end

return CutsceneController
