---------------------------
-- UNIT FRAMES POSITION
---------------------------
-- Set Frame Positions
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent",function(self,event,...)

PlayerFrame:ClearAllPoints()
PlayerFrame:SetPoint("CENTER", -225,-165) -- Scale 1.2
--PlayerFrame:SetPoint("CENTER", -250,-195) -- Default Scale = 1
PlayerFrame:SetUserPlaced(true)
PlayerFrame:SetScale(1.2)

TargetFrame:ClearAllPoints()
TargetFrame:SetPoint("CENTER", 225,-165)  -- Scale 1.2
--TargetFrame:SetPoint("CENTER", 250,-195) -- Default Scale = 1
TargetFrame:SetUserPlaced(true)
TargetFrame:SetScale(1.2)

FocusFrame:ClearAllPoints()
FocusFrame:SetPoint("CENTER", 450,-50)
--FocusFrame:SetPoint("CENTER", 500,-150)
FocusFrame:SetUserPlaced(true)

self:UnregisterEvent("PLAYER_LOGIN")

end)

--[[ Undo Frame Movement
PlayerFrame:SetUserPlaced(false)
TargetFrame:SetUserPlaced(false)
FocusFrame:SetUserPlaced(false)
]]--

-- Remove text on portait
PlayerHitIndicator:SetText(nil)
PlayerHitIndicator.SetText = function() end

------------------------
-- BOSS AND ARENA FRAMES
------------------------
-- Change Scale of boss frames
Boss1TargetFrame:SetScale(1.1)
Boss2TargetFrame:SetScale(1.1)
Boss3TargetFrame:SetScale(1.1)
Boss4TargetFrame:SetScale(1.1)
Boss5TargetFrame:SetScale(1.1)


