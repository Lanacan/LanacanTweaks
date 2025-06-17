-- Font settings
local font = "Fonts\\FRIZQT__.TTF"
local fontSize = 10  -- Adjust this value to your preferred size
local fontFlags = "OUTLINE"
local fontColor = {1, 1, 1, 1}  -- White (R,G,B,Alpha)

-- Backdrop settings for buff frame borders
local backdrop = {
  bgFile = nil,
  edgeFile = "Interface\\Buttons\\WHITE8X8",
  tile = false,
  tileSize = 32,
  edgeSize = 1,
  insets = { left = 0, right = 0, top = 0, bottom = 0 },
}

-- Function to apply font settings to text elements
local function setupFont(textElement)
    if textElement then
        textElement:SetFont(font, fontSize, fontFlags)
        textElement:SetTextColor(unpack(fontColor))
    end
end

-- Applies visual styling to a buff/debuff button
local function applySkin(b)
    if not b or b.styled then return end

    local name = b:GetName()
    if not name then return end

    local tempenchant = name:match("TempEnchant") ~= nil
    local debuff = name:match("Debuff") ~= nil

    b:SetSize(32, 32)

    local icon = _G[name .. "Icon"]
    if icon then
        icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        icon:ClearAllPoints()
        icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)     -- Small offset for padding
        icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    end
    b.icon = icon

    local border = _G[name .. "Border"] or b:CreateTexture(name .. "Border", "BACKGROUND", nil, -7)
    border:SetTexture("Interface\\Buttons\\WHITE8X8")
    border:SetTexCoord(0, 1, 0, 1)
    border:SetDrawLayer("BACKGROUND", -7)

    if tempenchant then
        border:SetVertexColor(0.7, 0, 1) -- Purple
    elseif not debuff then
        border:SetVertexColor(0, 0, 0)   -- Black
    end
    border:SetAllPoints(b)
    b.border = border

    local shadow = CreateFrame("Frame", nil, b, BackdropTemplateMixin and "BackdropTemplate")
    shadow:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
    shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
    shadow:SetFrameLevel(b:GetFrameLevel() - 1)
    shadow:SetBackdrop(backdrop)
    shadow:SetBackdropBorderColor(0, 0, 0, 1)
    b.bg = shadow

    local duration = _G[name .. "Duration"]
    if duration then
        setupFont(duration)
        duration:ClearAllPoints()
        duration:SetPoint("BOTTOM", b, "BOTTOM", 0, -2)
    end

    local count = _G[name .. "Count"]
    if count then
        setupFont(count)
        count:ClearAllPoints()
        count:SetPoint("TOPRIGHT", b, "TOPRIGHT", -2, -2)
        count:SetJustifyH("RIGHT")
    end

    b.styled = true
end

-- Updated updateAllBuffAnchors with larger gap between enchants and buffs
local function updateAllBuffAnchors()
    local numBuffs = BUFF_ACTUAL_DISPLAY or 0
    local numEnchants = BuffFrame.numEnchants or 0
    local gapBetweenEnchantsAndBuffs = 10 -- Bigger gap here
    local barPadding = 4 -- Use your existing padding (or adjust)

    -- Skin all buffs
    for i = 1, numBuffs do
        local button = _G["BuffButton"..i]
        if button and not button.styled then
            applySkin(button)
        end
    end

    -- Skin all temp enchants
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

    -- Position buffs with larger gap after enchants
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

-- Updates debuff anchors and skins them
local function updateDebuffAnchors(name, i)
    local button = _G[name .. i]
    if button and not button.styled then
        applySkin(button)
    end
end

-- Position the entire buff frame near minimap
local function positionBuffFrame()
    BuffFrame:ClearAllPoints()
    BuffFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, 2)
    BuffFrame:SetScale(1)
end

-- Hook into Blizzard update functions to apply styling and positioning
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", updateAllBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", updateDebuffAnchors)

-- Initialize styling and positioning on login
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
    positionBuffFrame()
    updateAllBuffAnchors()
end)
