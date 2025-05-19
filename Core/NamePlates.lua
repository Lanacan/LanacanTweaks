--------------
-- NAME PLATES
--------------

-- smaller names on nameplates
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
 
local function SetFont(obj, optSize)
    local fontName= obj:GetFont()
    obj:SetFont(fontName,optSize,"OUTLINE")
end
 
SetFont(SystemFont_LargeNamePlate,13)
SetFont(SystemFont_NamePlate,10)
SetFont(SystemFont_LargeNamePlateFixed,13)
SetFont(SystemFont_NamePlateFixed,10)
 
end)

-- License: Public Domain

C_Timer.After(.1, function() -- need to wait a bit
	if not InCombatLockdown() then
		-- set distance back to 40 (down from 60)
		SetCVar("nameplateMaxDistance", 40)
		--Standard NP
		--SetCVar("nameplateSelectedScale", 1.25)
		--SetCVar("nameplateGlobalScale", 1.25)
		
		--Large NP
		SetCVar("nameplateSelectedScale", 0.95)
		SetCVar("nameplateGlobalScale", 0.95)
		
		--Reset NP
		--SetCVar("nameplateSelectedScale", 1)
		--SetCVar("nameplateGlobalScale", 1)
		
		-- in patch 7.1 only the targeted nameplate clamps to the top of the screen,
		-- change back to default behavior
		SetCVar("nameplateOtherTopInset", GetCVarDefault("nameplateOtherTopInset"))
		SetCVar("nameplateOtherBottomInset", GetCVarDefault("nameplateOtherBottomInset"))
				
	end
end)

--Show Auras

local b={}
local gn=UnitAura
local function fn(a1,a2,a3,...)
  if a3 and a3:match("PLATE_ONLY") then
    a3=a3.."\124PLAYER"
  end
  local a={gn(a1,a2,a3,...)}
  a[14]=a[5]~=nil and not tContains(b,a[10]) and abs(a[5]-31)<31
  return unpack(a)
end
UnitAura=fn

