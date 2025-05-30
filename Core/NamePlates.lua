-- Table of colors indexed by reaction level for nameplate health bars
-- Reaction levels correspond to hostility/friendliness from hostile (1) to neutral (4) to friendly (5+)
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

-- Function to apply color to a given frame's health bar based on unit reaction
local function ApplyColors(frame, unit)
    if not unit then return end  -- Exit if no unit specified

    -- Get the nameplate frame associated with this unit
    local nameplate = C_NamePlate.GetNamePlateForUnit(unit)
    if not nameplate then return end  -- Exit if no nameplate found

    -- Only color non-player-controlled units (i.e., NPCs or pets)
    if not UnitPlayerControlled(unit) then
        local reaction = UnitReaction(unit, "player")  -- Get reaction of unit to player

        -- If unit is tapped (tagged by another player), force grey color
        if UnitIsTapDenied(unit) then reaction = 9 end

        if not reaction then return end  -- Exit if no reaction data available

        -- Get color corresponding to reaction
        local color = REACTION_COLORS[reaction]
        -- Set the health bar color accordingly
        frame:SetStatusBarColor(color.r, color.g, color.b)
    end
end

-- Hook into the CompactUnitFrame health color update function to recolor health bars
hooksecurefunc("CompactUnitFrame_UpdateHealthColor", function(self)
    ApplyColors(self.healthBar, self.unit)
end)

-- Hook into the CompactUnitFrame health update function to recolor health bars on health change
hooksecurefunc("CompactUnitFrame_UpdateHealth", function(self)
    ApplyColors(self.healthBar, self.unit)
end)

-- Create an event handler frame for managing CVar settings on login
local eventHandler = CreateFrame("Frame")

-- Register for the PLAYER_LOGIN event to apply settings after the player logs in
eventHandler:RegisterEvent("PLAYER_LOGIN")

-- Event handler function that sets various CVars to configure nameplate and unit name display
eventHandler:SetScript("OnEvent", function()
    -- Settings from first addon (likely to tweak class colors on nameplates)
    SetCVar("ShowClassColorInFriendlyNameplate", 1) -- Show class color for friendly nameplates
    SetCVar("ShowClassColorInNameplate", 0)         -- Disable class colors on all nameplates

    -- Settings from second addon to control nameplate visibility and scaling
    SetCVar("nameplateShowFriends", 0)        -- Don't show friendly nameplates by default
    SetCVar("nameplateShowEnemies", 1)        -- Show enemy nameplates
    SetCVar("nameplateMaxDistance", 60)       -- Max distance to show nameplates

    SetCVar("showClassColorInNameplate", 1)   -- Show class colors in nameplates

    SetCVar("nameplateOtherTopInset", -1)     -- Adjust vertical insets to tweak stacking
    SetCVar("nameplateOtherBottomInset", -1)

    -- Control scaling of nameplates based on distance and selection
    SetCVar("nameplateMinScale", 0.8)
    SetCVar("nameplateMaxScale", 1.1)
    SetCVar("nameplateGlobalScale", 1.0)

    -- Control display of player and NPC names on nameplates
    SetCVar("UnitNameFriendlyPlayerName", 1)
    SetCVar("UnitNameEnemyPlayerName", 1)
    SetCVar("UnitNameNPC", 1)
    SetCVar("UnitNameOwn", 0)  -- Do not show your own name on your nameplate

    -- Control alpha transparency of nameplates based on selection and occlusion
    SetCVar("nameplateMinAlpha", 0.6)
    SetCVar("nameplateMaxAlpha", 1.0)
    SetCVar("nameplateSelectedAlpha", 1.0)

    -- Control scaling on selected and self nameplates
    SetCVar("nameplateLargerScale", 1.0)
    SetCVar("nameplateSelectedScale", 1.0)
    SetCVar("nameplateSelfScale", 1.0)

    -- Control alpha multiplier for occluded nameplates (those hidden behind objects)
    SetCVar("nameplateOccludedAlphaMult", 0.4)
end)
