-------------
-- MINIMAP --
-------------

-- Configuration
local CONFIG = {
    scale = 1.3,
    position = {"TOPRIGHT", UIParent, -5, -10},
    borderSize = 142,
    mailIcon = {
        point = {"TOPRIGHT", Minimap, 0, 0},
        size = 27,
        alpha = 0.5,
        texture = "Interface\\MINIMAP\\TRACKING\\Mailbox"
    },
    clock = {
        point = {"TOPLEFT", Minimap, "BOTTOMLEFT", 0, -5}, -- updated anchor
        scale = 1,
        font = {"Fonts\\FRIZQT__.TTF", 10, "OUTLINE"}         -- font size updated to 12
    },
    zoneText = {
        subFont = {"Fonts\\FRIZQT__.TTF", 12, "OUTLINE"},
        size = {130, 20}
    },
    coords = {
        point = {"TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -5}, -- updated anchor
        font = {"Fonts\\FRIZQT__.TTF", 10, "OUTLINE"},          -- font size updated to 12
        size = {142, 12}
    }
}

-- Initialize Minimap
MinimapCluster:SetScale(CONFIG.scale)
Minimap:ClearAllPoints()
Minimap:SetPoint(unpack(CONFIG.position))

-- Hide Default Elements
local elementsToHide = {
    MinimapBorder,
    MinimapBorderTop,
    MinimapZoomIn,
    MinimapZoomOut,
    MiniMapTracking,
    MinimapToggleButton,
    MinimapZoneText
}

for _, element in pairs(elementsToHide) do
    if element then
        element:Hide()
        element.Show = function() end
    end
end

-- LFG Eye (Leatrix Plus style)
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

-- Mail Icon Setup
MiniMapMailFrame:ClearAllPoints()
MiniMapMailFrame:SetPoint(unpack(CONFIG.mailIcon.point))
MiniMapMailBorder:Hide()
MiniMapMailIcon:SetTexture(CONFIG.mailIcon.texture)
MiniMapMailBorder:SetBlendMode("ADD")
MiniMapMailBorder:ClearAllPoints()
MiniMapMailBorder:SetPoint("CENTER", MiniMapMailFrame, 0.5, 1.5)
MiniMapMailBorder:SetSize(CONFIG.mailIcon.size, CONFIG.mailIcon.size)
MiniMapMailBorder:SetAlpha(CONFIG.mailIcon.alpha)

-- Calendar/Clock Setup
GameTimeFrame:SetParent(Minimap)
GameTimeFrame:SetScale(CONFIG.clock.scale)
GameTimeFrame:ClearAllPoints()
GameTimeFrame:SetPoint(unpack(CONFIG.clock.point))

-- Hide all GameTimeFrame textures
for _, region in ipairs({GameTimeFrame:GetRegions()}) do
    if region:GetObjectType() == "Texture" then
        region:Hide()
    end
end

-- Create custom clock text properly anchored
local clockText = GameTimeFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
clockText:ClearAllPoints()
clockText:SetPoint("TOPLEFT", GameTimeFrame, "TOPLEFT", 0, 0) -- align top-left corner of text
clockText:SetFont(unpack(CONFIG.clock.font))
clockText:SetJustifyH("LEFT")
clockText:SetJustifyV("TOP")

-- Zone Text (Subzone only on hover)
local function CreateZoneText()
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
    subZone:SetTextColor(1, 1, 1)
    subZone:SetAlpha(0)
    subZone:SetSize(unpack(CONFIG.zoneText.size))
    subZone:SetJustifyH("CENTER")

    Minimap:HookScript("OnEnter", function()
        local r, g, b = GetZoneColor()
        subZone:SetTextColor(r, g, b)
        subZone:SetText(GetSubZoneText() or "")
        subZone:SetAlpha(1)
    end)

    Minimap:HookScript("OnLeave", function()
        subZone:SetAlpha(0)
    end)
end

-- Coordinate Display
local function CreateCoords()
    local coordFrame = CreateFrame("Frame", "MinimapCoordsFrame", Minimap)
    coordFrame:SetSize(unpack(CONFIG.coords.size))
    coordFrame:SetPoint(unpack(CONFIG.coords.point))

    local coordText = coordFrame:CreateFontString(nil, "OVERLAY")
    coordText:SetFont(unpack(CONFIG.coords.font))
	coordText:ClearAllPoints()
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

    coordFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    coordFrame:RegisterEvent("ZONE_CHANGED")
    coordFrame:RegisterEvent("ZONE_CHANGED_INDOORS")
    coordFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    coordFrame:SetScript("OnEvent", function()
        UpdateMapID()
        UpdateText()
    end)

    coordFrame:SetScript("OnUpdate", function(self, elapsed)
        self.timer = (self.timer or 0) + elapsed
        if self.timer >= 1 then
            UpdateText()
            self.timer = 0
        end
    end)
end

-- Mouse Controls
Minimap:EnableMouseWheel(true)

local zoomResetFrame = CreateFrame("Frame")
local zoomResetTimer = 0
local zoomResetActive = false

Minimap:SetScript("OnMouseWheel", function(_, delta)
    if delta > 0 then
        MinimapZoomIn:Click()
    elseif delta < 0 then
        MinimapZoomOut:Click()
    end

    -- Reset the timer on any scroll
    zoomResetTimer = 0
    zoomResetActive = true
    zoomResetFrame:Show()
end)

Minimap:SetScript("OnMouseUp", function(_, button)
    if button == "RightButton" then
        if GameTimeFrame and GameTimeFrame:IsVisible() and GameTimeFrame_OnClick then
            GameTimeFrame_OnClick(GameTimeFrame)
        end
    elseif button == "MiddleButton" then
        if MiniMapTrackingDropDown then
            ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, Minimap)
        end
    else
        Minimap_OnClick(Minimap)
    end
end)

zoomResetFrame:SetScript("OnUpdate", function(self, elapsed)
    if zoomResetActive then
        zoomResetTimer = zoomResetTimer + elapsed
        if zoomResetTimer >= 30 then
            -- Auto zoom all the way out
            for i = 1, 5 do
                MinimapZoomOut:Click()
            end
            zoomResetActive = false
            self:Hide()
        end
    end
end)
zoomResetFrame:Hide() -- Don't run until needed


-- Custom Border
local function CreateBorder()
    local border = CreateFrame("Frame", "CleanMapBorder", Minimap)
    border:SetFrameLevel(0)
    border:SetSize(CONFIG.borderSize, CONFIG.borderSize)
    border:SetPoint("CENTER")

    local points = {
        {"TOPLEFT", -1, 1}, {"TOPRIGHT", 1, 1},
        {"BOTTOMLEFT", -1, -1}, {"BOTTOMRIGHT", 1, -1},
        {"LEFT", -1, 0}, {"RIGHT", 1, 0},
        {"TOP", 0, 1}, {"BOTTOM", 0, -1}
    }

    for _, point in ipairs(points) do
        local tex = border:CreateTexture(nil, "BORDER")
        tex:SetTexture("Interface\\Buttons\\WHITE8x8")
        tex:SetVertexColor(0, 0, 0)
        tex:SetPoint(point[1], border, point[2], point[3])

        if point[1] == "TOP" or point[1] == "BOTTOM" then
            tex:SetSize(CONFIG.borderSize, 1)
        elseif point[1] == "LEFT" or point[1] == "RIGHT" then
            tex:SetSize(1, CONFIG.borderSize)
        else
            tex:SetSize(1, 1)
        end
    end

    local bg = border:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    bg:SetVertexColor(0, 0, 0, 1)

    Minimap:SetMaskTexture("Interface\\Buttons\\WHITE8x8")
end

-- Minimap Button Fader
local function SetupButtonFader()
    local buttons = {}

    local function SetupButton(button)
        if button and button.SetAlpha then
            table.insert(buttons, button)
            button:SetAlpha(0)
            button:SetScript("OnEnter", function(self)
                UIFrameFadeIn(self, 0.5, self:GetAlpha(), 1)
            end)
            button:SetScript("OnLeave", function(self)
                UIFrameFadeOut(self, 0.5, self:GetAlpha(), 0)
            end)
        end
    end

    for _, child in ipairs({Minimap:GetChildren()}) do
        if child:GetName() and child:GetName():find("LibDBIcon") then
            SetupButton(child)
        end
    end

    if LibStub and LibStub("LibDBIcon-1.0", true) then
        local LDBI = LibStub("LibDBIcon-1.0")
        LDBI.RegisterCallback("MinimapButtonFader", "LibDBIcon_IconCreated", function(_, _, name)
            SetupButton(_G[name])
        end)
    end
end

-- Final Init
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("PLAYER_LOGIN")
initFrame:SetScript("OnEvent", function()
    CreateZoneText()
    CreateCoords()
    CreateBorder()
    SetupButtonFader()

    -- TimeManager Clock
	if TimeManagerClockButton then
		TimeManagerClockButton:GetRegions():Hide()
		TimeManagerClockButton:SetParent(Minimap)
		TimeManagerClockButton:SetScale(CONFIG.clock.scale)
		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint(unpack(CONFIG.clock.point)) -- uses your config: bottomleft -2

		-- Adjust the built-in clock text directly
		TimeManagerClockTicker:ClearAllPoints()
		TimeManagerClockTicker:SetPoint("TOPLEFT", TimeManagerClockButton, "TOPLEFT", 0, 0)
		TimeManagerClockTicker:SetFont(unpack(CONFIG.clock.font))
		TimeManagerClockTicker:SetTextColor(1, 1, 1, 1)
		TimeManagerClockTicker:SetJustifyH("LEFT")
		TimeManagerClockTicker:SetJustifyV("TOP")
	end
end)
