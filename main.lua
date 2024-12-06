local api = require("api")

local reality_check_addon = {
	name = "Reality Check",
	author = "Michaelqt",
	version = "1.0",
	desc = "Time-related utilities for labor and in-game time."
}

local LABORPOINT_CAP = 10000
local LABORPOINT_REGEN_PER_5_MIN = 40
local WARNING_MINUTES_ORANGE = 120
local WARNING_MINUTES_RED = 30

local realityCheckWnd
local gameExitFrame
local function displayTimeString(timeInMs)
    local seconds = math.floor(timeInMs / 1000) % 60
    local minutes = math.floor(timeInMs / (1000*60)) % 60  
    local hours = math.floor(timeInMs / (1000*60*60)) % 24
    
    return string.format("%02dh %02dm", hours, minutes)
end

local function displayIRLTimeString(timeInMs)
    local seconds = math.floor(timeInMs / 1000) % 60
    local minutes = math.floor(timeInMs / (1000*60)) % 60  
    local hours = math.floor(timeInMs / (1000*60*60)) % 24
    
    local irlTimestamp = api.Time:GetLocalTime()
    local irlTime = api.Time:TimeToDate(irlTimestamp)
    
    -- Making a copy of the current time, and then adding the time til cap to it
    local laborCapTime = {}
    laborCapTime.year = irlTime.year
    laborCapTime.month = irlTime.month
    laborCapTime.day = irlTime.day
    laborCapTime.minute = irlTime.minute
    laborCapTime.hour = irlTime.hour
    laborCapTime.second = irlTime.second
    laborCapTime.minute = irlTime.minute + minutes
    if laborCapTime.minute > 59 then
        laborCapTime.hour = laborCapTime.hour + 1
        laborCapTime.minute = laborCapTime.minute - 60
    end 
    laborCapTime.hour = irlTime.hour + hours
    if laborCapTime.hour > 23 then
        laborCapTime.day = laborCapTime.day + 1
        laborCapTime.hour = laborCapTime.hour - 24
    end 

    -- Handling tomorrow or today text
    if irlTime.day < laborCapTime.day then
        return "Your labor will cap tomorrow at " .. string.format("%02d:%02d", laborCapTime.hour, laborCapTime.minute)
    else
        return "Your labor will cap today at " .. string.format("%02d:%02d", laborCapTime.hour, laborCapTime.minute)
    end 
    return nil
end 

local function updateLaborTimer(diff, laborPower)
    local distToLaborCap = LABORPOINT_CAP - tonumber(laborPower)
    local minutesUntilLaborCap = distToLaborCap / (LABORPOINT_REGEN_PER_5_MIN / 5)
    local msUntilLaborCap = minutesUntilLaborCap * 60 * 1000
    -- TODO: Add the real life time when you'll cap
    -- local localTimeMsWhenCapped = api.Time:GetLocalTime() + msUntilLaborCap
    -- api.Log:Info(tostring(api.Time:GetLocalTime()) ..  " " .. tostring(msUntilLaborCap))
    -- api.Log:Info(displayTimeString(api.Time:GetLocalTime()) ..  " " .. displayTimeString(msUntilLaborCap))
    -- realityCheckWnd.laborTimer:SetText("Time to Labor Cap: " .. displayTimeString(msUntilLaborCap) .. " (" .. tostring(displayIRLTimeString(localTimeMsWhenCapped)) .. " IRL)")
    realityCheckWnd.laborTimer:SetText("Labor Cap: " .. displayTimeString(msUntilLaborCap))
    gameExitFrame.logOutLaborTimer:SetText(displayIRLTimeString(msUntilLaborCap))
    if minutesUntilLaborCap > WARNING_MINUTES_ORANGE then 
        ApplyTextColor(realityCheckWnd.laborTimer, FONT_COLOR.LABORPOWER_YELLOW)
        ApplyTextColor(gameExitFrame.logOutLaborTimer, FONT_COLOR.LABORPOWER_YELLOW)
    elseif minutesUntilLaborCap < WARNING_MINUTES_ORANGE and minutesUntilLaborCap > WARNING_MINUTES_RED then 
        ApplyTextColor(realityCheckWnd.laborTimer, FONT_COLOR.ORANGE)
        ApplyTextColor(gameExitFrame.logOutLaborTimer, FONT_COLOR.ORANGE)
    elseif minutesUntilLaborCap < WARNING_MINUTES_RED then
        ApplyTextColor(realityCheckWnd.laborTimer, FONT_COLOR.RED)
        ApplyTextColor(gameExitFrame.logOutLaborTimer, FONT_COLOR.RED)
    end 
end 

local function updateInGameTimer()
    if realityCheckWnd.inGameTimer ~= nil then 
        local isAm, hour, minute = api.Time:GetGameTime()
        local irlTimestamp = api.Time:GetLocalTime()
        local irlTime = api.Time:TimeToDate(irlTimestamp)

        -- Formating the number as 00:00
        minute = math.floor(minute)
        if not isAm then
            hour = hour + 12
        end 
        if hour < 10 then
            hour = "0" .. tostring(hour)
        end 
        if minute < 10 then
            minute = "0" .. tostring(minute)
        end 
        if irlTime.hour < 10 then 
            irlTime.hour = "0" .. tostring(irlTime.hour)
        end 
        if irlTime.minute < 10 then
            irlTime.minute = "0" .. tostring(irlTime.minute)
        end
        

        local inGameTimerStr = tostring(hour) .. ":" .. tostring(minute) .. " (" .. tostring(irlTime.hour) .. ":" .. tostring(irlTime.minute) .. " IRL)"
        realityCheckWnd.inGameTimer:SetText(inGameTimerStr)
    end 
end 

local inGameTimerTick = 0
local inGameTimerTickRate = 300
local function OnUpdate(dt)
    if inGameTimerTick > inGameTimerTickRate then
        updateInGameTimer()
        inGameTimerTick = 0
    end 
    inGameTimerTick = inGameTimerTick + dt
end 

local function OnLoad()
	local settings = api.GetSettings("reality_check")
    realityCheckWnd = api.Interface:CreateEmptyWindow("realityCheckWnd", "UIParent")
    gameExitFrame = ADDON:GetContent(UIC.GAME_EXIT_FRAME)

    local laborTimer = realityCheckWnd:CreateChildWidget("label", "laborTimer", 0, true)
    laborTimer.style:SetAlign(ALIGN.LEFT)
    laborTimer:AddAnchor("BOTTOMLEFT", "UIParent", 300, -24)
    ApplyTextColor(laborTimer, FONT_COLOR.LABORPOWER_YELLOW)
    laborTimer.style:SetShadow(true)
    laborTimer:SetText("Labor Cap: Waiting for labor tick...")

    local inGameTimer = realityCheckWnd:CreateChildWidget("label", "inGameTimer", 0, true)
    inGameTimer.style:SetAlign(ALIGN.MIDDLE)
    inGameTimer:AddAnchor("TOPRIGHT", "UIParent", -90, 12)
    ApplyTextColor(inGameTimer, FONT_COLOR.LABORPOWER_YELLOW)
    inGameTimer.style:SetFontSize(FONT_SIZE.LARGE)
    inGameTimer.style:SetShadow(true)

    local logOutLaborTimer = gameExitFrame:CreateChildWidget("label", "logOutLaborTimer", 0, true)
    logOutLaborTimer.style:SetAlign(ALIGN.MIDDLE)
    logOutLaborTimer:AddAnchor("BOTTOM", gameExitFrame, 0, -82)
    ApplyTextColor(logOutLaborTimer, FONT_COLOR.DEFAULT)
    logOutLaborTimer:SetText("")
    logOutLaborTimer.style:SetShadow(true)
    
    --- Event Handlers for main window
    function realityCheckWnd:OnEvent(event, ...)
        if event == "LABORPOWER_CHANGED" then
            if arg ~= nil then 
                updateLaborTimer(unpack(arg))
            end 
        end
    end
    realityCheckWnd:SetHandler("OnEvent", realityCheckWnd.OnEvent)
    realityCheckWnd:RegisterEvent("LABORPOWER_CHANGED")

    realityCheckWnd:Show(true)
	
    api.On("UPDATE", OnUpdate)
	api.SaveSettings()
end

local function OnUnload()
	api.On("UPDATE", function() return end)
    realityCheckWnd:ReleaseHandler("LABORPOWER_CHANGED")
    realityCheckWnd:Show(false)
    realityCheckWnd = nil
    if gameExitFrame.logOutLaborTimer ~= nil then
        gameExitFrame.logOutLaborTimer:Show(false)
        gameExitFrame.logOutLaborTimer:SetText("")
        gameExitFrame.logOutLaborTimer = nil    
    end
    if gameExitFrame.inGameTimer ~= nil then
        gameExitFrame.inGameTimer:Show(false)
        gameExitFrame.inGameTimer:SetText("")
        gameExitFrame.inGameTimer = nil    
    end
end

reality_check_addon.OnLoad = OnLoad
reality_check_addon.OnUnload = OnUnload

return reality_check_addon