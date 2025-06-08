-- Make castbars look better & reposition them --

-- === CONFIGURATION ===
local CONFIG = {
    player = {
        x = 0,
        y = -220,
        scale = 0.89,
    },
    target = {
        x = 0,
        y = 180,
    },
    texture = "Interface\\TargetingFrame\\UI-StatusBar", -- or set to "Default"
}

-- === CONSTANTS ===
local format = string.format
local max = math.max
local FONT = STANDARD_TEXT_FONT

-- === Timer Setup ===
local function ApplyCastBarTimer(castBar, fontSize)
    castBar.timer = castBar:CreateFontString(nil, "OVERLAY")
    castBar.timer:SetFont(FONT, fontSize, "THINOUTLINE")
    castBar.timer:SetPoint("LEFT", castBar, "RIGHT", 5, 0)
    castBar.update = 0.1
end

-- === Timer OnUpdate ===
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

-- === Lag Indicator Hook ===
local function HookLagIndicator(castBar)
    castBar:HookScript("OnUpdate", function(self)
        if self.lag == nil then
            self.lag = _G[self:GetName().."Lag"] or self:CreateTexture(self:GetName().."Lag", "BORDER")
            self.lag:SetTexture("Interface\\RAIDFRAME\\Raid-Bar-Hp-Fill", "BACKGROUND")
            self.lag:SetVertexColor(1, 0, 0)
            self.lag:SetBlendMode("ADD")
        end

        if self.lag and self:IsShown() and self.casting then
            local down, up, lag = GetNetStats()
            local minVal, maxVal = self:GetMinMaxValues()
            local lagRatio = (lag / 1000) / (maxVal - minVal)
            if lagRatio < 0 then lagRatio = 0 elseif lagRatio > 1 then lagRatio = 1 end

            local barWidth = self:GetWidth()
            local lagWidth = barWidth * lagRatio

            -- 🔴 Minimum width for visibility
            if lag > 0 and lagWidth < 2 then
                lagWidth = 2
            end

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


-- === CastBar Styling ===
local function StyleCastBars()
    if InCombatLockdown() then return end

    -- === Player CastBar ===
    local cb = CastingBarFrame
    cb.ignoreFramePositionManager = true
    cb:SetMovable(true)
    cb:ClearAllPoints()
    cb:SetPoint("CENTER", UIParent, "CENTER", CONFIG.player.x, CONFIG.player.y)
    cb:SetScale(CONFIG.player.scale)
    cb:SetUserPlaced(true)

    cb.Icon:Show()
    cb.Icon:ClearAllPoints()
    cb.Icon:SetSize(20, 20)
    cb.Icon:SetPoint("RIGHT", cb, "LEFT", -5, 0)

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

    cb.Text:ClearAllPoints()
    cb.Text:SetPoint("CENTER", 0, 1)

    if CONFIG.texture ~= "Default" then
        cb:SetStatusBarTexture(CONFIG.texture)
    end

    ApplyCastBarTimer(cb, 14)
    cb:HookScript("OnUpdate", Castbar_OnUpdate)
    HookLagIndicator(cb)

    -- === Target CastBar (Minimalist: Icon + Timer Only) ===
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

-- === EVENT REGISTRATION ===
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    StyleCastBars()
end)
