--!strict

local AudioEvents = {
	UI = {
		Hover = "rbxassetid://12222076", -- Standard Pop
		Click = "rbxassetid://12222216", -- Clean click
		ButtonPressed = "rbxassetid://12222253", -- Soft tap
		TabSwitch = "rbxassetid://12222253",
	},
	Gameplay = {
		LevelUp = "rbxassetid://138677306", -- Success chime
		QuestCompleted = "rbxassetid://138677306",
		CraftSuccess = "rbxassetid://138677306",
		PetLegendary = "rbxassetid://138677306",
		PetSecret = "rbxassetid://138677306",
	},
	Store = {
		PurchaseSuccess = "rbxassetid://138677306",
		PurchaseFailed = "rbxassetid://12222076",
	},
	System = {
		Error = "rbxassetid://12222076",
		Notification = "rbxassetid://12222076",
	},
	Social = {
		TradeRequest = "rbxassetid://12222216",
	},
}

return AudioEvents
