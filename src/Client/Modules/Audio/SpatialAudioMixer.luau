--!strict

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Maid = require(ReplicatedStorage.Shared.Utility.Maid)
local SoundPool = require(ReplicatedStorage.Shared.Utility.SoundPool)

local SpatialAudioMixer = {}

export type SpatialSound = {
	SoundId: string,
	Position: Vector3,
	Range: number,
	Volume: number,
	Pitch: number,
	Looping: boolean,
	SoundObj: Sound?,
}

local spatialSounds: { SpatialSound } = {}
local listenerPart: BasePart?

function SpatialAudioMixer.SetListener(listener: BasePart?)
	listenerPart = listener
end

function SpatialAudioMixer.GetListener(): BasePart?
	return listenerPart
end

function SpatialAudioMixer.PlayAtPosition(soundId: string, position: Vector3, range: number, volume: number): Sound?
	if not listenerPart then
		return SoundPool.Play(soundId, "SFX", nil, volume)
	end

	local distance = (position - listenerPart.Position).Magnitude
	if distance > range then
		return nil
	end

	local distanceFactor = 1 - math.clamp(distance / range, 0, 1)
	local spatialVolume = volume * distanceFactor
	local spatialPan = math.clamp((position.X - listenerPart.Position.X) / range, -0.5, 0.5)

	if spatialVolume <= 0 then
		return nil
	end

	local sound = SoundPool.Play(soundId, "SFX", nil, spatialVolume)
	if sound then
		sound.PanStereo = spatialPan
		sound.PlayOnRemove = false
	end

	return sound
end

function SpatialAudioMixer.CreateSpatialLoop(soundId: string, positionProvider: () -> Vector3, range: number, volume: number): Maid
	local maid = Maid.new()
	local sound = Instance.new("Sound")
	sound.SoundId = soundId
	sound.Volume = volume
	sound.Looped = true
	sound.PlayOnRemove = false
	sound.Parent = Workspace

	maid:GiveTask(sound)

	local connection = RunService.Heartbeat:Connect(function()
		if not sound.Parent then
			return
		end

		local pos = positionProvider()
		sound.Position = pos

		if listenerPart then
			local distance = (pos - listenerPart.Position).Magnitude
			sound.Volume = if distance <= range then volume * (1 - distance / range) else 0
		end
	end)
	maid:GiveTask(connection)

	sound:Play()
	return maid
end

function SpatialAudioMixer.RegisterSound(sound: SpatialSound): string
	table.insert(spatialSounds, sound)
	return tostring(#spatialSounds)
end

function SpatialAudioMixer.UpdateAll(dt: number)
	if not listenerPart then
		return
	end

	local listenerPos = listenerPart.Position

	for _, entry in ipairs(spatialSounds) do
		local distance = (entry.Position - listenerPos).Magnitude
		if distance > entry.Range then
			if entry.SoundObj then
				entry.SoundObj.Volume = 0
			end
			continue
		end

		local factor = 1 - math.clamp(distance / entry.Range, 0, 1)
		local targetVolume = entry.Volume * factor

		if entry.SoundObj then
			entry.SoundObj.Volume = targetVolume
			entry.SoundObj.PanStereo = math.clamp(
				(entry.Position.X - listenerPos.X) / entry.Range,
				-0.5,
				0.5
			)
		end
	end
end

return SpatialAudioMixer
