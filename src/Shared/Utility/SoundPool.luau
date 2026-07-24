--!strict
-- SoundPool utility for recycling Sound instances and avoiding memory allocation chatter
-- Complies with COBLOX memory budget (<6GB RAM target) and SOA standards.

local SoundService = game:GetService("SoundService")
local ObjectPool = require(script.Parent.ObjectPool)

local SoundPool = {}
SoundPool.__index = SoundPool

export type SoundPoolInstance = {
	Play: (self: SoundPoolInstance, soundId: string, soundGroup: SoundGroup?, volume: number?, pitch: number?, parent: Instance?) -> Sound?,
	Return: (self: SoundPoolInstance, sound: Sound) -> (),
}

local soundTemplate = Instance.new("Sound")
soundTemplate.Name = "PooledSound"
soundTemplate.PlayOnRemove = false

local internalPool = ObjectPool.new(soundTemplate, 15)

function SoundPool.Play(soundId: string, soundGroup: SoundGroup?, volume: number?, pitch: number?, parent: Instance?): Sound?
	if not soundId or soundId == "" or soundId == "rbxassetid://0" then
		return nil
	end

	local soundObj = internalPool:Get() :: Sound
	soundObj.SoundId = soundId
	soundObj.Volume = volume or 0.8
	soundObj.PlaybackSpeed = pitch or 1.0
	soundObj.SoundGroup = soundGroup
	soundObj.Parent = parent or SoundService

	local conn: RBXScriptConnection? = nil
	local cleanup = function()
		if conn then
			conn:Disconnect()
			conn = nil
		end
		soundObj:Stop()
		internalPool:Return(soundObj)
	end

	conn = soundObj.Ended:Connect(cleanup)

	soundObj:Play()

	-- Safety cleanup fallback
	task.delay(10, function()
		if conn then
			cleanup()
		end
	end)

	return soundObj
end

return SoundPool
