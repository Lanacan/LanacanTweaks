----------------------
-- Lanacan Minimal Minimap
-- A minimalist reskin and repositioning of the World of Warcraft Classic minimap.
-- Features include:
-- - Scaled and repositioned minimap
-- - Hidden default clutter (buttons, borders, zone text)
-- - Custom mail icon styling
-- - Zone text displayed on mouse hover with PvP color coding
-- - Player coordinates displayed below the minimap
-- - Clock/calendar repositioned and styled
-- - Custom black border around the minimap
-- - Automatic zoom reset after 30 seconds of zoom activity
-- - LibDBIcon minimap buttons fade in/out on hover for cleaner appearance
----------------------

-- Configuration table holding all visual and positional settings for the minimap addon
local CONFIG = {
    scale = 1.3, -- Minimap scale factor
    position = {"TOPRIGHT", UIParent, -5, -10}, -- Minimap position on screen
    borderSize = 142, -- Size of the custom minimap border
    mailIcon = { -- Mail icon settings
        point = {"TOPRIGHT", Minimap, 0, 0},
        size = 27,
        alpha = 0.5,
        texture = "Interface\\MINIMAP\\TRACKING\\Mailbox"
    },
    clock = { -- Clock frame settings
        point = {"TOPLEFT", Minimap, "BOTTOMLEFT", 0, -5},
        scale = 1,
        font = {"Fonts\\FRIZQT__.TTF", 10, "OUTLINE"}
    },
    zoneText = { -- Zone text (subzone) display settings
        subFont = {"Fonts\\FRIZQT__.TTF", 10, "OUTLINE"},
        size = {130, 20}
    },
    coords = { -- Player coordinates display settings
        point = {"TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -5},
        font = {"Fonts\\FRIZQT__.TTF", 10, "OUTLINE"},
        size = {142, 12}
    }
}

-- Scale and reposition the minimap cluster and minimap itself
MinimapCluster:SetScale(CONFIG.scale)
Minimap:ClearAllPoints()
Minimap:SetPoint(unpack(CONFIG.position))

-- Hide default minimap UI elements to create a clean look
local elementsToHide = {
    MinimapBorder, MinimapBorderTop, MinimapZoomIn, MinimapZoomOut,
    MiniMapTracking, MinimapToggleButton, MinimapZoneText
}
for _, element in pairs(elementsToHide) do
    if element then
        element:Hide()
        element.Show = function() end -- Prevent elements from being shown again
    end
end

-- LFG Minimap eye toggle for Leatrix Plus compatibility
EventUtil.ContinueOnAddOnLoaded("Blizzard_GroupFinder_VanillaStyle", function()
    local function SetLFGButton()
        if C_LFGList.HasActiveEntryInfo() then
            LFGMinimapFrame:Show()
        else
            LFGMinimapFrame:Hide()
        end
    end
    LFGMinimapFrame:HookScript("OnEvent", SetLFGButton)
    SetLFGButton()
end)

-- Customize mail icon: reposition, resize, set texture and transparency, and hide default border
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint(unpack(CONFIG.mailIcon.point))
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture(CONFIG.mailIcon.texture)
MiniMapMailBorder:SetBlendMode("ADD")
MiniMapMailBorder:SetPoint("CENTER", MiniMapMailFrame, 0.5, 1.5)
MiniMapMailBorder:SetSize(CONFIG.mailIcon.size, CONFIG.mailIcon.size)
MiniMapMailBorder:SetAlpha(CONFIG.mailIcon.alpha)

-- Reparent and reposition the calendar/clock frame, scale and style its font
GameTimeFrame:SetParent(Minimap)
GameTimeFrame:SetScale(CONFIG.clock.scale)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint(unpack(CONFIG.clock.point))

-- Remove all textures from GameTimeFrame to clean up default clock graphics
for _, region in ipairs({GameTimeFrame:GetRegions()}) do
    if region:GetObjectType() == "Texture" then
        region:Hide()
    end
end

-- Create a custom font string inside GameTimeFrame to display clock text
local clockText = GameTimeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
clockText:ClearAllPoints()
clockText:SetPoint("TOPLEFT", GameTimeFrame, "TOPLEFT", 0, 0)
clockText:SetFont(unpack(CONFIG.clock.font))
clockText:SetJustifyH("LEFT")
clockText:SetJustifyV("TOP")

-- Create zone text that appears on mouse hover with color indicating PvP status
local function CreateZoneText()
    -- Determine color based on PvP zone type
    local function GetZoneColor()
        local pvpType = GetZonePVPInfo()
        if pvpType == "sanctuary" then return 0.4, 0.8, 0.94 end
        if pvpType == "arena" or pvpType == "hostile" then return 1, 0.1, 0.1 end
        if pvpType == "friendly" then return 0.1, 1, 0.1 end
        if pvpType == "contested" then return 1, 0.8, 0 end
        return 1, 1, 1
    end

    local subZone = Minimap:CreateFontString(nil, "OVERLAY")
    subZone:SetFont(unpack(CONFIG.zoneText.subFont))
    subZone:SetPoint("TOP", Minimap, "TOP", 0, 1)
    subZone:SetAlpha(0) -- Initially invisible
    subZone:SetSize(unpack(CONFIG.zoneText.size))
    subZone:SetJustifyH("CENTER")

    -- Show zone text with proper color on mouse enter
    Minimap:HookScript("OnEnter", function()
        local r, g, b = GetZoneColor()
        subZone:SetTextColor(r, g, b)
        subZone:SetText(GetSubZoneText() or "")
        subZone:SetAlpha(1)
    end)

    -- Hide zone text when mouse leaves minimap
    Minimap:HookScript("OnLeave", function()
        subZone:SetAlpha(0)
    end)
end

-- Create coordinate display below minimap that updates regularly
local function CreateCoords()
    local coordFrame = CreateFrame("Frame", "MinimapCoordsFrame", Minimap)
    coordFrame:SetSize(unpack(CONFIG.coords.size))
    coordFrame:SetPoint(unpack(CONFIG.coords.point))

    local coordText = coordFrame:CreateFontString(nil, "OVERLAY")
    coordText:SetFont(unpack(CONFIG.coords.font))
    coordText:SetPoint("TOPRIGHT", coordFrame, "TOPRIGHT", 0, 0)
    coordText:SetJustifyH("RIGHT")

    local currentMapID
    local function UpdateMapID()
        currentMapID = C_Map.GetBestMapForUnit("player")
    end

    local function GetCoords()
        if not currentMapID then return end
        local pos = C_Map.GetPlayerMapPosition(currentMapID, "player")
        if not pos then return end
        local x, y = pos:GetXY()
        if not x or not y or (x == 0 and y == 0) then return end
        return x * 100, y * 100
    end

    local function UpdateText()
        local x, y = GetCoords()
        if x and y then
            coordText:SetText(string.format("%.1f, %.1f", x, y))
        else
            coordText:SetText("???, ???")
        end
    end

    -- Update map ID and coordinates on zone change events
    coordFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    coordFrame:RegisterEvent("ZONE_CHANGED")
    coordFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    coordFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    coordFrame:SetScript("OnEvent", function()
        UpdateMapID()
        UpdateText()
    end)

    -- Update coordinates once per second
    coordFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer >= 1 then
            UpdateText()
            self.timer = 0
        end
    end)
end

-- Enable mouse wheel zooming on minimap and implement auto zoom reset after 30 seconds
Minimap:EnableMouseWheel(true)
local zoomResetFrame = CreateFrame("Frame")
local zoomResetTimer = 0
local zoomResetActive = false

-- Zoom in/out on mouse wheel scroll; start/reset zoom reset timer
Minimap:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 then
        MinimapZoomIn:Click()
    elseif delta < 0 then
        MinimapZoomOut:Click()
    end
    zoomResetTimer = 0
    zoomResetActive = true
    zoomResetFrame:Show()
end)

-- Right-click opens calendar, middle-click opens tracking dropdown, left-click opens minimap menu
Minimap:SetScript("OnMouseUp", function(_, button)
    if button == "RightButton" and GameTimeFrame and GameTimeFrame:IsVisible() then
        GameTimeFrame_OnClick(GameTimeFrame)
    elseif button == "MiddleButton" and MiniMapTrackingDropDown then
        ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, Minimap)
    else
        Minimap_OnClick(Minimap)
    end
end)

-- Zoom reset timer logic: zooms out fully after 30 seconds of inactivity
zoomResetFrame:SetScript("OnUpdate", function(self, elapsed)
    if zoomResetActive then
        zoomResetTimer = zoomResetTimer + elapsed
        if zoomResetTimer >= 30 then
            for i = 1, 5 do
                MinimapZoomOut:Click()
            end
            zoomResetActive = false
            self:Hide()
        end
    end
end)
zoomResetFrame:Hide()

-- Create a clean black border frame around the minimap
local function CreateBorder()
    local border = CreateFrame("Frame", "CleanMapBorder", Minimap)
    border:SetFrameLevel(0)
    border:SetSize(CONFIG.borderSize, CONFIG.borderSize)
    border:SetPoint("CENTER")

    -- Define border points and offsets for the black edges and corners
    local points = {
        {"TOPLEFT", -1, 1}, {"TOPRIGHT", 1, 1},
        {"BOTTOMLEFT", -1, -1}, {"BOTTOMRIGHT", 1, -1},
        {"LEFT", -1, 0}, {"RIGHT", 1, 0},
        {"TOP", 0, 1}, {"BOTTOM", 0, -1}
    }

    -- Create and position border textures for edges and corners
    for _, point in ipairs(points) do
        local tex = border:CreateTexture(nil, "BORDER")
        tex:SetTexture("Interface\\Buttons\\WHITE8x8")
        tex:SetVertexColor(0, 0, 0)
        tex:SetPoint(point[1], border, point[2], point[3])

        if point[1] == "TOP" or point[1] == "BOTTOM" then
            tex:SetSize(CONFIG.borderSize, 1) -- Horizontal lines
        elseif point[1] == "LEFT" or point[1] == "RIGHT" then
            tex:SetSize(1, CONFIG.borderSize) -- Vertical lines
        else
            tex:SetSize(1, 1) -- Corners
        end
    end

    -- Create a solid black background layer
    local bg = border:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    bg:SetVertexColor(0, 0, 0, 1)

    -- Set minimap mask texture to square to avoid default circular mask
    Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8x8")
end

-- Setup fading behavior for LibDBIcon minimap buttons (fade out by default, fade in on hover)
local function SetupButtonFader()
    local buttons = {}

    -- Configure fading scripts for each minimap button
    local function SetupButton(button)
        if button and button.SetAlpha then
            table.insert(buttons, button)
            button:SetAlpha(0) -- Start hidden
            button:SetScript("OnEnter", function(self)
                UIFrameFadeIn(self, 0.5, self:GetAlpha(), 1)
            end)
            button:SetScript("OnLeave", function(self)
                UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0)
            end)
        end
    end

    -- Apply to all existing minimap children matching LibDBIcon pattern
    for _, child in ipairs({Minimap:GetChildren()}) do
        if child:GetName() and child:GetName():find("LibDBIcon") then
            SetupButton(child)
        end
    end

    -- Register callback to fade in buttons created later by LibDBIcon
    if LibStub and LibStub("LibDBIcon-1.0", true) then
        local LDBI = LibStub("LibDBIcon-1.0")
        LDBI.RegisterCallback("MinimapButtonFader", "LibDBIcon_IconCreated", function(_, _, name)
            SetupButton(_G[name])
        end)
    end
end

-- Initialize addon features on PLAYER_LOGIN event
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    CreateZoneText()
    CreateCoords()
    CreateBorder()
    SetupButtonFader()

    -- Further customize the default TimeManager clock if present
    if TimeManagerClockButton then
        TimeManagerClockButton:GetRegions():Hide()
        TimeManagerClockButton:SetParent(Minimap)
        TimeManagerClockButton:SetScale(CONFIG.clock.scale)
        TimeManagerClockButton:ClearAllPoints()
        TimeManagerClockButton:SetPoint(unpack(CONFIG.clock.point))

        TimeManagerClockTicker:ClearAllPoints()
        TimeManagerClockTicker:SetPoint("TOPLEFT", TimeManagerClockButton, "TOPLEFT", 0, 0)
        TimeManagerClockTicker:SetFont(unpack(CONFIG.clock.font))
        TimeManagerClockTicker:SetTextColor(1, 1, 1, 1)
        TimeManagerClockTicker:SetJustifyH("LEFT")
        TimeManagerClockTicker:SetJustifyV("TOP")
    end
end)
