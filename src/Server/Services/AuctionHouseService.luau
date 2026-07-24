--!strict
local MemoryStoreService = game:GetService("MemoryStoreService")
local RunService = game:GetService("RunService")

local AuctionHouseService = {}
local GlobalAuctionHouse = {}
if not RunService:IsStudio() then
	local realMap = MemoryStoreService:GetSortedMap("GlobalAuctionHouse")
	function GlobalAuctionHouse:SetAsync(key, value, ttl)
		realMap:SetAsync(key, value, ttl)
	end
	function GlobalAuctionHouse:GetAsync(key)
		return realMap:GetAsync(key)
	end
	function GlobalAuctionHouse:RemoveAsync(key)
		realMap:RemoveAsync(key)
	end
else
	local mockMapData = {}
	function GlobalAuctionHouse:SetAsync(key, value, ttl)
		mockMapData[key] = value
	end
	function GlobalAuctionHouse:GetAsync(key)
		return mockMapData[key]
	end
	function GlobalAuctionHouse:RemoveAsync(key)
		mockMapData[key] = nil
	end
end

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
