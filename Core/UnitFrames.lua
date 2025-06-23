----------------------
-- Lanacan vUF - Custom Unit Frame Mod (Modified vUF)
-- Source: https://vranx.com/ui.htm#UnitFrames
--
-- Reworked vUF addon for WoW Classic with:
-- - Scalable & repositionable unit frames
-- - Optional class/reaction coloring on health bars
-- - Options to hide level text, combat flash, rest icons
-- - Darker UI styling option
-- - Thicker health bars & custom elite/rare textures
----------------------

-- CONFIGURATION
local vuf = {}
vuf.scale     = 1.00   -- Global scale for unit frames
vuf.position  = true   -- Enable custom positioning
vuf.player    = { "CENTER", UIParent, "CENTER", -235, -135 } -- Player frame position
vuf.target    = { "CENTER", UIParent, "CENTER", 235, -135 }  -- Target frame position
vuf.colors    = true   -- Enable class coloring for health bars
vuf.reactionColor = true  -- Enable reaction-based coloring for NPCs
vuf.rest      = false  -- Disable rest icon/flash
vuf.lvl       = false  -- Hide level text
vuf.lvlmax    = true   -- Hide level text only at level 60
vuf.combat    = true   -- Disable combat flashing
vuf.combati   = false  -- Hide combat icon
vuf.rcolor    = false  -- Set target name background to static color
vuf.dark      = true   -- Apply dark styling to frame textures
vuf.frameRgb  = { 0.4, 0.4, 0.4, 1 } -- Color used for dark styling
vuf.thickness = true   -- Apply thick health bars and elite/rare texture overrides

-- SCALE UNIT FRAMES
PlayerFrame:SetScale(vuf.scale)
TargetFrame:SetScale(vuf.scale)
CastingBarFrame:SetScale(vuf.scale)

-- POSITION UNIT FRAMES ON LOGIN
if vuf.position then
    local function ApplyPosition()
        PlayerFrame_ResetUserPlacedPosition()
        TargetFrame_ResetUserPlacedPosition()

        PlayerFrame:ClearAllPoints()
        PlayerFrame:SetPoint(unpack(vuf.player))
        PlayerFrame:SetUserPlaced(true)

        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint(unpack(vuf.target))
        TargetFrame:SetUserPlaced(true)
    end

    local enteringWorld = CreateFrame("Frame")
    enteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
    enteringWorld:SetScript("OnEvent", ApplyPosition)
end

-- APPLY CLASS OR REACTION COLORING TO HEALTH BARS
if vuf.colors or vuf.reactionColor then
    local REACTION_COLORS = {
        [1] = {r = 0.9,  g = 0,    b = 0},    -- Hostile
        [2] = {r = 0.9,  g = 0,    b = 0},
        [3] = {r = 0.75, g = 0.27, b = 0},    -- Unfriendly
        [4] = {r = 0.8,  g = 0.7,  b = 0.2},  -- Neutral
        [5] = {r = 0,    g = 0.7,  b = 0},    -- Friendly
        [6] = {r = 0,    g = 0.7,  b = 0},
        [7] = {r = 0,    g = 0.7,  b = 0},
        [8] = {r = 0,    g = 0.7,  b = 0},
        [9] = {r = 0.5,  g = 0.5,  b = 0.5},  -- Tapped
    }

    local function colour(statusbar, unit)
        if not UnitExists(unit) then return end

        if UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitClass(unit) and vuf.colors then
            local _, class = UnitClass(unit)
            local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
            if c then
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
            end
        elseif vuf.reactionColor then
            local reaction = UnitReaction(unit, "player")
            if UnitIsTapDenied(unit) then reaction = 9 end
            local c = REACTION_COLORS[reaction]
            if c then
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
            end
        end
    end

    hooksecurefunc("UnitFrameHealthBar_Update", colour)
    hooksecurefunc("HealthBar_OnValueChanged", function(self)
        colour(self, self.unit)
    end)
end

-- DISABLE REST ICONS & GLOW
if vuf.rest then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
        if IsResting("player") then
            PlayerStatusTexture:Hide()
            PlayerRestGlow:Hide()
            PlayerStatusGlow:Hide()
            PlayerRestIcon:Hide()
        end
    end)
end

-- HIDE LEVEL DISPLAY ON PLAYER FRAME
if vuf.lvl then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
        PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoLevel")
        PlayerLevelText:Hide()
    end)
end

-- HIDE LEVEL DISPLAY ONLY IF LEVEL 60
if vuf.lvlmax then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
        if UnitLevel("player") > 59 then
            PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoLevel")
            PlayerLevelText:Hide()
        end
    end)
end

-- DISABLE COMBAT FLASH EFFECTS
if vuf.combat then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
        if PlayerFrame.inCombat then
            PlayerStatusTexture:Hide()
            PlayerAttackGlow:Hide()
            PlayerStatusGlow:Hide()
        end
    end)
end

-- HIDE COMBAT ICON GRAPHICS
if vuf.combati then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
        PlayerAttackIcon:Hide()
        PlayerAttackBackground:Hide()
    end)
end

-- REMOVE FACTION-BASED BACKGROUND COLORING FROM TARGET NAME
if vuf.rcolor then
    hooksecurefunc("TargetFrame_CheckFaction", function(self)
        self.nameBackground:SetVertexColor(0, 0, 0, 0.5)
    end)
end

-- APPLY DARK COLORS TO VARIOUS FRAME TEXTURES
if vuf.dark then
    local function ApplyDarkColor(texture)
        if texture and texture.SetVertexColor and vuf.frameRgb then
            texture:SetVertexColor(unpack(vuf.frameRgb))
        end
    end

    local texturesToDarken = {
        PlayerFrameTexture,
        TargetFrameTextureFrameTexture,
        TargetFrameToTTextureFrameTexture,
        FocusFrameTextureFrameTexture,
        FocusFrameToTTextureFrameTexture,
        PetFrameTexture,
        PartyMemberFrame1Texture,
        PartyMemberFrame2Texture,
        PartyMemberFrame3Texture,
        PartyMemberFrame4Texture,
        CastingBarFrameBorder,
    }

    for _, tex in pairs(texturesToDarken) do
        ApplyDarkColor(tex)
    end
end

-- USE THICKER HEALTHBARS AND CUSTOM BORDERS FOR TARGET FRAME
if vuf.thickness then
    hooksecurefunc("TargetFrame_CheckClassification", function(self, forceNormalTexture)
        local classification = UnitClassification(self.unit)

        if classification == "worldboss" or classification == "elite" then
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\target\\Thick-Elite")
        elseif classification == "rareelite" then
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\target\\Thick-Rare-Elite")
        elseif classification == "rare" then
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\target\\Thick-Rare")
        else
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\unitframes\\UI-TargetingFrame")
        end

        self.borderTexture:SetVertexColor(unpack(vuf.frameRgb))

        -- Resize and reposition bars/texts
        self.highLevelTexture:SetPoint("CENTER", self.levelText, "CENTER", 0, 0)
        self.nameBackground:Hide()
        self.name:SetPoint("LEFT", self, 15, 36)
        self.healthbar:SetSize(119, 27)
        self.healthbar:SetPoint("TOPLEFT", 5, -24)
        self.manabar:SetSize(119, 13)
        self.manabar:SetPoint("TOPLEFT", 7, -52)

        if self.healthbar.LeftText then
            self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0)
        end
        if self.healthbar.RightText then
            self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0)
        end
        if self.healthbar.TextString then
            self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)
        end

        if self.manabar.LeftText then
            self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0)
        end
        if self.manabar.RightText then
            self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 0)
        end
        if self.manabar.TextString then
            self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0)
        end

        if forceNormalTexture then
            self.haveElite = nil
            self.Background:SetSize(119, 42)
            self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35)
        else
            self.haveElite = true
            self.Background:SetSize(119, 42)
        end
    end)

    -- Reposition PlayerFrame name
    PlayerFrame.name:ClearAllPoints()
    PlayerFrame.name:SetPoint('TOP', PlayerFrameHealthBar, 0, 15)

    PlayerStatusTexture:SetTexture()
    PlayerRestGlow:SetAlpha(0)

    local function LortiUIPlayerFrame(self)
        PlayerFrameTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\unitframes\\UI-TargetingFrame")
        self.name:Hide()
        self.name:ClearAllPoints()
        self.name:SetPoint("CENTER", PlayerFrame, "CENTER", 5.5, 36)

        self.healthbar:SetPoint("TOPLEFT", 106, -24)
        self.healthbar:SetHeight(27)
        self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0)
        self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0)
        self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0)

        self.manabar:SetPoint("TOPLEFT", 106, -52)
        self.manabar:SetHeight(13)
        self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0)
        self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 0)
        self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0)

        PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", 0, -20)
        PlayerFrameGroupIndicatorLeft:Hide()
        PlayerFrameGroupIndicatorMiddle:Hide()
        PlayerFrameGroupIndicatorRight:Hide()
        PlayerFrameGroupIndicatorText:Hide()
        PlayerFrameGroupIndicator:Hide()
    end

    hooksecurefunc("PlayerFrame_ToPlayerArt", LortiUIPlayerFrame)
    hooksecurefunc("PlayerFrame_ToVehicleArt", LortiUIPlayerFrame)

    if TargetFrameTextureFrameUnconsciousText then
        TargetFrameTextureFrameUnconsciousText:SetPoint("CENTER", TargetFrameTextureFrame, "CENTER", -50, 12)
    end
    if TargetFrameTextureFrameDeadText then
        TargetFrameTextureFrameDeadText:SetPoint("CENTER", TargetFrameTextureFrame, "CENTER", -50, 12)
    end
end
