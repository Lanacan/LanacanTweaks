-- Create a frame for modifying loot messages
local frame = CreateFrame("Frame", "LootLiteFrame")
frame:RegisterEvent('PLAYER_ENTERING_WORLD')

-- Override default global loot message constants when the world loads
local function eventHandler(self, event, ...)
    -- Self loot messages
    LOOT_ITEM_SELF = "|cff00ff00+ %s|r"
    LOOT_ITEM_SELF_MULTIPLE = "|cff00ff00+ %s x%d|r"
    LOOT_ITEM_CREATED_SELF = "|cff00ff00+ %s (crafted)|r"
    LOOT_ITEM_CREATED_SELF_MULTIPLE = "|cff00ff00+ %s x%d (crafted)|r"
    LOOT_ITEM_PUSHED_SELF = "|cff00ff00+ %s|r"
    LOOT_ITEM_PUSHED_SELF_MULTIPLE = "|cff00ff00+ %s x%d|r"

    -- Currency and money
    YOU_LOOT_MONEY = "|cffffff00+ %s|r"
    LOOT_MONEY_SPLIT = "|cffffff00+ %s (shared)|r"
    CURRENCY_GAINED = "|cff00ff00+ %s|r"
    CURRENCY_GAINED_MULTIPLE = "|cff00ff00+ %s x%d|r"

    -- Other people's loot
    LOOT_ITEM = "|cff00ccff%s|r |cff00ff00+ %s|r"
    LOOT_ITEM_MULTIPLE = "|cff00ccff%s|r |cff00ff00+ %s x%d|r"
    LOOT_ITEM_PUSHED = "|cff00ccff%s|r |cff00ff00+ %s|r"
    LOOT_ITEM_PUSHED_MULTIPLE = "|cff00ccff%s|r |cff00ff00+ %s x%d|r"

    -- Tradeskill loot
    TRADESKILL_LOG_FIRSTPERSON = "|cff00ff00+ %s (crafted)|r"
    TRADESKILL_LOG_THIRDPERSON = "|cff00ccff%s|r |cff00ff00+ %s (crafted)|r"
    CREATED_ITEM = "|cff00ff00+ %s (crafted)|r"
    CREATED_ITEM_MULTIPLE = "|cff00ff00+ %s x%d (crafted)|r"

    -- Refund and disenchant messages
    LOOT_ITEM_REFUND = "|cffff0000Refunded: %s|r"
    LOOT_ITEM_REFUND_MULTIPLE = "|cffff0000Refunded: %s x%d|r"
    LOOT_DISENCHANT_CREDIT = "|cff9370DB%s disenchanted: %s|r"

    -- Loss from death
    CURRENCY_LOST_FROM_DEATH = "|cffff0000Lost: %s x%d|r"

    -- Pet loot for Wrath Classic
    if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
        BATTLE_PET_LOOT_RECEIVED = "|cff00ff00+ Pet: %s|r"
    end
end

frame:SetScript("OnEvent", eventHandler)

-- === Attempt to recolor money loot messages in chat (may not work in Classic) ===
local moneyHandler = CreateFrame("Frame")
moneyHandler:RegisterEvent("CHAT_MSG_MONEY")
moneyHandler:SetScript("OnEvent", function(_, _, message)
    if string.find(message, LOOT_MONEY) then
        local newMessage = string.gsub(message, LOOT_MONEY, "|cffffff00"..LOOT_MONEY.."|r")
        ChatFrame_ReplaceMessage(ChatFrame1, newMessage)  -- Note: Not a valid function in Classic
    end
end)
