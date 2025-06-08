-- QoL automation and UI tweaks for WoW Classic
local addonName, addonTable = ...

-- === Utility Wrappers ===
local GetBagSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local GetItemLink = GetContainerItemLink or (C_Container and C_Container.GetContainerItemLink)
local UseItem = UseContainerItem or (C_Container and C_Container.UseContainerItem)

-- === Junk Selling ===
local function SellGrayItems()
    for bag = 0, 4 do
        local slots = GetBagSlots and GetBagSlots(bag)
        if slots then
            for slot = 1, slots do
                local link = GetItemLink and GetItemLink(bag, slot)
                if link then
                    local _, _, rarity = GetItemInfo(link)
                    if rarity == LE_ITEM_QUALITY_POOR then
                        if UseItem then
                            UseItem(bag, slot)
                        end
                    end
                end
            end
        end
    end
end

-- === XP and Reputation Bars ===
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

-- === Objective Tracker Scaling ===
local function scaleObjectiveTracker()
    if ObjectiveTrackerFrame then
        ObjectiveTrackerFrame:SetScale(0.95)
    end
end

-- === Main Event Handler ===
local function eventHandler(self, event, ...)
    if event == "PLAYER_ENTERING_WORLD" then
        -- Set CVars
        local cvars = {
            useCompactPartyFrames = 1,
            showDungeonEntrancesOnMap = 1,
            deselectOnClick = 1,
            autoClearAFK = 1,
            autoLootDefault = 1,
            interactOnLeftClick = 0,
            doNotFlashLowHealthWarning = 1,
            showTutorials = 0,
            Outline = 2,
            chatBubbles = 1,
            chatBubblesParty = 0,
            minimapTrackingShowAll = 1,
            alwaysCompareItems = 1,
            profanityFilter = 0,
            blockTrades = 0,
            blockChannelInvites = 0,
            showTimestamps = 'none',
            whisperMode = 'inline',
            lockActionBars = 1,
            alwaysShowActionBars = 0,
            cameraDistanceMaxZoomFactor = 2.6,
            cameraSmoothStyle = 0,
            mouseInvertPitch = 0,
            autoInteract = 0,
            cameraYawMoveSpeed = 90,
            Sound_EnableAllSound = 1,
            Sound_EnableSFX = 1,
            Sound_EnableMusic = 0,
            Sound_EnableAmbience = 1,
            Sound_EnableDialog = 1,
            Sound_EnableErrorSpeech = 0,
            Sound_MasterVolume = 0.5,
            Sound_SFXVolume = 0.5,
            Sound_MusicVolume = 0.2,
            Sound_AmbienceVolume = 0.5,
            Sound_DialogVolume = 0.6,
            ActionButtonUseKeyDown = 1,
            autoQuestWatch = 1,
            autoSelfCast = 1,
            chatStyle = 'classic',
            lootUnderMouse = 1,
            screenshotFormat = 'jpg',
            screenshotQuality = 10,
            scriptErrors = 1,
            trackQuestSorting = 'top',
            instantQuestText = 1,
			countdownForCooldowns = 1,
			timeMgrUseMilitaryTime = 1,
			timeMgrUseLocalTime = 1,
			showTargetOfTarget = 1,
			showTargetCastbar = 1,
        }
        for k, v in pairs(cvars) do SetCVar(k, v) end

        hideXPBar()
        scaleObjectiveTracker()
        return
    end

    if event == "DUEL_REQUESTED" then
        CancelDuel()
        StaticPopup_Hide("DUEL_REQUESTED")
        return
    end

    if event == "RESURRECT_REQUEST" then
        if not UnitAffectingCombat("player") then
            AcceptResurrect()
            StaticPopup_Hide("RESURRECT_NO_TIMER")
        end
        return
    end

    if event == "PLAYER_DEAD" then
        if UnitInBattleground("player") then
            RepopMe()
        end
        return
    end

	--[[ Not fully working.... 
    if event == "GOSSIP_SHOW" then
        if IsShiftKeyDown() then return end

        local activeQuests = C_GossipInfo.GetActiveQuests()
        local availableQuests = C_GossipInfo.GetAvailableQuests()
        if (activeQuests and #activeQuests > 0) or (availableQuests and #availableQuests > 0) then
            return
        end

        local gossipOptions = C_GossipInfo.GetOptions()
        if gossipOptions then
            for _, option in ipairs(gossipOptions) do
                if option.name and option.name:lower():find("transmog") then
                    C_GossipInfo.SelectOption(option.gossipOptionID)
                    return
                end
            end
            for _, option in ipairs(gossipOptions) do
                if option.name and option.name ~= "" then
                    C_GossipInfo.SelectOption(option.gossipOptionID)
                    return
                end
            end
        end
    end
	]]--

    if LossOfControlFrame then
        LossOfControlFrame:ClearAllPoints()
        LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end

-- === Merchant Hook for Auto Repair/Sell ===
local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")
g:SetScript("OnEvent", function()
    if CanMerchantRepair() then
        local cost = GetRepairAllCost()
        if cost > 0 then
            local money = GetMoney()
            if IsInGuild() then
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

    SellGrayItems()
end)

-- === Alt-Click Full Stack Buying ===
local NEW_ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY
ITEM_VENDOR_STACK_BUY = "|cffa9ff00" .. NEW_ITEM_VENDOR_STACK_BUY .. "|r"

local origMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
    origMerchantItemButton_OnModifiedClick(self, ...)
    if IsAltKeyDown() then
        local link = GetMerchantItemLink(self:GetID())
        if link then
            local _, _, _, _, _, _, _, maxStack = GetItemInfo(link)
            local _, _, _, quantity = GetMerchantItemInfo(self:GetID())
            if maxStack and maxStack > 1 then
                BuyMerchantItem(self:GetID(), floor(maxStack / quantity))
            end
        end
    end
end

-- === Event Frame Registration ===
local frame = CreateFrame("Frame", "FixesFrame")
frame:RegisterEvent("GOSSIP_SHOW")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("DUEL_REQUESTED")
frame:RegisterEvent("RESURRECT_REQUEST")
frame:SetScript("OnEvent", eventHandler)

-- === Confirmation ===
--print("|cFF0048ff Fixes|r loaded")