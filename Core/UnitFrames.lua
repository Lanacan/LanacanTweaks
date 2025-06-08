--[[
THIS IS A REWORED vUF WITH LARGER HEATHBARS- https://vranx.com/ui.htm#UnitFrames
]]--

-- CONFIG
local vuf = {}
vuf.scale     = 1.00   -- Set the overall scale of player, target, and casting bar frames
vuf.position  = true   -- Enable custom positioning of frames
vuf.player    = { "CENTER", UIParent, "CENTER", -230, -135 }  -- Player frame position anchor and offsets
vuf.target    = { "CENTER", UIParent, "CENTER", 230, -135 }   -- Target frame position anchor and offsets
vuf.colors    = true   -- Enable class colors on health bars for player and player-controlled units
vuf.reactionColor = true  -- Enable reaction-based colors on non-player target health bars
vuf.rest      = false   -- Disable rest state flashing and icons on player frame
vuf.lvl       = false   -- Hide player level display on player frame
vuf.lvlmax    = true    -- Hide player level display if player level is 60 (max level)
vuf.combat    = true    -- Disable combat flashing effects on player frame
vuf.combati   = false   -- Hide combat icon on player frame
vuf.rcolor    = false   -- Remove reaction color from target frame name background
vuf.dark      = true    -- Apply darker colors to various frame textures for a darker UI look
vuf.frameRgb  = { 0.4, 0.4, 0.4, 1 }  -- RGBA color values for frame darkening effect
vuf.thickness = true    -- Use thicker health bars and custom elite/rare borders on target frame

-- SCALE
-- Set the scale of player, target, and casting bar frames based on vuf.scale
PlayerFrame:SetScale(vuf.scale)
TargetFrame:SetScale(vuf.scale)
CastingBarFrame:SetScale(vuf.scale)

-- POSITION
-- If custom frame positioning is enabled, reposition the PlayerFrame and TargetFrame on login/entering world
if vuf.position then
    local function ApplyPosition()
        PlayerFrame_ResetUserPlacedPosition()  -- Reset any user-placed position so addon can override cleanly
        TargetFrame_ResetUserPlacedPosition()

        PlayerFrame:ClearAllPoints()            -- Clear existing anchors
        PlayerFrame:SetPoint(unpack(vuf.player))-- Set new position from config
        PlayerFrame:SetUserPlaced(true)         -- Prevent Blizzard from repositioning frame

        TargetFrame:ClearAllPoints()
        TargetFrame:SetPoint(unpack(vuf.target))
        TargetFrame:SetUserPlaced(true)
    end

    local enteringWorld = CreateFrame("Frame")
    enteringWorld:RegisterEvent("PLAYER_ENTERING_WORLD")
    enteringWorld:SetScript("OnEvent", ApplyPosition)  -- Apply positions when player enters the world
end

-- CLASS/REACTION COLORS
-- Applies class colors to player units and reaction colors to NPC targets' health bars
if vuf.colors or vuf.reactionColor then
    -- Custom reaction color table
    local REACTION_COLORS = {
        [1] = {r = 0.9,  g = 0,    b = 0},    -- Hostile (Red)
        [2] = {r = 0.9,  g = 0,    b = 0},    -- Hostile (Red)
        [3] = {r = 0.75, g = 0.27, b = 0},    -- Unfriendly (Orange-ish)
        [4] = {r = 0.8,  g = 0.7,  b = 0.2},  -- Neutral (Yellow)
        [5] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
        [6] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
        [7] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
        [8] = {r = 0,    g = 0.7,  b = 0},    -- Friendly (Green)
        [9] = {r = 0.5,  g = 0.5,  b = 0.5},  -- Tapped or denied (Grey)
    }

    local function colour(statusbar, unit)
        if not UnitExists(unit) then return end

        -- Use class color if unit is a player and coloring is enabled
        if UnitIsPlayer(unit) and UnitIsConnected(unit) and UnitClass(unit) and vuf.colors then
            local _, class = UnitClass(unit)
            local c = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
            if c then
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
            end

        -- Otherwise, use reaction color for non-player units if enabled
        elseif vuf.reactionColor then
            local reaction = UnitReaction(unit, "player")
            if reaction and REACTION_COLORS[reaction] then
				if UnitIsTapDenied(unit) then reaction = 9 end
                local c = REACTION_COLORS[reaction]
                statusbar:SetStatusBarColor(c.r, c.g, c.b)
            end
        end
    end

    -- Hook into health bar updates to apply colors dynamically
    hooksecurefunc("UnitFrameHealthBar_Update", colour)
    hooksecurefunc("HealthBar_OnValueChanged", function(self)
        colour(self, self.unit)
    end)
end


-- STOP REST FLASH
-- Disables the glowing/resting animation/icons on the player frame when resting if vuf.rest is true
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

-- HIDE LEVEL ON PLAYER FRAME
-- Hides player level and changes the texture to one without level display
if vuf.lvl then
    hooksecurefunc("PlayerFrame_UpdateStatus",function()
 	    PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoLevel")
 	    PlayerLevelText:Hide()
    end)
end

-- HIDE LEVEL ON PLAYER FRAME IF LEVEL 60
-- Hides the level display only if player is max level (60)
if vuf.lvlmax then
    hooksecurefunc("PlayerFrame_UpdateStatus",function()
      if UnitLevel("player") > 59 then
 	    PlayerFrameTexture:SetTexture("Interface\\TargetingFrame\\UI-TargetingFrame-NoLevel")
 	    PlayerLevelText:Hide()
      end
    end)
end

-- STOP COMBAT FLASH
-- Disables combat flashing effects on player frame when in combat if vuf.combat is true
if vuf.combat then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
       if PlayerFrame.inCombat then
          PlayerStatusTexture:Hide()
	      PlayerAttackGlow:Hide()
      	  PlayerStatusGlow:Hide()
       end
    end)
end

-- HIDE COMBAT ICON
-- Hides the combat icon and background on player frame if vuf.combati is true
if vuf.combati then
    hooksecurefunc("PlayerFrame_UpdateStatus", function()
     	  PlayerAttackIcon:Hide()
     	  PlayerAttackBackground:Hide()
    end)
end

-- SET TARGET REACTION COLOR
-- Removes the default faction reaction color from the target frame's name background by making it semi-transparent black
if vuf.rcolor then
    hooksecurefunc("TargetFrame_CheckFaction", function(self)
        self.nameBackground:SetVertexColor(0, 0, 0, 0.5);
    end)
end

-- DARK FRAMES
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


-- THICK FRAMES
-- Applies thicker health bars and custom borders for elite, rare elite, and rare mobs on the target frame
if vuf.thickness then
    hooksecurefunc("TargetFrame_CheckClassification", function(self, forceNormalTexture)
        local classification = UnitClassification(self.unit);

        -- Set different border textures and colors depending on mob classification
        if (classification == "worldboss" or classification == "elite") then
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\target\\Thick-Elite")
            self.borderTexture:SetVertexColor(unpack(vuf.frameRgb))
        elseif (classification == "rareelite") then
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\target\\Thick-Rare-Elite")
            self.borderTexture:SetVertexColor(unpack(vuf.frameRgb))
        elseif (classification == "rare") then
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\target\\Thick-Rare")
            self.borderTexture:SetVertexColor(unpack(vuf.frameRgb))
        else
            self.borderTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\unitframes\\UI-TargetingFrame")
            self.borderTexture:SetVertexColor(unpack(vuf.frameRgb))
        end

        -- Adjust positions and sizes of health, mana bars, and name for the thicker frame style
        self.highLevelTexture:SetPoint("CENTER", self.levelText, "CENTER", 0, 0);
        self.nameBackground:Hide();
        self.name:SetPoint("LEFT", self, 15, 36);
        self.healthbar:SetSize(119, 27);
        self.healthbar:SetPoint("TOPLEFT", 5, -24);
        self.manabar:SetPoint("TOPLEFT", 7, -52);
        self.manabar:SetSize(119, 13);

        -- Adjust healthbar text anchors if they exist
        if self.healthbar.LeftText then
            self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0)
        end
        if self.healthbar.RightText then
            self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0);
        end
        if self.healthbar.TextString then
            self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);
        end

        -- Adjust manabar text anchors if they exist
        if self.manabar.LeftText then
            self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0);
        end
        if self.manabar.RightText then
            self.manabar.RightText:ClearAllPoints();
            self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 0);
        end
        if self.manabar.TextString then
            self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0);
        end

        -- Adjust background size and elite indicator depending on forceNormalTexture
        if (forceNormalTexture) then
            self.haveElite = nil;
            self.Background:SetSize(119, 42);
            self.Background:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 7, 35);
        else
            self.haveElite = true;
            self.Background:SetSize(119, 42);
        end
    end)

    -- Reposition player frame name above the health bar for the thick frame style
    PlayerFrame.name:ClearAllPoints()
    PlayerFrame.name:SetPoint('TOP', PlayerFrameHealthBar, 0, 15)

    -- Remove some default textures and glows on the player frame for cleaner look
    PlayerStatusTexture:SetTexture()
    PlayerRestGlow:SetAlpha(0)

    -- Custom function to apply changes to player frame art for thick frames (called on player/vehicle art switch)
    local function LortiUIPlayerFrame(self)
        PlayerFrameTexture:SetTexture("Interface\\Addons\\LanacanTweaks\\textures\\unitframes\\UI-TargetingFrame");
        self.name:Hide();
        self.name:ClearAllPoints();
        self.name:SetPoint("CENTER", PlayerFrame, "CENTER", 5.5, 36);
        self.healthbar:SetPoint("TOPLEFT", 106, -24);
        self.healthbar:SetHeight(27);
        self.healthbar.LeftText:ClearAllPoints();
        self.healthbar.LeftText:SetPoint("LEFT", self.healthbar, "LEFT", 8, 0);
        self.healthbar.RightText:ClearAllPoints();
        self.healthbar.RightText:SetPoint("RIGHT", self.healthbar, "RIGHT", -5, 0);
        self.healthbar.TextString:SetPoint("CENTER", self.healthbar, "CENTER", 0, 0);
        self.manabar:SetPoint("TOPLEFT", 106, -52);
        self.manabar:SetHeight(13);
        self.manabar.LeftText:ClearAllPoints();
        self.manabar.LeftText:SetPoint("LEFT", self.manabar, "LEFT", 8, 0);
        self.manabar.RightText:ClearAllPoints();
        self.manabar.RightText:SetPoint("RIGHT", self.manabar, "RIGHT", -5, 0);
        self.manabar.TextString:SetPoint("CENTER", self.manabar, "CENTER", 0, 0);
        PlayerFrameGroupIndicatorText:ClearAllPoints();
        PlayerFrameGroupIndicatorText:SetPoint("BOTTOMLEFT", PlayerFrame, "TOP", 0, -20);
        PlayerFrameGroupIndicatorLeft:Hide();
        PlayerFrameGroupIndicatorMiddle:Hide();
        PlayerFrameGroupIndicatorRight:Hide();
        PlayerFrameGroupIndicatorText:Hide();
        PlayerFrameGroupIndicator:Hide();
    end

    -- Hook to apply the custom player frame art adjustments when switching player art styles (e.g. vehicle)
    hooksecurefunc("PlayerFrame_ToPlayerArt", LortiUIPlayerFrame)
    hooksecurefunc("PlayerFrame_ToVehicleArt", LortiUIPlayerFrame)

    -- Adjust the position of unconscious/dead text on the target frame for better alignment
    if TargetFrameTextureFrameUnconsciousText then
        TargetFrameTextureFrameUnconsciousText:SetPoint("CENTER", TargetFrameTextureFrame, "CENTER", -50, 12);
    end
    if TargetFrameTextureFrameDeadText then
        TargetFrameTextureFrameDeadText:SetPoint("CENTER", TargetFrameTextureFrame, "CENTER", -50, 12);
    end
end
