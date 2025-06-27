local function SetLanacanBindings()
    -- Action Bar 1 (Main): ACTIONBUTTON1 to ACTIONBUTTON12
    local mainBarKeys = { "1", "2", "3", "4", "R", "C", "F1", "F2", "F3", "F4", "F", "Z" }
    for i, key in ipairs(mainBarKeys) do
        SetBinding(key, "ACTIONBUTTON" .. i)
    end

    -- Action Bar 2 (Bottom Left): MULTIACTIONBAR1BUTTON1 to BUTTON12
    local bar2Keys = { "", "", "", "", "", "", "V", "SHIFT-V", "Q", "SHIFT-Q", "E", "SHIFT-E" }
    for i, key in ipairs(bar2Keys) do
        if key ~= "" then
            SetBinding(key, "MULTIACTIONBAR1BUTTON" .. i)
        end
    end

    -- Action Bar 3 (Bottom Right): MULTIACTIONBAR2BUTTON1 to BUTTON12
    local bar3Keys = {
        "SHIFT-1", "SHIFT-2", "SHIFT-3", "SHIFT-4", "SHIFT-5", "SHIFT-6",
        "ALT-1", "ALT-2", "ALT-3", "ALT-4", "ALT-5", "ALT-6"
    }
    for i, key in ipairs(bar3Keys) do
        SetBinding(key, "MULTIACTIONBAR2BUTTON" .. i)
    end

    -- Save to character-specific profile
    SaveBindings(1)  -- 1 = account-wide, 2 = character-specific
end

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
    SetLanacanBindings()
    print("Lanacan KeyBinder: Key bindings applied.")
end)
