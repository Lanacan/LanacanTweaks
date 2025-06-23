-----------------------------
-- Lanacan XP Top Bar
-- WoW Classic Addon to display a slim experience bar anchored to the top of the screen.
-- Shows level, XP progress, rested bonus, and estimated kills remaining.
-- Includes class-colored styling, a spark animation, and automatic updates every 0.2s.
-----------------------------

-- Get the player's class and its associated color
local _, playerClass = UnitClass("player")
local classColor = RAID_CLASS_COLORS[playerClass]

-- === Create a small top XP bar ===
local bar = CreateFrame("StatusBar", "XPTopStatusBar", UIParent)
bar:SetHeight(4)
bar:SetPoint("LEFT", UIParent, "LEFT", 0, 0)
bar:SetPoint("RIGHT", UIParent, "RIGHT", 0, 0)
bar:SetPoint("TOP", UIParent, "TOP", 0, 0)
bar:SetStatusBarTexture("Interface\\TARGETINGFRAME\\UI-StatusBar")
bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
bar:SetMinMaxValues(0, UnitXPMax("player"))
bar:SetValue(UnitXP("player"))
bar:Show()

-- === Create spark that moves along the bar ===
local spark = bar:CreateTexture(nil, "OVERLAY")
spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
spark:SetSize(6, 6)
spark:SetBlendMode("ADD")
spark:SetPoint("CENTER", bar, "LEFT", bar:GetWidth() * (UnitXP("player") / UnitXPMax("player")), 0)

-- === Create a frame and fontstring to display XP info ===
local f = CreateFrame("Frame", "XPTimeTrackerFrame", UIParent)
f:SetHeight(15)
f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 5, -6)

local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetAllPoints(true)
text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
text:SetJustifyH("LEFT")
text:SetWordWrap(false)

-- Add class-colored pipe separator between values
local coloredPipe = string.format("|cff%02x%02x%02x | |r", 
    classColor.r * 255, classColor.g * 255, classColor.b * 255)

-- === Track last XP gain from a kill to estimate kills remaining ===
local lastKillXP = nil

-- === COMBAT_LOG_EVENT_UNFILTERED handler to detect kills ===
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
eventFrame:SetScript("OnEvent", function()
    local _, subEvent = CombatLogGetCurrentEventInfo()
    if subEvent == "PARTY_KILL" then
        f:RegisterEvent("PLAYER_XP_UPDATE") -- Check for XP increase after kill
    end
end)

-- === Handle PLAYER_XP_UPDATE to store last gained XP ===
f:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_XP_UPDATE" then
        local gainedXP = UnitXP("player") - (self.lastXP or 0)
        if gainedXP > 0 then
            lastKillXP = gainedXP
        end
        self:UnregisterEvent("PLAYER_XP_UPDATE")
    end
end)

-- === Format the XP text line ===
local function FormatXP()
    local maxLevel = GetMaxPlayerLevel()
    local currentLevel = UnitLevel("player")
    if currentLevel == maxLevel then
        return string.format("Level %d (Max)", currentLevel)
    end

    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local percent = (currentXP / maxXP) * 100
    local restedXP = GetXPExhaustion()
    local restedPercent = restedXP and (restedXP / maxXP) * 100 or 0

    local baseText = string.format("Level %d%s%s/%s (%.1f%%)", 
        currentLevel, coloredPipe, BreakUpLargeNumbers(currentXP), BreakUpLargeNumbers(maxXP), percent)

    local killsText = ""
    if lastKillXP and lastKillXP > 0 then
        local killsLeft = math.ceil((maxXP - currentXP) / lastKillXP)
        killsText = string.format("%s~%d Kills", coloredPipe, killsLeft)
    end

    if restedPercent and restedPercent > 1 then
        return string.format("%s%s%sRested %.1f%%", baseText, killsText, coloredPipe, restedPercent)
    else
        return baseText .. killsText
    end
end

-- === Update bar, spark, and text ===
local function UpdateDisplay()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local restedXP = GetXPExhaustion()

    -- Save last XP value to track gains later
    f.lastXP = currentXP

    -- Change bar color if rested bonus is active
    if restedXP and restedXP > 0 then
        bar:SetStatusBarColor(0.6, 0.4, 0.8) -- Purple for rested
    else
        bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b) -- Class color
    end

    -- Update XP bar value and spark position
    bar:SetMinMaxValues(0, maxXP)
    bar:SetValue(currentXP)

    local barWidth = bar:GetRight() - bar:GetLeft()
    local percent = currentXP / maxXP
    spark:ClearAllPoints()
    spark:SetPoint("CENTER", bar, "LEFT", barWidth * percent, 0)

    -- Update XP info text
    local xpText = FormatXP()
    text:SetText("|cFFFFFFFF" .. xpText .. "|r")

    -- Resize text frame based on content
    local textWidth = text:GetStringWidth()
    local finalWidth = math.min(math.max(textWidth, 200), 600)
    f:SetWidth(finalWidth)
end

-- === Periodically refresh display every 0.2 seconds ===
f:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.2 then
        UpdateDisplay()
        self.timer = 0
    end
end)
