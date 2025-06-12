-- Font settings
local font = "Fonts\\FRIZQT__.TTF"
local fontSize = 10  -- Adjust this value to your preferred size
local fontFlags = "OUTLINE"
local fontColor = {1, 1, 1, 1}  -- White (R,G,B,Alpha)

-- Backdrop settings for buff frame borders
-- Defines a simple border style to be used as shadow/backdrop around buff/debuff icons
local backdrop = {
  bgFile = nil,                               -- No background texture, only border
  edgeFile = "Interface\\Buttons\\WHITE8X8", -- White square texture for border edges
  tile = false,                               -- Don't tile the edge texture
  tileSize = 32,                              -- Size for tiling if enabled (not used here)
  edgeSize = 1,                               -- Border thickness of 1 pixel
  insets = { left = 0, right = 0, top = 0, bottom = 0 }, -- No inset padding
}

-- Function to apply font settings to text elements
local function setupFont(textElement)
    if textElement then
        textElement:SetFont(font, fontSize, fontFlags)
        textElement:SetTextColor(unpack(fontColor))
    end
end

-- Applies visual styling to a buff/debuff button
-- This function customizes appearance by:
-- - resizing the button
-- - cropping and repositioning the icon texture
-- - coloring the border (purple for weapon enchants, black for regular buffs)
-- - adding a shadow/backdrop frame behind the button
-- - applying font settings to duration and count text
local function applySkin(b)
    if not b or b.styled then return end  -- Exit if button is nil or already styled

    local name = b:GetName()
    if not name then return end            -- Exit if button has no name

    -- Determine if this button is a temporary weapon enchant or a debuff by name pattern
    local tempenchant = name:match("TempEnchant") ~= nil
    local debuff = name:match("Debuff") ~= nil

    -- Set fixed button size to ensure uniform appearance
    b:SetSize(32, 32)

    -- Icon styling: crop and reposition to fit nicely within button borders
    local icon = _G[name .. "Icon"]
    if icon then
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9) -- Crop edges for a cleaner look
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)     -- Small offset for padding
        icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    end
    b.icon = icon

    -- Border texture creation or retrieval
    local border = _G[name .. "Border"] or b:CreateTexture(name .. "Border", "BACKGROUND", nil, -7)
    border:SetTexture("Interface\\Buttons\\WHITE8X8") -- Use white square texture for border
    border:SetTexCoord(0, 1, 0, 1)
    border:SetDrawLayer("BACKGROUND", -7)             -- Draw behind most UI elements

    -- Set border color depending on buff type:
    -- Purple for weapon temporary enchants, black for normal buffs
    if tempenchant then
        border:SetVertexColor(0.7, 0, 1) -- Purple
    elseif not debuff then
        border:SetVertexColor(0, 0, 0)   -- Black
    end
    border:SetAllPoints(b)               -- Make border cover entire button area
    b.border = border

    -- Shadow/backdrop frame behind the buff button for visual depth
    local shadow = CreateFrame("Frame", nil, b, BackdropTemplateMixin and "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    shadow:SetFrameLevel(b:GetFrameLevel() - 1) -- Place behind the buff button
    shadow:SetBackdrop(backdrop)                 -- Apply the border backdrop style
    shadow:SetBackdropBorderColor(0, 0, 0, 1)   -- Solid black border color
    b.bg = shadow

    -- Apply font settings to duration and count text
    local duration = _G[name .. "Duration"]
    if duration then
        setupFont(duration)
        duration:ClearAllPoints()
        duration:SetPoint("BOTTOM", b, "BOTTOM", 0, -2) -- Adjust position if needed
    end

    local count = _G[name .. "Count"]
    if count then
        setupFont(count)
        count:ClearAllPoints()
        count:SetPoint("TOPRIGHT", b, "TOPRIGHT", -2, -2) -- Adjust position if needed
        count:SetJustifyH("RIGHT")
    end

    b.styled = true -- Mark button as styled to avoid redundant styling
end

-- Updates all buff button anchors and applies skins
-- Loops through all displayed buffs and temporary weapon enchants
-- Applies our custom skin styling to any buttons not already styled
local function updateAllBuffAnchors()
    local numBuffs = BUFF_ACTUAL_DISPLAY or 0 -- Number of buffs currently displayed
    for i = 1, numBuffs do
        local button = _G["BuffButton" .. i]
        if button and not button.styled then
            applySkin(button)
        end
    end

    -- Handle temporary weapon enchants (like sharpening stones or poisons)
    for i = 1, (BuffFrame.numEnchants or 0) do
        local button = _G["TempEnchant" .. i]
        if button and not button.styled then
            applySkin(button)
        end
    end
end

-- Updates debuff button anchors and applies skins
-- Called when debuff buttons are updated, styling any new debuff buttons found
local function updateDebuffAnchors(name, i)
    local button = _G[name .. i]
    if button and not button.styled then
        applySkin(button)
    end
end

-- Positions the entire buff frame near the minimap
-- Clears existing positioning and sets a fixed position and scale near the Minimap frame
local function positionBuffFrame()
    BuffFrame:ClearAllPoints()
    BuffFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 2)
    BuffFrame:SetScale(1)
end

-- Hook into Blizzard's functions to apply our custom styling dynamically
-- Hooks into buff and debuff update functions to apply skins automatically
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)

-- Initialize styling and positioning on player entering the world
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    positionBuffFrame()    -- Position buff frame near minimap on login
    updateAllBuffAnchors() -- Apply skins to all existing buffs on login
end)