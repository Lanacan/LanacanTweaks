-- Raid Frame Resizer for WoW Classic
local frame = CreateFrame("Frame")

-- Main function to resize and recolor raid frames and related UI elements
local function ResizeRaidFrames()
    -- Exit early if the main raid frame container isn't loaded yet
    if not CompactRaidFrameContainer then return end
    
    -- Adjust size sliders for raid frames if they exist (mostly for newer versions, may not exist in Classic)
    local n = "CompactUnitFrameProfilesGeneralOptionsFrame"
    if _G[n.."HeightSlider"] and _G[n.."WidthSlider"] then
        -- Set slider min/max to allow a wide range of resizing
        _G[n.."HeightSlider"]:SetMinMaxValues(1, 150)
        _G[n.."WidthSlider"]:SetMinMaxValues(1, 150)
    end
    
    -- Set the scale of the entire raid frame container (makes frames bigger/smaller)
    CompactRaidFrameContainer:SetScale(1.2)
    
    -- Change background color of the raid frame manager to black for better visibility
    if CompactRaidFrameManager then
        for _, region in pairs({CompactRaidFrameManager:GetRegions()}) do
            if region:IsObjectType("Texture") then
                region:SetVertexColor(0, 0, 0)  -- Black color
            end
        end
    end
    
    -- Color the border of the resize frame black if it exists
    if CompactRaidFrameManagerContainerResizeFrame then
        for _, region in pairs({CompactRaidFrameManagerContainerResizeFrame:GetRegions()}) do
            if region.GetName and region:GetName():find("Border") then
                region:SetVertexColor(0, 0, 0)  -- Black border color
            end
        end
    end
end

-- Register events to detect when to resize raid frames
frame:RegisterEvent("ADDON_LOADED")         -- Fires when an addon loads
frame:RegisterEvent("GROUP_ROSTER_UPDATE")  -- Fires when group/raid composition changes (important for Classic)

-- Event handler function for ADDON_LOADED and GROUP_ROSTER_UPDATE
frame:SetScript("OnEvent", function(self, event, addon)
    if event == "ADDON_LOADED" and addon == "Blizzard_CompactRaidFrames" then
        -- When the Blizzard raid frames addon loads, run resize function
        ResizeRaidFrames()
    elseif event == "GROUP_ROSTER_UPDATE" then
        -- When group/raid changes, delay slightly and then resize to ensure frames exist
        C_Timer.After(1, ResizeRaidFrames)
    end
end)

-- Also try to resize once when player enters the world
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Delay to make sure UI is fully loaded, then resize raid frames
        C_Timer.After(2, ResizeRaidFrames)
        -- Unregister this event since we only need it once
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)
