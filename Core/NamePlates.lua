----------------------
-- Lanacan Nameplate Colors & Settings
-- Custom coloring of nameplate health bars based on unit reaction and tailored nameplate CVars
--
-- This addon recolors nameplate health bars dynamically by hooking Blizzard’s
-- CompactUnitFrame health updates and sets CVars on login to customize nameplate
-- scaling, visibility, and unit name display for a cleaner UI.
----------------------

-- Color table indexed by unit reaction for nameplate health bars
-- Reaction levels range from hostile (1) to neutral (4) to friendly (5+)
local REACTION_COLORS = {
    [1] = {r = 0.9,  g = 0,    b = 0},    -- Hostile (Red)
    [2] = {r = 0.9,  g = 0,    b = 0},    -- Hostile (Red)
    [3] = {r = 0.75, g = 0.27, b = 0},    -- Unfriendly (Orange-ish)
    [4] = {r = 0.8,  g = 0.7,  b = 0.2},  -- Neutral (Yellow)
    [5] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
    [6] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
    [7] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
    [8] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
    [9] = {r = 0.5,  g = 0.5,  b = 0.5},  -- Tapped or denied (Grey)
}

---
-- Apply custom color to a nameplate health bar based on unit reaction
-- @param frame The health bar frame to color
-- @param unit The unit token associated with the nameplate
---
local function ApplyColors(frame, unit)
    if not unit then return end

    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end

    -- Only color NPCs/pets, skip player-controlled units
    if not UnitPlayerControlled(unit) then
        local reaction = UnitReaction(unit, "player")

        if UnitIsTapDenied(unit) then reaction = 9 end
        if not reaction then return end

        local color = REACTION_COLORS[reaction]
        frame:SetStatusBarColor(color.r, color.g, color.b)
    end
end

-- Hook Blizzard’s health color update to recolor health bars dynamically
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(self)
    ApplyColors(self.healthBar, self.unit)
end)

-- Hook Blizzard’s health update to recolor health bars on health changes
hooksecurefunc("CompactUnitFrame_UpdateHealth", function(self)
    ApplyColors(self.healthBar, self.unit)
end)

-- Frame to set CVars on player login for nameplate appearance and behavior
local eventHandler = CreateFrame("Frame")
eventHandler:RegisterEvent("PLAYER_LOGIN")

eventHandler:SetScript("OnEvent", function()
    SetCVar("ShowClassColorInFriendlyNameplate", 1)
    SetCVar("ShowClassColorInNameplate", 0)

    SetCVar("nameplateShowFriends", 0)
    SetCVar("nameplateShowEnemies", 1)
    SetCVar("nameplateMaxDistance", 60)

    SetCVar("showClassColorInNameplate", 1)

    SetCVar("nameplateOtherTopInset", -1)
    SetCVar("nameplateOtherBottomInset", -1)

    SetCVar("nameplateMinScale", 0.8)
    SetCVar("nameplateMaxScale", 1.1)
    SetCVar("nameplateGlobalScale", 1.0)

    SetCVar("UnitNameFriendlyPlayerName", 1)
    SetCVar("UnitNameEnemyPlayerName", 1)
    SetCVar("UnitNameNPC", 1)
    SetCVar("UnitNameOwn", 0)

    SetCVar("nameplateMinAlpha", 0.6)
    SetCVar("nameplateMaxAlpha", 1.0)
    SetCVar("nameplateSelectedAlpha", 1.0)

    SetCVar("nameplateLargerScale", 1.0)
    SetCVar("nameplateSelectedScale", 1.0)
    SetCVar("nameplateSelfScale", 1.0)

    SetCVar("nameplateOccludedAlphaMult", 0.4)
end)
