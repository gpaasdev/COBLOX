--!strict

local RunService = game:GetService("RunService")
local DataStoreService = game:GetService("DataStoreService")

local hideoutStore = DataStoreService:GetDataStore("CovenHideouts_v1")

local CovenHideoutDataService = {
	ServiceStatus = "Experimental",
	Name = "CovenHideoutData",
}

function CovenHideoutDataService.Init()
end

function CovenHideoutDataService.Start()
end

type StructureData = {
	Id: string,
	ItemType: string,
	Position: { number },
	Rotation: { number },
}

type HideoutSaveData = {
	Structures: { StructureData },
	LastSaved: number,
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
