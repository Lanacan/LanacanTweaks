-- Auto-decline, auto-resurrect, duel cancel, alt-buy stacks

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_DEAD")
frame:RegisterEvent("DUEL_REQUESTED")
frame:RegisterEvent("RESURRECT_REQUEST")
--frame:RegisterEvent("GOSSIP_SHOW") Coming Soonish....

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "DUEL_REQUESTED" then
        CancelDuel()
        StaticPopup_Hide("DUEL_REQUESTED")
    elseif event == "RESURRECT_REQUEST" then
        if not UnitAffectingCombat("player") then
            AcceptResurrect()
            StaticPopup_Hide("RESURRECT_NO_TIMER")
        end
    elseif event == "PLAYER_DEAD" then
        if UnitInBattleground("player") then
            RepopMe()
        end
    end

    if LossOfControlFrame then
        LossOfControlFrame:ClearAllPoints()
        LossOfControlFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
end)

-- Alt-click full stack buying
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
