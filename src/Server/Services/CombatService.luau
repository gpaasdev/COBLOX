--!strict
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)

local CombatService = {}
local COMBAT_RANGE = 15

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
        if distance <= COMBAT_RANGE then
            local damage = 10
            local hitStun = 0.5
            
            -- Apply Ruleset Modifiers
            if zone == "Wilderness" then
                damage = 15 -- High Stakes
                hitStun = 1.2 -- Soulslike heavy stun
            elseif zone == "Arena" then
                damage = 8
                hitStun = 0.2 -- Fast paced
            elseif zone == "FactionWars" then
                damage = 25 -- AoE scaled down
                hitStun = 0.4
            end
            
            MobService.TakeDamage(targetId, damage, player)
            
            -- PvP Check (Mocked for future Player vs Player extension)
            local targetPlayer = Players:GetPlayerByUserId(tonumber(targetId) or 0)
            if targetPlayer and targetPlayer.Character then
                if zone == "FactionWars" then
                    -- Check faction (assuming faction is stored as attribute)
                    if targetPlayer:GetAttribute("Faction") == player:GetAttribute("Faction") then
                        return -- No friendly fire
                    end
                end
                
                if targetPlayer.Character:FindFirstChild("Humanoid") then
                    targetPlayer.Character.Humanoid:TakeDamage(damage)
                    if targetPlayer.Character.Humanoid.Health <= 0 and zone == "Wilderness" then
                        -- Loot Drop Consequence
                        print("[CombatService] PVP Kill in Wilderness. Dropping Loot for " .. player.Name)
                    end
                end
            end
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
