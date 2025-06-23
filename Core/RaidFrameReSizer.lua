----------------------
-- Lanacan Raid Frame Resizer
-- Custom resizing and recoloring of Blizzard default raid frames in WoW Classic
--
-- This addon increases the scale of the default raid frames, adjusts slider ranges (if present),
-- and recolors the raid frame manager background and resize frame border to black for improved contrast.
-- It runs on key UI events to ensure consistent sizing and styling.
----------------------

-- Create a frame to listen for relevant events
local frame = CreateFrame("Frame")

--- 
-- Resize and recolor Blizzard default raid frames and related UI elements
-- Scales raid frame container, modifies sliders if available, and recolors textures to black.
---
local function ResizeRaidFrames()
    if not CompactRaidFrameContainer then return end

    local optionsFrameName = "CompactUnitFrameProfilesGeneralOptionsFrame"
    local heightSlider = _G[optionsFrameName .. "HeightSlider"]
    local widthSlider  = _G[optionsFrameName .. "WidthSlider"]
    if heightSlider and widthSlider then
        heightSlider:SetMinMaxValues(1, 150)
        widthSlider:SetMinMaxValues(1, 150)
    end

    CompactRaidFrameContainer:SetScale(1.2)

    if CompactRaidFrameManager then
        for _, region in pairs({CompactRaidFrameManager:GetRegions()}) do
            if region:IsObjectType("Texture") then
                region:SetVertexColor(0, 0, 0)
            end
        end
    end

    if CompactRaidFrameManagerContainerResizeFrame then
        for _, region in pairs({CompactRaidFrameManagerContainerResizeFrame:GetRegions()}) do
            if region.GetName and region:GetName():find("Border") then
                region:SetVertexColor(0, 0, 0)
            end
        end
    end
end

---
-- Event handler for resizing raid frames on relevant UI events
-- Handles ADDON_LOADED, GROUP_ROSTER_UPDATE, and PLAYER_ENTERING_WORLD events.
---
local function OnEvent(self, event, addon)
    if event == "ADDON_LOADED" and addon == "Blizzard_CompactRaidFrames" then
        ResizeRaidFrames()
    elseif event == "GROUP_ROSTER_UPDATE" then
        C_Timer.After(1, ResizeRaidFrames)
    elseif event == "PLAYER_ENTERING_WORLD" then
        C_Timer.After(2, ResizeRaidFrames)
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("GROUP_ROSTER_UPDATE")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", OnEvent)
