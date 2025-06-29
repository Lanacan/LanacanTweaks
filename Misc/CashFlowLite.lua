local frame = CreateFrame("FRAME", "CashFlowLiteFrame");
frame:RegisterEvent('PLAYER_ENTERING_WORLD');
frame:RegisterEvent('MAIL_SHOW');
frame:RegisterEvent('MAIL_CLOSED');

local function eventHandler(self, event, ...)
	if event == "MAIL_SHOW" then
		COPPER_AMOUNT = "%d Copper"
		SILVER_AMOUNT = "%d Silver"
		GOLD_AMOUNT = "%d Gold"
	else
		COPPER_AMOUNT = "%d |cFF954F28"..COPPER_AMOUNT_SYMBOL.."|r";
		SILVER_AMOUNT = "%d |cFFC0C0C0"..SILVER_AMOUNT_SYMBOL.."|r";
		GOLD_AMOUNT = "%d |cFFF0D440"..GOLD_AMOUNT_SYMBOL.."|r";
	end
	YOU_LOOT_MONEY = "+ %s";
	LOOT_MONEY_SPLIT = "+ %s";
end
frame:SetScript("OnEvent", eventHandler);