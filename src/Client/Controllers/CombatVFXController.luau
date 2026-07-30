--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Debris = game:GetService("Debris")
local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local VFXEngine = require(script.Parent.Parent.Modules.UI.VFXEngine)
local Maid = require(ReplicatedStorage.Shared.Utility.Maid)

local CombatVFXController = {}
CombatVFXController.Name = "CombatVFXController"
CombatVFXController.ServiceStatus = "Production"

local telegraphCache: { [string]: any } = {}

function CombatVFXController.Init(self)
	self.maid = Maid.new()
end

function CombatVFXController.Start(self)
	self.maid:GiveTask(Workspace.DescendantAdded:Connect(function(desc)
		if desc:IsA("Attachment") and desc.Name == "MobTelegraph" then
			task.defer(function()
				CombatVFXController._AttachTelegraphAdorn(desc)
			end)
		end
	end))

	for _, v in Workspace:GetDescendants() do
		if v:IsA("Attachment") and v.Name == "MobTelegraph" then
			CombatVFXController._AttachTelegraphAdorn(v)
		end
	end
end

function CombatVFXController._AttachTelegraphAdorn(attachment: Attachment)
	local cyl = Instance.new("CylinderHandleAdornment")
	cyl.Name = "TelegraphAdorn"
	cyl.Adornee = attachment.Parent
	cyl.Attachment0 = attachment
	cyl.Radius = 4
	cyl.Height = 0.2
	cyl.Color3 = Color3.fromRGB(255, 50, 50)
	cyl.Transparency = 0.4
	cyl.AlwaysOnTop = true
	cyl.Visible = false
	cyl.CFrame = CFrame.new(0, 0.1, 0)
	cyl.Parent = attachment

	local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local pulseDown = { Transparency = 0.8, Radius = 1 }
	local pulseUp = { Transparency = 0.4, Radius = 4 }
	local tweenDown = game:GetService("TweenService"):Create(cyl, tweenInfo, pulseDown)
	local tweenUp = game:GetService("TweenService"):Create(cyl, tweenInfo, pulseUp)

	local connection = attachment.AncestryChanged:Connect(function()
		tweenDown:Cancel()
		tweenUp:Cancel()
		connection:Disconnect()
	end)

	telegraphCache[attachment.Name] = { attachment, cyl }
end

function CombatVFXController._FindMobModel(mobId: string): Model?
	local mobsFolder = Workspace:FindFirstChild("Mobs") or Workspace
	for _, child in ipairs(mobsFolder:GetChildren()) do
		if child:IsA("Model") and child:GetAttribute("MobId") == mobId then
			return child
		end
	end
	return nil
end

function CombatVFXController.PlayTelegraph(mobId: string)
	print("[VFX] RED TELEGRAPH: Monster is winding up to attack!")

	local mobModel = CombatVFXController._FindMobModel(mobId)
	if mobModel then
		local hrp = mobModel:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			local attach = hrp:FindFirstChildOfClass("Attachment")
			if not attach then
				attach = Instance.new("Attachment")
				attach.Name = "MobTelegraph"
				attach.Parent = hrp
			end
			local adorn = attach:FindFirstChild("TelegraphAdorn")
			if adorn and adorn:IsA("CylinderHandleAdornment") then
				adorn.Visible = true

				local tweenService = game:GetService("TweenService")
				local tweenInfo = TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
				local tween = tweenService:Create(adorn, tweenInfo, { Transparency = 0.8, Radius = 1 })
				tween:Play()
				tween.Completed:Connect(function()
					local t2 = tweenService:Create(adorn, tweenInfo, { Transparency = 0.4, Radius = 4 })
					t2:Play()
					t2.Completed:Connect(function()
						adorn.Visible = false
					end)
				end)
			end
		end
	end

	VFXEngine.PlayCameraShake(0.1, 0.4)
end

function CombatVFXController.PlayStunVFX(mobId: string)
	print("[VFX] PERFECT PARRY! Monster stunned!")

	local mobModel = CombatVFXController._FindMobModel(mobId)
	if mobModel then
		local hrp = mobModel:FindFirstChild("HumanoidRootPart") :: BasePart?
		if hrp then
			local star = Instance.new("Attachment")
			star.Name = "StunStar_" .. os.clock()
			star.Parent = hrp

			local starAdorn = Instance.new("StarHandleAdornment")
			starAdorn.Adornee = hrp
			starAdorn.Attachment0 = star
			starAdorn.Radius = 3
			starAdorn.NumPoints = 4
			starAdorn.Color3 = Color3.fromRGB(255, 255, 0)
			starAdorn.Transparency = 0.3
			starAdorn.AlwaysOnTop = true
			starAdorn.Parent = hrp

			Debris:AddItem(starAdorn, 1.5)
			Debris:AddItem(star, 1.5)
		end
	end

	VFXEngine.ScreenPunch(0.8)
	VFXEngine.PlayCameraShake(0.6, 0.25)
end

function CombatVFXController.PlayHitStopVFX(duration: number)
	print("[VFX] HIT-STOP: Freezing time for juiciness! Duration:", duration)
	VFXEngine.PlayCameraShake(0.8, duration)
end

return CombatVFXController
