local api = require("api")

local visible_buffs_and_stacks_addon = {
	name = "Visible Buffs & Stacks",
	author = "Michaelqt",
	version = "v1.0.0",
	desc = "Removes buff blink, and improves stack text."
}

local serMeatballWindow

local clockTimer = 0
local clockResetTime = 1000

local buffIdCounter = 1
local buffInfos = {}

local haveWritten = false

local function OnUpdate(dt)
    if clockTimer + dt > clockResetTime then
		clockTimer = 0
        local playerFrame = ADDON:GetContent(UIC.PLAYER_UNITFRAME)
        for key,value in pairs(playerFrame.buffWindow.button) do
            local buffBtn = playerFrame.buffWindow.button[key]
            buffBtn:SetAlpha(1)
            buffBtn.OnUpdate = nil
            buffBtn:ReleaseHandler("OnUpdate")
            
        end
        for key,value in pairs(playerFrame.debuffWindow.button) do
            local debuffBtn = playerFrame.debuffWindow.button[key]
            debuffBtn:SetAlpha(1)
            debuffBtn.OnUpdate = nil
            debuffBtn:ReleaseHandler("OnUpdate")
            
        end
        local targetFrame = ADDON:GetContent(UIC.TARGET_UNITFRAME)
        for key,value in pairs(targetFrame.buffWindow.button) do
            local buffBtn = targetFrame.buffWindow.button[key]
            buffBtn:SetAlpha(1)
            buffBtn.OnUpdate = nil
            buffBtn:ReleaseHandler("OnUpdate")
            
        end
        for key,value in pairs(targetFrame.debuffWindow.button) do
            local debuffBtn = targetFrame.debuffWindow.button[key]
            debuffBtn:SetAlpha(1)
            debuffBtn.OnUpdate = nil
            debuffBtn:ReleaseHandler("OnUpdate")
            
        end
    end 
    clockTimer = clockTimer + dt
end 

local function OnLoad()
	local settings = api.GetSettings("visible_buffs_and_stacks")

	local playerFrame = ADDON:GetContent(UIC.PLAYER_UNITFRAME)
	for key,value in pairs(playerFrame.buffWindow.button) do
		
		local buffBtn = playerFrame.buffWindow.button[key]
		buffBtn.leftTimeText:RemoveAllAnchors()
		buffBtn.leftTimeText:AddAnchor("CENTER", buffBtn, -2, 2)
		buffBtn.stack.style:SetFontSize(12)
		ApplyTextColor(buffBtn.stack, {0.85, 1, 0.85, 1})
		-- ApplyTextColor(buffBtn.stack, FONT_COLOR.WHITE)
		buffBtn.stack.style:SetOutline(true)
	end
	for key,value in pairs(playerFrame.debuffWindow.button) do
		
		local debuffBtn = playerFrame.debuffWindow.button[key]
		debuffBtn.leftTimeText:RemoveAllAnchors()
		debuffBtn.leftTimeText:AddAnchor("CENTER", debuffBtn, -2, -4)
		debuffBtn.stack.style:SetFontSize(12)
		ApplyTextColor(debuffBtn.stack, {1, 0.85, 0.85, 1})
		-- ApplyTextColor(debuffBtn.stack, FONT_COLOR.WHITE)
		debuffBtn.stack.style:SetOutline(true)
	end

    local targetFrame = ADDON:GetContent(UIC.TARGET_UNITFRAME)
    for key,value in pairs(targetFrame.buffWindow.button) do
		
		local buffBtn = targetFrame.buffWindow.button[key]
		buffBtn.leftTimeText:RemoveAllAnchors()
		buffBtn.leftTimeText:AddAnchor("CENTER", buffBtn, -2, 2)
		buffBtn.stack.style:SetFontSize(12)
		ApplyTextColor(buffBtn.stack, {0.85, 1, 0.85, 1})
		-- ApplyTextColor(buffBtn.stack, FONT_COLOR.WHITE)
		buffBtn.stack.style:SetOutline(true)
	end
	for key,value in pairs(targetFrame.debuffWindow.button) do
		
		local debuffBtn = targetFrame.debuffWindow.button[key]
		debuffBtn.leftTimeText:RemoveAllAnchors()
		debuffBtn.leftTimeText:AddAnchor("CENTER", debuffBtn, -2, -4)
		debuffBtn.stack.style:SetFontSize(12)
		ApplyTextColor(debuffBtn.stack, {1, 0.85, 0.85, 1})
		-- ApplyTextColor(debuffBtn.stack, FONT_COLOR.WHITE)
		debuffBtn.stack.style:SetOutline(true)
	end
	
    api.On("UPDATE", OnUpdate)
	api.SaveSettings()
end

local function OnUnload()
	api.On("UPDATE", function() return end)
end

visible_buffs_and_stacks_addon.OnLoad = OnLoad
visible_buffs_and_stacks_addon.OnUnload = OnUnload

return visible_buffs_and_stacks_addon
