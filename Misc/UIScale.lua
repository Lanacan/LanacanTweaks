---------------
-- UI SCALE
---------------
local f = CreateFrame("Frame", nil, UIParent)
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function(self, event)
	--UIParent:SetScale(0.5)
	UIParent:SetScale(768 / 1080)	-- change the size and reload your ui (/reloadui) or restart the game
	f:UnregisterAllEvents()
end)
