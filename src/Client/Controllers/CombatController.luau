--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local CombatEvent = NetChannels.GetRemoteEvent("CombatEvent")

local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local CombatController = {}
local canAttack = true
local isDashing = false

local VFXEngine = require(script.Parent.Parent.Modules.UI.VFXEngine)

function CombatController.Init()
	-- Bind Mobile & PC Actions via ContextActionService (creates Touch Buttons automatically on Mobile)
	ContextActionService:BindAction("AttackAction", function(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			CombatController.Attack()
		end
	end, true, Enum.KeyCode.ButtonX)
	ContextActionService:SetTitle("AttackAction", "🗡️ SWORD")

	ContextActionService:BindAction("ParryAction", function(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			CombatController.Parry()
		end
	end, true, Enum.KeyCode.F, Enum.KeyCode.ButtonY)
	ContextActionService:SetTitle("ParryAction", "🛡️ PARRY [F]")

	ContextActionService:BindAction("DashAction", function(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			CombatController.Dash()
		end
	end, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonL2)
	ContextActionService:SetTitle("DashAction", "⚡ DASH [Q]")

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			CombatController.Attack()
		elseif input.KeyCode == Enum.KeyCode.C then
			CombatController.ConsumePotion()
		elseif input.KeyCode == Enum.KeyCode.G then
			CombatController.TriggerFlex()
		end
	end)

	CombatEvent.OnClientEvent:Connect(function(event, mobId)
		if event == "MobWindup" then
			CombatController.PlayTelegraph(mobId)
		elseif event == "MobStunned" then
			CombatController.PlayStunVFX(mobId)
		end
	end)

	print("⚔️ CombatController Initialized with Mobile Touch Support")
end

function CombatController.Attack()
	if not canAttack or isDashing then
		return
	end
	canAttack = false

	print("[VFX] Slash played!")

	local char = Players.LocalPlayer.Character
	if char and char.PrimaryPart then
		local nearestMobId = nil
		local nearestDist = 15

		for _, part in Workspace:GetChildren() do
			if part.Name == "CorruptedElemental" and part.PrimaryPart then
				local dist = (part.PrimaryPart.Position - char.PrimaryPart.Position).Magnitude
				if dist <= nearestDist then
					nearestDist = dist
					nearestMobId = part:GetAttribute("MobId")

					-- Trigger Impact Sparks locally for juicy visual feedback
					VFXEngine.EmitImpactSparks(
						part.PrimaryPart.Position + Vector3.new(0, 1, 0),
						Color3.fromRGB(255, 180, 50)
					)
					VFXEngine.HitStop(0.04)
					VFXEngine.PlayCameraShake(0.3, 0.15)
				end
			end
		end

		CombatEvent:FireServer("Attack", nearestMobId)
	end

	task.delay(0.4, function()
		canAttack = true
	end)
end

function CombatController.Dash()
	if isDashing then
		return
	end
	isDashing = true
	print("[VFX] Dash trail played!")
	task.delay(0.5, function()
		isDashing = false
	end)
end

function CombatController.Parry()
	print("[VFX] Parry shield activated!")
	CombatEvent:FireServer("Parry")

	-- 3D Visual Hologram Shield Effect on Player Character
	local char = Players.LocalPlayer.Character
	if char and char.PrimaryPart then
		local hrp = char.PrimaryPart
		local shield = Instance.new("Part")
		shield.Name = "ParryShield"
		shield.Shape = Enum.PartType.Ball
		shield.Size = Vector3.new(6, 6, 6)
		shield.CFrame = hrp.CFrame
		shield.Color = Color3.fromRGB(56, 189, 248) -- Cyan Hologram Shield
		shield.Material = Enum.Material.ForceField
		shield.CanCollide = false
		shield.Anchored = true
		shield.Parent = Workspace

		local tween = TweenService:Create(shield, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(8, 8, 8),
			Transparency = 1,
		})
		tween:Play()
		tween.Completed:Connect(function()
			shield:Destroy()
		end)
	end
end

function CombatController.PlayTelegraph(mobId: string)
	print("[VFX] ⚠️ RED TELEGRAPH: Monster is winding up to attack! Press F / Shield to PARRY!")
	local uiFolder = script.Parent
	local UIController = require(uiFolder:WaitForChild("UIController") :: any)
	UIController.ShowNotification(
		"⚠️ PERINGATAN: Monster akan menyerang! Tekan [F] / Tombol Tameng untuk MENANGKIS!"
	)
end

function CombatController.PlayStunVFX(mobId: string)
	print("[VFX] 💥 PERFECT PARRY! Monster stunned!")

	-- Cinematic dopamine hit
	VFXEngine.ScreenPunch(0.8)
	VFXEngine.PlayCameraShake(0.6, 0.25)

	local uiFolder = script.Parent
	local UIController = require(uiFolder:WaitForChild("UIController") :: any)
	UIController.ShowNotification("💥 TANGKISAN SEMPURNA! Monster Terkena Stun (+50 Coins)!")
end

function CombatController.ConsumePotion()
	local consumeRemoteFunc = NetChannels.GetRemoteFunction("RequestConsumePotion")
	if consumeRemoteFunc then
		print("[CombatController] Requesting potion consumption...")
		local res = consumeRemoteFunc:InvokeServer("DefaultPotion")
		print("[CombatController] Potion Result:", res)
	end
end

function CombatController.TriggerFlex()
	local flexRemoteFunc = NetChannels.GetRemoteFunction("RequestFlexEffect")
	if flexRemoteFunc then
		print("[CombatController] Requesting Flex Effect...")
		local res = flexRemoteFunc:InvokeServer("GoldAura")
		print("[CombatController] Flex Result:", res)
	end
end

return CombatController
