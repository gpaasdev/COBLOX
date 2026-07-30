--!strict
local UserInputService = game:GetService("UserInputService")
local GuiService = game:GetService("GuiService")

export type Device = "Mobile" | "Console" | "Desktop" | "VR"

local DeviceType: Device = "Desktop"

do
	if GuiService:IsTenFootInterface() then
		DeviceType = "Console"
	elseif UserInputService.VREnabled then
		DeviceType = "VR"
	elseif UserInputService.TouchEnabled and not UserInputService.MouseEnabled then
		DeviceType = "Mobile"
	end
end

local function Get(): Device
	return DeviceType
end

local function IsMobile(): boolean
	return DeviceType == "Mobile"
end

local function IsConsole(): boolean
	return DeviceType == "Console"
end

local function IsDesktop(): boolean
	return DeviceType == "Desktop"
end

local function IsTouchEnabled(): boolean
	return UserInputService.TouchEnabled
end

local function GetSafeAreaTop(): UDim
	return if DeviceType == "Mobile" then UDim.new(0, 48) else UDim.new(0, 4)
end

local function GetSafeAreaBottom(): UDim
	return if DeviceType == "Mobile" then UDim.new(0, 36) else UDim.new(0, 0)
end

local function GetMinTouchTarget(): UDim
	return if DeviceType == "Mobile" then UDim.new(0, 48) else UDim.new(0, 36)
end

local function GetCasButtonScale(): number
	return if DeviceType == "Mobile" then 0.65 else 0.5
end

return {
	Get = Get,
	IsMobile = IsMobile,
	IsConsole = IsConsole,
	IsDesktop = IsDesktop,
	IsTouchEnabled = IsTouchEnabled,
	GetSafeAreaTop = GetSafeAreaTop,
	GetSafeAreaBottom = GetSafeAreaBottom,
	GetMinTouchTarget = GetMinTouchTarget,
	GetCasButtonScale = GetCasButtonScale,
}
