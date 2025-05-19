local frame = CreateFrame("FRAME", "FixesFrame")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")

LoadAddOn('Blizzard_TradeSkillUI')

-- Add button to filter to newest shit in tradeskills
local function filterNewShit()
	local categoryList = {C_TradeSkillUI.GetCategories()}
	for _, v in ipairs(categoryList) do
		local catInfo = C_TradeSkillUI.GetCategoryInfo(v)
		if string.match(catInfo.name, "Shadowlands") then
			C_TradeSkillUI.ClearRecipeCategoryFilter()
			C_TradeSkillUI.SetRecipeCategoryFilter(catInfo.categoryID)
		end
	end
end

local function setPin(mapx, mapy)
	local map = C_Map.GetBestMapForUnit("player")
	if not C_Map.CanSetUserWaypointOnMap(map) then
		return
	end
	C_Map.ClearUserWaypoint()
	local mapPoint = UiMapPoint.CreateFromVector2D(map, {x=mapx, y=mapy})
	C_Map.SetUserWaypoint(mapPoint)
	print("Pin set.")
end

local function slashHandler(msg, editbox)
	if string.len(msg) ~= 10 then
		print("Bad coords. Should be like: /pin 12.3 45.6")
		return
	end
	local x = tonumber(string.sub(msg, 1, 4)) / 100
	local y = tonumber(string.sub(msg, 7, 10)) / 100
	if x == nil or y == nil then
		return
	else
		setPin(x, y)
	end
end

-- Auto vendor and repair
	local g = CreateFrame("Frame")
        g:RegisterEvent("MERCHANT_SHOW")
        g:SetScript("OnEvent", function()
            if (CanMerchantRepair()) then
				--print("REPAIR")
                local cost = GetRepairAllCost()
                if cost > 0 then
                    local money = GetMoney()
                    if IsInGuild() and db == 'Guild' then
                        local guildMoney = GetGuildBankWithdrawMoney()
                        if guildMoney > GetGuildBankMoney() then
                            guildMoney = GetGuildBankMoney()
                        end

                        if guildMoney > cost and CanGuildBankRepair() then
                            RepairAllItems(1)
                            print(format("|cfff07100Repair cost covered by G-Bank: %.1fg|r", cost * 0.0001))
                            return
                        end
                    end
                    if money > cost then
                        RepairAllItems()
                        print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
                    else
                        print("Not enough gold to cover the repair cost.")
                    end
                end
            end
        end)
		
		local g = CreateFrame("Frame")
        g:RegisterEvent("MERCHANT_SHOW")
        g:SetScript("OnEvent", function()
            local bag, slot
            for bag = 0, 4 do
                for slot = 0, C_Container.GetContainerNumSlots(bag) do
                    local link = C_Container.GetContainerItemLink(bag, slot)
                    if link and (select(3, GetItemInfo(link)) == 0) then
                        C_Container.UseContainerItem(bag, slot)
                    end
                end
            end
        end)

	--HIDE XP BAR
	StatusTrackingBarManager:Hide()
	--SCALE OBJECTIVE TRACKER
	ObjectiveTrackerFrame:SetScale(0.95)
	
	--HIDE MINIMAP ICONS
	ExpansionLandingPageMinimapButton:SetScale(.001)
	ExpansionLandingPageMinimapButton:SetAlpha(0)



local function eventHandler(self, event, ...)

	-- Force some sensible settings
	if event == "PLAYER_ENTERING_WORLD" then
		
		-- Grouping	
		SetCVar("useCompactPartyFrames", 1)
		SetCVar("showDungeonEntrancesOnMap", 1)
				
		-- Controls
		SetCVar("deselectOnClick", 1)
		SetCVar("autoDismountFlying", 1)
		SetCVar("autoClearAFK", 1)
		SetCVar("autoLootDefault", 1)
		SetCVar("interactOnLeftClick", 0)

		-- Combat
		SetCVar("spellActivationOverlayOpacity", 1)
		SetCVar("doNotFlashLowHealthWarning", 1)
		SetCVar("lossOfControl", 1)

		-- Display
		SetCVar("hideAdventureJournalAlerts", 0) -- legion
		SetCVar("showTutorials", 0)
		SetCVar("enableFloatingCombatText", 0) -- legion
		SetCVar("Outline", 2)
		SetCVar("ShowQuestUnitCircles", 0) -- legion, find the category
		SetCVar("findYourselfMode", -1) -- legion
		SetCVar("chatBubbles", 1)
		SetCVar("chatBubblesParty", 0)
		SetCVar("minimapTrackingShowAll",1)
		SetCVar("alwaysCompareItems",1)		
		
		-- Social
		SetCVar("profanityFilter", 0)
		SetCVar("spamFilter", 0)
		SetCVar("guildMemberNotify", 1)
		SetCVar("blockTrades", 0)
		SetCVar("blockChannelInvites", 0)
		SetCVar("showToastOnline", 0)
		SetCVar("showToastOffline", 0)
		SetCVar("showToastBroadcast", 0)
		SetCVar("showToastFriendRequest", 0)
		SetCVar("showToastWindow", 0)
		SetCVar("enableTwitter", 0)
		SetCVar("showTimestamps", 'none')
		SetCVar("whisperMode", 'inline')

		-- ActionBars
		SetCVar("lockActionBars", 1)
		SetCVar("alwaysShowActionBars", 0)
		SetCVar("countdownForCooldowns", 0)
		
		ExtraActionButton1:SetScale(1) --Scale the button
		ExtraActionButton1.style:SetAlpha(0) -- Hide background texture
		
		-- Camera
		SetCVar("cameraWaterCollision", 0)
		SetCVar("cameraDistanceMaxZoomFactor", 2.6) -- 2.6 is default max
		SetCVar("cameraSmoothStyle", 0)

		-- Mouse
		SetCVar("enableMouseSpeed", 0)
		SetCVar("mouseInvertPitch", 0)
		SetCVar("autoInteract", 0)
		SetCVar("cameraYawMoveSpeed", 90)

		-- Accessibility
		SetCVar("enableMovePad", 0)
		SetCVar("movieSubtitle", 1)
		SetCVar("colorblindMode", 0)
		SetCVar("colorblindSimulator", 0)

		-- Sound
		SetCVar("Sound_EnableAllSound", 1)
		SetCVar("Sound_EnableSFX", 1)
		SetCVar("Sound_EnableMusic", 0)
		SetCVar("Sound_EnableAmbience", 1)
		SetCVar("Sound_EnableDialog", 1)
		SetCVar("Sound_EnableErrorSpeech", 0)
		SetCVar("Sound_EnableSoundWhenGameIsInBG", 1)
		SetCVar("Sound_EnableReverb", 0)
		SetCVar("Sound_EnablePositionalLowPassFilter", 1)
		SetCVar("Sound_EnableDSPEffects", 0)
		SetCVar("Sound_MasterVolume", 0.5)
		SetCVar("Sound_SFXVolume", 0.5)
		SetCVar("Sound_MusicVolume", 0.2)
		SetCVar("Sound_AmbienceVolume", 0.5)
		SetCVar("Sound_DialogVolume", 0.6)
		
		SetCVar("ActionButtonUseKeyDown", 1)
		SetCVar("autoQuestWatch", 1) -- unused
		SetCVar("autoSelfCast", 1) -- unused, still a keybind
		SetCVar("chatStyle", 'im')
		SetCVar("lootUnderMouse", 0)
		SetCVar("mapFade", 1)
		SetCVar("removeChatDelay", 1) -- unused
		SetCVar("screenshotFormat", 'png')
		SetCVar("screenshotQuality", 10)
		SetCVar("scriptErrors", 1)
		SetCVar("taintLog", 1)
		SetCVar("trackQuestSorting", 'proximity')
		SetCVar("secureAbilityToggle", 1)
		SetCVar("cursorSizePreferred", 0)
				
		--SetSortBagsRightToLeft(true)
		
		return
	end
	
	
	--Decline Duel
	local frame = CreateFrame("Frame")
        frame:RegisterEvent("DUEL_REQUESTED")
        frame:RegisterEvent("PET_BATTLE_PVP_DUEL_REQUESTED")
        frame:SetScript("OnEvent", function(self, event, name)
            if event == "DUEL_REQUESTED" then
                CancelDuel()
                StaticPopup_Hide("DUEL_REQUESTED")
            elseif event == "PET_BATTLE_PVP_DUEL_REQUESTED" then
                C_PetBattles.CancelPVPDuel()
                StaticPopup_Hide("PET_BATTLE_PVP_DUEL_REQUESTED")
            end
        end)
		
	--AutoRez
	local resurrect = CreateFrame("Frame")
	resurrect:RegisterEvent("RESURRECT_REQUEST")
	resurrect:SetScript("OnEvent", function(_, event, name)
		if event == "RESURRECT_REQUEST" then
			if not UnitAffectingCombat(name) then
				AcceptResurrect()
				StaticPopup_Hide("RESURRECT_NO_TIMER")
			end
		end
	end)

	-- Auto-release in BGs
	if event == "PLAYER_DEAD" then
		local bg = C_PvP.IsBattleground()
		if bg then
			RepopMe()
		end
		return
	end

	-- Skip "sure you wanna vendor that?" for tradeables
	if event == "MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL" then
		StaticPopup_Hide(event)
		SellCursorItem()
		return
	end
	
	-- Skip to transmog/renown
	if event == "GOSSIP_SHOW" then
		if IsShiftKeyDown() then -- Bail if shift is held, in case you want to use trial of style shit
			return
		end
		local gossip = C_GossipInfo.GetOptions()
		for i in ipairs(gossip) do
			if gossip[i].type == "transmogrify" or string.match(gossip[i].name, "Renown") then
				C_GossipInfo.SelectOption(i)
				return
			end
		end
		return
	end
	
	--loss of control
	LossOfControlFrame:ClearAllPoints()
    LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    select(1, LossOfControlFrame:GetRegions()):SetAlpha(0)
    select(2, LossOfControlFrame:GetRegions()):SetAlpha(0)
    select(3, LossOfControlFrame:GetRegions()):SetAlpha(0)
	
	
		
	--Stack Buy		
	local NEW_ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY
        ITEM_VENDOR_STACK_BUY = "|cffa9ff00" .. NEW_ITEM_VENDOR_STACK_BUY .. "|r"
        local origMerchantItemButton_OnModifiedClick = _G.MerchantItemButton_OnModifiedClick
        local function MerchantItemButton_OnModifiedClickHook(self, ...)
            origMerchantItemButton_OnModifiedClick(self, ...)
            if (IsAltKeyDown()) then
                local maxStack = select(8, GetItemInfo(GetMerchantItemLink(self:GetID())))
                local _, _, _, quantity = GetMerchantItemInfo(self:GetID())

                if (maxStack and maxStack > 1) then
                    BuyMerchantItem(self:GetID(), floor(maxStack / quantity))
                end
            end
        end

    MerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClickHook

end

frame:SetScript("OnEvent", eventHandler)

SlashCmdList["FIXES"] = slashHandler
SLASH_FIXES1 = "/pin"

print("|cFF0048ffFixes|r v14")
