-- Modified Action Bar layout. 

local function init()
    -- Do not run if Bartender4 or Dominos is loaded
      if IsAddOnLoaded("Bartender4") then
        print("|cFFFFFFFFLanacan|r|cffa335eeTweaks|r: Bartender4 is loaded. Custom Actionbar layout code will not run.")
        return
    elseif IsAddOnLoaded("Dominos") then
        print("|cFFFFFFFFLanacan|r|cffa335eeTweaks|r: Dominos is loaded. Custom Actionbar layout code will not run.")
        return
    end

    -- CONFIG --
	-- *** == NOTE: LancanLayout Does not work in Wow Classic due to scaling issues with MultiBarRight and MultiBarLeft ***--
	local LayoutStyle = "LancanLayout" -- Options: "LancanLayout", "StackedLayout", "Default"
    local HideStance = false -- Hide the stance bar
	
    -- Hide stuff
    local hiddenElements = { 
        CharacterMicroButton,
		SpellbookMicroButton,
		TalentMicroButton,
		QuestLogMicroButton,
		SocialsMicroButton,
		LFGMicroButton,
		MainMenuMicroButton,
		HelpMicroButton,		
		WorldMapMicroButton,
				
        -- StatusTrackingBarManager, -- Doesn't exist in Classic
        MainMenuBarVehicleLeaveButton,
		MainMenuBarBackpackButton,
		CharacterBag0Slot,
		CharacterBag1Slot,
		CharacterBag2Slot,
		CharacterBag3Slot,
		KeyRingButton,
		
		-- Action Bars
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuBarTexture0,
		MainMenuBarTexture1,
		MainMenuBarTexture2,
		MainMenuBarTexture3,
		MainMenuBarLeftEndCap,
		MainMenuBarRightEndCap,
		ActionBarUpButton,
		ActionBarDownButton,
		ReputationWatchBar,
		MainMenuExpBar,
		ArtifactWatchBar,
		HonorWatchBar,
		MainMenuBarPageNumber,
		SlidingActionBarTexture0,
		SlidingActionBarTexture1,
		MainMenuBarTextureExtender,
		MainMenuBarMaxLevelBar,
		MainMenuBarPerformanceBarFrame,
    }

    for _, hiddenElement in pairs(hiddenElements) do
        if hiddenElement then
            hiddenElement:Hide()
        end
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

    -- Hide stance bar
	if HideStance then
		StanceBarFrame:SetAlpha(0)
		RegisterStateDriver(StanceBarFrame, "visibility", "hide")
	end

    if AlertFrame then
        AlertFrame:ClearAllPoints()
        AlertFrame:SetPoint("TOP", UIParent, "TOP", 0, 0)
        AlertFrame.SetPoint = function() end
    end

	-----------------------------------
	-- LAYOUTS
	-----------------------------------
    if LayoutStyle == "LancanLayout" then
		---------------------------------------
        -- My Personal Layout
        ---------------------------------------
		ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("CENTER", MainMenuBar, -105, 305)
		--ActionButton1:SetPoint("CENTER", UIParent, -105, -170) -- This is where we want it to be located
		--ActionButton1:SetPoint("CENTER", UIParent, "CENTER", -105, -400) --  Scaling has noticably shrunk for the MultiBarRight and MultiBarLeft Bars

        ActionButton7:ClearAllPoints()
        ActionButton7:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0)

		MainMenuBar:SetScale(0.95)

        MultiBarBottomLeftButton1:ClearAllPoints()
        MultiBarBottomLeftButton1:SetPoint("BOTTOM", UIParent, -231)
		MultiBarBottomLeft:SetScale(0.90)

        MultiBarBottomRightButton10:ClearAllPoints()
        MultiBarBottomRightButton10:SetPoint("BOTTOM", UIParent, 315)

        MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton10, "TOPLEFT", 0)

        MultiBarBottomRightButton4:ClearAllPoints()
        MultiBarBottomRightButton4:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton7, "TOPLEFT", 0)

        MultiBarBottomRightButton1:ClearAllPoints()
        MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton4, "TOPLEFT", 0)

        if PetActionButton1 then
            PetActionButton1:ClearAllPoints()
            PetActionButton1:SetPoint("BOTTOM", MultiBarBottomLeftButton2, "TOP", 10)
            PetActionBarFrame:SetFrameStrata("HIGH")
            PetActionBarFrame:SetScale(.90)
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton12, "BOTTOMRIGHT", 20, 1)			
        end

        if PossessButton1 then
            PossessButton1:ClearAllPoints()
            PossessButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton2, "TOPLEFT", 25, 30)
        end

	elseif LayoutStyle == "StackedLayout" then
		---------------------------------------
        -- Stacked bar layout 12 x 3
        ---------------------------------------	
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 263, -30)
		--ActionButton1:SetPoint("BOTTOM", UIParent, "BOTTOM", -230.5, 40) -- adjust Y
				
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
			StanceButton1:SetAlpha(.25)
        end

	else
		 ---------------------------------------
        -- Default layout with 6 x 2 MultiBarBottomRight
        ---------------------------------------	
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

	MultiBarRight:ClearAllPoints()
	MultiBarRight:SetPoint("RIGHT", UIParent, "RIGHT", 0, -100)
	MultiBarRight:SetScale(.90)
	MultiBarLeftButton1:ClearAllPoints()
	MultiBarLeftButton1:SetPoint("RIGHT", MultiBarRightButton1, "LEFT", -3, 0)
	MultiBarLeft:SetScale(.90)
	
	 -- Remove obtrusive artwork from Stance bar when only bottom bar enabled
    if SlidingActionBarTexture0 then SlidingActionBarTexture0:Hide() end
	if SlidingActionBarTexture1 then SlidingActionBarTexture1:Hide() end

    -- Fix issue with Blizzard trying to call this
    if not AchievementMicroButton_Update then
        AchievementMicroButton_Update = function() end
    end

    -- Store button needs moved off screen as it does not have Hide() for some reason.
    if StoreMicroButton then
        StoreMicroButton:SetPoint("TOPLEFT",-250,-50000)
    end
	if TalentMicroButton then
        TalentMicroButton:SetPoint("TOPLEFT",-250,-50000)
    end

    ---------------------------------------
    -- FUNCTIONS
    ---------------------------------------
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

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)
