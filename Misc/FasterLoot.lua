-- Create a frame to handle events for the addon
local addon = CreateFrame("Frame")

-- Variable to store the last time loot was attempted
-- Used to throttle looting to avoid spamming too quickly
local epoch = 0

-- Slightly reduced delay to account for Classic's slower server response during loot
local LOOT_DELAY = 0.2

-- Register for loot-related events:
-- LOOT_READY: Triggered when loot window is populated and ready
-- LOOT_CLOSED: Triggered when loot window closes
addon:RegisterEvent("LOOT_READY")
addon:RegisterEvent("LOOT_CLOSED")

-- Set a script to run when the registered events fire
addon:SetScript("OnEvent", function(self, event)
    -- When loot window is closed, reset the timer
    if event == "LOOT_CLOSED" then
        epoch = 0
        return
    end
    
    -- Only proceed with autoloot if conditions match user settings:
    -- Checks if the current click matches the auto-loot toggle state
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        -- Ensure enough time has passed since last loot attempt (throttling)
        if (GetTime() - epoch) >= LOOT_DELAY then
            -- Get number of items in the loot window
            local numItems = GetNumLootItems()
            if numItems and numItems > 0 then
                -- Iterate backwards through the loot slots and loot items if present
                for i = numItems, 1, -1 do
                    if LootSlotHasItem(i) then
                        LootSlot(i)
                    end
                end
                -- Update epoch to current time to enforce LOOT_DELAY on next attempt
                epoch = GetTime()
            end
        end
    end
end)
