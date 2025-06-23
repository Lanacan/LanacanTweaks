-----------------------------
-- Lanacan UI Scale Adjuster
-- WoW Classic Addon to manually or automatically scale the default UI and the Objective Tracker.
-- Supports fixed scaling by percentage or calculated scaling based on screen resolution.
-- Also scales the ObjectiveTrackerFrame independently.
-----------------------------

-- Create a new unnamed frame parented to UIParent
local f = CreateFrame("Frame", nil, UIParent)

-- Register for the PLAYER_LOGIN event to ensure changes are applied after the game fully loads
f:RegisterEvent("PLAYER_LOGIN")

-- === Configuration ===
local useCalculatedScale = false   -- Set to true to calculate scale based on screen height (768p baseline)
local fixedScalePercent = 80       -- Fixed scale percent if not using calculated scale (e.g., 80 = 80%)

-- === Objective Tracker Scaling Function ===
local function scaleObjectiveTracker()
    -- Ensure the frame exists before trying to scale it
    if ObjectiveTrackerFrame then
        ObjectiveTrackerFrame:SetScale(0.95)  -- Shrink to 95% of normal size
    end
end

-- === Event Handler ===
f:SetScript("OnEvent", function(self, event)
    -- Delay scaling slightly to ensure UI is fully initialized
    C_Timer.After(1, function()
        local width, height = GetPhysicalScreenSize()

        if width and height then
            -- Calculate base scale using 768p as a vertical reference
            local baseScale = 768 / height
            local finalScale

            if useCalculatedScale then
                -- Automatically use calculated scale based on resolution
                finalScale = baseScale
            else
                -- Use user-defined fixed percentage instead
                finalScale = fixedScalePercent / 100
            end

            -- Apply the final scale to the root UI frame
            UIParent:SetScale(finalScale)
        else
            print("Failed to get physical screen size.")
        end

        -- Apply scaling to the Objective Tracker as well
        scaleObjectiveTracker()
    end)

    -- Clean up: no further events needed after login
    self:UnregisterAllEvents()
end)
