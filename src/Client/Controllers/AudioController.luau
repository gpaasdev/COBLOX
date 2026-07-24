--!strict

local SoundService = game:GetService("SoundService")
local Players = game:GetService("Players")

local AudioEventBus = require(script.Parent.Parent:WaitForChild("Modules"):WaitForChild("Audio"):WaitForChild("AudioEventBus") :: any)

local AudioController = {}
AudioController.Name = "AudioController"

local soundGroup: SoundGroup

function AudioController.Init()
	print("[AudioController] Initializing Audio & Sound Channels...")
	soundGroup = Instance.new("SoundGroup")
	soundGroup.Name = "COBLOX_MasterAudio"
	soundGroup.Volume = 0.8
	soundGroup.Parent = SoundService
end

function AudioController.Start()
	AudioEventBus.Subscribe(function(soundId: string, volume: number)
		AudioController.PlaySound(soundId, volume)
	end)
end

function AudioController.PlaySound(soundId: string, volume: number?)
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume or 0.8
	sound.SoundGroup = soundGroup
	sound.Parent = SoundService
	sound:Play()
	sound.Ended:Connect(function()
		sound:Destroy()
	end)
end

return AudioController
