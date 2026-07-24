--!strict
local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

local AuctionHouseService = {}
local GlobalAuctionHouse = MemoryStoreService:GetSortedMap("GlobalAuctionHouse")

function AuctionHouseService.Init()
    print("[AuctionHouseService] Initializing Global Auction House...")
end

function AuctionHouseService.Start()
    -- Subsystem listening/refresh logic
end

function AuctionHouseService.ListItem(player: Player, itemId: string, price: number)
    local listingId = player.UserId .. "_" .. itemId .. "_" .. tostring(os.time())
    local listingData = {
        SellerId = player.UserId,
        ItemId = itemId,
        Price = price
    }
    
    local success, err = pcall(function()
        -- TTL set to 86400 seconds (24 hours) to prevent memory inflation
        GlobalAuctionHouse:SetAsync(listingId, listingData, 86400)
    end)
    
    if not success then
        warn("[AuctionHouseService] Failed to list item: " .. tostring(err))
    end
end

return AuctionHouseService
