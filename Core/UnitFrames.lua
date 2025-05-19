---------------------------
-- UNIT FRAMES
---------------------------
-- Set Frame Positions
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent",function(self,event,...)

PlayerFrame:ClearAllPoints()
--PlayerFrame:SetPoint("CENTER", -235,-150)
PlayerFrame:SetPoint("CENTER", -225,-165)
--PlayerFrame:SetPoint("CENTER", -260,-180)
--PlayerFrame:SetPoint("CENTER", -350,-180)
PlayerFrame:SetUserPlaced(true)

TargetFrame:ClearAllPoints()
--TargetFrame:SetPoint("CENTER", 235,-150)
TargetFrame:SetPoint("CENTER", 225,-165)
--TargetFrame:SetPoint("CENTER", 260,-180)
--TargetFrame:SetPoint("CENTER", 350,-180)
TargetFrame:SetUserPlaced(true)

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


--------------------
-- Moving Castbar --
--------------------

CastingBarFrame:ClearAllPoints()
CastingBarFrame:SetPoint("CENTER", WorldFrame, "CENTER", 0, -265) --250
CastingBarFrame.SetPoint = function() end

--HideTargetCastBar
--SetCVar("showTargetCastbar", 0)

--showTargetCastBar
SetCVar("showTargetCastbar", 1)


--TargetFrameSpellBar:ClearAllPoints()
--TargetFrameSpellBar:SetPoint("CENTER", WorldFrame, "CENTER", 0, 0)
--TargetFrameSpellBar.SetPoint = function() end


-- Larger SpellBara
--TargetFrameSpellBar:SetScale(1);
--FocusFrameSpellBar:SetScale(1);

