--!strict

local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioEventBus =
	require(script.Parent.Parent:WaitForChild("Modules"):WaitForChild("Audio"):WaitForChild("AudioEventBus") :: any)
local Shared = ReplicatedStorage:WaitForChild("Shared")
local SoundPool = require(Shared:WaitForChild("Utility"):WaitForChild("SoundPool") :: any)
local AssetsFolder = Shared:WaitForChild("Assets")
local AssetRegistry = require(AssetsFolder:WaitForChild("AssetRegistry") :: any)

local Maid = require(Shared:WaitForChild("Utility"):WaitForChild("Maid"))

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

	masterGroup = SoundService:FindFirstChild("COBLOX_Master") :: SoundGroup or Instance.new("SoundGroup")
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
	self.maid = Maid.new()
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

	local cat: string = if channel == "UI" then "UI" elseif channel == "Ambient" then "Ambient" else "SFX"
	return SoundPool.Play(soundId, cat :: any, group, volume, pitch)
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

	-- FASE 6 FIX: Reuse 2 fixed BGM slots instead of Instance.new() every call
	-- Slot A = currentBGMSound, Slot B = _bgmNextSlot
	-- This prevents a new Sound instance being created on every scene transition.
	if not AudioController._bgmSlotA then
		AudioController._bgmSlotA = Instance.new("Sound")
		AudioController._bgmSlotA.Name = "BGM_SlotA"
		AudioController._bgmSlotA.Looped = true
		AudioController._bgmSlotA.Volume = 0
		AudioController._bgmSlotA.SoundGroup = bgmGroup
		AudioController._bgmSlotA.Parent = SoundService
	end
	if not AudioController._bgmSlotB then
		AudioController._bgmSlotB = Instance.new("Sound")
		AudioController._bgmSlotB.Name = "BGM_SlotB"
		AudioController._bgmSlotB.Looped = true
		AudioController._bgmSlotB.Volume = 0
		AudioController._bgmSlotB.SoundGroup = bgmGroup
		AudioController._bgmSlotB.Parent = SoundService
	end

	-- Pick the inactive slot for the new BGM
	local oldSound = currentBGMSound
	local newSound = if currentBGMSound == AudioController._bgmSlotA
		then AudioController._bgmSlotB
		else AudioController._bgmSlotA

	-- Assign new track to the inactive slot and play
	newSound.SoundId = soundId
	newSound.Volume = 0
	newSound:Stop()
	newSound:Play()

	-- Crossfade: fade out old, fade in new
	if oldSound then
		local fadeOutTween =
			TweenService:Create(oldSound, TweenInfo.new(duration, Enum.EasingStyle.Sine), { Volume = 0 })
		fadeOutTween:Play()
		self.maid:GiveTask(fadeOutTween.Completed:Connect(function()
			oldSound:Stop()
			-- Don't Destroy — reuse on next call
		end)
	end

	local fadeInTween = TweenService:Create(newSound, TweenInfo.new(duration, Enum.EasingStyle.Sine), { Volume = 0.7 })
	fadeInTween:Play()

	currentBGMSound = newSound
	currentBGMKey = soundKey
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
