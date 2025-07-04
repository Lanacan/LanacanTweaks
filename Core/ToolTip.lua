----------------------
-- Zarem Tooltip (Reworked by Vranx)
-- https://www.wowinterface.com/downloads/info26383-ZaremTooltip.html
--
-- This addon enhances and customizes the default World of Warcraft tooltip behavior.
-- Features include class- and reaction-based styling, item quality borders,
-- guild and title display, health bar customization, and cursor anchoring.
-- It provides a slash command interface for enabling mouse anchor mode and for moving
-- the tooltip via a draggable frame.
-- All configuration options are managed in the `config` table.
----------------------

local _G, ipairs, format, strfind = _G, ipairs, format, strfind
local GameTooltip, GameTooltipStatusBar, ItemRefTooltip = GameTooltip, GameTooltipStatusBar, ItemRefTooltip
local GameTooltipTextLeft1, GameTooltipTextLeft2 = GameTooltipTextLeft1, GameTooltipTextLeft2

-- Configuration table holding all visual and behavioral settings for the tooltip
local config = {
    bg = {0.08,0.08,0.1,0.8},            -- Tooltip background color RGBA
    border = {0.1,0.1,0.1},               -- Tooltip border color RGB
    health = { 0, 1, 0 },                 -- Default health bar color (green)

    classBorder = false,                  -- Use class color for tooltip border
    classBg = false,                      -- Use class color for tooltip background
    classNames = true,                    -- Color player names by class
    classHealth = true,                   -- Color health bar by class

    reactionBorder = false,               -- Use reaction color for tooltip border
    reactionBg = false,                   -- Use reaction color for tooltip background
    reactionGuild = true,                 -- Color guild names by reaction
    reactionHealth = true,                -- Color health bar by reaction

    itemBorder = true,                    -- Color item tooltip border by quality
    itemBg = false,                       -- Color item tooltip background by quality

    scale = 1.2,                         -- Tooltip scale multiplier

    font = STANDARD_TEXT_FONT,
    fontHeaderSize = 14,
    fontSize = 12,

    outlineFontHeader = true,             -- Use outlined font for header text
    outlineFont = false,                  -- Use outlined font for tooltip text

    healthHeight = 6,                     -- Height of the health bar
    healthTexture = "Interface\\TargetingFrame\\UI-StatusBar", -- Texture used for health bar
    healthInside = true,                  -- Position health bar inside tooltip frame at top
    padding = 0,                         -- Padding around tooltip content

    -- Mouse anchor position for tooltips when following cursor
    mouseAnchorPos = { "ANCHOR_CURSOR_RIGHT", 24, 5 }, -- Position, offsetX, offsetY

    instantFade = true,                   -- Instantly fade tooltip when mouse leaves
    hideInCombat = false,                 -- Hide tooltip during combat
    hideHealthBar = false,                -- Hide health bar

    playerTitle = false,                  -- Show player titles
    playerRealm = true,                   -- Show player realm name
    guildRank = true,                     -- Show guild rank text
    guildRankIndex = false,               -- Show guild rank index
    pvpText = false,                     -- Show reaction-colored PVP text

    -- Text strings marking player statuses
    youText = format(">>%s<<", strupper(YOU)),
    afkText = "|cff909090 <AFK>",
    dndText = "|cff909090 <DND>",
    dcText = "|cff909090 <DC>",
    targetText = "|cffffffff@",

    yourGuild = false,                    -- Special color for your own guild
    yourGuildColor = { 1, 0.3, 1 }, 
    guildColor = { 1, 0.3, 1 },
    gRankColor = "|cff909090",

    -- Special level and classification labels
    bossLevel = "|r|cffff0000??",
    bossClass = format(" (%s)", BOSS),
    eliteClass = "+",
    rareClass = format(" |cffff00da%s", ITEM_QUALITY3_DESC),
    rareEliteClass = format("+ |cffff00da%s", ITEM_QUALITY3_DESC),

    -- Backdrop (background + border) style for tooltips
    backdrop = {
        bgFile = "Interface\\Buttons\\WHITE8X8",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 },
    },
}

-- Table mapping unit reaction levels to RGB colors for consistent coloring
local REACTION_COLORS = {
    [1] = {r = 0.75,  g = 0.15,  b = 0.15}, -- Hostile dark red
    [2] = {r = 0.75,  g = 0.15,  b = 0.15}, -- Hostile dark red
    [3] = {r = 0.75,  g = 0.27,  b = 0},    -- Neutral orange
    [4] = {r = 0.9,   g = 0.8,   b = 0.3},  -- Friendly yellow
    [5] = {r = 0,     g = 0.8,   b = 0},    -- Friendly green
    [6] = {r = 0,     g = 0.8,   b = 0},
    [7] = {r = 0,     g = 0.8,   b = 0},
    [8] = {r = 0,     g = 0.8,   b = 0},
    [9] = {r = 0.5,   g = 0.5,   b = 0.5},  -- Dead/gray
}

-- Configure the GameTooltip health bar texture and size per config settings
GameTooltipStatusBar:SetStatusBarTexture(config.healthTexture)
GameTooltipStatusBar:SetHeight(config.healthHeight)

-- Position health bar inside tooltip frame at top if enabled in config
if config.healthInside then
    GameTooltipStatusBar:ClearAllPoints()
    GameTooltipStatusBar:SetPoint("LEFT", 5, 0)
    GameTooltipStatusBar:SetPoint("RIGHT", -5, 0)
    GameTooltipStatusBar:SetPoint("TOP", 0, -2.5)
end

do
    -- Setup a movable frame for repositioning the tooltip on screen
    if not ZaremTooltipAnchor then
        -- Saved anchor info (defaults)
        ZaremTooltipAnchor = {
            point = "BOTTOMRIGHT",
            relativePoint = "BOTTOMRIGHT",
            xOffset = "-95",
            yOffset = "110",
        }
    end

    local moverFrame = CreateFrame("Frame", nil, UIParent)
    moverFrame:SetFrameStrata("TOOLTIP")
    moverFrame:SetMovable(true)
    moverFrame:EnableMouse(true)
    moverFrame:RegisterForDrag("LeftButton")
    moverFrame:SetClampedToScreen(true)
    moverFrame:Hide()

    -- Start moving on drag
    moverFrame:SetScript("OnDragStart", function(self)
        self:StartMoving()
    end)

    -- Stop moving and save anchor on drag end
    moverFrame:SetScript("OnDragStop", function(self)
        self:StopMovingOrSizing()
        local point, _, relativePoint, xOffset, yOffset = self:GetPoint()
        ZaremTooltipAnchor.point = point
        ZaremTooltipAnchor.relativePoint = relativePoint
        ZaremTooltipAnchor.xOffset = xOffset
        ZaremTooltipAnchor.yOffset = yOffset
    end)

    moverFrame:SetPoint("CENTER")
    moverFrame:SetSize(180, 80)

    local texture = moverFrame:CreateTexture(nil, "ARTWORK")
    texture:SetAllPoints()
    texture:SetColorTexture(0, 0.8, 0, 0.6) -- Semi-transparent green box for mover

    -- Slash commands to toggle mover frame and mouse anchor mode
    SLASH_ZAREMTOOLTIP1 = "/zaremtooltip"
    SLASH_ZAREMTOOLTIP2 = "/ztt"
    SlashCmdList["ZAREMTOOLTIP"] = function(msg)
        if msg == "mouse" then
            if not ZaremTooltipAnchor.mouse then
                ZaremTooltipAnchor.mouse = true
            else
                ZaremTooltipAnchor.mouse = nil
            end
        else
            if moverFrame:IsShown() then
                moverFrame:Hide()
            else
                moverFrame:Show()
            end
        end
    end
end

-- Hook GameTooltip default anchor to support repositioning and mouse anchoring
hooksecurefunc("GameTooltip_SetDefaultAnchor", function(self, parent)
    self:ClearAllPoints()

    local mouseFocus = GetMouseFoci()
    -- If mouse anchoring enabled and mouse is over world frame, anchor tooltip to cursor
    if ZaremTooltipAnchor.mouse and mouseFocus[1] == WorldFrame then 
        self:SetOwner(parent, config.mouseAnchorPos[1], config.mouseAnchorPos[2], config.mouseAnchorPos[3])
    else
        -- Otherwise anchor tooltip at saved position on screen
        self:SetOwner(parent, "ANCHOR_NONE") 
        self:SetPoint(ZaremTooltipAnchor.point, UIParent, ZaremTooltipAnchor.relativePoint, ZaremTooltipAnchor.xOffset, ZaremTooltipAnchor.yOffset)
    end
end)

-- Instantly hide tooltip if mouse moves off unit and instantFade enabled in config
GameTooltip:HookScript("OnUpdate", function(self)
    local mouseFocus = GetMouseFoci()
    if config.instantFade and self:GetUnit() and not (UnitExists("mouseover") or ZaremTooltipAnchor.mouse) and mouseFocus[1] == WorldFrame then
        self:Hide()
    end
end)

-- Custom fade out method to instantly hide tooltip if enabled
function GameTooltip:FadeOut()
    if ZaremTooltipAnchor.mouse or config.instantFade then
        self:Hide()
    end
end

do
    -- Set font and outline for tooltip header and text based on config
    if config.outlineFontHeader then
        GameTooltipHeaderText:SetFont(config.font, config.fontHeaderSize, "OUTLINE")
    else
        GameTooltipHeaderText:SetFont(config.font, config.fontHeaderSize)
    end

    if config.outlineFont then
        for i = 1, 20 do
            local textLine = _G["GameTooltipTextLeft" .. i]
            local textLineRight = _G["GameTooltipTextRight" .. i]
            if textLine then textLine:SetFont(config.font, config.fontSize, "OUTLINE") end
            if textLineRight then textLineRight:SetFont(config.font, config.fontSize, "OUTLINE") end
        end
    else
        for i = 1, 20 do
            local textLine = _G["GameTooltipTextLeft" .. i]
            local textLineRight = _G["GameTooltipTextRight" .. i]
            if textLine then textLine:SetFont(config.font, config.fontSize) end
            if textLineRight then textLineRight:SetFont(config.font, config.fontSize) end
        end
    end
end

-- Apply backdrop (background and border) to tooltip frame with configured colors
function ApplyBackdrop(frame)
    if frame.SetBackdrop then
        frame:SetBackdrop(config.backdrop)
        frame:SetBackdropColor(unpack(config.bg))
        frame:SetBackdropBorderColor(unpack(config.border))
    else
        -- fallback: frame does not support SetBackdrop (rare)
    end
end

-- Color tooltip border based on class, reaction, or item quality
function ColorBorder(frame, unit, itemQuality)
    if itemQuality and config.itemBorder then
        local r, g, b = GetItemQualityColor(itemQuality)
        if r and g and b then
            frame:SetBackdropBorderColor(r, g, b)
            return
        end
    end

    if UnitIsPlayer(unit) then
        if config.classBorder then
            local _, class = UnitClass(unit)
            if class then
                local color = RAID_CLASS_COLORS[class]
                frame:SetBackdropBorderColor(color.r, color.g, color.b)
                return
            end
        end
    else
        if config.reactionBorder then
            local reaction = UnitReaction(unit, "player") or 5
            local c = REACTION_COLORS[reaction]
            if c then
                frame:SetBackdropBorderColor(c.r, c.g, c.b)
                return
            end
        end
    end

    -- Default border color fallback
    frame:SetBackdropBorderColor(unpack(config.border))
end

-- Set health bar color based on unit's class or reaction or default
function SetHealthBarColor(unit)
    local r, g, b = unpack(config.health)
    if not unit then
        GameTooltipStatusBar:SetStatusBarColor(r, g, b)
        return
    end

    if UnitIsPlayer(unit) then
        if config.classHealth then
            local _, class = UnitClass(unit)
            if class then
                local color = RAID_CLASS_COLORS[class]
                if color then
                    r, g, b = color.r, color.g, color.b
                end
            end
        end
    else
        if config.reactionHealth then
            local reaction = UnitReaction(unit, "player")
            if reaction then
                local color = REACTION_COLORS[reaction]
                if color then
                    r, g, b = color.r, color.g, color.b
                end
            end
        end
    end

    GameTooltipStatusBar:SetStatusBarColor(r, g, b)
end

-- Update health bar value and visibility based on unit health and config
local function UpdateHealthBar(unit)
    if not unit or config.hideHealthBar then
        GameTooltipStatusBar:Hide()
        return
    end

    local health = UnitHealth(unit)
    local maxHealth = UnitHealthMax(unit)

    if maxHealth == 0 then
        GameTooltipStatusBar:Hide()
        return
    end

    GameTooltipStatusBar:SetMinMaxValues(0, maxHealth)
    GameTooltipStatusBar:SetValue(health)
    SetHealthBarColor(unit)
    GameTooltipStatusBar:Show()
end

-- Update tooltip text: color player name by class or reaction, show guild info if enabled
local function UpdateTooltipText(unit)
    if not unit then return end

    local name, realm = UnitName(unit)
    local colorName = name or UNKNOWN
    local guildName, guildRankName, guildRankIndex = GetGuildInfo(unit)

    if UnitIsPlayer(unit) then
        if config.classNames then
            local _, class = UnitClass(unit)
            if class then
                local color = RAID_CLASS_COLORS[class]
                if color then
                    colorName = format("|cff%02x%02x%02x%s|r", color.r*255, color.g*255, color.b*255, name)
                end
            end
        elseif config.reactionGuild and guildName then
            local reaction = UnitReaction(unit, "player")
            if reaction then
                local c = REACTION_COLORS[reaction]
                if c then
                    colorName = format("|cff%02x%02x%02x%s|r", c.r*255, c.g*255, c.b*255, name)
                end
            end
        end

        -- Append realm name if different and enabled
        if realm and realm ~= "" and config.playerRealm then
            colorName = colorName .. "-" .. realm
        end

        -- Replace the first line (player name) in the tooltip
        GameTooltipTextLeft1:SetText(colorName)

        -- Show guild info if configured
        if guildName and config.guildRank then
            local guildLine = guildName
            if config.guildRankIndex and guildRankIndex then
                guildLine = format("%s [%d]", guildLine, guildRankIndex)
            elseif guildRankName then
                guildLine = format("%s <%s>", guildLine, guildRankName)
            end
            GameTooltip:AddLine(guildLine, 0.7, 0.7, 0.7)
        end
    end
end

-- Hook GameTooltip event to update health bar and text on unit tooltip set
GameTooltip:HookScript("OnTooltipSetUnit", function(self)
    local unit = select(2, self:GetUnit())

    UpdateHealthBar(unit)
    UpdateTooltipText(unit)
    ApplyBackdrop(self)

    -- Color border according to unit or item quality (nil here because this is unit)
    ColorBorder(self, unit, nil)
end)

-- Hook into item tooltip to color border by item quality and optionally background
GameTooltip:HookScript("OnTooltipSetItem", function(self)
    local _, link = self:GetItem()
    if link then
        local quality = select(3, GetItemInfo(link))
        if quality then
            ColorBorder(self, nil, quality)
            if config.itemBg then
                local r, g, b = GetItemQualityColor(quality)
                self:SetBackdropColor(r * 0.1, g * 0.1, b * 0.1, 0.9)
            end
        else
            self:SetBackdropColor(unpack(config.bg))
            self:SetBackdropBorderColor(unpack(config.border))
        end
    end
end)

-- Ensure tooltip is drawn above other frames
GameTooltip:SetFrameStrata("TOOLTIP")

-- Optional: Return the module table for organization (empty here)
local ZaremTooltip = {}

return ZaremTooltip
