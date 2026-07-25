--!strict
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local CreatureBuilder = require(ReplicatedStorage.Shared.Modules.Render.CreatureBuilder)
local CombatEvent = NetChannels.GetRemoteEvent("CombatEvent")

local MobService = {}

export type MobState = "IDLE" | "CHASE" | "WINDUP" | "ATTACK" | "RETURN" | "DEAD"
export type Mob = {
	Id: string,
	Model: Model,
	State: MobState,
	StateTime: number,
	Target: Player?,
	Health: number,
	SpawnPosition: Vector3,
}

local activeMobs: { [string]: Mob } = {}
local MOB_SPEED = 14
local AGGRO_RADIUS = 30
local ATTACK_RANGE = 6
local LEASH_DISTANCE = 45
local WINDUP_DURATION = 1.0

function MobService.Init()
	-- Tick-Rate Driven AI Loop (0.5 second pulse for performance budget < 2.5 GB RAM)
	task.spawn(function()
		while true do
			MobService.Tick(0.5)
			task.wait(0.5)
		end
	end)
	print("🧟 MobService Initialized (5-State FSM Architecture)")
end

function MobService.SpawnMob(id: string, position: Vector3)
	local mobModel: Model
	if string.find(id, "Golem") or string.find(id, "Tank") then
		mobModel = CreatureBuilder.BuildCrystalGolem("CrystalGolem_" .. id, position)
	elseif string.find(id, "Pyro") or string.find(id, "Beast") then
		mobModel = CreatureBuilder.BuildPyroBeast("PyroBeast_" .. id, position)
	elseif string.find(id, "Spectre") or string.find(id, "Ghost") then
		mobModel = CreatureBuilder.BuildAstralSpectre("AstralSpectre_" .. id, position)
	elseif string.find(id, "Titan") or string.find(id, "Boss") then
		mobModel = CreatureBuilder.BuildVoidTitan("VoidTitan_" .. id, position)
	else
		-- Default / Varied monster selection based on id string length hash
		local index = (#id % 4) + 1
		if index == 1 then
			mobModel = CreatureBuilder.BuildShadowWraith("ShadowWraith_" .. id, position)
		elseif index == 2 then
			mobModel = CreatureBuilder.BuildCrystalGolem("CrystalGolem_" .. id, position)
		elseif index == 3 then
			mobModel = CreatureBuilder.BuildPyroBeast("PyroBeast_" .. id, position)
		else
			mobModel = CreatureBuilder.BuildAstralSpectre("AstralSpectre_" .. id, position)
		end
	end
	mobModel:SetAttribute("MobId", id)
	
	local hrp = mobModel.PrimaryPart
	if not hrp then return end

	-- 3D Overhead Health Bar & Name HUD (Hologram Theme)
	local bb = Instance.new("BillboardGui")
	bb.Name = "MobHealthHUD"
	bb.Size = UDim2.new(0, 160, 0, 45)
	bb.StudsOffset = Vector3.new(0, 4, 0)
	bb.MaxDistance = 35 -- Reduced to prevent clutter
	bb.AlwaysOnTop = false

	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 1, 0)
	card.BackgroundColor3 = Color3.fromRGB(15, 23, 42)
	card.BackgroundTransparency = 0.25
	card.BorderSizePixel = 0
	card.Parent = bb

	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 6)
	uiCorner.Parent = card

	local uiStroke = Instance.new("UIStroke")
	uiStroke.Color = Color3.fromRGB(239, 68, 68)
	uiStroke.Thickness = 1 -- Thinner stroke for premium look
	uiStroke.Parent = card

	local nameLbl = Instance.new("TextLabel")
	nameLbl.Size = UDim2.new(1, -6, 0, 18)
	nameLbl.Position = UDim2.new(0, 3, 0, 2)
	nameLbl.Text = "<b>👻 SHADOW WRAITH</b>"
	nameLbl.RichText = true
	nameLbl.BackgroundTransparency = 1
	nameLbl.TextColor3 = Color3.fromRGB(255, 255, 255) -- White text for better contrast
	nameLbl.TextScaled = true
	nameLbl.Font = Enum.Font.GothamBold
	nameLbl.Parent = card

	local nameStroke = Instance.new("UIStroke")
	nameStroke.Color = Color3.fromRGB(153, 27, 27) -- Dark red stroke for readability
	nameStroke.Thickness = 1.5
	nameStroke.Parent = nameLbl

	local hpBg = Instance.new("Frame")
	hpBg.Name = "HPBg"
	hpBg.Size = UDim2.new(0.9, 0, 0, 12)
	hpBg.Position = UDim2.new(0.05, 0, 0.58, 0)
	hpBg.BackgroundColor3 = Color3.fromRGB(30, 41, 59)
	hpBg.Parent = card

	local hpCorner = Instance.new("UICorner")
	hpCorner.CornerRadius = UDim.new(0, 4)
	hpCorner.Parent = hpBg

	local hpBar = Instance.new("Frame")
	hpBar.Name = "HPBar"
	hpBar.Size = UDim2.new(1, 0, 1, 0)
	hpBar.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	hpBar.Parent = hpBg

	local hpBarCorner = Instance.new("UICorner")
	hpBarCorner.CornerRadius = UDim.new(0, 4)
	hpBarCorner.Parent = hpBar

	bb.Parent = hrp
	mobModel.Parent = workspace
	
	-- Physics Movers for Smooth Interpolation
	local attachment = Instance.new("Attachment")
	attachment.Name = "MoverAttachment"
	attachment.Parent = hrp
	
	local alignPos = Instance.new("AlignPosition")
	alignPos.Attachment0 = attachment
	alignPos.Mode = Enum.PositionAlignmentMode.OneAttachment
	alignPos.Position = position
	alignPos.MaxForce = 100000
	alignPos.MaxVelocity = MOB_SPEED
	alignPos.Responsiveness = 40
	alignPos.Parent = hrp
	
	local alignOri = Instance.new("AlignOrientation")
	alignOri.Attachment0 = attachment
	alignOri.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOri.CFrame = hrp.CFrame
	alignOri.MaxTorque = 100000
	alignOri.MaxAngularVelocity = 15
	alignOri.Responsiveness = 30
	alignOri.Parent = hrp
	
	-- Ensure Unanchored for Physics
	hrp.Anchored = false
	hrp:SetNetworkOwner(nil) -- Force Server Ownership for AlignPosition to work!

	local mobActor = Instance.new("Actor")
	mobActor.Name = "MobActor"
	mobActor.Parent = mobModel
	
	activeMobs[id] = {
		Id = id,
		Model = mobModel,
		Actor = mobActor,
		State = "IDLE",
		StateTime = os.clock(),
		Target = nil,
		Health = 100,
		SpawnPosition = position,
	}
end

function MobService.Start()
	-- Auto-spawn initial mobs in central wild nest area (0, 5, 0)
	MobService.SpawnMob("Mob_1", Vector3.new(0, 5, 0))
	MobService.SpawnMob("Mob_2", Vector3.new(-12, 5, 12))
	MobService.SpawnMob("Mob_3", Vector3.new(12, 5, -12))
end

function MobService.TriggerAggro(player: Player, mobId: string?)
	if MobService._IsPlayerInSafeZone(player) then return end
	
	if mobId then
		local mob = activeMobs[mobId]
		if mob and mob.State == "IDLE" then
			mob.Target = player
			mob.State = "CHASE"
			mob.StateTime = os.clock()
		end
	else
		-- Trigger nearest IDLE mob
		for _, mob in activeMobs do
			if mob.State == "IDLE" then
				mob.Target = player
				mob.State = "CHASE"
				mob.StateTime = os.clock()
				break
			end
		end
	end
end

function MobService.GetMob(id: string): Mob?
	return activeMobs[id]
end

function MobService.TakeDamage(id: string, amount: number, attacker: Player?)
	local mob = activeMobs[id]
	if mob and mob.State ~= "DEAD" and mob.State ~= "RETURN" then -- Invulnerable during RETURN
		mob.Health -= amount
		if mob.Health <= 0 then
			mob.State = "DEAD"
			mob.Model:Destroy()
			activeMobs[id] = nil

			-- Award loot drop
			if attacker then
				local EconomyService = require(script.Parent.EconomyService)
				EconomyService.AddCurrency(attacker, "Coins", 50, "MobLoot")
				print(string.format("[MobService] Player %s defeated mob %s (+50 Coins)", attacker.Name, id))
			end

			-- Respawn mob after delay
			task.delay(10, function()
				MobService.SpawnMob(id, mob.SpawnPosition)
			end)
		end
	end
end

function MobService.Tick(dt: number)
	for id, mob in activeMobs do
		local hrp = mob.Model.PrimaryPart
		if not hrp then continue end
		
		local alignPos = hrp:FindFirstChildOfClass("AlignPosition")
		local alignOri = hrp:FindFirstChildOfClass("AlignOrientation")
		
		if not alignPos or not alignOri then continue end
		
		local now = os.clock()
		local timeInState = now - mob.StateTime
		
		if mob.State == "IDLE" then
			-- Proximity Aggro Detection (AGGRO_RADIUS = 30)
			for _, player in ipairs(Players:GetPlayers()) do
				if player.Character and player.Character.PrimaryPart then
					local dist = (player.Character.PrimaryPart.Position - hrp.Position).Magnitude
					if dist <= AGGRO_RADIUS and not MobService._IsPlayerInSafeZone(player) then
						mob.Target = player
						mob.State = "CHASE"
						mob.StateTime = now
						print(string.format("[MobService] Mob %s aggroed on player %s!", id, player.Name))
						break
					end
				end
			end

			-- Gentle Idle Patrol around central nest spawn point
			if mob.State == "IDLE" and timeInState > 4 then
				local randomAngle = math.rad(math.random(0, 360))
				local patrolTarget = mob.SpawnPosition + Vector3.new(math.cos(randomAngle) * 10, 0, math.sin(randomAngle) * 10)
				alignPos.Position = patrolTarget
				alignOri.CFrame = CFrame.lookAt(hrp.Position, patrolTarget)
				mob.StateTime = now
			end
			
		elseif mob.State == "CHASE" then
			-- Event-Triggered Aggro has a 15-second chase limit or safe zone leash
			if timeInState > 15 or not mob.Target or not mob.Target.Character or not mob.Target.Character.PrimaryPart or MobService._IsPlayerInSafeZone(mob.Target) then
				-- Time limit reached or Player entered Safe Zone -> RETURN to nest
				mob.Target = nil
				mob.State = "RETURN"
				mob.StateTime = now
				continue
			end
			
			local targetPos = mob.Target.Character.PrimaryPart.Position
			local hrpPos = hrp.Position
			
			local distFromTarget = (targetPos - hrpPos).Magnitude
			local distFromSpawn = (hrpPos - mob.SpawnPosition).Magnitude
			local lookAtCFrame = CFrame.lookAt(hrpPos, targetPos * Vector3.new(1,0,1) + Vector3.new(0, hrpPos.Y, 0))
			
			if distFromTarget > LEASH_DISTANCE or distFromSpawn > LEASH_DISTANCE then
				-- Exceeded Leash distance -> RETURN state
				mob.Target = nil
				mob.State = "RETURN"
				mob.StateTime = now
			elseif distFromTarget <= ATTACK_RANGE then
				-- Within attack range -> WINDUP warning state (1.0s stop + Red Zone Visual Telegraph)
				mob.State = "WINDUP"
				mob.StateTime = now
				alignPos.Position = hrp.Position -- Stop moving

				-- Flash Eyes Red for WINDUP telegraph
				local eyesCore = mob.Model:FindFirstChild("EyesCore") :: BasePart?
				if eyesCore then
					eyesCore.Color = Color3.fromRGB(255, 255, 255)
					task.delay(0.2, function()
						if eyesCore then eyesCore.Color = Color3.fromRGB(239, 68, 68) end
					end)
				end

				CombatEvent:FireAllClients("MobWindup", mob.Id, targetPos)
			else
				-- Physics follow target
				alignPos.Position = targetPos
				alignOri.CFrame = CFrame.lookAt(hrp.Position, targetPos * Vector3.new(1,0,1) + Vector3.new(0, hrp.Position.Y, 0))
			end
			
		elseif mob.State == "WINDUP" then
			if timeInState >= WINDUP_DURATION then 
				mob.State = "ATTACK"
				mob.StateTime = now
			end
			
		elseif mob.State == "ATTACK" then
			-- Hitbox Validation via Spatial Query (Lag-compensated) & Auto-Transition back to CHASE
			if mob.Target and mob.Target.Character and mob.Target.Character.PrimaryPart then
				local targetChar = mob.Target.Character
				
				local overlapParams = OverlapParams.new()
				overlapParams.FilterType = Enum.RaycastFilterType.Include
				overlapParams.FilterDescendantsInstances = {targetChar}
				
				local attackHitboxSize = Vector3.new(ATTACK_RANGE * 2, 8, ATTACK_RANGE * 2)
				local attackHitboxCFrame = hrp.CFrame * CFrame.new(0, 0, -ATTACK_RANGE/2)
				
				local hitParts = workspace:GetPartBoundsInBox(attackHitboxCFrame, attackHitboxSize, overlapParams)
				
				if #hitParts > 0 then
					local CombatService = require(script.Parent.CombatService)
					if CombatService.CheckParry(mob.Target) then
						CombatEvent:FireAllClients("MobStunned", mob.Id)
					else
						local hum = targetChar:FindFirstChildOfClass("Humanoid")
						if hum then
							hum:TakeDamage(20)
						end
					end
				end
			end
			
			-- Auto-transition back to CHASE
			mob.State = "CHASE"
			mob.StateTime = now
			
		elseif mob.State == "RETURN" then
			-- Walk back to SpawnPosition
			local distToSpawn = (mob.SpawnPosition - hrp.Position).Magnitude
			if distToSpawn <= 2 then
				mob.State = "IDLE"
				mob.StateTime = now
			else
				alignPos.Position = mob.SpawnPosition
				alignOri.CFrame = CFrame.lookAt(hrp.Position, mob.SpawnPosition)
			end
		end
	end
end

function MobService._IsPlayerInSafeZone(player: Player): boolean
	local char = player.Character
	if not char or not char.PrimaryPart then return false end
	
	local pos = char.PrimaryPart.Position
	local mapFolder = workspace:FindFirstChild("Map")
	if not mapFolder then return false end
	
	local plots = mapFolder:FindFirstChild("Plots")
	if not plots then return false end
	
	for _, plot in ipairs(plots:GetChildren()) do
		if plot:IsA("BasePart") then
			-- Check 2D distance inside Tycoon Plot (Radius <= 25 studs)
			local dist = (Vector3.new(pos.X, 0, pos.Z) - Vector3.new(plot.Position.X, 0, plot.Position.Z)).Magnitude
			if dist <= 25 then
				return true
			end
		end
	end
	
	return false
end

return MobService
