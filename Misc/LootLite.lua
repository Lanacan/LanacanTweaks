local frame = CreateFrame("FRAME", "LootLiteFrame");
frame:RegisterEvent('PLAYER_ENTERING_WORLD');

local function eventHandler(self, event, ...)
--Self Loot
	LOOT_ITEM_SELF = "+ %s +";
	LOOT_ITEM_SELF_MULTIPLE = "+ %sx%d +";
	LOOT_ITEM_BONUS_ROLL_SELF = "+ %s, Bonus +";
	LOOT_ITEM_BONUS_ROLL_SELF_MULTIPLE = "+ %sx%d, Bonus +";
	LOOT_ITEM_CREATED_SELF = "+ %s +";
	LOOT_ITEM_CREATED_SELF_MULTIPLE = "+ %sx%d +";
	LOOT_ITEM_PUSHED_SELF = "+ %s +";
	LOOT_ITEM_PUSHED_SELF_MULTIPLE = "+ %sx%d +";
	LOOT_ITEM_REFUND = "Refunded - %s -";
	LOOT_ITEM_REFUND_MULTIPLE = "Refunded - %sx%d -";
	LOOT_ITEM_PUSHED_SELF = "+ %s +";
	LOOT_ITEM_PUSHED_SELF_MULTIPLE = "+ %sx%d +";
	CURRENCY_GAINED = "+ %s +";
	CURRENCY_GAINED_MULTIPLE = "+ %s x%d +";
	CURRENCY_GAINED_MULTIPLE_BONUS = "+ %s x%d (Bonus Objective) +";
	CURRENCY_LOST_FROM_DEATH = "Lost - %s x%d -";
	BATTLE_PET_LOOT_RECEIVED = "+ ";
	LOOT_CURRENCY_REFUND = "Refunded - %s x%d -";
	LOOT_DISENCHANT_CREDIT = "%s Disenchanted - %s -";

--Other People's Loot
	LOOT_ITEM = "%s + %s +";
	LOOT_ITEM_MULTIPLE = "%s + %sx%d +";
	LOOT_ITEM_BONUS_ROLL = "%s, Bonus + %s +";
	LOOT_ITEM_BONUS_ROLL_MULTIPLE = "%s, Bonus + %sx%d +";
	LOOT_ITEM_PUSHED = "%s + %s +";
	LOOT_ITEM_PUSHED_MULTIPLE = "%s + %sx%d +";
end
frame:SetScript("OnEvent", eventHandler);