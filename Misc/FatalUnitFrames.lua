local _, ns = ...
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
eventFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
eventFrame:RegisterEvent("UNIT_NAME_UPDATE")

UNIT_COLOURS = {}
UNIT_COLOURS["grey"] = {r=25, g=25, b=25, a=0.65}
UNIT_COLOURS["red"] = {r=185, g=0, b=0, a=0.65}
UNIT_COLOURS["yellow"] = {r=246, g=190, b=0, a=0.65}
UNIT_COLOURS["green"] = {r=0, g=185, b=0, a=0.65}
UNIT_COLOURS["blue"] = {r=0, g=0, b=185, a=0.65}
TEXT_COLOUR = {r=255, g=255, b=255}

function ns:getUnitColourClassification(unit)
    if (not UnitPlayerControlled(unit) and UnitIsTapDenied(unit)) then
        return "grey"
    end
    local r, g, b, _ = UnitSelectionColor(unit)
    if r == 1 and g == 0 then
        return "red"
    elseif r == 0 and g == 1 then
        return "green"
    elseif b == 1 then
        return "blue"
    elseif r == 1 and g == 1 then
        return "yellow"
    end
    return "green"
end

function ns:getUnitColour(unit)
    local unitColourClassification = ns:getUnitColourClassification(unit)
    return UNIT_COLOURS[unitColourClassification]
end

function ns:setTextTheme(frame)
    if (frame) then
        frame:SetVertexColor(TEXT_COLOUR.r/255, TEXT_COLOUR.g/255, TEXT_COLOUR.b/255)
    end
end

function ns:setBackgroundTheme(frame, unit)
    if (frame) then
        local unitColour = ns:getUnitColour(unit)
        frame:SetVertexColor(unitColour.r/255, unitColour.g/255, unitColour.b/255, unitColour.a)
    end
end

local frames = {TargetFrame, FocusFrame}
for _, frame in ipairs(frames) do
    hooksecurefunc(frame, "CheckLevel", function() -- update level text colour when queried
        ns:setTextTheme(frame.TargetFrameContent.TargetFrameContentMain.LevelText)
    end)
    hooksecurefunc(frame, "CheckFaction", function() -- update rep bar colour when queried
        ns:setBackgroundTheme(frame.TargetFrameContent.TargetFrameContentMain.ReputationColor, frame.unit)
    end)
    local toTFrame = _G[frame:GetName().."ToT"]
    hooksecurefunc(toTFrame.Name, "SetText", function() -- update target of target/focus text
        ns:setTextTheme(toTFrame.Name)
    end)
end

hooksecurefunc("PlayerFrame_UpdateLevel", function() -- update own level
    ns:setTextTheme(PlayerLevelText)
end)

eventFrame:SetScript("OnEvent", function(frame, event, arg1, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        ns:setTextTheme(PlayerName)
        ns:setTextTheme(TargetFrame.TargetFrameContent.TargetFrameContentMain.Name)
        ns:setTextTheme(PetName)
    elseif event == "PLAYER_TARGET_CHANGED" then
        ns:setTextTheme(TargetFrame.TargetFrameContent.TargetFrameContentMain.Name)
    elseif event == "PLAYER_FOCUS_CHANGED" then
        ns:setTextTheme(FocusFrame.TargetFrameContent.TargetFrameContentMain.Name)
    elseif event == "UNIT_NAME_UPDATE" then
        -- may need to update level here too?
        if arg1 == "target" then
            ns:setTextTheme(TargetFrame.TargetFrameContent.TargetFrameContentMain.Name)
        elseif arg1 == "focus" then
            ns:setTextTheme(FocusFrame.TargetFrameContent.TargetFrameContentMain.Name)
        end
    end
end)