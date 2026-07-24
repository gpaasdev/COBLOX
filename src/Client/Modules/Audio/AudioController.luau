--!strict
local SoundService = game:GetService("SoundService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AssetManifest = require(ReplicatedStorage.Shared.Parent.Assets.AssetManifest)

local AudioController = {}
AudioController.Name = "AudioController"

local bgmSound: Sound? = nil

function AudioController.Init()
	print("[AudioController] Initializing Central Sound & BGM Engine...")
	AudioController._SetupSoundGroups()
	AudioController.PlayBGM("LobbyTheme")
end

function AudioController._SetupSoundGroups()
	local bgmGroup = SoundService:FindFirstChild("BGMGroup")
	if not bgmGroup then
		bgmGroup = Instance.new("SoundGroup")
		bgmGroup.Name = "BGMGroup"
		bgmGroup.Volume = 0.5
		bgmGroup.Parent = SoundService
	end

	local sfxGroup = SoundService:FindFirstChild("SFXGroup")
	if not sfxGroup then
		sfxGroup = Instance.new("SoundGroup")
		sfxGroup.Name = "SFXGroup"
		sfxGroup.Volume = 0.7
		sfxGroup.Parent = SoundService
	end
end

function AudioController.PlayBGM(themeKey: string)
	local soundId = AssetManifest.Audio.BGM[themeKey]
	if not soundId or soundId == "rbxassetid://0" then return end

	if bgmSound then
		bgmSound:Stop()
		bgmSound:Destroy()
	end

	local sound = Instance.new("Sound")
	sound.Name = "CurrentBGM"
	sound.SoundId = soundId
	sound.Looped = true
	sound.Volume = 0.4
	sound.SoundGroup = SoundService:FindFirstChild("BGMGroup") :: SoundGroup
	sound.Parent = SoundService
	sound:Play()

	bgmSound = sound
end

function AudioController.PlaySFX(sfxKey: string)
	local soundId = AssetManifest.Audio.SFX[sfxKey]
	if not soundId or soundId == "rbxassetid://0" then return end

	local sound = Instance.new("Sound")
	sound.Name = "SFX_" .. sfxKey
	sound.SoundId = soundId
	sound.Volume = 0.8
	sound.SoundGroup = SoundService:FindFirstChild("SFXGroup") :: SoundGroup
	sound.Parent = SoundService
	sound:Play()

	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

return AudioController
