--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local GameConfig = require(ReplicatedStorage.Shared.Configuration.GameConfig)

local CombatService = {}

local stunRecords = {}
local parryWindows = {}

-- Modular Rulesets
type ZoneRuleset = "Wilderness" | "Arena" | "FactionWars" | "Safezone"

local function GetZoneRuleset(position: Vector3): ZoneRuleset
    local distFromCenter = Vector3.new(position.X, 0, position.Z).Magnitude
    if distFromCenter < 100 then
        return "Safezone"
    elseif distFromCenter < 300 then
        return "Arena"
    elseif distFromCenter < 600 then
        return "FactionWars"
    else
        return "Wilderness"
    end
end

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
    
    local zone = GetZoneRuleset(hrp.Position)
    if zone == "Safezone" then
        print("[CombatService] Attack blocked: Player is in Safezone.")
        return
    end

    local MobService = require(script.Parent.MobService)
    local mob = MobService.GetMob(targetId)
    
    if mob and mob.Model and mob.Model.PrimaryPart then
        local distance = (hrp.Position - mob.Model.PrimaryPart.Position).Magnitude
        if distance <= GameConfig.Combat.CombatRange then
            -- Config-driven zone damage & hit stun (replaces hardcoded 10/15/25)
            local mods = GameConfig.Combat.ZoneModifiers[zone]
            local damage = GameConfig.Combat.BaseDamage * (mods and mods.damage or 1.0)
            local hitStun = mods and mods.hitStun or 0.5
            _ = hitStun -- reserved for stun system
            
            MobService.TakeDamage(targetId, damage, player)
            
            -- PvP is currently disabled until Phase B (Combat Update)
            -- Only PvE logic remains.
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
