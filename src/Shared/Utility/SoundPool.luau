--!strict
-- SoundPool utility for recycling Sound instances and avoiding memory allocation chatter
-- Fase 6: Per-category pools (SFX=20, UI=8, Ambient=4) for fine-grained memory budgeting.
-- Complies with COBLOX memory budget (<6GB RAM target) and SOA standards.

local SoundService = game:GetService("SoundService")
local ObjectPool = require(script.Parent.ObjectPool)

local SoundPool = {}
SoundPool.__index = SoundPool

export type SoundCategory = "SFX" | "UI" | "Ambient"

-- Per-category pool sizes
local CATEGORY_SIZES: { [SoundCategory]: number } = {
	SFX = 20,
	UI = 8,
	Ambient = 4,
}

-- Lazy-init pools per category
local categoryPools: { [SoundCategory]: typeof(ObjectPool.new(Instance.new("Sound"), 1)) } = {} :: any

local function _getPool(category: SoundCategory)
	if not categoryPools[category] then
		local template = Instance.new("Sound")
		template.Name = "PooledSound_" .. category
		template.PlayOnRemove = false
		categoryPools[category] = ObjectPool.new(template, CATEGORY_SIZES[category] or 8)
	end
	return categoryPools[category]
end

-- Play a pooled sound.
-- @param category  "SFX" | "UI" | "Ambient"  (defaults to "SFX")
function SoundPool.Play(
	soundId: string,
	category: SoundCategory?,
	soundGroup: SoundGroup?,
	volume: number?,
	pitch: number?,
	parent: Instance?
): Sound?
	if not soundId or soundId == "" or soundId == "rbxassetid://0" then
		return nil
	end

	local cat: SoundCategory = category or "SFX"
	local pool = _getPool(cat)
	local soundObj = pool:Get() :: Sound
	soundObj.SoundId = soundId
	soundObj.Volume = volume or 0.8
	soundObj.PlaybackSpeed = pitch or 1.0
	soundObj.SoundGroup = soundGroup
	soundObj.Parent = parent or SoundService

	local conn: RBXScriptConnection? = nil
	local function cleanup()
		if conn then
			conn:Disconnect()
			conn = nil
		end
		soundObj:Stop()
		pool:Return(soundObj)
	end

	conn = soundObj.Ended:Connect(cleanup)
	soundObj:Play()

	-- Safety cleanup fallback (max 10s)
	task.delay(10, function()
		if conn then
			cleanup()
		end
	end)

	return soundObj
end

return SoundPool
