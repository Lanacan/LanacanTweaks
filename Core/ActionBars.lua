-- Lanacan Tweaks - Modified Action Bar Layout for WoW Classic

local function init()
    -- Do not run if other major action bar addons are loaded
    if IsAddOnLoaded("Bartender4") then
        print("|cFFFFFFFFLanacan|r|cffa335eeTweaks|r: Bartender4 is loaded. Custom Actionbar layout code will not run.")
        return
    elseif IsAddOnLoaded("Dominos") then
        print("|cFFFFFFFFLanacan|r|cffa335eeTweaks|r: Dominos is loaded. Custom Actionbar layout code will not run.")
        return
    end

    ----------------------
    -- CONFIGURATION
    ----------------------
    local LayoutStyle = "LancanLayout" -- Options: "LancanLayout", "StackedLayout", "Default"
    local HideStance = false -- Hide the stance bar

    ----------------------
    -- UI CLEANUP
    ----------------------
    local hiddenElements = {
        CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, QuestLogMicroButton,
        SocialsMicroButton, LFGMicroButton, MainMenuMicroButton, HelpMicroButton, WorldMapMicroButton,
        MainMenuBarVehicleLeaveButton,
        MainMenuBarBackpackButton, CharacterBag0Slot, CharacterBag1Slot, CharacterBag2Slot,
        CharacterBag3Slot, KeyRingButton,
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuBarLeftEndCap, MainMenuBarRightEndCap, ActionBarUpButton, ActionBarDownButton,
        ReputationWatchBar, MainMenuExpBar, ArtifactWatchBar, HonorWatchBar,
        MainMenuBarPageNumber, SlidingActionBarTexture0, SlidingActionBarTexture1,
        MainMenuBarTextureExtender, MainMenuBarMaxLevelBar, MainMenuBarPerformanceBarFrame,
    }

    for _, hiddenElement in pairs(hiddenElements) do
        if hiddenElement then hiddenElement:Hide() end
    end

    if MainMenuBarVehicleLeaveButton then
        MainMenuBarVehicleLeaveButton:SetAlpha(0)
        MainMenuBarVehicleLeaveButton:SetMovable(true)
        MainMenuBarVehicleLeaveButton:ClearAllPoints()
        MainMenuBarVehicleLeaveButton:SetScale(1)
        MainMenuBarVehicleLeaveButton:SetPoint("BOTTOMLEFT", 0, 0)
        MainMenuBarVehicleLeaveButton:SetUserPlaced(true)
        MainMenuBarVehicleLeaveButton:SetMovable(false)
    end

    if HideStance then
        StanceBarFrame:SetAlpha(0)
        RegisterStateDriver(StanceBarFrame, "visibility", "hide")
    end

    ----------------------
    -- ALERT FRAME POSITION
    ----------------------
    if AlertFrame then
        AlertFrame:ClearAllPoints()
        AlertFrame:SetPoint("TOP", UIParent, "TOP", 0, 0)
        AlertFrame.SetPoint = function() end
    end

	----------------------
    -- SIDEBAR POSITIONING & SCALE FIX
    ----------------------
	local SIDEBAR_SCALE = 0.80
	
	MultiBarRightButton1:ClearAllPoints()
    MultiBarRightButton1:SetPoint("RIGHT", UIParent, "RIGHT", 0, 100)
    --MultiBarRight:SetScale(SIDEBAR_SCALE)

    MultiBarLeftButton1:ClearAllPoints()
    MultiBarLeftButton1:SetPoint("RIGHT", MultiBarRightButton1, "LEFT", -3, 0)
    --MultiBarLeft:SetScale(SIDEBAR_SCALE)
	
	-- Make sure the scale sticks
    local function FixSideBarButtonScale()
        for i = 1, 12 do
            local right = _G["MultiBarRightButton"..i]
            local left = _G["MultiBarLeftButton"..i]
            if right then
                right:SetIgnoreParentScale(true)
                right:SetScale(UIParent:GetScale() * SIDEBAR_SCALE)				
            end
            if left then
                left:SetIgnoreParentScale(true)
                left:SetScale(UIParent:GetScale() * SIDEBAR_SCALE)
            end
        end
    end

    local scaleFixer = CreateFrame("Frame")
    scaleFixer:RegisterEvent("PLAYER_LOGIN")
    scaleFixer:RegisterEvent("UI_SCALE_CHANGED")
    scaleFixer:RegisterEvent("PLAYER_ENTERING_WORLD")

    scaleFixer:SetScript("OnEvent", function(self, event)
        if event == "PLAYER_REGEN_ENABLED" then
            self:UnregisterEvent("PLAYER_REGEN_ENABLED")
            FixSideBarButtonScale()
        elseif InCombatLockdown() then
            self:RegisterEvent("PLAYER_REGEN_ENABLED")
        else
            FixSideBarButtonScale()
        end
    end)

    ----------------------
    -- ACTIONBAR LAYOUTS
    ----------------------
    if LayoutStyle == "LancanLayout" then
        -- Custom personal layout
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("CENTER", MainMenuBar, -105, 315)
        ActionButton7:ClearAllPoints()
        ActionButton7:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0)
        MainMenuBar:SetScale(0.95)

        MultiBarBottomLeftButton1:ClearAllPoints()
        MultiBarBottomLeftButton1:SetPoint("BOTTOM", UIParent, -231, 0)
        MultiBarBottomLeft:SetScale(0.90)

        MultiBarBottomRightButton10:ClearAllPoints()
        MultiBarBottomRightButton10:SetPoint("BOTTOM", UIParent, 315, 0)
        MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton10, "TOPLEFT", 0, 0)
        MultiBarBottomRightButton4:ClearAllPoints()
        MultiBarBottomRightButton4:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton7, "TOPLEFT", 0, 0)
        MultiBarBottomRightButton1:ClearAllPoints()
        MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton4, "TOPLEFT", 0, 0)
		
        if PetActionButton1 then
            PetActionButton1:ClearAllPoints()
            PetActionButton1:SetPoint("BOTTOM", MultiBarBottomLeftButton2, "TOP", 10)
            PetActionBarFrame:SetFrameStrata("HIGH")
            PetActionBarFrame:SetScale(.90)
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton12, "BOTTOMRIGHT", 20, 1)
			StanceBarFrame:SetAlpha(0.25)
        end

        if PossessButton1 then
            PossessButton1:ClearAllPoints()
            PossessButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton2, "TOPLEFT", 25, 30)
        end

    elseif LayoutStyle == "StackedLayout" then
        -- 12 x 3 stacked layout
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 263, -30)

        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, -10)

        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0)

        if PetActionButton1 then
            PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton2, "TOP", 12)
            PetActionBarFrame:SetScale(.90)
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("TOPLEFT", ActionButton12, "TOPRIGHT", 50, 0)
            StanceBarFrame:SetAlpha(0.25)
        end

    else
        -- Default layout (6x2 right bar)
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 136.5, 10)
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0)
        MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("LEFT", ActionButton12, "RIGHT", 10, 0)

        if PetActionButton1 then
            PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton2, "TOPRIGHT", 0)
            PetActionBarFrame:SetScale(.90)
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("BOTTOMLEFT", ActionButton2, "TOP", 4, 56)
        end
    end

    

    ----------------------
    -- HIDE DECORATIVE TEXTURES
    ----------------------
    if SlidingActionBarTexture0 then SlidingActionBarTexture0:Hide() end
    if SlidingActionBarTexture1 then SlidingActionBarTexture1:Hide() end

    ----------------------
    -- BLOCK ERRORS
    ----------------------
    if not AchievementMicroButton_Update then
        AchievementMicroButton_Update = function() end
    end

    if StoreMicroButton then
        StoreMicroButton:SetPoint("TOPLEFT", -250, -50000)
    end
    if TalentMicroButton then
        TalentMicroButton:SetPoint("TOPLEFT", -250, -50000)
    end

    ----------------------
    -- HOTKEY FONT TWEAK
    ----------------------
    local function UpdateAllHotkeyFonts()
        local font = "Fonts\\FRIZQT__.TTF"
        local fontSize = 12
        local fontFlags = "OUTLINE"
        local fontColor = {1, 1, 1, 1}

        for i = 1, NUM_ACTIONBAR_BUTTONS do
            local buttons = {
                "ActionButton", "MultiBarBottomLeftButton",
                "MultiBarBottomRightButton", "MultiBarLeftButton",
                "MultiBarRightButton"
            }
            for _, prefix in ipairs(buttons) do
                local ho = _G[prefix..i.."HotKey"]
                if ho then
                    ho:SetFont(font, fontSize, fontFlags)
                    ho:SetTextColor(unpack(fontColor))
                    ho:ClearAllPoints()
                    ho:SetPoint("TOPRIGHT", _G[prefix..i], "TOPRIGHT", -2, -2)
                end
            end
        end

        for i = 1, NUM_PET_ACTION_SLOTS do
            local ho = _G["PetActionButton"..i.."HotKey"]
            if ho then
                ho:SetFont(font, fontSize, fontFlags)
                ho:SetTextColor(unpack(fontColor))
                ho:ClearAllPoints()
                ho:SetPoint("TOPRIGHT", _G["PetActionButton"..i], "TOPRIGHT", -2, -2)
            end
        end

        for i = 1, NUM_STANCE_SLOTS do
            local ho = _G["StanceButton"..i.."HotKey"]
            if ho then
                ho:SetFont(font, fontSize, fontFlags)
                ho:SetTextColor(unpack(fontColor))
                ho:ClearAllPoints()
                ho:SetPoint("TOPRIGHT", _G["StanceButton"..i], "TOPRIGHT", -2, -2)
            end
        end
    end

    UpdateAllHotkeyFonts()

    local fontFrame = CreateFrame("Frame")
    fontFrame:RegisterEvent("UPDATE_BINDINGS")
    fontFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    fontFrame:SetScript("OnEvent", UpdateAllHotkeyFonts)
end

-- Initialize addon on login
local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
