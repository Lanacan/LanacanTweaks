----------------------
-- LANACAN ACTIONBARS - CUSTOM ACTION BAR LAYOUT FOR WOW CLASSIC
-- A configurable layout system for default Blizzard action bars, designed to improve usability and aesthetics.
-- Includes multiple layout presets (LancanLayout, StackedLayout, Modified Default), sidebar scale fixes, 
-- mouseover corner menus for bags and micro buttons, and hotkey font tweaks. 
-- Automatically disables if Bartender4 or Dominos is loaded to prevent conflicts.
----------------------


local function init()
    ----------------------
	-- Do not run this addon if Bartender4 or Dominos are loaded
	----------------------
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
	local SIDEBAR_SCALE = 0.70 -- Sidebar scalling gets borked when playing stealth characters, this is used to fix that. 

    ----------------------
    -- UI CLEANUP
    ----------------------
    local hiddenElements = {
        MainMenuBarVehicleLeaveButton,
        MainMenuBarTexture0, MainMenuBarTexture1, MainMenuBarTexture2, MainMenuBarTexture3,
        MainMenuBarLeftEndCap, MainMenuBarRightEndCap,
        ActionBarUpButton, ActionBarDownButton,
        ReputationWatchBar, MainMenuExpBar,
        ArtifactWatchBar, HonorWatchBar,
        MainMenuBarPageNumber,
        SlidingActionBarTexture0, SlidingActionBarTexture1,
        MainMenuBarTextureExtender,
        MainMenuBarMaxLevelBar,
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

	--Hide Stance
    if HideStance then
        StanceBarFrame:SetAlpha(0)
        RegisterStateDriver(StanceBarFrame, "visibility", "hide")
    end
	
	-- Hide XP and Reputation Bars 
	local function hideXPBar()
		if MainMenuExpBar then
			MainMenuExpBar:Hide()
			MainMenuExpBar:UnregisterAllEvents()
		end
		if ReputationWatchBar then
			ReputationWatchBar:Hide()
			ReputationWatchBar:UnregisterAllEvents()
		end
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
    MultiBarRightButton1:ClearAllPoints()
    MultiBarRightButton1:SetPoint("RIGHT", UIParent, "RIGHT", -5, 175)

    MultiBarLeftButton1:ClearAllPoints()
    MultiBarLeftButton1:SetPoint("RIGHT", MultiBarRightButton1, "LEFT", -3, 0)

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
	-- CORNER MENU SYSTEM (Bags + Micro Buttons with Mouseover)
	-- Thank you Tidy Bars for code.
	----------------------
	local MenuButtonFrames = {
		CharacterMicroButton, SpellbookMicroButton, TalentMicroButton,
		QuestLogMicroButton, SocialsMicroButton, LFGMicroButton,
		MainMenuMicroButton, HelpMicroButton, WorldMapMicroButton,
	}

	local BagButtonFrameList = {
		MainMenuBarBackpackButton, CharacterBag0Slot,
		CharacterBag1Slot, CharacterBag2Slot, CharacterBag3Slot,
		KeyRingButton,
	}

	local CornerMenuFrame = CreateFrame("Frame", "LanacanTweaks_CornerMenuFrame", UIParent)
	CornerMenuFrame:SetFrameStrata("MEDIUM") -- Or "HIGH" if necessary
	CornerMenuFrame:SetFrameLevel(10)        -- Ensure above default UI
	CornerMenuFrame:SetWidth(300)
	CornerMenuFrame:SetHeight(150)
	CornerMenuFrame:SetPoint("BOTTOMRIGHT")
	CornerMenuFrame:SetScale(1)
	CornerMenuFrame:SetAlpha(0) -- Start hidden

	CornerMenuFrame:EnableMouse(true)
	
	MainMenuMicroButton:SetParent(CornerMenuFrame)
	MainMenuMicroButton:EnableMouse(true)

	HelpMicroButton:SetParent(CornerMenuFrame)
	HelpMicroButton:EnableMouse(true)

	WorldMapMicroButton:SetParent(CornerMenuFrame)
	WorldMapMicroButton:EnableMouse(true)


	local function FadeIn(frame)
		UIFrameFadeIn(frame, 0.25, frame:GetAlpha(), 1)
	end

	local function FadeOut(frame)
		UIFrameFadeOut(frame, 0.25, frame:GetAlpha(), 0)
	end

	CornerMenuFrame:SetScript("OnEnter", function(self)
		FadeIn(self)
	end)

	CornerMenuFrame:SetScript("OnLeave", function(self)
		FadeOut(self)
	end)

	-- Position bag buttons
	for i, btn in pairs(BagButtonFrameList) do
		btn:SetParent(CornerMenuFrame)
		btn:ClearAllPoints()
		if i == 1 then			
			btn:SetPoint("BOTTOMRIGHT", CornerMenuFrame, "BOTTOMRIGHT", -10, 45)
		else
			btn:SetPoint("RIGHT", BagButtonFrameList[i-1], "LEFT", -2, 0)
		end
	end

	-- Position micro buttons
	for i, btn in ipairs(MenuButtonFrames) do
		if btn then
			btn:SetParent(CornerMenuFrame)
			btn:ClearAllPoints()
			--btn:SetScale(UIParent:GetScale())
			btn:SetAlpha(1)
			btn:Show()
			if i == 1 then				
				btn:SetPoint("BOTTOMRIGHT", CornerMenuFrame, "BOTTOMRIGHT", -(btn:GetWidth() * 7), 5)
			else
				btn:SetPoint("LEFT", MenuButtonFrames[i-1], "RIGHT", 0, 0)
			end
		end
	end

	-- Keep frame visible while mouse is over any button
	local function OnChildEnter(self)
		FadeIn(CornerMenuFrame)
	end

	local function OnChildLeave(self)
		-- Small delay to prevent flicker, or immediately fade out
		FadeOut(CornerMenuFrame)
	end

	-- Add mouse events to all buttons
	for _, btn in ipairs(MenuButtonFrames) do
		if btn then
			btn:EnableMouse(true)
			btn:SetScript("OnEnter", OnChildEnter)
			btn:SetScript("OnLeave", OnChildLeave)
		end
	end

	for _, btn in ipairs(BagButtonFrameList) do
		if btn then
			btn:EnableMouse(true)
			btn:SetScript("OnEnter", OnChildEnter)
			btn:SetScript("OnLeave", OnChildLeave)
		end
	end

    ----------------------
    -- ACTIONBAR LAYOUTS
    ----------------------
    if LayoutStyle == "LancanLayout" then
		-- My Personal Layout with the 2 x 6 Main action bar between unit frames. 
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("CENTER", MainMenuBar, -105, 315)
        ActionButton7:ClearAllPoints()
        ActionButton7:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0)
        MainMenuBar:SetScale(0.95)

        MultiBarBottomLeftButton1:ClearAllPoints()
        MultiBarBottomLeftButton1:SetPoint("BOTTOM", UIParent, -231, 5)
        MultiBarBottomLeft:SetScale(0.90)

        MultiBarBottomRightButton10:ClearAllPoints()
        MultiBarBottomRightButton10:SetPoint("BOTTOM", UIParent, 315, 5)
        MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton10, "TOPLEFT", 0, 0)
        MultiBarBottomRightButton4:ClearAllPoints()
        MultiBarBottomRightButton4:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton7, "TOPLEFT", 0, 0)
        MultiBarBottomRightButton1:ClearAllPoints()
        MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton4, "TOPLEFT", 0, 0)

        if PetActionButton1 then
            PetActionButton1:ClearAllPoints()
            PetActionButton1:SetPoint("BOTTOM", MultiBarBottomLeftButton2, "TOP", 10, 5)
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
		-- The three main action bars stacked in the lower center of the UI. 
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 263, -30)

        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, -10)

        MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0)

        if PetActionButton1 then
            PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton2, "TOP", 12, 5)
            PetActionBarFrame:SetScale(.90)
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("TOPLEFT", ActionButton12, "TOPRIGHT", 50, 0)
            StanceBarFrame:SetAlpha(0.25)
        end

    else
		-- A modified Default layout with MultiBarBottomRight bar stacked in a 2 X 6 configuration. 
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 136.5, 10)
        MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0)
        MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("LEFT", ActionButton12, "RIGHT", 10, 0)

        if PetActionButton1 then
            PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton2, "TOPRIGHT", 0, 5)
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
    if SlidingActionBarTexture0 then
        SlidingActionBarTexture0:Hide()
        SlidingActionBarTexture0:SetAlpha(0)
    end
    if SlidingActionBarTexture1 then
        SlidingActionBarTexture1:Hide()
        SlidingActionBarTexture1:SetAlpha(0)
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
	hideXPBar()
	
    local fontFrame = CreateFrame("Frame")
    fontFrame:RegisterEvent("UPDATE_BINDINGS")
    fontFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    fontFrame:SetScript("OnEvent", UpdateAllHotkeyFonts)
end

-- Initialize addon on login
local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)

