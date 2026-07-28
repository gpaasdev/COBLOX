--!strict
local GlobalBroadcastService = require(script.Parent.Parent.GlobalBroadcastService)
local PlayerDataService = require(script.Parent.Parent.PlayerDataService)

local LiveOpsEventScheduler = {}
LiveOpsEventScheduler.Name = "LiveOpsEventScheduler"

local EventConfig = {
	DoubleManaWeekend = {
		IsActive = false,
		Multiplier = 2.0,
	},
	GoldenEggRateUp = {
		IsActive = false,
		Multiplier = 1.5,
	},
}

function LiveOpsEventScheduler.Init()
	print("[LiveOpsEventScheduler] Initializing Automated LiveOps Engine...")
end

function LiveOpsEventScheduler.Start()
	task.spawn(function()
		while true do
			local currentDay = os.date("!*t").wday

			-- Enable Double Mana on Weekends (Saturday=7, Sunday=1)
			local isWeekend = (currentDay == 1 or currentDay == 7)
			if isWeekend and not EventConfig.DoubleManaWeekend.IsActive then
				EventConfig.DoubleManaWeekend.IsActive = true
				GlobalBroadcastService.Broadcast("🌟 DOUBLE MANA WEEKEND IS ACTIVE! Earn 2x Mana!", 255, 215, 0)
			elseif not isWeekend and EventConfig.DoubleManaWeekend.IsActive then
				EventConfig.DoubleManaWeekend.IsActive = false
				GlobalBroadcastService.Broadcast("Double Mana Weekend has ended. See you next week!", 200, 200, 200)
			end

			task.wait(60) -- Check every minute
		end
	end)
end

function LiveOpsEventScheduler.GetManaMultiplier()
	return EventConfig.DoubleManaWeekend.IsActive and EventConfig.DoubleManaWeekend.Multiplier or 1.0
end

return LiveOpsEventScheduler
