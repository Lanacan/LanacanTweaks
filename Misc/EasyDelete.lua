-- Create a frame to listen for the PLAYER_LOGIN event
-- This ensures our code only runs after the player has fully logged into the game
local CF = CreateFrame("Frame")
CF:RegisterEvent("PLAYER_LOGIN")

-- Set the function to run when the PLAYER_LOGIN event is triggered
CF:SetScript("OnEvent", function(self, event)
    -- Hook into the function that displays popup dialogs
    -- This allows us to intercept when the delete confirmation dialog is shown
    hooksecurefunc("StaticPopup_Show", function(which, text_arg1, text_arg2, data)
        -- Find the actual dialog frame that is currently visible
        local dialog = StaticPopup_FindVisible(which)
        
        -- If the dialog exists and has an editBox (text input field)
        if dialog and dialog.editBox then
            -- Check if the dialog is one of the delete confirmation types
            if which == "DELETE_ITEM" or which == "DELETE_GOOD_ITEM" or which == "DELETE_GOOD_QUEST_ITEM" then
                -- Pre-fill the confirmation text so the user doesn't have to type "DELETE"
                dialog.editBox:SetText(DELETE_ITEM_CONFIRM_STRING)
            end
        end
    end)
end)
