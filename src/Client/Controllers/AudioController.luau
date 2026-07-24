--!strict

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioEventBus = require(script.Parent.Parent:WaitForChild("Modules"):WaitForChild("Audio"):WaitForChild("AudioEventBus") :: any)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local SoundPool = require(Shared:WaitForChild("Utility"):WaitForChild("SoundPool") :: any)
local AssetsFolder = ReplicatedStorage:WaitForChild("Assets")
local AssetRegistry = require(AssetsFolder:WaitForChild("AssetRegistry") :: any)

local AudioController = {}
AudioController.Name = "AudioController"

local masterGroup: SoundGroup
local bgmGroup: SoundGroup
local sfxGroup: SoundGroup
local uiGroup: SoundGroup

local currentBGMSound: Sound? = nil
local currentBGMKey: string? = nil

function AudioController.Init()
	print("[AudioController] Initializing 4-Channel SoundGroups (Master, BGM, SFX, UI)...")
	
	masterGroup = SoundService:FindFirstChild("COBLOX_Master") :: SoundGroup
		or Instance.new("SoundGroup")
	masterGroup.Name = "COBLOX_Master"
	masterGroup.Volume = 0.8
	masterGroup.Parent = SoundService

	bgmGroup = Instance.new("SoundGroup")
	bgmGroup.Name = "COBLOX_BGM"
	bgmGroup.Volume = 0.7
	bgmGroup.Parent = masterGroup

	sfxGroup = Instance.new("SoundGroup")
	sfxGroup.Name = "COBLOX_SFX"
	sfxGroup.Volume = 0.9
	sfxGroup.Parent = masterGroup

	uiGroup = Instance.new("SoundGroup")
	uiGroup.Name = "COBLOX_UI"
	uiGroup.Volume = 0.8
	uiGroup.Parent = masterGroup
end

function AudioController.Start()
	AudioEventBus.Subscribe(function(soundId: string, volume: number)
		AudioController.PlaySound(soundId, volume)
	end)
end

function AudioController.PlaySound(soundId: string, volume: number?, pitch: number?, channel: string?)
	local group = sfxGroup
	if channel == "UI" then
		group = uiGroup
	elseif channel == "BGM" then
		group = bgmGroup
	elseif channel == "Master" then
		group = masterGroup
	end

	return SoundPool.Play(soundId, group, volume, pitch)
end

function AudioController.PlayBGM(soundKey: string, fadeTime: number?)
	if currentBGMKey == soundKey and currentBGMSound and currentBGMSound.IsPlaying then
		return
	end

	local duration = fadeTime or 1.5
	local soundId = AssetRegistry.GetAudioId("BGM", soundKey)
	if soundId == "rbxassetid://0" or soundId == "" then
		print(string.format("[AudioController] BGM track '%s' missing or empty ID", soundKey))
		return
	end

	local oldSound = currentBGMSound
	if oldSound then
		local fadeOutTween = TweenService:Create(oldSound, TweenInfo.new(duration, Enum.EasingStyle.Sine), { Volume = 0 })
		fadeOutTween:Play()
		fadeOutTween.Completed:Connect(function()
			oldSound:Stop()
			oldSound:Destroy()
		end)
	end

	local newSound = Instance.new("Sound")
	newSound.Name = string.format("BGM_%s", soundKey)
	newSound.SoundId = soundId
	newSound.Volume = 0
	newSound.Looped = true
	newSound.SoundGroup = bgmGroup
	newSound.Parent = SoundService

	currentBGMSound = newSound
	currentBGMKey = soundKey
	newSound:Play()

	local fadeInTween = TweenService:Create(newSound, TweenInfo.new(duration, Enum.EasingStyle.Sine), { Volume = 0.7 })
	fadeInTween:Play()
end

function AudioController.PlayCraftingChime()
	local soundId = AssetRegistry.GetAudioId("SFX", "CoinPurchase")
	AudioController.PlaySound(soundId, 0.9, 1.0, "SFX")
end

function AudioController.PlayButtonClick()
	local soundId = AssetRegistry.GetAudioId("SFX", "CoinPurchase")
	AudioController.PlaySound(soundId, 0.5, 1.2, "UI")
end

function AudioController.PlaySuccessFanfare()
	local soundId = AssetRegistry.GetAudioId("SFX", "EggHatchLegendary")
	AudioController.PlaySound(soundId, 1.0, 1.0, "SFX")
end

function AudioController.SetChannelVolume(channelName: string, volume: number)
	local targetGroup = (channelName == "BGM" and bgmGroup)
		or (channelName == "SFX" and sfxGroup)
		or (channelName == "UI" and uiGroup)
		or masterGroup
	targetGroup.Volume = math.clamp(volume, 0, 1)
end

return AudioController
