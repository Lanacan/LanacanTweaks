-- Auto-repair and junk selling

local GetBagSlots = GetContainerNumSlots or (C_Container and C_Container.GetContainerNumSlots)
local GetItemLink = GetContainerItemLink or (C_Container and C_Container.GetContainerItemLink)
local UseItem = UseContainerItem or (C_Container and C_Container.UseContainerItem)

local function SellGrayItems()
    for bag = 0, 4 do
        local slots = GetBagSlots and GetBagSlots(bag)
        if slots then
            for slot = 1, slots do
                local link = GetItemLink and GetItemLink(bag, slot)
                if link then
                    local _, _, rarity = GetItemInfo(link)
                    if rarity == LE_ITEM_QUALITY_POOR and UseItem then
                        UseItem(bag, slot)
                    end
                end
            end
        end
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("MERCHANT_SHOW")
frame:SetScript("OnEvent", function()
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
