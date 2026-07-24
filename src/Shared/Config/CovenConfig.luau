--!strict

local CovenConfig = {
    -- Template Place ID used by AssetService:CreatePlaceAsync for live instances
    TEMPLATE_PLACE_ID = 123456789,

    -- Local Studio Simulation coordinates (Coven Zone)
    STUDIO_MOCK_ZONE_POSITION = Vector3.new(0, 500, 0),

    -- Maximum capacity for hideout instances
    MAX_HIGHOUT_CAPACITY = 20,

    -- Default Hideout Name Format
    DEFAULT_HIDEOUT_NAME_FORMAT = "%s's Sanctuary",
}

return CovenConfig
