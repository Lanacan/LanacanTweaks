--[[
Created by Slothpala 
--]]
GameTooltip:HookScript("OnUpdate", function()
    if UnitPlayerControlled("mouseover") then
        local _, englishClass = UnitClass("mouseover")
        local r,g,b = GetClassColor(englishClass)
        GameTooltipStatusBarTexture:SetVertexColor(r,g,b)
    end
end)