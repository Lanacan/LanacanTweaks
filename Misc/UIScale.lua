-- Create a new frame without a global name, parented to UIParent
local f = CreateFrame("Frame", nil, UIParent)

-- Register for the PLAYER_LOGIN event, which fires when the player fully logs in
f:RegisterEvent("PLAYER_LOGIN")

-- Configuration:
local useCalculatedScale = false   -- Set to true to use calculated scale; false to use fixed scale
local fixedScalePercent = 80       -- Fixed scale percent (if useCalculatedScale is false)

-- === Objective Tracker Scaling ===
local function scaleObjectiveTracker()
    if ObjectiveTrackerFrame then
        ObjectiveTrackerFrame:SetScale(0.95)
    end
end

-- Set the OnEvent script handler for the frame
f:SetScript("OnEvent", function(self, event)
    C_Timer.After(1, function()
        local width, height = GetPhysicalScreenSize()

        if width and height then
            --print("Detected physical screen size:", width, height)

            local baseScale = 768 / height
            local finalScale

            if useCalculatedScale then
                finalScale = baseScale
                --print(string.format("Using calculated UI scale: %.3f", finalScale))
            else
                finalScale = fixedScalePercent / 100
                --print(string.format("Using fixed UI scale: %d%% (%.3f)", fixedScalePercent, finalScale))
            end

            UIParent:SetScale(finalScale)
        else
            print("Failed to get physical screen size.")
        end

        -- Apply objective tracker scale
        scaleObjectiveTracker()
    end)

    self:UnregisterAllEvents()
end)
