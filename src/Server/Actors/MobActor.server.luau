--!strict
-- Server/Actors/MobActor.server.luau
-- Parallel Luau Worker Script inside Mob Actor instance

local actor = script:GetActor()
if not actor then return end

actor:BindToMessageParallel("ComputePathAndDistance", function(targetPos: Vector3, hrpPos: Vector3, spawnPos: Vector3)
	-- Parallel Phase: Heavy Math calculation across worker threads
	local distFromTarget = (targetPos - hrpPos).Magnitude
	local distFromSpawn = (hrpPos - spawnPos).Magnitude
	local lookAtCFrame = CFrame.lookAt(hrpPos, targetPos * Vector3.new(1,0,1) + Vector3.new(0, hrpPos.Y, 0))
	
	-- Synchronize to communicate back results safely
	task.synchronize()
	actor:SendMessage("ComputeResults", distFromTarget, distFromSpawn, lookAtCFrame)
end)
