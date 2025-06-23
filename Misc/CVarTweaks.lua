-----------------------------
-- Lanacan CVar Tweaks
-- WoW Classic Addon to automatically apply personal UI, camera, audio, and social preferences
-- using CVars. These are applied once on PLAYER_ENTERING_WORLD.
-- Useful for quickly restoring preferred settings without touching config.wtf.
-----------------------------

-- === Function to apply custom CVars ===
local function applyCVars()
    local cvars = {
        -- === Unit Frames ===
        useCompactPartyFrames = 1,     -- Use compact party layout
        showTargetOfTarget = 1,        -- Show target-of-target frame
        showTargetCastbar = 1,         -- Show casting bar on target frame

        -- === Map and Quest Tracking ===
        showDungeonEntrancesOnMap = 1, -- Show instance entrances on world map
        trackQuestSorting = 'top',     -- Sort tracked quests top-down
        autoQuestWatch = 1,            -- Auto-track newly accepted quests
        instantQuestText = 1,          -- Disable scrolling quest text

        -- === Looting and Inventory ===
        autoLootDefault = 1,           -- Enable auto-loot by default
        alwaysCompareItems = 1,        -- Always show compare tooltips
        lootUnderMouse = 1,            -- Loot window appears under cursor
        autoSelfCast = 1,              -- Enable auto self-casting

        -- === Camera and Movement ===
        cameraDistanceMaxZoomFactor = 2.6, -- Increase max camera zoom
        cameraSmoothStyle = 0,             -- Disable smooth follow
        cameraYawMoveSpeed = 90,           -- Speed up camera yaw turn
        mouseInvertPitch = 0,              -- Do not invert pitch (up/down)
        autoInteract = 0,                  -- Disable click-to-move interaction

        -- === Action Bars and UI Elements ===
        lockActionBars = 1,            -- Lock action bar positions
        alwaysShowActionBars = 0,      -- Hide empty bars
        ActionButtonUseKeyDown = 1,    -- Trigger actions on key down
        countdownForCooldowns = 1,     -- Show numeric cooldown text

        -- === Chat Settings ===
        chatBubbles = 1,               -- Show chat bubbles for /say /yell
        chatBubblesParty = 0,          -- Disable bubbles for /party /raid
        chatStyle = 'classic',         -- Use classic chat box (no IM style)
        showTimestamps = 'none',       -- Disable chat timestamps
        whisperMode = 'inline',        -- Inline whispers, not in new windows

        -- === Social and Interaction Settings ===
        deselectOnClick = 1,           -- Deselect target if clicked again
        autoClearAFK = 1,              -- Clear AFK when moving/talking
        interactOnLeftClick = 0,       -- Prevent left click interaction
        blockTrades = 0,               -- Allow incoming trade requests
        blockChannelInvites = 0,       -- Allow channel invites
        profanityFilter = 0,           -- Disable profanity filter

        -- === Audio Settings ===
        Sound_EnableAllSound = 1,
        Sound_EnableSFX = 1,
        Sound_EnableMusic = 0,
        Sound_EnableAmbience = 1,
        Sound_EnableDialog = 1,
        Sound_EnableErrorSpeech = 0,
        Sound_MasterVolume = 0.5,
        Sound_SFXVolume = 0.5,
        Sound_MusicVolume = 0.2,
        Sound_AmbienceVolume = 0.5,
        Sound_DialogVolume = 0.6,

        -- === Visual/Graphical Settings ===
        Outline = 2,                   -- Enable outline mode for nameplates
        ResampleAlwaysSharpen = 1,     -- Sharpen upscaled UI elements

        -- === Screenshot and Debug ===
        screenshotFormat = 'jpg',      -- Smaller file size
        screenshotQuality = 10,        -- Max quality
        scriptErrors = 1,              -- Show Lua errors

        -- === Clock and Time Display ===
        timeMgrUseMilitaryTime = 1,    -- Use 24h clock
        timeMgrUseLocalTime = 1,       -- Show local instead of server time

        -- === Tutorials and Warnings ===
        showTutorials = 0,             -- Disable new player tutorials
        doNotFlashLowHealthWarning = 1, -- Prevent red flash on low HP

        -- === Minimap ===
        minimapTrackingShowAll = 1,    -- Show all minimap tracking options
    }

    -- Loop through and apply each CVar
    for k, v in pairs(cvars) do
        SetCVar(k, v)
    end
end

-- === Register to apply CVars when entering world ===
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    applyCVars()
end)
