-- Make castbars look better & reposition them --

-- === CONFIGURATION ===
local CONFIG = {
    player = {
        x = 0,
        y = -220,
        scale = .89,
    },    
    texture = "Interface\\TargetingFrame\\UI-StatusBar", -- or set to "Default"
}

-- === CONSTANTS ===
local format = string.format
local max = math.max
local FONT = STANDARD_TEXT_FONT

local function ApplyCastBarTimer(castBar, fontSize)
    castBar.timer = castBar:CreateFontString(nil, "OVERLAY")
    castBar.timer:SetFont(FONT, fontSize, "THINOUTLINE")
    castBar.timer:SetPoint("LEFT", castBar, "RIGHT", 5, 0)
    castBar.update = 0.1
end

local function Castbar_OnUpdate(self, elapsed)
    if not self.timer then return end
    if self.update and self.update < elapsed then
        if self.casting then
            self.timer:SetText(format("%.1f", max(self.maxValue - self.value, 0)))
        elseif self.channeling then
            self.timer:SetText(format("%.1f", max(self.value, 0)))
        else
            self.timer:SetText("")
        end
        self.update = 0.1
    else
        self.update = self.update - elapsed
    end
end

local function AnchorTargetCastBar()
    local tcb = TargetFrameSpellBar
    tcb:ClearAllPoints()
    tcb:SetPoint("CENTER", UIParent, "BOTTOM", CONFIG.target.x, CONFIG.target.y)
end

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

    -- === Target CastBar (Minimalist: Icon + Timer Only) ===
    local tcb = TargetFrameSpellBar
	tcb.Border:SetDrawLayer("OVERLAY", 1)
	
	--tcb.ignoreFramePositionManager = true
    --tcb:ClearAllPoints()
    --tcb:SetPoint("BOTTOM", TargetFrame, "TOP", 0, 10)
		
    -- Set icon
    tcb.Icon:SetSize(15, 15)
    tcb.Icon:SetPoint("RIGHT", tcb, "LEFT", -5, 0)

    -- Optional: use the same texture as player
    if CONFIG.texture ~= "Default" then
        tcb:SetStatusBarTexture(CONFIG.texture)
    end

    -- Timer only
    ApplyCastBarTimer(tcb, 11)
    tcb:HookScript("OnUpdate", Castbar_OnUpdate)
    
end

-- === EVENT REGISTRATION ===
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function()
    StyleCastBars()
end)
