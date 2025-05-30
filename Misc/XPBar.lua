-- Get the player's class and its associated color
local _, playerClass = UnitClass("player")
local classColor = RAID_CLASS_COLORS[playerClass]

-- === Create a small top XP bar ===
local bar = CreateFrame("StatusBar", "XPTopStatusBar", UIParent)
bar:SetSize(GetScreenWidth(), 4)  -- Full width, small height
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

-- === Text display showing level, XP, and rested info ===
local f = CreateFrame("Frame", "XPTimeTrackerFrame", UIParent)
f:SetHeight(15)
f:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 5, -6)

local text = f:CreateFontString(nil, "OVERLAY", "GameFontNormal")
text:SetAllPoints(true)
text:SetFont("Fonts\\FRIZQT__.TTF", 12, "OUTLINE")
text:SetJustifyH("LEFT")
text:SetWordWrap(false)

-- Class colored pipe symbol between values
local coloredPipe = string.format("|cff%02x%02x%02x | |r", 
    classColor.r * 255, classColor.g * 255, classColor.b * 255)

-- === Format the XP text to show level, current XP, max XP, %, and rested XP ===
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

    if restedPercent and restedPercent > 1 then
        return string.format("%s%sRested %.1f%%", baseText, coloredPipe, restedPercent)
    else
        return baseText
    end
end

-- === Update bar, spark, and text ===
local function UpdateDisplay()
    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")
    local restedXP = GetXPExhaustion()

    -- Determine bar color: purple if rested XP is present, otherwise class color
    if restedXP and restedXP > 0 then
        bar:SetStatusBarColor(0.6, 0.4, 0.8)  -- Soft purple
    else
        bar:SetStatusBarColor(classColor.r, classColor.g, classColor.b)
    end

    -- Set XP bar values
    bar:SetMinMaxValues(0, maxXP)
    bar:SetValue(currentXP)

    -- Update spark position
    local barWidth = bar:GetWidth()
    local percent = currentXP / maxXP
    spark:ClearAllPoints()
    spark:SetPoint("CENTER", bar, "LEFT", barWidth * percent, 0)

    -- Update text
    local xpText = FormatXP()
    text:SetText("|cFFFFFFFF" .. xpText .. "|r")

    -- Resize frame based on text width
    local textWidth = text:GetStringWidth()
    local minWidth = 200
    local maxWidth = 600
    local padding = 0
    local finalWidth = math.min(math.max(textWidth + padding, minWidth), maxWidth)
    f:SetWidth(finalWidth)
end


-- === Periodic update of the display every 0.2s ===
f:SetScript("OnUpdate", function(self, elapsed)
    self.timer = (self.timer or 0) + elapsed
    if self.timer >= 0.2 then
        UpdateDisplay()
        self.timer = 0
    end
end)
