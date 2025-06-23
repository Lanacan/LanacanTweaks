----------------------
-- Lanacan Buff Styler
-- WoW Classic Addon to reposition and reskin buffs, debuffs, and weapon enchants.
-- Applies custom font, border, and layout styling to improve visibility and aesthetics.
----------------------

-- Font settings
local font = "Fonts\\FRIZQT__.TTF"
local fontSize = 10  -- Font size for count and duration text
local fontFlags = "OUTLINE"
local fontColor = {1, 1, 1, 1}  -- White (RGBA)

-- Backdrop settings used for a shadow-like border around each buff button
local backdrop = {
  bgFile = nil,
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  tile = false,
  tileSize = 32,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- Applies font settings to text elements (e.g., duration and stack count)
local function setupFont(textElement)
    if textElement then
        textElement:SetFont(font, fontSize, fontFlags)
        textElement:SetTextColor(unpack(fontColor))
    end
end

-- Applies custom skinning (size, borders, shadows, font) to a buff/debuff/ench button
local function applySkin(b)
    if not b or b.styled then return end

    local name = b:GetName()
    if not name then return end

    local tempenchant = name:match("TempEnchant") ~= nil
    local debuff = name:match("Debuff") ~= nil

    b:SetSize(32, 32)  -- Standardized button size

    -- Style the icon texture
    local icon = _G[name .. "Icon"]
    if icon then
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
        icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    end
    b.icon = icon

    -- Style the border (used for color-coding)
    local border = _G[name .. "Border"] or b:CreateTexture(name .. "Border", "BACKGROUND", nil, -7)
    border:SetTexture("Interface\\Buttons\\WHITE8X8")
    border:SetTexCoord(0, 1, 0, 1)
    border:SetDrawLayer("BACKGROUND", -7)

    if tempenchant then
        border:SetVertexColor(0.7, 0, 1) -- Purple for enchants
    elseif not debuff then
        border:SetVertexColor(0, 0, 0)   -- Black for standard buffs
    end
    border:SetAllPoints(b)
    b.border = border

    -- Adds a background shadow-style frame
    local shadow = CreateFrame("Frame", nil, b, BackdropTemplateMixin and "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    shadow:SetFrameLevel(b:GetFrameLevel() - 1)
    shadow:SetBackdrop(backdrop)
    shadow:SetBackdropBorderColor(0, 0, 0, 1)
    b.bg = shadow

    -- Style duration text
    local duration = _G[name .. "Duration"]
    if duration then
        setupFont(duration)
        duration:ClearAllPoints()
        duration:SetPoint("BOTTOM", b, "BOTTOM", 0, -2)
    end

    -- Style stack count text
    local count = _G[name .. "Count"]
    if count then
        setupFont(count)
        count:ClearAllPoints()
        count:SetPoint("TOPRIGHT", b, "TOPRIGHT", -2, -2)
        count:SetJustifyH("RIGHT")
    end

    b.styled = true
end

-- Custom update function to reskin and reposition all buff and enchant buttons
local function updateAllBuffAnchors()
    local numBuffs = BUFF_ACTUAL_DISPLAY or 0
    local numEnchants = BuffFrame.numEnchants or 0
    local gapBetweenEnchantsAndBuffs = 10  -- Custom gap
    local barPadding = 4  -- Padding between buttons

    -- Skin all buff buttons
    for i = 1, numBuffs do
        local button = _G["BuffButton"..i]
        if button and not button.styled then
            applySkin(button)
        end
    end

    -- Skin all temporary enchant buttons
    for i = 1, numEnchants do
        local button = _G["TempEnchant"..i]
        if button and not button.styled then
            applySkin(button)
        end
    end

    -- Position temp enchants
    local prevEnchant
    for i = 1, numEnchants do
        local button = _G["TempEnchant"..i]
        if button then
            button:ClearAllPoints()
            if i == 1 then
                button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
            else
                button:SetPoint("TOPRIGHT", prevEnchant, "TOPLEFT", -barPadding, 0)
            end
            prevEnchant = button
        end
    end

    -- Position buff buttons with spacing after enchants
    for i = 1, numBuffs do
        local button = _G["BuffButton"..i]
        if button then
            button:ClearAllPoints()
            if i == 1 then
                if numEnchants > 0 then
                    local lastEnchant = _G["TempEnchant"..numEnchants]
                    button:SetPoint("TOPRIGHT", lastEnchant, "TOPLEFT", -gapBetweenEnchantsAndBuffs, 0)
                else
                    button:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
                end
            else
                local prevBuff = _G["BuffButton"..(i-1)]
                button:SetPoint("TOPRIGHT", prevBuff, "TOPLEFT", -barPadding, 0)
            end
        end
    end
end

-- Skin and anchor a debuff button
local function updateDebuffAnchors(name, i)
    local button = _G[name .. i]
    if button and not button.styled then
        applySkin(button)
    end
end

-- Move the entire BuffFrame to a custom position near the minimap
local function positionBuffFrame()
    BuffFrame:ClearAllPoints()
    BuffFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 2)
    BuffFrame:SetScale(1)
end

-- Hook into Blizzard's update functions to override the default layout/skin
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)

-- Initialize everything when the player enters the world
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    positionBuffFrame()
    updateAllBuffAnchors()
end)
