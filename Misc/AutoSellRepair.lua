----------------------
-- Lanacan Auto Repair & Junk Seller
-- WoW Classic Addon to automatically repair gear (using guild funds if available) 
-- and sell gray-quality (junk) items when visiting a vendor.
----------------------

-- Compatibility shim for API changes across WoW versions (Classic vs Retail)
local GetBagSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local GetItemLink = GetContainerItemLink or (C_Container and C_Container.GetContainerItemLink)
local UseItem = UseContainerItem or (C_Container and C_Container.UseContainerItem)

-- Function to automatically sell gray-quality items (junk)
local function SellGrayItems()
    for bag = 0, 4 do
        local slots = GetBagSlots and GetBagSlots(bag)
        if slots then
            for slot = 1, slots do
                local link = GetItemLink and GetItemLink(bag, slot)
                if link then
                    local _, _, rarity = GetItemInfo(link)
                    -- If item rarity is poor (gray), sell it
                    if rarity == LE_ITEM_QUALITY_POOR and UseItem then
                        UseItem(bag, slot)
                    end
                end
            end
        end
    end
end

-- Create a frame to handle the MERCHANT_SHOW event
local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")

-- Event handler for auto-repair and junk selling
frame:SetScript("OnEvent", function()
    if CanMerchantRepair() then
        local cost = GetRepairAllCost()
        if cost > 0 then
            local money = GetMoney()
            
            -- Try to use guild repair funds if available
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

            -- Fallback to personal funds
            if money > cost then
                RepairAllItems()
                print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
            else
                print("Not enough gold to cover the repair cost.")
            end
        end
    end

    -- Sell junk after repairing
    SellGrayItems()
end)
