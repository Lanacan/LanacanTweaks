----------------------
-- Embeded EasyDelete 
-- WoW Classic Addon to automatically pre-fill "DELETE" confirmation text
-- in item deletion popups to save typing effort.
----------------------

-- Create a frame to listen for the PLAYER_LOGIN event
-- Ensures the addon runs only after full player login
local CF = CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")

-- Run this when the player logs in
CF:SetScript("OnEvent", function(self, event)
    -- Hook Blizzard’s popup show function to intercept delete confirmations
    hooksecurefunc("StaticPopup_Show", function(which, text_arg1, text_arg2, data)
        -- Find the visible popup dialog frame of the specified type
        local dialog = StaticPopup_FindVisible(which)
        
        -- If the popup exists and has an input box
        if dialog and dialog.editBox then
            -- For delete confirmation dialogs, auto-fill the confirmation text
            if which == "DELETE_ITEM" or which == "DELETE_GOOD_ITEM" or which == "DELETE_GOOD_QUEST_ITEM" then
                dialog.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
            end
        end
    end)
end)
