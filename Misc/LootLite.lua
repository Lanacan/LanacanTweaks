----------------------------
-- Lanacan LootLite Addon (Original Author - WNxSajuukCor) --
-- Simplifies and recolors loot messages for better readability
----------------------------

local frame = CreateFrame("Frame", "LootLiteFrame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function eventHandler(self, event, ...)
    -- Override global loot message formats with colored versions

    -- Self loot messages (green + prefix)
    LOOT_ITEM_SELF = "|cff00ff00+ %s|r"
    LOOT_ITEM_SELF_MULTIPLE = "|cff00ff00+ %s x%d|r"
    LOOT_ITEM_CREATED_SELF = "|cff00ff00+ %s (crafted)|r"
    LOOT_ITEM_CREATED_SELF_MULTIPLE = "|cff00ff00+ %s x%d (crafted)|r"
    LOOT_ITEM_PUSHED_SELF = "|cff00ff00+ %s|r"
    LOOT_ITEM_PUSHED_SELF_MULTIPLE = "|cff00ff00+ %s x%d|r"

    -- Currency and money loot (yellow and green)
    YOU_LOOT_MONEY = "|cffffff00+ %s|r"
    LOOT_MONEY_SPLIT = "|cffffff00+ %s (shared)|r"
    CURRENCY_GAINED = "|cff00ff00+ %s|r"
    CURRENCY_GAINED_MULTIPLE = "|cff00ff00+ %s x%d|r"

    -- Other people's loot (blue player name + green item)
    LOOT_ITEM = "|cff00ccff%s|r |cff00ff00+ %s|r"
    LOOT_ITEM_MULTIPLE = "|cff00ccff%s|r |cff00ff00+ %s x%d|r"
    LOOT_ITEM_PUSHED = "|cff00ccff%s|r |cff00ff00+ %s|r"
    LOOT_ITEM_PUSHED_MULTIPLE = "|cff00ccff%s|r |cff00ff00+ %s x%d|r"

    -- Tradeskill crafting loot
    TRADESKILL_LOG_FIRSTPERSON = "|cff00ff00+ %s (crafted)|r"
    TRADESKILL_LOG_THIRDPERSON = "|cff00ccff%s|r |cff00ff00+ %s (crafted)|r"
    CREATED_ITEM = "|cff00ff00+ %s (crafted)|r"
    CREATED_ITEM_MULTIPLE = "|cff00ff00+ %s x%d (crafted)|r"

    -- Refund and disenchant messages (red and purple)
    LOOT_ITEM_REFUND = "|cffff0000Refunded: %s|r"
    LOOT_ITEM_REFUND_MULTIPLE = "|cffff0000Refunded: %s x%d|r"
    LOOT_DISENCHANT_CREDIT = "|cff9370DB%s disenchanted: %s|r"

    -- Currency loss on death (red)
    CURRENCY_LOST_FROM_DEATH = "|cffff0000Lost: %s x%d|r"

    -- Pet loot message for Wrath Classic (green)
    if WOW_PROJECT_ID == WOW_PROJECT_WRATH_CLASSIC then
        BATTLE_PET_LOOT_RECEIVED = "|cff00ff00+ Pet: %s|r"
    end
end

frame:SetScript("OnEvent", eventHandler)

--[[ 
Note: The following code attempts to recolor money loot messages in chat.
However, ChatFrame_ReplaceMessage() does not exist in Classic WoW API,
so this part is non-functional and can be removed or replaced with a proper
chat filter if desired.
]]

--[[
local moneyHandler = CreateFrame("Frame")
moneyHandler:RegisterEvent("CHAT_MSG_MONEY")
moneyHandler:SetScript("OnEvent", function(_, _, message)
    if string.find(message, LOOT_MONEY) then
        local newMessage = string.gsub(message, LOOT_MONEY, "|cffffff00"..LOOT_MONEY.."|r")
        -- ChatFrame_ReplaceMessage is not available in Classic
        -- This code does nothing as-is
    end
end)
]]
