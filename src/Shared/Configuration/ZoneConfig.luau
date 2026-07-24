--!strict

local WorldConfig = require(script.Parent.Parent.Configuration.WorldConfig)

local ZoneConfig = {}

function ZoneConfig.GetZone(zoneId: string)
	return WorldConfig.Zones[zoneId]
end

function ZoneConfig.GetAllZones()
	return WorldConfig.Zones
end

function ZoneConfig.GetPortals()
	return WorldConfig.Portals
end

return ZoneConfig
