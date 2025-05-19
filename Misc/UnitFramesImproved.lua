--Resize Frames
PlayerFrame:SetScale(1.5)
TargetFrame:SetScale(1.5)
-- Change Scale of boss frames
Boss1TargetFrame:SetScale(1.1)
Boss2TargetFrame:SetScale(1.1)
Boss3TargetFrame:SetScale(1.1)
Boss4TargetFrame:SetScale(1.1)
Boss5TargetFrame:SetScale(1.1)

--No Portrait Text
	PlayerHitIndicator:SetText(nil)
	PlayerHitIndicator.SetText = function() end
    PetHitIndicator:SetText(nil)
    PetHitIndicator.SetText = function() end

--MOVE TARGET CAST BAR
	TargetFrameSpellBar:HookScript("OnUpdate", function()
    TargetFrameSpellBar:ClearAllPoints()
    --TargetFrameSpellBar:SetPoint("TOPLEFT", TargetFrame, "TOPLEFT", 45, 0)
	TargetFrameSpellBar:SetPoint("CENTER", UIParent, "CENTER", 0, -55)
	end)

PlayerCastingBarFrame:ClearAllPoints()
PlayerCastingBarFrame:SetPoint("CENTER", UIParent, "CENTER", 0, -190)


--HIDE REST/COMBAT FLASH AND REST ANIMATION
local hideRest = CreateFrame("Frame")
PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerRestLoop:SetParent(hideRest)
PlayerFrame.PlayerFrameContent.PlayerFrameContentMain.StatusTexture:SetParent(hideRest)
PlayerFrame.PlayerFrameContent.PlayerFrameContentContextual.PlayerPortraitCornerIcon:SetParent(hideRest)
PlayerFrame.PlayerFrameContainer.FrameFlash:SetParent(hideRest)
TargetFrame.TargetFrameContainer.Flash:SetParent(hideRest)
hideRest:Hide()

--HidePowerBars()
 if playerClass == 'Paladin' then
        PaladinPowerBarFrame:Hide()
    elseif playerClass == 'Rogue' then
        ComboPointPlayerFrame:Hide()
    elseif playerClass == 'Warlock' then
        WarlockPowerFrame:Hide()
    elseif playerClass == 'Druid' then
        ComboPointDruidPlayerFrame:Hide()
    elseif playerClass == 'Monk' then
        MonkHarmonyBarFrame:Hide()
        MonkStaggerBar:Hide() -- not working
    elseif playerClass == 'Death Knight' then
        RuneFrame:Hide()
    elseif playerClass == 'Evoker' then
        EssencePlayerFrame:Hide()
    end


--UNIT FRAME CLASS COLORS
hooksecurefunc("HealthBar_OnValueChanged", function (self)
     if UnitIsPlayer(self.unit) and UnitIsConnected(self.unit) then
         local c = RAID_CLASS_COLORS[select(2,UnitClass(self.unit))];
         if c then
                 self:SetStatusBarColor(c.r, c.g, c.b)
                 self:SetStatusBarDesaturated(true)
         else
                 self:SetStatusBarColor(0.5, 0.5, 0.5)
                 self:SetStatusBarDesaturated(true)
         end
     elseif UnitIsPlayer(self.unit) then
         self:SetStatusBarColor(0.5, 0.5, 0.5)
         self:SetStatusBarDesaturated(true)
     else
         self:SetStatusBarColor(0.0, 1.0, 0.0)
         self:SetStatusBarDesaturated(true)
     end
end);
hooksecurefunc("UnitFrameHealthBar_Update", function (self)
     if UnitIsPlayer(self.unit) and UnitIsConnected(self.unit) then
         local c = RAID_CLASS_COLORS[select(2,UnitClass(self.unit))];
         if c then
                 self:SetStatusBarColor(c.r, c.g, c.b)
                 self:SetStatusBarDesaturated(true)
         else
                 self:SetStatusBarColor(0.5, 0.5, 0.5)
                 self:SetStatusBarDesaturated(true)
         end
     elseif UnitIsPlayer(self.unit) then
         self:SetStatusBarColor(0.5, 0.5, 0.5)
         self:SetStatusBarDesaturated(true)
     else
         self:SetStatusBarColor(0.0, 1.0, 0.0)
         self:SetStatusBarDesaturated(true)
     end
end);