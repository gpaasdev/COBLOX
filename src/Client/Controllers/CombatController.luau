--!strict
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local CombatEvent = NetChannels.GetRemoteEvent("CombatEvent")
local MobWindupVFX = NetChannels.GetUnreliableRemoteEvent("MobWindupVFX")

local ContextActionService = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")

local CombatController = {}
local canAttack = true
local isDashing = false

local PLAYER_WEAPONS = { "Fist", "Sword", "Staff" }
local currentWeapon = "Fist"
local weaponDamage = { Fist = 10, Sword = 25, Staff = 35 }
local weaponRange = { Fist = 8, Sword = 14, Staff = 20 }

local VFXEngine = require(script.Parent.Parent.Modules.UI.VFXEngine)
local LocalizationController = require(script.Parent:WaitForChild("LocalizationController") :: any)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

function CombatController.Init(self)
	self.maid = Maid.new()
	-- Bind Mobile & PC Actions via ContextActionService (creates Touch Buttons automatically on Mobile)
	ContextActionService:BindAction("AttackAction", function(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			CombatController.Attack()
		end
	end, true, Enum.KeyCode.ButtonX)
	ContextActionService:SetTitle("AttackAction", "🗡️ SWORD")
	ContextActionService:SetPosition("AttackAction", UDim2.new(0.85, 0, 0.8, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("AttackAction")
	end)

	ContextActionService:BindAction("ParryAction", function(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			CombatController.Parry()
		end
	end, true, Enum.KeyCode.F, Enum.KeyCode.ButtonY)
	ContextActionService:SetTitle("ParryAction", "🛡️ PARRY [F]")
	ContextActionService:SetPosition("ParryAction", UDim2.new(0.75, 0, 0.65, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("ParryAction")
	end)

	ContextActionService:BindAction("DashAction", function(actionName, inputState)
		if inputState == Enum.UserInputState.Begin then
			CombatController.Dash()
		end
	end, true, Enum.KeyCode.Q, Enum.KeyCode.ButtonL2)
	ContextActionService:SetTitle("DashAction", "⚡ DASH [Q]")
	ContextActionService:SetPosition("DashAction", UDim2.new(0.02, 0, 0.8, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("DashAction")
	end)

	ContextActionService:BindAction("WeaponSwitch", function()
		CombatController.SwitchWeapon()
	end, false, Enum.KeyCode.X, Enum.KeyCode.ButtonL1)
	ContextActionService:SetTitle("WeaponSwitch", "🔪 WEAPON")
	ContextActionService:SetPosition("WeaponSwitch", UDim2.new(0.02, 0, 0.65, 0))
	self.maid:GiveTask(function()
		ContextActionService:UnbindAction("WeaponSwitch")
	end)

	self.maid:GiveTask(UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then
			return
		end
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			CombatController.Attack()
		elseif input.KeyCode == Enum.KeyCode.X then
			CombatController.SwitchWeapon()
		elseif input.KeyCode == Enum.KeyCode.C then
			CombatController.ConsumePotion()
		elseif input.KeyCode == Enum.KeyCode.G then
			CombatController.TriggerFlex()
		end
	end))

	self.maid:GiveTask(CombatEvent.OnClientEvent:Connect(function(event, data)
		if event == "MobStunned" then
			require(script.Parent.CombatVFXController).PlayStunVFX(data)
		elseif event == "MobDamaged" then
			if typeof(data) == "table" then
				local dmgText = tostring(data.damage)
				VFXEngine.CreateFloatingText(dmgText, data.position, Color3.fromRGB(255, 50, 50))
				if data.currentHp <= 0 then
					VFXEngine.CreateFloatingText("KILL!", data.position, Color3.fromRGB(255, 200, 0))
				end
			end
		elseif event == "PotionUsed" then
			VFXEngine.CreateFloatingText("+30 HP!", Vector3.new(), Color3.fromRGB(50, 255, 50))
		elseif event == "FlexEffect" then
			VFXEngine.CreateFloatingText("💪 FLEX!", Vector3.new(), Color3.fromRGB(255, 255, 0))
		end
	end))

	if MobWindupVFX then
		self.maid:GiveTask(MobWindupVFX.OnClientEvent:Connect(function(mobId: string, targetPos: Vector3)
			require(script.Parent.CombatVFXController).PlayTelegraph(mobId)
		end))
	end

	print("⚔️ CombatController Initialized with Mobile Touch Support")
end

function CombatController._UpdateWeaponVisual()
	local char = Players.LocalPlayer.Character
	if not char then
		return
	end
	local existing = char:FindFirstChild("WeaponHandle")
	if existing then
		existing:Destroy()
	end
	local handle = Instance.new("Part")
	handle.Name = "WeaponHandle"
	handle.Size = Vector3.new(0.4, 2, 0.4)
	handle.Anchored = false
	handle.CanCollide = false
	handle.Color = if currentWeapon == "Sword"
		then Color3.fromRGB(200, 200, 255)
		elseif currentWeapon == "Staff" then Color3.fromRGB(255, 200, 100)
		else Color3.fromRGB(255, 100, 100)
	handle.Material = Enum.Material.Metal
	handle.Parent = char
	local weld = Instance.new("Weld")
	weld.Part0 = handle
	weld.Part1 = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm") or char.PrimaryPart
	weld.C0 = CFrame.new(0, -1, 0.5) * CFrame.Angles(math.rad(45), 0, 0)
	weld.Parent = handle
end

function CombatController.SwitchWeapon()
	local idx = 0
	for i, w in ipairs(PLAYER_WEAPONS) do
		if w == currentWeapon then
			idx = i % #PLAYER_WEAPONS + 1
			break
		end
	end
	currentWeapon = PLAYER_WEAPONS[idx]
	CombatController._UpdateWeaponVisual()
	CombatEvent:FireServer("SwitchWeapon", currentWeapon)
	print(
		string.format(
			"[CombatController] Weapon switched to: %s (DMG: %d, Range: %d)",
			currentWeapon,
			weaponDamage[currentWeapon],
			weaponRange[currentWeapon]
		)
	)
	local uiFolder = script.Parent
	local UIController = require(uiFolder:WaitForChild("UIController") :: any)
	UIController.ShowNotification(
		string.format(
			LocalizationController.Get("COMBAT_WEAPON_INFO"),
			currentWeapon,
			weaponDamage[currentWeapon],
			weaponRange[currentWeapon]
		)
	)
end

function CombatController.Attack()
	if not canAttack or isDashing then
		return
	end
	canAttack = false

	local char = Players.LocalPlayer.Character
	if not char or not char.PrimaryPart then
		task.delay(0.4, function()
			canAttack = true
		end)
		return
	end

	local mobsFolder = Workspace:FindFirstChild("Mobs") or Workspace
	local nearestMobId = nil
	local nearestDist = weaponRange[currentWeapon]
	local attackRange = nearestDist

	for _, child in ipairs(mobsFolder:GetChildren()) do
		if child:IsA("Model") then
			local mobId = child:GetAttribute("MobId")
			local prim = child.PrimaryPart
			if mobId and prim then
				local dist = (prim.Position - char.PrimaryPart.Position).Magnitude
				if dist <= attackRange then
					nearestDist = dist
					nearestMobId = mobId

					VFXEngine.EmitImpactSparks(prim.Position + Vector3.new(0, 1, 0), Color3.fromRGB(255, 180, 50))
					VFXEngine.HitStop(0.04)
					VFXEngine.PlayCameraShake(0.3, 0.15)
				end
			end
		end
	end

	local weaponIdMap = { Fist = "Fist", Sword = "IronSword", Staff = "FlameSaber" }
	CombatEvent:FireServer("Attack", nearestMobId, weaponIdMap[currentWeapon] or "Fist")

	if nearestMobId then
		print(
			string.format(
				"[CombatController] Attacked mob %s with %s (DMG: %d)",
				nearestMobId,
				currentWeapon,
				weaponDamage[currentWeapon]
			)
		)
	else
		print("[CombatController] No mobs in range")
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
		CombatController.maid:GiveTask(tween.Completed:Connect(function()
			shield:Destroy()
		end))
	end
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
