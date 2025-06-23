----------------------
-- Lanacan CastBar Enhancer
-- Enhances the player and target cast bars by adding:
-- - Numeric countdown timers
-- - Repositioned and resized bars and icons
-- - A visual lag indicator overlay on the player cast bar
-- - Optional custom status bar texture override
-- - Minimalist styling for the target's cast bar
----------------------

-- Configuration for positioning, scaling, and texture override
local CONFIG = {
    player = {
        x = 0,       -- X offset for player cast bar
        y = -220,    -- Y offset for player cast bar
        scale = 0.89 -- Scale factor for player cast bar
    },
    target = {
        x = 0,       -- Reserved for future target cast bar positioning
        y = 180
    },
    texture = "Interface\\TargetingFrame\\UI-StatusBar" -- Custom status bar texture, "Default" to skip
}

local format = string.format
local max = math.max
local FONT = STANDARD_TEXT_FONT

---
-- Add a countdown timer font string to a cast bar
-- @param castBar The cast bar frame to modify
-- @param fontSize Font size for the timer text
---
local function ApplyCastBarTimer(castBar, fontSize)
    castBar.timer = castBar:CreateFontString(nil, "OVERLAY")
    castBar.timer:SetFont(FONT, fontSize, "THINOUTLINE")
    castBar.timer:SetPoint("LEFT", castBar, "RIGHT", 5, 0)
    castBar.update = 0.1 -- Update interval in seconds
end

---
-- Update function for cast bar countdown timer
-- Displays remaining cast/channel time with one decimal precision
-- @param self The cast bar frame
-- @param elapsed Time elapsed since last update
---
local function Castbar_OnUpdate(self, elapsed)
    if not self.timer then return end
    self.update = self.update - elapsed
    if self.update <= 0 then
        if self.casting then
            self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
        elseif self.channeling then
            self.timer:SetText(format("%.1f", max(self.value, 0)))
        else
            self.timer:SetText("")
        end
        self.update = 0.1
    end
end

---
-- Adds a red latency overlay segment on the player cast bar indicating network lag
-- @param castBar The cast bar frame to hook
---
local function HookLagIndicator(castBar)
    castBar:HookScript("OnUpdate", function(self)
        if self.lag == nil then
            self.lag = _G[self:GetName().."Lag"] or self:CreateTexture(self:GetName().."Lag", "BORDER")
            self.lag:SetTexture("Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill")
            self.lag:SetVertexColor(1, 0, 0)
            self.lag:SetBlendMode("ADD")
        end

        if self.lag and self:IsShown() and self.casting then
            local _, _, lag = GetNetStats()
            local minVal, maxVal = self:GetMinMaxValues()
            local lagRatio = (lag / 1000) / (maxVal - minVal)
            lagRatio = lagRatio < 0 and 0 or (lagRatio > 1 and 1 or lagRatio)

            local barWidth = self:GetWidth()
            local lagWidth = barWidth * lagRatio
            if lag > 0 and lagWidth < 2 then lagWidth = 2 end

            self.lag:ClearAllPoints()
            self.lag:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
            self.lag:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
            self.lag:SetWidth(lagWidth)
            self.lag:SetHeight(self:GetHeight())
            self.lag:Show()
        elseif self.lag then
            self.lag:Hide()
        end
    end)
end

---
-- Styles the player and target cast bars according to configuration,
-- including positioning, scaling, icon resizing, texture setting, timers, and lag indicator
---
local function StyleCastBars()
    if InCombatLockdown() then return end

    -- Player Cast Bar
    local cb = CastingBarFrame
    cb.ignoreFramePositionManager = true
    cb:SetMovable(true)
    cb:ClearAllPoints()
    cb:SetPoint("CENTER", UIParent, "CENTER", CONFIG.player.x, CONFIG.player.y)
    cb:SetScale(CONFIG.player.scale)
    cb:SetUserPlaced(true)

    -- Icon setup
    cb.Icon:Show()
    cb.Icon:ClearAllPoints()
    cb.Icon:SetSize(20, 20)
    cb.Icon:SetPoint("RIGHT", cb, "LEFT", -5, 0)

    -- Border and flash textures repositioned
    cb.Border:SetTexture([[Interface\CastingBar\UI-CastingBar-Border-Small]])
    cb.Border:SetDrawLayer("OVERLAY", 1)
    cb.Border:ClearAllPoints()
    cb.Border:SetPoint("TOP", 0, 26)

    if cb.Flash then
        cb.Flash:SetTexture([[Interface\CastingBar\UI-CastingBar-Flash-Small]])
        cb.Flash:SetPoint("TOP", 0, 26)
    end

    if cb.BorderShield then
        cb.BorderShield:SetPoint("TOP", 0, 26)
    end

    -- Center cast text
    cb.Text:ClearAllPoints()
    cb.Text:SetPoint("CENTER", 0, 1)

    -- Apply custom texture if specified
    if CONFIG.texture ~= "Default" then
        cb:SetStatusBarTexture(CONFIG.texture)
    end

    -- Add timer and lag indicator hooks
    ApplyCastBarTimer(cb, 14)
    cb:HookScript("OnUpdate", Castbar_OnUpdate)
    HookLagIndicator(cb)

    -- Target Cast Bar - Minimalist styling
    local tcb = TargetFrameSpellBar
    tcb.Border:SetDrawLayer("OVERLAY", 1)
    tcb.Icon:SetSize(15, 15)
    tcb.Icon:SetPoint("RIGHT", tcb, "LEFT", -5, 0)

    if CONFIG.texture ~= "Default" then
        tcb:SetStatusBarTexture(CONFIG.texture)
    end

    ApplyCastBarTimer(tcb, 11)
    tcb:HookScript("OnUpdate", Castbar_OnUpdate)
end

-- Create frame and register login event to apply castbar styling after player login
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    StyleCastBars()
end)
