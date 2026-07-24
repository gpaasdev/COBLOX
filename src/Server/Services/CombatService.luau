--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local CombatService = {}
local COMBAT_RANGE = 15

local stunRecords = {}
local parryWindows = {}

function CombatService.Init()
    local combatEvent = NetChannels.GetRemoteEvent("CombatEvent")
    local RateLimitService = require(script.Parent.RateLimitService)

    combatEvent.OnServerEvent:Connect(function(player, action: string, targetId: string?)
        if not RateLimitService.CheckRateLimit(player, "CombatEvent_" .. tostring(action), 0.2) then
            return
        end
        
        if action == "Attack" and targetId then
            CombatService.ProcessHit(player, targetId)
        elseif action == "Parry" then
            parryWindows[player.UserId] = os.clock()
        end
    end)
    print("⚔️ CombatService Initialized")
end

function CombatService.ProcessHit(player: Player, targetId: string)
    local char = player.Character
    if not char then return end
    
    local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart
    if not hrp then return end
    
    local MobService = require(script.Parent.MobService)
    local mob = MobService.GetMob(targetId)
    
    if mob and mob.Model and mob.Model.PrimaryPart then
        local distance = (hrp.Position - mob.Model.PrimaryPart.Position).Magnitude
        if distance <= COMBAT_RANGE then
            MobService.TakeDamage(targetId, 10, player)
        end
    end
end

function CombatService.CheckParry(player: Player): boolean
    local lastParryTime = parryWindows[player.UserId]
    if lastParryTime and (os.clock() - lastParryTime <= 0.3) then
        return true
    end
    return false
end

return CombatService
