--!strict
--[[
	ProceduralAlchemicalCore.luau
	High-Fidelity 3D Alchemical Core Visual Asset for COBLOX
	Features:
	- Procedural 3D Geometry (Glowing Core + 3 Concentric Orbiting Rings)
	- Spring-Damper Physics Engine (Elastic Juiciness on Interaction)
	- Automatic PBR Fallback Architecture (SurfaceAppearance -> Glass/Neon/Metal)
	- Client-Side RenderStepped Loop (60 FPS, Zero Server Latency)
--]]

local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ProceduralAlchemicalCore = {}
ProceduralAlchemicalCore.__index = ProceduralAlchemicalCore

export type CoreOptions = {
	CoreColor: Color3?,
	RingColor: Color3?,
	Scale: number?,
	EnableCameraShake: boolean?,
	PBRColorMap: string?,
	PBRNormalMap: string?,
}

-- Simple 1D Spring Physics Solver
type Spring = {
	Target: number,
	Position: number,
	Velocity: number,
	Stiffness: number,
	Damping: number,
	Update: (self: Spring, dt: number) -> number,
	Impulse: (self: Spring, force: number) -> (),
}

local function CreateSpring(stiffness: number, damping: number): Spring
	local self = {
		Target = 1.0,
		Position = 1.0,
		Velocity = 0,
		Stiffness = stiffness or 160,
		Damping = damping or 12,
	} :: any

	function self:Update(dt: number): number
		local force = (self.Target - self.Position) * self.Stiffness
		self.Velocity = (self.Velocity + force * dt) * (1 - math.clamp(self.Damping * dt, 0, 1))
		self.Position = self.Position + self.Velocity * dt
		return self.Position
	end

	function self:Impulse(force: number)
		self.Velocity = self.Velocity + force
	end

	return self
end

function ProceduralAlchemicalCore.new(parent: Instance, position: Vector3, options: CoreOptions?)
	local opts = options or {}
	local coreColor = opts.CoreColor or Color3.fromRGB(56, 189, 248) -- Cyber Neon Cyan
	local ringColor = opts.RingColor or Color3.fromRGB(168, 85, 247) -- Mana Purple
	local scale = opts.Scale or 1.0
	local enableShake = if opts.EnableCameraShake ~= nil then opts.EnableCameraShake else true

	local model = Instance.new("Model")
	model.Name = "AlchemicalCore_" .. tostring(math.random(1000, 9999))

	-- Main Pivot Root Part
	local rootPart = Instance.new("Part")
	rootPart.Name = "CoreRoot"
	rootPart.Size = Vector3.new(0.2, 0.2, 0.2)
	rootPart.Position = position
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.CanTouch = false
	rootPart.CanQuery = false
	rootPart.Transparency = 1
	rootPart.Parent = model

	model.PrimaryPart = rootPart

	-- 1. Glowing Central Crystal Core
	local corePart = Instance.new("Part")
	corePart.Name = "CrystalCore"
	corePart.Shape = Enum.PartType.Ball
	corePart.Size = Vector3.new(4 * scale, 4 * scale, 4 * scale)
	corePart.Position = position
	corePart.Anchored = true
	corePart.CanCollide = false
	corePart.CanTouch = false
	corePart.Material = Enum.Material.Glass
	corePart.Color = coreColor
	corePart.Transparency = 0.2
	corePart.Parent = model

	-- Inner Neon Power Source
	local innerPower = Instance.new("Part")
	innerPower.Name = "InnerPower"
	innerPower.Shape = Enum.PartType.Ball
	innerPower.Size = Vector3.new(2.2 * scale, 2.2 * scale, 2.2 * scale)
	innerPower.Position = position
	innerPower.Anchored = true
	innerPower.CanCollide = false
	innerPower.CanTouch = false
	innerPower.Material = Enum.Material.Neon
	innerPower.Color = coreColor
	innerPower.Parent = model

	-- Light Source
	local pointLight = Instance.new("PointLight")
	pointLight.Color = coreColor
	pointLight.Range = 25 * scale
	pointLight.Brightness = 3
	pointLight.Parent = innerPower

	-- Particle Spores Emitter
	local particleEmitter = Instance.new("ParticleEmitter")
	particleEmitter.Name = "AlchemicalSpores"
	particleEmitter.Texture = "rbxassetid://6071575925" -- Glowing Star/Sparkle
	particleEmitter.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, coreColor),
		ColorSequenceKeypoint.new(1, ringColor),
	})
	particleEmitter.Size = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.4 * scale),
		NumberSequenceKeypoint.new(0.5, 0.8 * scale),
		NumberSequenceKeypoint.new(1, 0),
	})
	particleEmitter.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	particleEmitter.Lifetime = NumberRange.new(1.5, 3.0)
	particleEmitter.Rate = 12
	particleEmitter.Speed = NumberRange.new(1, 3)
	particleEmitter.SpreadAngle = Vector2.new(360, 360)
	particleEmitter.Parent = innerPower

	-- 2. SurfaceAppearance PBR Fallback Layer
	if opts.PBRColorMap and opts.PBRColorMap ~= "" then
		local sa = Instance.new("SurfaceAppearance")
		sa.ColorMap = opts.PBRColorMap
		if opts.PBRNormalMap then
			sa.NormalMap = opts.PBRNormalMap
		end
		sa.Parent = corePart
	end

	-- 3. Concentric Orbiting Runic Rings (3 Axes)
	local rings = {}
	local ringRadii = { 3.2 * scale, 4.2 * scale, 5.2 * scale }
	local ringSpeeds = { Vector3.new(0.8, 1.2, 0), Vector3.new(0, 0.9, -1.1), Vector3.new(-1.0, 0.5, 0.7) }

	for i = 1, 3 do
		local ringPart = Instance.new("Part")
		ringPart.Name = "OrbitRing_" .. i
		ringPart.Size = Vector3.new(ringRadii[i] * 2, 0.3 * scale, ringRadii[i] * 2)
		ringPart.Position = position
		ringPart.Anchored = true
		ringPart.CanCollide = false
		ringPart.CanTouch = false
		ringPart.Material = Enum.Material.Metal
		ringPart.Color = ringColor
		ringPart.Parent = model

		-- Ring Cylinder SpecialMesh for Hollow Ring Effect
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType = Enum.MeshType.Cylinder
		mesh.Scale = Vector3.new(1, 0.1, 1)
		mesh.Parent = ringPart

		-- Neon Trim for Ring Edge
		local ringTrim = Instance.new("Part")
		ringTrim.Name = "RingTrim_" .. i
		ringTrim.Size = Vector3.new(ringRadii[i] * 2.05, 0.35 * scale, ringRadii[i] * 2.05)
		ringTrim.Position = position
		ringTrim.Anchored = true
		ringTrim.CanCollide = false
		ringTrim.CanTouch = false
		ringTrim.Material = Enum.Material.Neon
		ringTrim.Color = coreColor
		ringTrim.Transparency = 0.3
		ringTrim.Parent = model

		local trimMesh = Instance.new("SpecialMesh")
		trimMesh.MeshType = Enum.MeshType.Cylinder
		trimMesh.Scale = Vector3.new(1, 0.05, 1)
		trimMesh.Parent = ringTrim

		table.insert(rings, {
			Part = ringPart,
			Trim = ringTrim,
			Speed = ringSpeeds[i],
			Angle = Vector3.new(math.rad(i * 30), math.rad(i * 45), 0),
		})
	end

	-- 4. Interactive Click Detector for Juiciness & Tactile Feedback
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 25
	clickDetector.Parent = corePart

	model.Parent = parent

	-- Instantiate Spring Engine & State
	local spring = CreateSpring(160, 12)
	local elapsedTime = 0
	local connection: RBXScriptConnection? = nil

	-- Click Interaction Behavior
	clickDetector.MouseClick:Connect(function(player: Player)
		-- Elastic Bounce Impulse
		spring:Impulse(0.8)

		-- Particle Burst
		particleEmitter:Emit(25)

		-- Optional Subtle Camera Shake for Local Player
		if enableShake and player == Players.LocalPlayer then
			local cam = Workspace.CurrentCamera
			if cam then
				task.spawn(function()
					for _ = 1, 6 do
						local shakeOffset = Vector3.new(
							(math.random() - 0.5) * 0.3,
							(math.random() - 0.5) * 0.3,
							(math.random() - 0.5) * 0.3
						)
						cam.CFrame = cam.CFrame * CFrame.new(shakeOffset)
						task.wait(0.02)
					end
				end)
			end
		end
	end)

	-- 5. Client RenderStepped Animation Loop (60 FPS)
	connection = RunService.RenderStepped:Connect(function(dt: number)
		elapsedTime += dt

		-- Spring Scale Calculation
		local currentScale = spring:Update(dt)
		local hoverY = math.sin(elapsedTime * 2.5) * (0.8 * scale)
		local currentPos = position + Vector3.new(0, hoverY, 0)

		-- Update Core Parts
		corePart.CFrame = CFrame.new(currentPos) * CFrame.Angles(0, elapsedTime * 0.5, 0)
		corePart.Size = Vector3.new(4 * scale * currentScale, 4 * scale * currentScale, 4 * scale * currentScale)

		innerPower.CFrame = CFrame.new(currentPos)
		innerPower.Size =
			Vector3.new(2.2 * scale * currentScale, 2.2 * scale * currentScale, 2.2 * scale * currentScale)

		-- Rotate Orbiting Rings
		for _, ringData in ipairs(rings) do
			ringData.Angle = ringData.Angle + ringData.Speed * dt
			local ringCF = CFrame.new(currentPos) * CFrame.Angles(ringData.Angle.X, ringData.Angle.Y, ringData.Angle.Z)

			ringData.Part.CFrame = ringCF
			ringData.Trim.CFrame = ringCF
		end
	end)

	local instance = {
		Model = model,
		Destroy = function()
			if connection then
				connection:Disconnect()
				connection = nil
			end
			model:Destroy()
		end,
	}

	return instance
end

return ProceduralAlchemicalCore
