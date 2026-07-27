--!strict

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local NetChannels = {}

-- Create central RemoteEvent folder inside ReplicatedStorage upon bootstrap
local remotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
if not remotesFolder then
	if RunService:IsServer() then
		remotesFolder = Instance.new("Folder")
		remotesFolder.Name = "Remotes"
		remotesFolder.Parent = ReplicatedStorage
	else
		remotesFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
		if not remotesFolder then
			warn("[NetChannels] Remotes folder not created by server after 10s timeout")
		end
	end
end

function NetChannels.GetRemoteEvent(name: string): RemoteEvent?
	if RunService:IsServer() then
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteEvent")
			remote.Name = name
			remote.Parent = remotesFolder
		end
		return remote :: RemoteEvent
	else
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = remotesFolder:WaitForChild(name, 15)
		end
		return remote :: RemoteEvent?
	end
end

function NetChannels.GetRemoteFunction(name: string): RemoteFunction?
	if RunService:IsServer() then
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("RemoteFunction")
			remote.Name = name
			remote.Parent = remotesFolder
		end
		return remote :: RemoteFunction
	else
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = remotesFolder:WaitForChild(name, 15)
		end
		return remote :: RemoteFunction?
	end
end

function NetChannels.GetUnreliableRemoteEvent(name: string): UnreliableRemoteEvent?
	if RunService:IsServer() then
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = Instance.new("UnreliableRemoteEvent")
			remote.Name = name
			remote.Parent = remotesFolder
		end
		return remote :: UnreliableRemoteEvent
	else
		local remote = remotesFolder:FindFirstChild(name)
		if not remote then
			remote = remotesFolder:WaitForChild(name, 15)
		end
		return remote :: UnreliableRemoteEvent?
	end
end

return NetChannels
