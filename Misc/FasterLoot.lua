----------------------
-- Embeded FasterLool
-- WoW Classic Addon to automatically loot all items when the loot window opens,
-- with throttling to avoid spamming loot requests too quickly.
-- Honors the user's autoLoot toggle setting and modified clicks.
----------------------

-- Create a frame to handle addon events
local addon = CreateFrame("Frame")

-- Timestamp of the last loot attempt to throttle looting speed
local epoch = 0

-- Delay in seconds between loot attempts to account for Classic server latency
local LOOT_DELAY = 0.2

-- Register for loot-related events:
-- LOOT_READY: Fired when loot window is ready to be looted
-- LOOT_CLOSED: Fired when loot window is closed
addon:RegisterEvent("LOOT_READY")
addon:RegisterEvent("LOOT_CLOSED")

-- Event handler function for registered events
addon:SetScript("OnEvent", function(self, event)
    if event == "LOOT_CLOSED" then
        -- Reset the loot timer when loot window closes
        epoch = 0
        return
    end
    
    -- Proceed only if autoLoot is enabled and toggle key is not modifying the behavior
    if GetCVarBool("autoLootDefault") ~= IsModifiedClick("AUTOLOOTTOGGLE") then
        -- Throttle loot attempts to at least LOOT_DELAY seconds apart
        if (GetTime() - epoch) >= LOOT_DELAY then
            local numItems = GetNumLootItems()
            if numItems and numItems > 0 then
                -- Loot items from the last slot to the first
                for i = numItems, 1, -1 do
                    if LootSlotHasItem(i) then
                        LootSlot(i)
                    end
                end
                -- Update the last loot time to current time
                epoch = GetTime()
            end
        end
    end
end)
