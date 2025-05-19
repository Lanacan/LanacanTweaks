--This is how you make the raid frames even more resizable :) you can also put all this in one line and just use a macro in game.
local n,w,h="CompactUnitFrameProfilesGeneralOptionsFrame" h,w=
_G[n.."HeightSlider"],
_G[n.."WidthSlider"] 
h:SetMinMaxValues(1,150) 
w:SetMinMaxValues(1,150)


----------------------
-- RaidFrames scale --
----------------------
	
CompactRaidFrameContainer:SetScale(1.2)


---------------------
-- COLORING FRAMES --
---------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(self, event, addon)
		for _, region in pairs({CompactRaidFrameManager:GetRegions()}) do
			if region:IsObjectType("Texture") then
				region:SetVertexColor(0, 0, 0)
			end
		end

		for _, region in pairs({CompactRaidFrameManagerContainerResizeFrame:GetRegions()}) do
			if region:GetName():find("Border") then
				region:SetVertexColor(0, 0, 0)
			end
		end

  	self:UnregisterEvent("ADDON_LOADED")
  	frame:SetScript("OnEvent", nil)
end)