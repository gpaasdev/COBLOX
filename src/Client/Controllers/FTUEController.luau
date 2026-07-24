--!strict
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local ContextActionService = game:GetService("ContextActionService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local FTUEController = {}
FTUEController.Name = "FTUEController"

local localPlayer = Players.LocalPlayer
local questHUD: Frame
local milestone1: TextLabel
local milestone2: TextLabel
local milestone3: TextLabel
local milestone4: TextLabel

local hasClaimedPlot = false
local hasBoughtDropper = false
local hasHatchedEgg = false
local hasCraftedCrystal = false

function FTUEController.Init()
	print("[FTUEController] Initializing Frictionless Onboarding and Quest Bar...")
	FTUEController._CreateQuestBar()
end

function FTUEController.Start()
	local ftueRemote = NetChannels.GetRemoteEvent("StartCinematicFTUE")
	ftueRemote.OnClientEvent:Connect(function()
		FTUEController.PlayCinematicIntro()
	end)

	-- 1. Focus camera and draw guide to nearest unclaimed Plot ClaimPad
	task.spawn(function()
		task.wait(1) -- Wait for game load
		FTUEController.GuideToClaimPad()
	end)

	-- 2. Local loops/events to check milestones
	local hatchRemote = NetChannels.GetRemoteEvent("EggHatchedVisual")
	if hatchRemote then
		hatchRemote.OnClientEvent:Connect(function()
			if not hasHatchedEgg then
				hasHatchedEgg = true
				FTUEController.UpdateMilestone(milestone3, "✅ Tetas Telur Pertama")
				
				-- Start guiding to Furnace for the final step
				FTUEController.GuideToFurnace()
			end
		end)
	end
	
	-- Mock remote for crafting detection since it's server authoritative
	local craftRemote = NetChannels.GetRemoteFunction("RequestCraft")
	if craftRemote then
		-- In a real scenario we might wait for a server broadcast, but we can hook into the client invocation
		-- for immediate UI feedback. However, since it's a function we don't have OnClientEvent.
		-- Let's just poll the inventory or assume success when they invoke for the tutorial.
	end

	-- Scan the workspace to check if the plot is claimed or droppers bought
	RunService.Heartbeat:Connect(function()
		if not hasClaimedPlot then
			-- Scan plots for local player ownership
			local map = Workspace:FindFirstChild("Map")
			local plots = map and map:FindFirstChild("Plots")
			if plots then
				for _, plot in ipairs(plots:GetChildren()) do
					local claimPad = plot:FindFirstChild("ClaimPad")
					if claimPad then
						local bb = claimPad:FindFirstChildOfClass("BillboardGui")
						local label = bb and bb:FindFirstChildOfClass("TextLabel")
						if label and string.find(label.Text, localPlayer.Name) then
							hasClaimedPlot = true
							FTUEController.UpdateMilestone(milestone1, "✅ Klaim Plot Pabrik")
							-- Now enable dropper check
							break
						end
					end
				end
			end
		elseif not hasBoughtDropper then
			-- Check if they bought their first item beyond Dropper_Tier1
			local map = Workspace:FindFirstChild("Map")
			local plots = map and map:FindFirstChild("Plots")
			if plots then
				for _, plot in ipairs(plots:GetChildren()) do
					local claimPad = plot:FindFirstChild("ClaimPad")
					if claimPad then
						local bb = claimPad:FindFirstChildOfClass("BillboardGui")
						local label = bb and bb:FindFirstChildOfClass("TextLabel")
						if label and string.find(label.Text, localPlayer.Name) then
							-- Check if collector or tier 2 dropper exists in plot
							if plot:FindFirstChild("Collector_Tier1") or plot:FindFirstChild("Dropper_Tier2") then
								hasBoughtDropper = true
								FTUEController.UpdateMilestone(milestone2, "✅ Beli Upgrade Pertama")
							end
							break
						end
					end
				end
			elseif not hasCraftedCrystal and hasHatchedEgg then
				-- Scan backpack or local stats (mocked check for FTUE purposes)
				if localPlayer:GetAttribute("HasCraftedCrystal") then
					hasCraftedCrystal = true
					FTUEController.UpdateMilestone(milestone4, "✅ First Crystal Crafted")
				end
			end
		end
	end)
end

function FTUEController.GuideToFurnace()
	local map = Workspace:FindFirstChild("Map")
	local plots = map and map:FindFirstChild("Plots")
	if not plots then return end
	
	local myPlot = nil
	for _, plot in ipairs(plots:GetChildren()) do
		local claimPad = plot:FindFirstChild("ClaimPad")
		if claimPad then
			local bb = claimPad:FindFirstChildOfClass("BillboardGui")
			local label = bb and bb:FindFirstChildOfClass("TextLabel")
			if label and string.find(label.Text, localPlayer.Name) then
				myPlot = plot
				break
			end
		end
	end
	
	if myPlot then
		local furnace = myPlot:FindFirstChild("Furnace_Tier1") or myPlot:FindFirstChild("AlchemyFurnace")
		if furnace then
			local character = localPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local beam = Instance.new("Beam")
				local att0 = Instance.new("Attachment", hrp)
				local att1 = Instance.new("Attachment", furnace)
				beam.Attachment0 = att0
				beam.Attachment1 = att1
				beam.FaceCamera = true
				beam.Width0 = 1
				beam.Width1 = 1
				beam.Color = ColorSequence.new(Color3.fromRGB(250, 204, 21)) -- Yellow-400
				beam.Parent = hrp
				
				local bb = Instance.new("BillboardGui")
				bb.Size = UDim2.new(0, 200, 0, 50)
				bb.StudsOffset = Vector3.new(0, 5, 0)
				bb.AlwaysOnTop = true
				
				local lbl = Instance.new("TextLabel")
				lbl.Size = UDim2.new(1, 0, 1, 0)
				lbl.BackgroundTransparency = 1
				lbl.Text = "Craft Your First Crystal Here!"
				lbl.TextColor3 = Color3.fromRGB(250, 204, 21)
				lbl.Font = Enum.Font.GothamBold
				lbl.TextScaled = true
				lbl.Parent = bb
				bb.Parent = furnace
				
				-- Cleanup once crafted
				task.spawn(function()
					while not hasCraftedCrystal do task.wait(1) end
					beam:Destroy()
					bb:Destroy()
					att0:Destroy()
					att1:Destroy()
				end)
			end
		end
	end
end

function FTUEController.GuideToClaimPad()
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart") :: BasePart
	
	local map = Workspace:FindFirstChild("Map")
	local plots = map and map:FindFirstChild("Plots")
	if not plots then return end

	local nearestPad: BasePart? = nil
	local shortestDist = math.huge

	for _, plot in ipairs(plots:GetChildren()) do
		local claimPad = plot:FindFirstChild("ClaimPad")
		if claimPad and claimPad:IsA("BasePart") and claimPad.Color ~= Color3.fromRGB(0, 255, 0) then
			-- Unclaimed pad (not green)
			local dist = (hrp.Position - claimPad.Position).Magnitude
			if dist < shortestDist then
				shortestDist = dist
				nearestPad = claimPad
			end
		end
	end

	if nearestPad then
		print("[FTUEController] Focusing camera on nearest unclaimed plot...")
		local camera = Workspace.CurrentCamera
		if camera then
			-- Smooth temporary pan to the claim pad
			local originalCFrame = camera.CFrame
			camera.CameraType = Enum.CameraType.Scriptable
			
			local targetCFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 15, 20), nearestPad.Position)
			local tween = TweenService:Create(camera, TweenInfo.new(1.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = targetCFrame })
			tween:Play()
			tween.Completed:Wait()
			
			task.wait(1)
			
			local returnTween = TweenService:Create(camera, TweenInfo.new(1.0, Enum.EasingStyle.Quad), { CFrame = originalCFrame })
			returnTween:Play()
			returnTween.Completed:Wait()
			camera.CameraType = Enum.CameraType.Custom
		end
	end
end

function FTUEController.PlayCinematicIntro()
	local camera = Workspace.CurrentCamera
	local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
	local hrp = character:WaitForChild("HumanoidRootPart") :: BasePart
	
	-- Lock movement
	ContextActionService:BindAction("FreezeMovement", function() return Enum.ContextActionResult.Sink end, false, unpack(Enum.PlayerActions:GetEnumItems()))
	
	local originalCFrame = camera.CFrame
	camera.CameraType = Enum.CameraType.Scriptable
	
	-- Pan up
	local targetCFrame = CFrame.lookAt(hrp.Position + Vector3.new(0, 30, -30), hrp.Position)
	local tween = TweenService:Create(camera, TweenInfo.new(3.0, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), { CFrame = targetCFrame })
	tween:Play()
	
	-- Show Master Alchemist Dialogue
	print("[FTUE] Master Alchemist: Welcome to the Multiverse Alchemy Sanctum! We must melt this ice barrier!")
	
	-- Prompt Throw Potion
	local throwBtn = Instance.new("TextButton")
	throwBtn.Size = UDim2.new(0.3, 0, 0.1, 0)
	throwBtn.Position = UDim2.new(0.35, 0, 0.8, 0)
	throwBtn.Text = "Throw Pyro Potion!"
	throwBtn.BackgroundColor3 = Color3.fromRGB(220, 38, 38)
	throwBtn.TextColor3 = Color3.fromRGB(255,255,255)
	throwBtn.Font = Enum.Font.GothamBold
	throwBtn.TextScaled = true
	throwBtn.Parent = localPlayer:WaitForChild("PlayerGui"):WaitForChild("COBLOX_MainHUD")
	
	throwBtn.MouseButton1Click:Connect(function()
		throwBtn:Destroy()
		print("[VFX] Pyro Potion Explodes! Ice Wall Melted!")
		-- Unlock movement
		ContextActionService:UnbindAction("FreezeMovement")
		
		-- Advance FTUE state on server
		local advanceRemote = NetChannels.GetRemoteEvent("AdvanceFTUE")
		if advanceRemote then
			advanceRemote:FireServer(3)
		end
		
		-- Return camera
		local returnTween = TweenService:Create(camera, TweenInfo.new(1.0, Enum.EasingStyle.Quad), { CFrame = originalCFrame })
		returnTween:Play()
		returnTween.Completed:Wait()
		camera.CameraType = Enum.CameraType.Custom
	end)
end

local milestone4: TextLabel

function FTUEController._CreateQuestBar()
	local playerGui = localPlayer:WaitForChild("PlayerGui")
	local mainHUD = playerGui:WaitForChild("COBLOX_AlchemyHUD")
	
	questHUD = Instance.new("Frame")
	questHUD.Name = "FTUE_QuestBar"
	questHUD.Size = UDim2.new(0.5, 0, 0.08, 0)
	questHUD.Position = UDim2.new(0.25, 0, 0.9, 0)
	questHUD.BackgroundColor3 = Color3.fromRGB(15, 23, 42) -- Slate 900
	questHUD.BorderSizePixel = 0
	questHUD.Parent = mainHUD
	
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = questHUD
	
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(13, 148, 136) -- Teal 600
	stroke.Thickness = 2
	stroke.Parent = questHUD
	
	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0.05, 0)
	layout.Parent = questHUD

	milestone1 = Instance.new("TextLabel")
	milestone1.Size = UDim2.new(0.22, 0, 0.8, 0)
	milestone1.BackgroundTransparency = 1
	milestone1.Text = "✨ Buka Sanctum"
	milestone1.TextColor3 = Color3.fromRGB(248, 250, 252)
	milestone1.Font = Enum.Font.GothamBold
	milestone1.TextScaled = true
	milestone1.Parent = questHUD

	milestone2 = Instance.new("TextLabel")
	milestone2.Size = UDim2.new(0.22, 0, 0.8, 0)
	milestone2.BackgroundTransparency = 1
	milestone2.Text = "⚡ Bejana Aura"
	milestone2.TextColor3 = Color3.fromRGB(148, 163, 184) -- Slate 400 (locked look)
	milestone2.Font = Enum.Font.GothamBold
	milestone2.TextScaled = true
	milestone2.Parent = questHUD

	milestone3 = Instance.new("TextLabel")
	milestone3.Size = UDim2.new(0.22, 0, 0.8, 0)
	milestone3.BackgroundTransparency = 1
	milestone3.Text = "🐉 Panggil Spirit"
	milestone3.TextColor3 = Color3.fromRGB(148, 163, 184)
	milestone3.Font = Enum.Font.GothamBold
	milestone3.TextScaled = true
	milestone3.Parent = questHUD

	milestone4 = Instance.new("TextLabel")
	milestone4.Size = UDim2.new(0.22, 0, 0.8, 0)
	milestone4.BackgroundTransparency = 1
	milestone4.Text = "⬜ Craft Crystal"
	milestone4.TextColor3 = Color3.fromRGB(148, 163, 184)
	milestone4.Font = Enum.Font.GothamBold
	milestone4.TextScaled = true
	milestone4.Parent = questHUD
end

function FTUEController.UpdateMilestone(label: TextLabel, text: string)
	label.Text = text
	label.TextColor3 = Color3.fromRGB(34, 197, 94) -- Green 500
	
	-- Play a quick pop sound for positive reinforcement
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://6895079853"
	sound.Parent = Workspace
	sound:Play()
	task.delay(1, function()
		sound:Destroy()
	end)
	
	-- Small bounce animation
	local originalSize = label.Size
	local tweenGrow = TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(label.Size.X.Scale * 1.2, 0, label.Size.Y.Scale * 1.2, 0)
	})
	local tweenShrink = TweenService:Create(label, TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = originalSize
	})
	
	tweenGrow:Play()
	tweenGrow.Completed:Wait()
	tweenShrink:Play()
end

return FTUEController
