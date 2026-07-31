--!strict
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Animator = Players.LocalPlayer.Character
	and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
	and Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid").Animator

local AssetManifest = require(ReplicatedStorage.Shared.Assets.AssetManifest)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local AnimationController = {
	Name = "AnimationController",
}

local currentTrack: AnimationTrack? = nil
local activeTracks: { AnimationTrack } = {}

function AnimationController.Init(self)
	self.maid = Maid.new()
end

function AnimationController.Start(self)
	local char = Players.LocalPlayer.Character
	if char then
		AnimationController._LoadAnimator(char)
	end
	Players.LocalPlayer.CharacterAdded:Connect(function(newChar)
		AnimationController._LoadAnimator(newChar)
	end)
end

function AnimationController._LoadAnimator(char: Model)
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if humanoid then
		Animator = humanoid.Animator
	end
end

function AnimationController.PlaySwing(self, comboStep: number?)
	if not Animator then
		return
	end
	AnimationController._StopCurrent()

	local animIds = {
		AssetManifest.Animations.SwordSwing,
		AssetManifest.Animations.SwordSwing2,
		AssetManifest.Animations.SwordSwing3,
	}
	local animId = animIds[comboStep or 1] or animIds[1]

	local ok, anim = pcall(function()
		return Animator:LoadAnimation({
			AnimationId = animId,
		})
	end)

	if ok and anim then
		anim.Priority = Enum.AnimationPriority.Action4
		anim:Play(0.1, 1, 1)
		table.insert(activeTracks, anim)
		currentTrack = anim
	end
end

function AnimationController.PlayParry(self)
	if not Animator then
		return
	end
	AnimationController._StopCurrent()

	local animId = AssetManifest.Animations.Parry

	local ok, anim = pcall(function()
		return Animator:LoadAnimation({
			AnimationId = animId,
		})
	end)

	if ok and anim then
		anim.Priority = Enum.AnimationPriority.Action4
		anim:Play(0.05, 1, 1)
		table.insert(activeTracks, anim)
		currentTrack = anim
	end
end

function AnimationController.PlayDash(self)
	if not Animator then
		return
	end
	AnimationController._StopCurrent()

	local animId = AssetManifest.Animations.Dash

	local ok, anim = pcall(function()
		return Animator:LoadAnimation({
			AnimationId = animId,
		})
	end)

	if ok and anim then
		anim.Priority = Enum.AnimationPriority.Action4
		anim:Play(0.05, 1, 1.5)
		table.insert(activeTracks, anim)
		currentTrack = anim
	end
end

function AnimationController.PlayStun(self)
	if not Animator then
		return
	end
	AnimationController._StopCurrent()

	local animId = AssetManifest.Animations.Stun

	local ok, anim = pcall(function()
		return Animator:LoadAnimation({
			AnimationId = animId,
		})
	end)

	if ok and anim then
		anim.Priority = Enum.AnimationPriority.Action3
		anim:Play(0.05, 1, 1)
		table.insert(activeTracks, anim)
		currentTrack = anim
	end
end

function AnimationController.PlayEquip(self)
	if not Animator then
		return
	end
	AnimationController._StopCurrent()

	local animId = AssetManifest.Animations.Equip

	local ok, anim = pcall(function()
		return Animator:LoadAnimation({
			AnimationId = animId,
		})
	end)

	if ok and anim then
		anim.Priority = Enum.AnimationPriority.Action2
		anim:Play(0.1, 1, 0.8)
		table.insert(activeTracks, anim)
		currentTrack = anim
	end
end

function AnimationController._StopCurrent()
	if currentTrack then
		currentTrack:Stop(0.1)
		currentTrack:Destroy()
		currentTrack = nil
	end
end

function AnimationController.StopAll(self)
	AnimationController._StopCurrent()
	for _, track in ipairs(activeTracks) do
		track:Stop(0.1)
		track:Destroy()
	end
	activeTracks = {}
end

return AnimationController
