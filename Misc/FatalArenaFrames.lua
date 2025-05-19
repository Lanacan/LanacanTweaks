local _, ns = ...
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

local hiddenFrame = CreateFrame("Frame")
hiddenFrame:Hide()

function ns:isArena()
    local instanceType = select(2, IsInInstance())
    if instanceType == "arena" then
        return true
    end
    return false
end

function ns:handleFrame(frame, originalParent)
    if not frame then return end
    if not ns:isArena() then
        frame:SetParent(originalParent) -- unhide
        return
    end
    frame:SetParent(hiddenFrame) -- hide
end

eventFrame:SetScript("OnEvent", function()
    for i=1,5 do
        local prepPlayerFrame = _G["ArenaEnemyPrepFrame"..i]
        local prepPetFrame = _G["ArenaEnemyPrepFrame"..i.."PetFrame"]
        local matchPlayerFrame = _G["ArenaEnemyMatchFrame"..i]
        local matchPetFrame = _G["ArenaEnemyMatchFrame"..i.."PetFrame"]
        
        ns:handleFrame(prepPlayerFrame, nil)
        ns:handleFrame(prepPetFrame, nil)
        ns:handleFrame(matchPlayerFrame, ArenaEnemyMatchFramesContainer)
        ns:handleFrame(matchPetFrame, ArenaEnemyMatchFramesContainer)
    end
end)