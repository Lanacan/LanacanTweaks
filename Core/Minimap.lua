-------------
-- MINIMAP --
-------------
	-- Increase Minimap Size
	Minimap:SetScale(1.2)
	Minimap:ClearAllPoints()
	Minimap:SetPoint("TOPRIGHT", UIParent, -5, -13)

	--mail
	MiniMapMailFrame:ClearAllPoints()
	MiniMapMailFrame:SetPoint("TOPRIGHT",Minimap,-0,0)
	MiniMapMailBorder:Hide()
	MiniMapMailIcon:SetTexture("Interface\\MINIMAP\\TRACKING\\Mailbox.blp")
	MiniMapMailBorder:SetBlendMode("ADD")
	MiniMapMailBorder:ClearAllPoints()
	MiniMapMailBorder:SetPoint("CENTER",MiniMapMailFrame,0.5,1.5)
	MiniMapMailBorder:SetSize(27,27)
	MiniMapMailBorder:SetAlpha(0.5)

	function handleMinimapZoneText()
		
		-- Mouseover zone text
		MinimapBorderTop:Hide()
		MinimapZoneText:Hide()
		local function GetZoneColor()
			local zoneType = GetZonePVPInfo()
			if zoneType == "sanctuary" then
				return 0.4, 0.8, 0.94
			elseif zoneType == "arena" then
				return 1, 0.1, 0.1
			elseif zoneType == "friendly" then
				return 0.1, 1, 0.1
			elseif zoneType == "hostile" then
				return 1, 0.1, 0.1
			elseif zoneType == "contested" then
				return 1, 0.8, 0
			else
				return 1, 1, 1
			end
		end
			
		local MainZone = Minimap:CreateFontString(nil, "OVERLAY")
		MainZone:SetFont(STANDARD_TEXT_FONT, 14, "THINOUTLINE")
		MainZone:SetPoint("TOP", Minimap, "TOP", 0, 34)
		MainZone:SetTextColor(1, 1, 1)
		MainZone:SetAlpha(0)
		MainZone:SetSize(130, 32)
		MainZone:SetJustifyV("BOTTOM")
		MainZone:SetWordWrap(true)
		MainZone:SetNonSpaceWrap(true)
		MainZone:SetMaxLines(2)

		local SubZone = Minimap:CreateFontString(nil, "OVERLAY")
		SubZone:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")
		SubZone:SetPoint("TOP", MainZone, "BOTTOM", 0, -1)
		SubZone:SetTextColor(1, 1, 1)
		SubZone:SetAlpha(0)
		SubZone:SetSize(130, 26)
		SubZone:SetJustifyV("TOP")
		SubZone:SetWordWrap(true)
		SubZone:SetNonSpaceWrap(true)
		SubZone:SetMaxLines(2)

		Minimap:HookScript("OnEnter", function(self)
			if not IsShiftKeyDown() then
				SubZone:SetTextColor(GetZoneColor())
				SubZone:SetText(GetSubZoneText())
				securecall("UIFrameFadeIn", SubZone, 0.15, SubZone:GetAlpha(), 1)
				MainZone:SetTextColor(GetZoneColor())
				MainZone:SetText(GetRealZoneText())
				securecall("UIFrameFadeIn", MainZone, 0.15, MainZone:GetAlpha(), 1)
			end
		end)

		Minimap:HookScript("OnLeave", function(self)
			securecall("UIFrameFadeOut", SubZone, 0.15, SubZone:GetAlpha(), 0)
			securecall("UIFrameFadeOut", MainZone, 0.15, MainZone:GetAlpha(), 0)
		end)      
	end

	--[[QueueStatusMinimapButton (lfg) -- Old Position
	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetParent(Minimap)
	QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, 0, 0)
	QueueStatusMinimapButtonBorder:Hide()
	]]--

	QueueStatusMinimapButton:ClearAllPoints()
	QueueStatusMinimapButton:SetPoint("BOTTOMLEFT", Minimap, 4, 4)
	QueueStatusMinimapButton:SetSize(14, 14)
	QueueStatusMinimapButton:SetHighlightTexture(nil)

	QueueStatusMinimapButtonBorder:SetTexture()
	QueueStatusMinimapButton.Eye:Hide()

	hooksecurefunc("EyeTemplate_StartAnimating", function(self)
		self:SetScript("OnUpdate", nil)
	end)

	QueueStatusMinimapButton.Text = QueueStatusMinimapButton:CreateFontString(nil, "OVERLAY")
	QueueStatusMinimapButton.Text:SetFont(STANDARD_TEXT_FONT, 15, "OUTLINE")
	QueueStatusMinimapButton.Text:SetPoint("TOP", QueueStatusMinimapButton)
	QueueStatusMinimapButton.Text:SetTextColor(1, 0.4, 0)
	QueueStatusMinimapButton.Text:SetText("Q")

	-- Queue Tooltip fix 
	QueueStatusFrame:ClearAllPoints()
	QueueStatusFrame:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 282, -10)

	--Garrison Icon
	GarrisonLandingPageMinimapButton:SetSize(32, 32)
	hooksecurefunc("GarrisonLandingPageMinimapButton_UpdateIcon", function(self)
		self:ClearAllPoints()
		self:SetPoint("BOTTOMRIGHT", Minimap, 10, -5)
		self:SetScale(0.75)
	end)

	-- Skin the ticket status frame
	TicketStatusFrame:ClearAllPoints()
	TicketStatusFrame:SetPoint("BOTTOMRIGHT", UIParent, -25, -33)
	TicketStatusFrameButton:HookScript("OnShow", function(self)
		self:SetBackdrop({
			bgFile = "Interface\\Buttons\\WHITE8x8",
			insets = {
				left = 3,
				right = 3,
				top = 3,
				bottom = 3
			}
		})
		self:SetBackdropColor(0, 0, 0, 0.5)
		self:CreateBeautyBorder(12)
	end)

	function init(self, event)
		--------------------------------------------------------------------
		-- MINIMAP BORDER
		--------------------------------------------------------------------
		local CleanMapBorder = CreateFrame("Frame", "CleanMapBorder", Minimap, "BackdropTemplate")
		CleanMapBorder:SetFrameLevel(0)
		CleanMapBorder:SetFrameStrata("background")
		CleanMapBorder:SetHeight(142)
		CleanMapBorder:SetWidth(142)
		CleanMapBorder:SetPoint("CENTER",0,0)
		CleanMapBorder:SetScale(1)

		CleanMapBorder.backdropInfo = {
			bgFile = SQUARE_TEXTURE,
			edgeFile = SQUARE_TEXTURE,
			tile = false, tileSize = 0, edgeSize = 1,
			insets = { left = -1, right = -1, top = -1, bottom = -1 }
		}
		CleanMapBorder:ApplyBackdrop()
		CleanMapBorder:SetBackdropColor(0,0,0,1)
		CleanMapBorder:SetBackdropBorderColor(0,0,0,1)
		CleanMapBorder:Show()

		-- Square Minimap
		Minimap:SetMaskTexture(SQUARE_TEXTURE)
		
		--Blizzard_TimeManager
		LoadAddOn("Blizzard_TimeManager")
		TimeManagerClockButton:GetRegions():Hide()
		TimeManagerClockButton:ClearAllPoints()
		TimeManagerClockButton:SetPoint("BOTTOM",0,-5)
		TimeManagerClockTicker:SetFont(STANDARD_TEXT_FONT,12,"OUTLINE")	
		TimeManagerClockTicker:SetTextColor(1,1,1,1)

		--GameTimeFrame
		GameTimeFrame:SetParent(Minimap)
		GameTimeFrame:SetScale(1)
		GameTimeFrame:ClearAllPoints()
		GameTimeFrame:SetPoint("TOPRIGHT",Minimap,-18,-18)
		GameTimeFrame:SetHitRectInsets(0, 0, 0, 0)
		GameTimeFrame:GetNormalTexture():SetTexCoord(0,1,0,1)
		GameTimeFrame:SetPushedTexture(nil)
		GameTimeFrame:SetHighlightTexture (nil)
		local fs = GameTimeFrame:GetFontString()
		fs:ClearAllPoints()
		fs:SetPoint("CENTER",0,-5)
		fs:SetFont(STANDARD_TEXT_FONT,20)
		fs:SetTextColor(0.2,0.2,0.1,0.9)

		-- Hide Border
		MinimapBorder:Hide()
		MinimapBorderTop:Hide()

		MinimapZoomIn:Hide()
		MinimapZoomOut:Hide()
		MiniMapWorldMapButton:Hide()

		-- Hide/unhide Minimap zone text
		handleMinimapZoneText()

		MiniMapTracking:Hide()
		MiniMapTracking.Show = kill
		MiniMapTracking:UnregisterAllEvents()

		-- Hide Calendar
		GameTimeFrame:Hide()

		-- Mousewheel Zoom
		Minimap:EnableMouseWheel(true)
		Minimap:SetScript("OnMouseWheel", function(self, z)
			local c = Minimap:GetZoom()
			if(z > 0 and c < 5) then
				Minimap:SetZoom(c + 1)
			elseif(z < 0 and c > 0) then
				Minimap:SetZoom(c - 1)
			end
		end)

		-- Mouse shortcuts
		Minimap:SetScript("OnMouseUp", function(self, btn)
			if btn == "RightButton" then
				_G.GameTimeFrame:Click()
			elseif btn == "MiddleButton" then
				_G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, self)
			else
				_G.Minimap_OnClick(self)
			end
		end)

		------------
		-- XP Bar --
		------------
		local maxPlayerLevel = GetMaxLevelForPlayerExpansion()
		if (UnitLevel("player") < maxPlayerLevel) then
			local xpInfo = {
				xp = 0,
				totalLevelXP = 0,
				xpToNextLevel = 0,
				tPercent = 0
			}

			--match bar height to map edge size
			--local _, height = Minimap:GetHeight() --143

			local xpBar = createStatusBar(
				"CleanXp",
				CleanMapBorder,
				14, CleanMapBorder:GetHeight() + 2,
				{ r = 0.6, g = 0, b = 0.6 }
			)
			xpBar:SetFrameStrata("medium")
			xpBar:SetPoint("RIGHT", CleanMapBorder, "LEFT", 0, 0)

			xpBar:SetScript("OnEnter", function()
				GameTooltip:SetOwner(xpBar);
				GameTooltip:AddLine("Experience")
				GameTooltip:AddLine(abbrNumber(xpInfo.xp) .. "/" .. abbrNumber(xpInfo.totalLevelXP) .. " (" .. round(xpInfo.tPercent, 1) .. "%)", 1, 1, 1)
				GameTooltip:Show()
			end)

			xpBar:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)

			-- artifactBar.Text = artifactBar:CreateFontString(nil, "OVERLAY")
			-- artifactBar.Text:SetFontObject(GameFontHighlight)
			-- artifactBar.Text:SetPoint("CENTER", artifactBar, "CENTER")

			local artifactInfo = {
				xpToNextLevel = 0,
				xp = 0,
				totalLevelXP = 2000,
				tPercent = 0
			}
			local function getBarData()
				if (UnitLevel("player") == maxPlayerLevel) then
					xpBar:Hide()
					return
				end
				local xp = UnitXP("player")
				local totalLevelXP = UnitXPMax("player")
				xpInfo.xpToNextLevel = totalLevelXP - xp

				xpInfo.xp = xp
				xpInfo.totalLevelXP = totalLevelXP
				xpInfo.tPercent = xp / totalLevelXP * 100

				xpBar.Status:SetMinMaxValues(0, xpInfo.totalLevelXP)
				xpBar.Status:SetValue(xpInfo.xp)
				xpBar:Show()
			end

			-- Initialise bar
			getBarData()

			local eventFrame = CreateFrame("Frame")
			eventFrame:RegisterEvent("PLAYER_XP_UPDATE")
			eventFrame:SetScript("OnEvent", getBarData)
		end
	end

	local CF=CreateFrame("Frame")
	CF:RegisterEvent("PLAYER_LOGIN")
	CF:SetScript("OnEvent", init)
