--!strict
local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local AssetService = game:GetService("AssetService")
local TeleportService = game:GetService("TeleportService")
local RunService = game:GetService("RunService")
local TextService = game:GetService("TextService")

local NetChannels = require(ReplicatedStorage.Shared.Network.NetChannels)
local PlayerDataService = require(script.Parent.PlayerDataService)
local CovenConfig = require(ReplicatedStorage.Shared.Config.CovenConfig)

local CovenService = {}

type CovenData = {
    Id: string,
    Name: string,
    LeaderId: number,
    Members: {number},
    InvitedGuests: {[number]: boolean},
    TreasuryCoins: number,
    Level: number,
    HideoutPlaceId: number?
}

local activeCovens: {[string]: CovenData} = {}
local playerCovenMap: {[number]: string} = {} -- Maps UserId to CovenId

function CovenService.Init()
    local covenEvent = NetChannels.GetRemoteEvent("CovenEvent")
    local RateLimitService = require(script.Parent.RateLimitService)
    
    covenEvent.OnServerEvent:Connect(function(player, action: string, data: any)
        if not RateLimitService.CheckRateLimit(player, "CovenEvent_" .. tostring(action), 0.5) then
            return
        end
        
        if action == "Create" and type(data) == "string" then
            CovenService.CreateCoven(player, data)
        elseif action == "Donate" and type(data) == "number" then
            CovenService.DonateToCoven(player, data)
        elseif action == "TeleportToHideout" then
            CovenService.TeleportPlayerToHideout(player)
        elseif action == "InviteGuest" and type(data) == "number" then
            CovenService.InviteGuest(player, data)
        end
    end)

    CovenService._AssembleCovenHideoutZone()
    print("🏰 CovenService Initialized (Instanced Hideouts Enabled)")
end

function CovenService._AssembleCovenHideoutZone()
    local map = workspace:FindFirstChild("Map") or workspace
    local covenZone = map:FindFirstChild("CovenMockZone")
    if not covenZone then
        covenZone = Instance.new("Folder")
        covenZone.Name = "CovenMockZone"
        covenZone.Parent = map
    end

    -- 3D Floating Sanctum Island Platform at (0, 500, 0)
    local island = Instance.new("Part")
    island.Name = "CovenIslandBase"
    island.Size = Vector3.new(80, 8, 80)
    island.Position = CovenConfig.STUDIO_MOCK_ZONE_POSITION
    island.Anchored = true
    island.Color = Color3.fromRGB(15, 23, 42)
    island.Material = Enum.Material.SmoothPlastic
    island.Parent = covenZone

    -- Altar Core Ring
    local altarRing = Instance.new("Part")
    altarRing.Name = "CovenAltarRing"
    altarRing.Shape = Enum.PartType.Cylinder
    altarRing.Size = Vector3.new(1.5, 20, 20)
    altarRing.CFrame = CFrame.new(island.Position + Vector3.new(0, 4.5, 0)) * CFrame.Angles(0, 0, math.rad(90))
    altarRing.Anchored = true
    altarRing.Color = Color3.fromRGB(168, 85, 247) -- Purple Neon
    altarRing.Material = Enum.Material.Neon
    altarRing.Parent = island

    -- Floating Mana Crystal
    local crystal = Instance.new("Part")
    crystal.Name = "CovenManaCrystal"
    crystal.Size = Vector3.new(4, 8, 4)
    crystal.Position = island.Position + Vector3.new(0, 10, 0)
    crystal.Anchored = true
    crystal.Color = Color3.fromRGB(192, 132, 252)
    crystal.Material = Enum.Material.Glass
    crystal.Transparency = 0.2
    crystal.Parent = island
end

function CovenService.CreateCoven(player: Player, rawName: string)
    if playerCovenMap[player.UserId] then
        print("[CovenService] Player already in a Coven")
        return
    end
    
    local cleanName = string.sub(rawName or "New Coven", 1, 20)
    -- Filter Coven name via TextService
    local filterResult = nil
    local pcallOk = pcall(function()
        filterResult = TextService:FilterStringAsync(cleanName, player.UserId)
    end)

    if pcallOk and filterResult then
        pcall(function()
            cleanName = filterResult:GetNonChatStringForBroadcastAsync()
        end)
    end

    local covenId = HttpService:GenerateGUID(false)
    local newCoven: CovenData = {
        Id = covenId,
        Name = cleanName,
        LeaderId = player.UserId,
        Members = {player.UserId},
        InvitedGuests = {},
        TreasuryCoins = 0,
        Level = 1,
        HideoutPlaceId = nil
    }

    -- Asynchronously generate Coven Hideout Place via AssetService
    task.spawn(function()
        if RunService:IsStudio() then
            -- Studio Simulation: Assign mock place ID
            print("[CovenService] Studio Mode: Simulating Coven Hideout Creation...")
            newCoven.HideoutPlaceId = 9990000 + math.random(1000, 9999)
        else
            local success, newPlaceId = pcall(function()
                return AssetService:CreatePlaceAsync(
                    CovenConfig.TEMPLATE_PLACE_ID,
                    string.format(CovenConfig.DEFAULT_HIDEOUT_NAME_FORMAT, cleanName),
                    "Instanced Coven Sanctuary for " .. cleanName
                )
            end)

            if success and type(newPlaceId) == "number" then
                newCoven.HideoutPlaceId = newPlaceId
                print("[CovenService] Created Live Hideout Place ID: " .. newPlaceId)
            else
                warn("[CovenService] AssetService:CreatePlaceAsync failed or blocked. Using fallback.")
            end
        end

        NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", newCoven)
    end)
    
    activeCovens[covenId] = newCoven
    playerCovenMap[player.UserId] = covenId
    print("[CovenService] Coven Created: " .. newCoven.Name)
    NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", newCoven)
end

function CovenService.InviteGuest(leaderPlayer: Player, guestUserId: number)
    local covenId = playerCovenMap[leaderPlayer.UserId]
    if not covenId then return end
    local coven = activeCovens[covenId]
    if not coven or coven.LeaderId ~= leaderPlayer.UserId then return end

    coven.InvitedGuests[guestUserId] = true
    print("[CovenService] User " .. guestUserId .. " invited to Coven " .. coven.Name .. "'s Hideout")

    -- Notify guest if online
    local guestPlayer = Players:GetPlayerByUserId(guestUserId)
    if guestPlayer then
        NetChannels.GetRemoteEvent("CovenEvent"):FireClient(guestPlayer, "GuestInviteReceived", {
            CovenId = covenId,
            CovenName = coven.Name
        })
    end
end

function CovenService.TeleportPlayerToHideout(player: Player)
    local covenId = playerCovenMap[player.UserId]
    local coven = covenId and activeCovens[covenId]

    -- Check if player is a guest if not in coven
    if not coven then
        for _, activeCoven in pairs(activeCovens) do
            if activeCoven.InvitedGuests[player.UserId] then
                coven = activeCoven
                break
            end
        end
    end

    if not coven then
        warn("[CovenService] Teleport failed: Player " .. player.Name .. " is not a member or invited guest of any Coven")
        return
    end

    print("[CovenService] Preparing Teleport for " .. player.Name .. " to Hideout (" .. tostring(coven.HideoutPlaceId) .. ")")

    if RunService:IsStudio() then
        -- Studio Mock Teleport: Move character locally to Studio Mock Zone
        local character = player.Character
        if character and character:FindFirstChild("HumanoidRootPart") then
            local root = character.HumanoidRootPart :: BasePart
            root.CFrame = CFrame.new(CovenConfig.STUDIO_MOCK_ZONE_POSITION)
            print("[CovenService] Studio Simulation: Player local-teleported to Coven Mock Zone " .. tostring(CovenConfig.STUDIO_MOCK_ZONE_POSITION))
        end
    else
        if coven.HideoutPlaceId then
            local teleportOptions = Instance.new("TeleportOptions")
            teleportOptions:SetTeleportData({
                CovenId = coven.Id,
                CovenName = coven.Name,
                IsGuest = (coven.LeaderId ~= player.UserId and not table.find(coven.Members, player.UserId))
            })
            
            pcall(function()
                TeleportService:TeleportAsync(coven.HideoutPlaceId, {player}, teleportOptions)
            end)
        else
            warn("[CovenService] Hideout Place ID not available for teleportation.")
        end
    end
end

function CovenService.DonateToCoven(player: Player, amount: number)
    local covenId = playerCovenMap[player.UserId]
    if not covenId then return end
    
    local coven = activeCovens[covenId]
    if not coven then return end
    
    local EconomyService = require(script.Parent.EconomyService)
    if EconomyService.HasEnoughCoins(player, amount) then
        EconomyService.DeductCoins(player, amount, "CovenDonation")
        coven.TreasuryCoins += amount
        
        -- Logarithmic Anti-Inflation Level Up Formula: Level = max(1, floor(5 * ln(Treasury / 5000)))
        local rawRatio = math.max(1, coven.TreasuryCoins / 5000)
        local newLevel = math.max(1, math.floor(5 * math.log(rawRatio)))
        if newLevel > coven.Level then
            coven.Level = newLevel
            print("[CovenService] Coven " .. coven.Name .. " leveled up to " .. coven.Level)
        end
        
        local DomainEventBus = require(ReplicatedStorage.Shared.Events.DomainEventBus)
        DomainEventBus.Publish("CovenDonated", player, {
            Amount = amount,
            CovenLevel = coven.Level,
            CovenId = covenId
        })

        NetChannels.GetRemoteEvent("CovenEvent"):FireClient(player, "Sync", coven)
    end
end

function CovenService.GetGlobalMultiplier(player: Player): number
    local covenId = playerCovenMap[player.UserId]
    if not covenId then return 1.0 end
    
    local coven = activeCovens[covenId]
    if not coven then return 1.0 end
    
    -- Logarithmic Global Multiplier Buff: 1 + (0.15 * ln(Level + 1))
    return 1.0 + (0.15 * math.log(coven.Level + 1))
end

return CovenService
