--!strict

local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local hideoutStore = {}
if not RunService:IsStudio() then
	local realStore = DataStoreService:GetDataStore("CovenHideouts_v1")
	function hideoutStore:SetAsync(key, value)
		realStore:SetAsync(key, value)
	end
	function hideoutStore:GetAsync(key)
		return realStore:GetAsync(key)
	end
else
	local mockStoreData = {}
	function hideoutStore:SetAsync(key, value)
		mockStoreData[key] = value
	end
	function hideoutStore:GetAsync(key)
		return mockStoreData[key]
	end
end

local CovenHideoutDataService = {}

type StructureData = {
    Id: string,
    ItemType: string,
    Position: {number},
    Rotation: {number}
}

type HideoutSaveData = {
    Structures: {StructureData},
    LastSaved: number
}

function CovenHideoutDataService.SaveHideout(covenId: string, data: HideoutSaveData): boolean
    local key = "Hideout_" .. covenId
    local success, err = pcall(function()
        hideoutStore:SetAsync(key, data)
    end)
    
    if not success then
        warn("[CovenHideoutDataService] Failed to save hideout for Coven " .. covenId .. ": " .. tostring(err))
    end
    return success
end

function CovenHideoutDataService.LoadHideout(covenId: string): HideoutSaveData?
    local key = "Hideout_" .. covenId
    local data: HideoutSaveData? = nil
    local success, err = pcall(function()
        data = hideoutStore:GetAsync(key) :: any
    end)
    
    if not success then
        warn("[CovenHideoutDataService] Failed to load hideout for Coven " .. covenId .. ": " .. tostring(err))
    end
    return data
end

return CovenHideoutDataService
