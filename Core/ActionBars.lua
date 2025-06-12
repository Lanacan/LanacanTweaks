local function init()
    local dominos = IsAddOnLoaded("Dominos")
    local bartender4 = IsAddOnLoaded("Bartender4")
    local LancanLayout = true -- Set to false if you want to have the default bliz layout.
	local StackedLayout = false -- Stack as three main action bars (LancanLayout != true)
	local HideStance = true -- Hide the stance bar
          
    -- Updated sizing values
    local size = 32
    local spacing = 1  -- More negative = tighter spacing (was -3)
	
    -- EXACT match to your Buffs.lua backdrop settings
    local backdrop = {
        bgFile = "Interface\\BUTTONS\\WHITE8X8",
        edgeFile = "Interface\\Buttons\\WHITE8X8",
        tile = false,
        tileSize = 32,
        edgeSize = 2,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    }

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
    if LancanLayout then
        ---------------------------------------
        -- My Personal Layout
        ---------------------------------------
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("CENTER", MainMenuBar, -105, 310, spacing)
		
        ActionButton7:ClearAllPoints()
        ActionButton7:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, spacing)
			
		MainMenuBar:SetScale(0.95)
				
        MultiBarBottomLeftButton1:ClearAllPoints()
        MultiBarBottomLeftButton1:SetPoint("BOTTOM", UIParent, -231, spacing)
		MultiBarBottomLeft:SetScale(0.90)

		--[[Mouse Grid]]--
        MultiBarBottomRightButton10:ClearAllPoints()
        MultiBarBottomRightButton10:SetPoint("BOTTOM", UIParent, 315, spacing)

        MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton10, "TOPLEFT", 0, spacing)

        MultiBarBottomRightButton4:ClearAllPoints()
        MultiBarBottomRightButton4:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton7, "TOPLEFT", 0, spacing)

        MultiBarBottomRightButton1:ClearAllPoints()
        MultiBarBottomRightButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton4, "TOPLEFT", 0, spacing)
							
        if PetActionButton1 then
            PetActionButton1:ClearAllPoints()
            PetActionButton1:SetPoint("BOTTOM", MultiBarBottomLeftButton2, "TOP", 10, spacing)
            PetActionBarFrame:SetFrameStrata("HIGH")
            PetActionBarFrame:SetScale(.90)
			PetActionButton1.SetPoint = function() end
        end
            
        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("RIGHT", MultiBarBottomLeftButton1, "LEFT", -200, spacing) 
			StanceButton1.SetPoint = function() end			
        end

        if PossessButton1 then
            PossessButton1:ClearAllPoints()
            PossessButton1:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton2, "TOPLEFT", 25, 30)
			PossessButton1.SetPoint = function() end
        end
                
	elseif StackedLayout then
		---------------------------------------
        -- Stacked bar layout 12 x 3
        ---------------------------------------
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 263, -30, spacing)
        ActionButton1.SetPoint = function() end
        
		MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, spacing)
        MultiBarBottomLeft.SetPoint = function() end
		
		MultiBarBottomRight:ClearAllPoints()
        MultiBarBottomRight:SetPoint("BOTTOMLEFT", MultiBarBottomLeftButton1, "TOPLEFT", 0, spacing)
		MultiBarBottomRight.SetPoint = function() end
		
        if PetActionButton1 then
            PetActionButton1:SetPoint("BOTTOMLEFT", MultiBarBottomRightButton2, "TOP", 12, spacing)
			PetActionBarFrame:SetScale(.90)
            PetActionButton1.SetPoint = function() end
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("TOPLEFT", ActionButton12, "TOPRIGHT", 50, -25, spacing)
            StanceButton1.SetPoint = function() end
        end
				
	else
        ---------------------------------------
        -- Default layout with 6 x 2 MultiBarBottomRight
        ---------------------------------------		
        ActionButton1:ClearAllPoints()
        ActionButton1:SetPoint("BOTTOMLEFT", MainMenuBar, "TOPLEFT", 136.5, 10, spacing)
        ActionButton1.SetPoint = function() end
        
		MultiBarBottomLeft:ClearAllPoints()
        MultiBarBottomLeft:SetPoint("BOTTOMLEFT", ActionButton1, "TOPLEFT", 0, spacing)
        MultiBarBottomLeft.SetPoint = function() end
		
		MultiBarBottomRightButton7:ClearAllPoints()
        MultiBarBottomRightButton7:SetPoint("TOPLEFT", MultiBarBottomRightButton1, "BOTTOMLEFT", 0, spacing - 2)
		MultiBarBottomRightButton7.SetPoint = function() end

        if PetActionButton1 then
            PetActionButton1:SetPoint("BOTTOMLEFT", ActionButton2, "TOP", 4, 56)
            PetActionButton1.SetPoint = function() end
        end

        if StanceButton1 then
            StanceButton1:ClearAllPoints()
            StanceButton1:SetPoint("BOTTOMLEFT", ActionButton2, "TOP", 4, 56)
			StanceButton1.SetPoint = function() end
        end
		
    end
		
	--[[Multibar right and left positioning because the UI sucks and breaks easily.]]--	
	-- Lock their position (example: place on screen edges)
	MultiBarRight:ClearAllPoints()
	MultiBarRight:SetPoint("RIGHT", UIParent, "RIGHT", 0, -100)  -- Adjust X/Y as needed

	MultiBarLeftButton1:ClearAllPoints()
	MultiBarLeftButton1:SetPoint("RIGHT", MultiBarRightButton1, "LEFT", 0, spacing)
		
	-- Prevent WoW from messing with the bars' scale
	-- Store the desired scale in a variable
	local DESIRED_SCALE = 0.85

	-- Only modify the scale if it's wrong, and don't trigger recursive calls
	local function SafeSetScale(self, scale)
		if math.abs(self:GetEffectiveScale() - DESIRED_SCALE) > 0.01 then
			self:SetScale(DESIRED_SCALE)
		end
	end
	
	-- Initial setup
	MultiBarRight:SetScale(DESIRED_SCALE)
	MultiBarLeft:SetScale(DESIRED_SCALE)

	-- Hook to maintain the scale without recursion
	hooksecurefunc(MultiBarRight, "SetScale", function(self, scale)
		if math.abs(scale - DESIRED_SCALE) > 0.01 then
			SafeSetScale(self, DESIRED_SCALE)
		end
	end)

	hooksecurefunc(MultiBarLeft, "SetScale", function(self, scale)
		if math.abs(scale - DESIRED_SCALE) > 0.01 then
			SafeSetScale(self, DESIRED_SCALE)
		end
	end)
		
    if ExtraActionButton1 then    
        ExtraActionButton1:SetMovable(true)
        ExtraActionButton1:ClearAllPoints()
        --ExtraActionButton1:Hide() 
        ExtraActionButton1:SetPoint("BOTTOM", MainMenuBar, "TOP", -500, (spacing +60))
        ExtraActionButton1:SetFrameStrata("MEDIUM")
        ExtraActionButton1:SetFrameLevel(5)
    end

    -- ZoneAbilityFrame doesn't exist in Classic
    -- if ZoneAbilityFrame then
    --     ZoneAbilityFrame:SetMovable(true)  
    --     ZoneAbilityFrame:ClearAllPoints()
    --     --ZoneAbilityFrame.Style:Hide()
    --     ZoneAbilityFrame.SpellButtonContainer:SetPoint("BOTTOM", MainMenuBar, "TOP", -500, (spacing +60))
    --     ZoneAbilityFrame.SpellButtonContainer:SetFrameStrata("MEDIUM")
    --     ZoneAbilityFrame.SpellButtonContainer:SetFrameLevel(5)
    -- end

    if PossessBarFrame then
        PossessBarFrame:SetMovable(true)
        PossessBarFrame:ClearAllPoints()
        PossessBarFrame:SetScale(1)
        PossessBarFrame:SetPoint("BOTTOMLEFT", ActionButton1, "TOP", 0, 60)
        PossessBarFrame:SetUserPlaced(true)
        PossessBarFrame:SetMovable(false)
    end

    -- PlayerPowerBarAlt doesn't exist in Classic
    -- if PlayerPowerBarAlt then
    --     PlayerPowerBarAlt:SetMovable(true)
    --     PlayerPowerBarAlt:SetUserPlaced(true)
    --     PlayerPowerBarAlt:ClearAllPoints()
    --     PlayerPowerBarAlt:SetPoint("TOP", UIParent, "TOP", 0, -160)
    --     PlayerPowerBarAlt:SetMovable(false)
    -- end

    -- Hide Talking Head Frame (not in Classic)
    -- if IsAddOnLoaded("Blizzard_TalkingHeadUI") then
    --     NoTalkingHeads()
    -- else
    --   local waitFrame = CreateFrame("FRAME")
    --   waitFrame:RegisterEvent("ADDON_LOADED")
    --   waitFrame:SetScript("OnEvent", function(self, event, arg1)
    --     if arg1 == "Blizzard_TalkingHeadUI" then
    --       NoTalkingHeads()
    --       waitFrame:UnregisterAllEvents()
    --     end
    --   end)
    -- end

    -- Clean up XP Bar (Classic only has XP, no Azerite)
    -- Classic doesn't have StatusTrackingBarManager in the same way
    -- if MainMenuExpBar then
    --     MainMenuExpBar:SetAlpha(0)
    -- end

    -- Remove obtrusive artwork from Stance bar when only bottom bar enabled
    if SlidingActionBarTexture0 then SlidingActionBarTexture0:SetAlpha(0) end
    if SlidingActionBarTexture1 then SlidingActionBarTexture1:SetAlpha(0) end

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

    --backdrop settings
    --local bgfile, edgefile = "", ""

    --backdrop
    --local backdropcolor = {0,0,0,1}


    ---------------------------------------
    -- FUNCTIONS
    ---------------------------------------

    if IsAddOnLoaded("Masque") and (dominos or bartender4) then
        return
    end
	
	 -- =============================================
    -- Global Keybind Font Override (NEW CODE)
    -- =============================================
    local function UpdateAllHotkeyFonts()
        local font = "Fonts\\FRIZQT__.TTF"
        local fontSize = 12  -- Adjust this value to your preferred size
        local fontFlags = "OUTLINE"
        local fontColor = {1, 1, 1, 1}  -- White (R,G,B,Alpha)

        -- Main action bars
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

        -- Pet bar
        for i = 1, NUM_PET_ACTION_SLOTS do
            local ho = _G["PetActionButton"..i.."HotKey"]
            if ho then 
                ho:SetFont(font, fontSize, fontFlags)
                ho:SetTextColor(unpack(fontColor))
                ho:ClearAllPoints()
                ho:SetPoint("TOPRIGHT", _G["PetActionButton"..i], "TOPRIGHT", -2, -2)
            end
        end

        -- Stance bar
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

    -- Initial application
    UpdateAllHotkeyFonts()

    -- Reapply after UI reloads or binding changes
    local fontFrame = CreateFrame("Frame")
    fontFrame:RegisterEvent("UPDATE_BINDINGS")
    fontFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
    fontFrame:SetScript("OnEvent", UpdateAllHotkeyFonts)

    local function applyBackground(bu, isLeaveButton)
        if not bu or (bu and bu.bg) then
            return
        end

        --shadows+background
        if bu:GetFrameLevel() < 1 then
            bu:SetFrameLevel(1)
        end

        bu.bg = CreateFrame("Frame", nil, bu, "BackdropTemplate")
        bu.bg:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
        bu.bg:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
        bu.bg:SetFrameLevel(bu:GetFrameLevel() - 1)

        bu.bg.backdropInfo = backdrop
        bu.bg:ApplyBackdrop()
        bu.bg:SetBackdropColor(0, 0, 0, 1)  -- Fixed this line

        bu.bg:SetBackdropBorderColor(0, 0, 0, 0)

        -- Remove the normaltexture
        local nt = bu:GetNormalTexture()
            if not isLeaveButton then
                nt:SetAlpha(0)
                hooksecurefunc(
                bu,
                "SetNormalTexture",
                function(self, texture)
                    --make sure the normaltexture stays the way we want it
                    nt:SetAlpha(0)
                end
                )
            else
                --nt:SetTexCoord(0.07, 0.93, 0.07, 0.93)
				nt:SetTexCoord(0.1, 0.9, 0.1, 0.9)
                nt:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
                nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
            end
        end

        --style extraactionbutton
        local function styleExtraActionButton(bu)
            if not bu or (bu and bu.rabs_styled) then
                return
            end
        local name = bu:GetName() or bu:GetParent():GetName()
        local style = bu.style or bu.Style
        local icon = bu.icon or bu.Icon
        local cooldown = bu.cooldown or bu.Cooldown
        local ho = _G[name .. "HotKey"]

        -- remove the style background theme
        if style then
            style:SetTexture(nil)
            hooksecurefunc(
                style,
                "SetTexture",
            function(self, texture)
                if texture then
                    self:SetTexture(nil)
                end
            end
            )
        end

        --icon
        if icon then
            --icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetAllPoints(bu)
            icon:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
            icon:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
        end

        --cooldown
        if cooldown then cooldown:SetAllPoints(icon) end

        --apply background
        if not bu.bg then applyBackground(bu) end
    end

	--initial style func
	local function styleActionButton(bu)
		
		if not bu or (bu and bu.rabs_styled) then
			return
		end

		local action = bu.action
		local name = bu:GetName()
		local ic = _G[name .. "Icon"]
		local co = _G[name .. "Count"]
		local bo = _G[name .. "Border"]
		local ho = _G[name .. "HotKey"]
		local cd = _G[name .. "Cooldown"]
		local na = _G[name .. "Name"]
		local fl = _G[name .. "Flash"]
		local nt = _G[name .. "NormalTexture"]
		local fbg = _G[name .. "FloatingBG"]
		local fob = _G[name .. "FlyoutBorder"]
		local fobs = _G[name .. "FlyoutBorderShadow"]
	
		if fbg then
			fbg:Hide()
		end --floating background
			
		--flyout border stuff
		if fob then
			fob:SetTexture(nil)
		end

		if fobs then
			fobs:SetTexture(nil)
		end

		if bo then bo:SetTexture(nil) end --hide the border (plain ugly, sry blizz)

		--hotkey
		if ho then
			ho:ClearAllPoints()
			ho:SetPoint("TOPLEFT", bu, -2, -2)
		end
		   
		--macro name
		if na then na:Hide() end

		if not nt then
			--fix the non existent texture problem (no clue what is causing this)
			nt = bu:GetNormalTexture()
		end
			
		--cut the default border of the icons
		if ic then
			--ic:SetTexCoord(0.07, 0.93, 0.07, 0.93)
			ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
			ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
		end
		
		--adjust the cooldown frame
		if cd then
			cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
			cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
		end

		--make the normaltexture match the buttonsize
		if nt then
			nt:SetAllPoints(bu)
			nt:SetAlpha(0)

			--hook to prevent Blizzard from reseting our colors
			hooksecurefunc(
				nt,
				"SetVertexColor",
				function(nt, r, g, b, a)
					if nt then nt:SetAlpha(0) end
				end
			)
		end

		--shadows+background
		if not bu.bg then
		  applyBackground(bu)
		end
		bu.rabs_styled = true

		if bartender4 then --fix the normaltexture
		  if nt then
			nt:SetTexCoord(0, 1, 0, 1)
			nt.SetTexCoord = function()
				return
			end 
		  end
			
		  bu.SetNormalTexture = function()
			  return
		  end
		end
	end

	-- style leave button
	local function styleLeaveButton(bu)
		if not bu or (bu and bu.rabs_styled) then
			return
		end

		--shadows+background
		if not bu.bg then
			applyBackground(bu, true)
		end

		bu.rabs_styled = true
	end

	--style pet buttons
	local function stylePetButton(bu)
		if not bu or (bu and bu.rabs_styled) then
			return
		end
		
		local name = bu:GetName()
		local ic = _G[name .. "Icon"]
		local fl = _G[name .. "Flash"]
		local nt = _G[name .. "NormalTexture2"]
		local cd = _G[name .. "Cooldown"]
		
		if nt then nt:SetAllPoints(bu) end

		--cut the default border of the icons and make them shiny
		if ic then
			ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
			ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
		end
		
		--adjust the cooldown frame
		if cd then
			cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
			cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
		end

		--shadows+background
		if not bu.bg then
			applyBackground(bu)
		end

		bu.rabs_styled = true
	 end

	--style stance buttons
	local function styleStanceButton(bu)
		if not bu or (bu and bu.rabs_styled) then
		  return
		end
		local name = bu:GetName()
		local ic = _G[name .. "Icon"]
		local fl = _G[name .. "Flash"]
		local nt = _G[name .. "NormalTexture2"]
		if nt then nt:SetAllPoints(bu) end

		--shadows+background
		if not bu.bg then
		  applyBackground(bu)
		end
		bu.rabs_styled = true
	end

	--style possess buttons
	local function stylePossessButton(bu)
		if not bu or (bu and bu.rabs_styled) then
			return
		end

		local name = bu:GetName()
		local ic = _G[name .. "Icon"]
		local fl = _G[name .. "Flash"]
		local nt = _G[name .. "NormalTexture2"]
		if nt then nt:SetAllPoints(bu) end
		
		--cut the default border of the icons and make them shiny
		if ic then
			ic:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
			ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2)
		end
				
		--shadows+background
		if not bu.bg then
			applyBackground(bu)
		end

		bu.rabs_styled = true
	end

	--update hotkey func
	local function updateHotkey(self, actionButtonType)
		local ho = _G[self:GetName() .. "HotKey"]
		if ho and ho:IsShown() then
			ho:Hide()
		end
	end

	-- Make sure to style all buttons regardless of layout mode
	for i = 1, NUM_ACTIONBAR_BUTTONS do
		styleActionButton(_G["ActionButton"..i])
		styleActionButton(_G["MultiBarBottomLeftButton"..i])
		styleActionButton(_G["MultiBarBottomRightButton"..i])
		styleActionButton(_G["MultiBarLeftButton"..i])  -- This is now properly styled
		styleActionButton(_G["MultiBarRightButton"..i]) -- This is now properly styled
	end

	-- OverrideActionBar doesn't exist in Classic
	-- for i = 1, 6 do
	--     styleActionButton(_G["OverrideActionBarButton" .. i])
	-- end

	--style leave button
	if MainMenuBarVehicleLeaveButton then
		styleLeaveButton(MainMenuBarVehicleLeaveButton)
	end
	if rABS_LeaveVehicleButton then
		styleLeaveButton(rABS_LeaveVehicleButton)
	end

	--petbar buttons
	for i = 1, NUM_PET_ACTION_SLOTS do
		stylePetButton(_G["PetActionButton" .. i])
	end

	--stance buttons
	for i = 1, NUM_STANCE_SLOTS do
		styleStanceButton(_G["StanceButton" .. i])
	end

	--possess buttons
	--for i = 1, NUM_POSSESS_SLOTS do
	--    stylePossessButton(_G["PossessButton" .. i])
	--end

	--extraactionbutton1
	if ExtraActionButton1 then
		styleExtraActionButton(ExtraActionButton1)
	end
	-- ZoneAbilityFrame doesn't exist in Classic
	-- styleExtraActionButton(ZoneAbilityFrame.SpellButton)-- TODO: Fix

	--spell flyout
	if SpellFlyoutBackgroundEnd then SpellFlyoutBackgroundEnd:SetTexture(nil) end
	if SpellFlyoutHorizontalBackground then SpellFlyoutHorizontalBackground:SetTexture(nil) end
	if SpellFlyoutVerticalBackground then SpellFlyoutVerticalBackground:SetTexture(nil) end

	local function checkForFlyoutButtons(self)
		local NUM_FLYOUT_BUTTONS = 10
		for i = 1, NUM_FLYOUT_BUTTONS do
			styleActionButton(_G["SpellFlyoutButton" .. i])
		end
	end

	if SpellFlyout then
		SpellFlyout:HookScript("OnShow", checkForFlyoutButtons)
	end

	--dominos styling
	if dominos then
		print("Dominos found")
		for i = 1, 60 do
			styleActionButton(_G["DominosActionButton" .. i])
		end
	end

	--bartender4 styling
	if bartender4 then
		--print("Bartender4 found")
		for i = 1, 120 do
			styleActionButton(_G["BT4Button" .. i])
			stylePetButton(_G["BT4PetButton" .. i])
		end
	end      
end

local a = CreateFrame("Frame")
a:RegisterEvent("PLAYER_LOGIN")
a:SetScript("OnEvent", init)