-- Create the main frame for displaying FPS and latency stats
StatsFrame = CreateFrame("Frame", "StatsFrame", UIParent)

-- Toggle whether the frame is movable (false = fixed position, true = draggable)
local movable = false

-- If the frame is not movable, anchor it to the bottom-left of the screen
if movable == false then
    StatsFrame:ClearAllPoints()
    StatsFrame:SetPoint('BOTTOMLEFT', UIParent, "BOTTOMLEFT", 5, 5)
end

-- Enable mouse interaction on the frame (needed for dragging if movable)
StatsFrame:EnableMouse(true)

-- If the frame is movable, set it up to be draggable by mouse
if movable == true then
    StatsFrame:ClearAllPoints()
    StatsFrame:SetPoint('BOTTOMLEFT', UIParent, "BOTTOMLEFT", 5, 3)
    StatsFrame:SetClampedToScreen(true) -- Prevent dragging frame off-screen
    StatsFrame:SetMovable(true)         -- Allow it to be moved
    StatsFrame:SetUserPlaced(true)      -- Save user-placed position
    StatsFrame:SetFrameLevel(4)         -- Set layer level

    -- Start moving frame on mouse down
    StatsFrame:SetScript("OnMouseDown", function()
        StatsFrame:ClearAllPoints()
        StatsFrame:StartMoving()
    end)

    -- Stop moving frame on mouse up
    StatsFrame:SetScript("OnMouseUp", function()
        StatsFrame:StopMovingOrSizing()
    end)
end

-- Create another frame to wait for the PLAYER_LOGIN event (delays setup until UI is ready)
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)

    -- Font and appearance settings
    local font = STANDARD_TEXT_FONT
    local fontSize = 12
    local fontFlag = "THINOUTLINE"
    local textAlign = "CENTER"
    local customColor = RAID_CLASS_COLORS
    local useShadow = false

    -- Determine color to use (class color or white)
    local color
    if customColor == false then
        color = {r = 1, g = 1, b = 1} -- White
    else
        local _, class = UnitClass("player")
        color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
    end

    -- Function to get current FPS formatted as a string
    local function getFPS()
        return "|c00ffffff" .. floor(GetFramerate()) .. "|r fps"
    end

    -- Function to get world latency (server response time)
    local function getLatencyWorld()
        return "|c00ffffff" .. select(4, GetNetStats()) .. "|r ms"
    end

    -- Function to get home latency (client to Blizzard network)
    local function getLatency()
        return "|c00ffffff" .. select(3, GetNetStats()) .. "|r ms"
    end

    -- Set size and create text element for the stats display
    StatsFrame:SetWidth(50)
    StatsFrame:SetHeight(fontSize)
    StatsFrame.text = StatsFrame:CreateFontString(nil, "BACKGROUND")
    StatsFrame.text:SetPoint(textAlign, StatsFrame)
    StatsFrame.text:SetFont(font, fontSize, fontFlag)

    -- Optional text shadow (off by default)
    if useShadow then
        StatsFrame.text:SetShadowOffset(1, -1)
        StatsFrame.text:SetShadowColor(0, 0, 0)
    end

    -- Set text color to the chosen color
    StatsFrame.text:SetTextColor(color.r, color.g, color.b)

    -- Timer tracking for updating once per second
    local lastUpdate = 0

    -- Update function runs every frame; updates text if more than 1 second passed
    local function update(self, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > 1 then
            lastUpdate = 0
            -- Update the displayed FPS and latency
            StatsFrame.text:SetText(getFPS() .. " " .. getLatency())
            -- Resize the frame to fit the new text width/height
            self:SetWidth(StatsFrame.text:GetStringWidth())
            self:SetHeight(StatsFrame.text:GetStringHeight())
        end
    end

    -- Attach the update function to the frame's OnUpdate handler
    StatsFrame:SetScript("OnUpdate", update)

end)
