---------------------------
-- Lanacan Auto Actions --
-- Auto-decline duels, auto-accept resurrection,
-- auto-repop in battlegrounds, and alt-click full stack buying
---------------------------

local frame = CreateFrame("Frame")

-- Register relevant events
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("DUEL_REQUESTED")
frame:RegisterEvent("RESURRECT_REQUEST")
-- frame:RegisterEvent("GOSSIP_SHOW") -- Coming soon...

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "DUEL_REQUESTED" then
        -- Automatically decline duel requests
        CancelDuel()
        StaticPopup_Hide("DUEL_REQUESTED")

    elseif event == "RESURRECT_REQUEST" then
        -- Auto-accept resurrection if not in combat
        if not UnitAffectingCombat("player") then
            AcceptResurrect()
            StaticPopup_Hide("RESURRECT_NO_TIMER")
        end

    elseif event == "PLAYER_DEAD" then
        -- Automatically release spirit in battlegrounds
        if UnitInBattleground("player") then
            RepopMe()
        end
    end

    -- Center LossOfControlFrame on screen
    if LossOfControlFrame then
        LossOfControlFrame:ClearAllPoints()
        LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end)

-- Add colored label for stack buying in vendor tooltip
local NEW_ITEM_VENDOR_STACK_BUY = ITEM_VENDOR_STACK_BUY
ITEM_VENDOR_STACK_BUY = "|cffa9ff00" .. NEW_ITEM_VENDOR_STACK_BUY .. "|r"

-- Hook merchant item click to buy full stack on Alt-click
local origMerchantItemButton_OnModifiedClick = MerchantItemButton_OnModifiedClick
function MerchantItemButton_OnModifiedClick(self, ...)
    origMerchantItemButton_OnModifiedClick(self, ...)

    if IsAltKeyDown() then
        local link = GetMerchantItemLink(self:GetID())
        if link then
            local _, _, _, _, _, _, _, maxStack = GetItemInfo(link)
            local _, _, _, quantity = GetMerchantItemInfo(self:GetID())

            if maxStack and maxStack > 1 then
                -- Calculate how many stacks to buy based on max stack size
                BuyMerchantItem(self:GetID(), floor(maxStack / quantity))
            end
        end
    end
end
