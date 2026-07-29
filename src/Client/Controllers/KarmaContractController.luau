--!strict

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local Maid = require(ReplicatedStorage:WaitForChild("Shared"):WaitForChild("Utility"):WaitForChild("Maid"))

local KarmaContractController = {}
KarmaContractController.Name = "KarmaContractController"

local currentTargetUserId: number? = nil
local activeCompass: BillboardGui? = nil
local activePrompt: ProximityPrompt? = nil

function KarmaContractController.Init()
	print("[KarmaContractController] Initializing Karma Contract Tracker HUD...")
end

function KarmaContractController.Start()
	self.maid = Maid.new()
	local syncKarmaRemote = NetChannels.GetRemoteEvent("SyncKarmaContract")
	if syncKarmaRemote then
		self.maid:GiveTask(syncKarmaRemote.OnClientEvent:Connect(function(data)
			if data and data.Active then
				currentTargetUserId = data.TargetUserId
				KarmaContractController.ShowCompass(data.TargetName or "Target")
				KarmaContractController.AttachPromptToTarget()
			else
				currentTargetUserId = nil
				KarmaContractController.HideCompass()
				KarmaContractController.RemovePrompt()
			end
		end))
	end
end

function KarmaContractController.TriggerKarmaRetribution()
	if not currentTargetUserId then
		return
	end

	local karmaRemoteFunc = NetChannels.GetRemoteFunction("RequestKarmaContract")
	if karmaRemoteFunc then
		local response = karmaRemoteFunc:InvokeServer(currentTargetUserId)
		if response and response.Success then
			print("[KarmaContractController] 🎉 KARMA TERBALAS! Retribusi berhasil diklaim!")
			KarmaContractController.HideCompass()
			KarmaContractController.RemovePrompt()
		else
			warn("[KarmaContractController] Retribution failed:", response and response.Message or "Unknown error")
		end
	end
end

function KarmaContractController.AttachPromptToTarget()
	KarmaContractController.RemovePrompt()
	if not currentTargetUserId then
		return
	end

	local targetPlayer = Players:GetPlayerByUserId(currentTargetUserId)
	if not targetPlayer or not targetPlayer.Character then
		return
	end

	local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = "🎯 Kena Karma!"
	prompt.ActionText = "Balas Begalan Aura [E]"
	prompt.HoldDuration = 0.5
	prompt.MaxActivationDistance = 15
	prompt.RequiresLineOfSight = false
	prompt.Parent = hrp

	KarmaContractController.maid:GiveTask(prompt.Triggered:Connect(function(playerWhoTriggered)
		if playerWhoTriggered == Players.LocalPlayer then
			KarmaContractController.TriggerKarmaRetribution()
		end
	end))
	activePrompt = prompt
end

function KarmaContractController.RemovePrompt()
	if activePrompt then
		activePrompt:Destroy()
		activePrompt = nil
	end
end

function KarmaContractController.ShowCompass(targetName: string)
	KarmaContractController.HideCompass()
	if not currentTargetUserId then
		return
	end

	local targetPlayer = Players:GetPlayerByUserId(currentTargetUserId)
	if not targetPlayer or not targetPlayer.Character then
		return
	end

	local hrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not hrp then
		return
	end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "KarmaTrackerCompass"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.AlwaysOnTop = true
	billboard.MaxDistance = 60
	billboard.Adornee = hrp

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 0.5
	label.BackgroundColor3 = Color3.fromRGB(239, 68, 68)
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Text = string.format("🎯 TARGET KARMA: %s", targetName)
	label.Parent = billboard

	local localPlayer = Players.LocalPlayer
	if localPlayer and localPlayer.PlayerGui then
		billboard.Parent = localPlayer.PlayerGui
	end
	activeCompass = billboard

	-- Auto Distance Click Handler
	task.spawn(function()
		while activeCompass and currentTargetUserId do
			task.wait(0.5)
			local localChar = localPlayer.Character
			local targetChar = targetPlayer.Character
			if localChar and targetChar and localChar.PrimaryPart and targetChar.PrimaryPart then
				local dist = (localChar.PrimaryPart.Position - targetChar.PrimaryPart.Position).Magnitude
				if dist <= 15 then
					label.Text = string.format("🎯 TARGET KARMA: %s (TEKAN E!)", targetName)
				else
					label.Text = string.format("🎯 TARGET KARMA: %s (%.0fm)", targetName, dist)
				end
			end
		end
	end)
end

function KarmaContractController.HideCompass()
	if activeCompass then
		activeCompass:Destroy()
		activeCompass = nil
	end
end

return KarmaContractController
