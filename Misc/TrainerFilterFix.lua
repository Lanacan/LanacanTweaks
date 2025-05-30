-- Function to fix or override the default trainer window filters
local function TrainerFilterFix()
    -- Delay execution slightly to allow the Blizzard UI to initialize fully
    C_Timer.After(0.1, function()
        -- Override Blizzard's internal filter booleans
        TRAINER_FILTER_AVAILABLE_BOOL = true        -- Show available skills
        TRAINER_FILTER_UNAVAILABLE_BOOL = false     -- Hide unavailable skills
        TRAINER_FILTER_USED_BOOL = false            -- Hide already known skills

        -- Apply these filters using the appropriate API if available
        if SetTrainerServiceTypeFilter then
            SetTrainerServiceTypeFilter("available", true)
            SetTrainerServiceTypeFilter("unavailable", false)
            SetTrainerServiceTypeFilter("used", false)
        end

        -- Force the trainer UI to refresh with the new settings
        if TrainerFrame_Update then
            TrainerFrame_Update()
        end
    end)
end

-- Create a frame to listen for when the trainer UI is opened
local frame = CreateFrame("Frame")

-- Register for the "TRAINER_SHOW" event (fires when opening a class trainer)
frame:RegisterEvent("TRAINER_SHOW")

-- Run the filter-fixing function when the event fires
frame:SetScript("OnEvent", TrainerFilterFix)
