-- CVAR configuration and related tweaks

local function applyCVars()
    local cvars = {
        -- === Unit Frames ===
        useCompactPartyFrames = 1,
        showTargetOfTarget = 1,
        showTargetCastbar = 1,

        -- === Map and Quest Tracking ===
        showDungeonEntrancesOnMap = 1,
        trackQuestSorting = 'top',
        autoQuestWatch = 1,
        instantQuestText = 1,

        -- === Looting and Inventory ===
        autoLootDefault = 1,
        alwaysCompareItems = 1,
        lootUnderMouse = 1,
        autoSelfCast = 1,

        -- === Camera and Movement ===
        cameraDistanceMaxZoomFactor = 2.6,
        cameraSmoothStyle = 0,
        cameraYawMoveSpeed = 90,
        mouseInvertPitch = 0,
        autoInteract = 0,

        -- === Action Bars and UI Elements ===
        lockActionBars = 1,
        alwaysShowActionBars = 0,
        ActionButtonUseKeyDown = 1,
        countdownForCooldowns = 1,

        -- === Chat Settings ===
        chatBubbles = 1,
        chatBubblesParty = 0,
        chatStyle = 'classic',
        showTimestamps = 'none',
        whisperMode = 'inline',

        -- === Social and Interaction Settings ===
        deselectOnClick = 1,
        autoClearAFK = 1,
        interactOnLeftClick = 0,
        blockTrades = 0,
        blockChannelInvites = 0,
        profanityFilter = 0,

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
        Outline = 2,
        ResampleAlwaysSharpen = 1,

        -- === Screenshot and Debug ===
        screenshotFormat = 'jpg',
        screenshotQuality = 10,
        scriptErrors = 1,

        -- === Clock and Time Display ===
        timeMgrUseMilitaryTime = 1,
        timeMgrUseLocalTime = 1,

        -- === Tutorials and Warnings ===
        showTutorials = 0,
        doNotFlashLowHealthWarning = 1,

        -- === Minimap ===
        minimapTrackingShowAll = 1,
    }

    for k, v in pairs(cvars) do
        SetCVar(k, v)
    end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
    applyCVars()
end)
