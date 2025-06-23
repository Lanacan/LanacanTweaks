----------------------
-- Lanacan Chat Enhancer
-- Customizes WoW Classic chat interface:
-- - Resizes/repositions chat frames
-- - Adds timestamps
-- - Shortens channel names (e.g., General → GEN)
-- - Colors player names by class
-- - Hides unnecessary UI elements
-- - Enables clickable URLs
-- - Player name clicks whisper
-- - Adds /rl slash command to reload UI
----------------------

-- Chat window config
local ChatConfig = {
    width = 450,
    height = 250,
    anchor = "BOTTOMLEFT",
    xOffset = 5,
    yOffset = 30,
}

-- Main event frame
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event)
    -- Add timestamp prefix to chat messages
    local function AddTimestamp(msg)
        local timeStamp = date("|cff999999[%H:%M]|r")
        return timeStamp .. " " .. msg
    end

    -- Override AddMessage to inject timestamps
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame and not chatFrame.originalAddMessage then
            chatFrame.originalAddMessage = chatFrame.AddMessage
            chatFrame.AddMessage = function(self, msg, ...)
                if type(msg) == "string" and not msg:find("^|cff999999%[%d%d:%d%d%]|r") then
                    msg = AddTimestamp(msg)
                end
                return self:originalAddMessage(msg, ...)
            end
        end
    end

    -- Chat fade and tab alpha settings
    CHAT_FRAME_FADE_TIME = 0.15
    CHAT_FRAME_FADE_OUT_TIME = 1
    CHAT_TAB_HIDE_DELAY = 0
    CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
    CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
    CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0

    -- Enable fading on main chat windows
    for i = 1, 7 do
        _G["ChatFrame"..i]:SetFading(true)
    end

    -- Hide menu button
    if ChatFrameMenuButton then
        ChatFrameMenuButton:HookScript("OnShow", ChatFrameMenuButton.Hide)
        ChatFrameMenuButton:Hide()
    end

    local processedFrames = {}

    -- Function to style chat frames
    local function ProcessFrame(frame)
        if processedFrames[frame] then return end
        local name = frame:GetName()

        -- Hide button frame and edit box art
        if _G[name.."ButtonFrame"] then _G[name.."ButtonFrame"]:Hide() end
        if _G[name.."EditBoxLeft"] then
            _G[name.."EditBoxLeft"]:Hide()
            _G[name.."EditBoxMid"]:Hide()
            _G[name.."EditBoxRight"]:Hide()
        end

        -- Reposition and configure edit box
        local editbox = _G[name.."EditBox"]
        if editbox then
            editbox:ClearAllPoints()
            editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -7, 15)
            editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 10, 15)
            editbox:SetAltArrowKeyMode(false)
        end

        -- Hide scrollbar and scroll button
        if frame.ScrollBar then
            frame.ScrollBar:Hide()
            frame.ScrollBar.Show = function() end
        end
        if frame.ScrollToBottomButton then
            frame.ScrollToBottomButton:Hide()
            frame.ScrollToBottomButton.Show = function() end
        end

        -- Fade channel button on mouseover
        if ChatFrameChannelButton then
            frame:EnableMouse(true)
            ChatFrameChannelButton:EnableMouse(true)
            ChatFrameChannelButton:SetAlpha(0)

            frame:SetScript("OnEnter", function()
                ChatFrameChannelButton:SetAlpha(0.8)
            end)
            frame:SetScript("OnLeave", function()
                ChatFrameChannelButton:SetAlpha(0)
            end)

            ChatFrameChannelButton:SetScript("OnEnter", function()
                ChatFrameChannelButton:SetAlpha(0.8)
            end)
            ChatFrameChannelButton:SetScript("OnLeave", function()
                ChatFrameChannelButton:SetAlpha(0)
            end)
        end

        processedFrames[frame] = true
    end

    -- Apply to all chat windows
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            ProcessFrame(chatFrame)

            if i == 1 then
                chatFrame:ClearAllPoints()
                chatFrame:SetPoint(ChatConfig.anchor, UIParent, ChatConfig.anchor, ChatConfig.xOffset, ChatConfig.yOffset)
                chatFrame:SetSize(ChatConfig.width, ChatConfig.height)
                chatFrame:SetUserPlaced(true)
            end

            chatFrame:SetClampRectInsets(-10, 10, 0, 0)
            chatFrame:SetClampedToScreen(true)

            -- Remove chat tab textures
            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then
                if _G["ChatFrame"..i.."TabLeft"] then _G["ChatFrame"..i.."TabLeft"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabMiddle"] then _G["ChatFrame"..i.."TabMiddle"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabRight"] then _G["ChatFrame"..i.."TabRight"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedLeft"] then _G["ChatFrame"..i.."TabSelectedLeft"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedMiddle"] then _G["ChatFrame"..i.."TabSelectedMiddle"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedRight"] then _G["ChatFrame"..i.."TabSelectedRight"]:SetTexture(nil) end
                tab:SetAlpha(1)
            end
        end
    end

    -- Style temporary chat windows as they open
    local old_OpenTemporaryWindow = FCF_OpenTemporaryWindow
    FCF_OpenTemporaryWindow = function(...)
        local newFrame = old_OpenTemporaryWindow(...)
        ProcessFrame(newFrame)
        return newFrame
    end

    -- Enable shift-scroll scrolling
    function FloatingChatFrame_OnMouseScroll(self, delta)
        if delta > 0 then
            if IsShiftKeyDown() then
                self:ScrollToTop()
            else
                self:ScrollUp()
            end
        elseif delta < 0 then
            if IsShiftKeyDown() then
                self:ScrollToBottom()
            else
                self:ScrollDown()
            end
        end
    end
end)

-- URL matching patterns for clickable links
local urlPatterns = {
    "(https://%S+%.%S+)",
    "(http://%S+%.%S+)",
    "(www%.%S+%.%S+)",
    "(%d+%.%d+%.%d+%.%d+:?%d*/?%S*)"
}

-- Chat message events to filter
local chatEvents = {
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_BATTLEGROUND", "CHAT_MSG_BATTLEGROUND_LEADER",
    "CHAT_MSG_CHANNEL", "CHAT_MSG_SYSTEM"
}

-- Register message filter for URLs, class colors, channel abbreviations
for _, event in pairs(chatEvents) do
    ChatFrame_AddMessageEventFilter(event, function(self, event, msg, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter, guid, ...)
        -- Shorten channel names
        msg = msg:gsub("%[(%d+)%. ([^%]]+)%]", function(channelNum, chanName)
            local abbr = {
                ["General"] = "GEN",
                ["Trade"] = "TRD",
                ["LocalDefense"] = "DEF",
                ["LookingForGroup"] = "LFG",
                ["World"] = "WRLD",
                ["GuildRecruitment"] = "GR",
                ["global"] = "GLBL",
            }
            return "[" .. (abbr[chanName] or chanName:sub(1,3):upper()) .. "]"
        end)

        -- Color URLs blue & make clickable
        for _, pattern in ipairs(urlPatterns) do
            msg = msg:gsub(pattern, "|cff0394ff|Hurl:%1|h[%1]|h|r")
        end

        -- Color player names by class
        if sender and guid and type(guid) == "string" and guid ~= "0" and guid ~= "" then
            local _, class = GetPlayerInfoByGUID(guid)
            if class then
                local color = RAID_CLASS_COLORS[class]
                if color then
                    local colorCode = format("|cff%02x%02x%02x", color.r*255, color.g*255, color.b*255)
                    msg = msg:gsub("(|Hplayer:"..sender.."|h)%[([^%]]+)%]|h", function(prefix, nameInBrackets)
                        return prefix .. "[" .. colorCode .. nameInBrackets .. "|r]|h"
                    end)
                    msg = msg:gsub("(%f[%a])"..sender.."(%f[%A])", colorCode .. sender .. "|r")
                end
            end
        end

        return false, msg, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter, guid, ...
    end)
end

-- Whisper player on clicking their name link in chat
hooksecurefunc("ChatFrame_OnHyperlinkShow", function(frame, link, text, button)
    if strsub(link, 1, 7) == "player:" then
        local playerName = strmatch(link, "player:([^:]+)")
        if playerName and button == "LeftButton" then
            ChatFrame_SendTell(playerName, frame)
        end
    end
end)

-- Make URLs clickable, pasting into chat edit box
local originalSetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
    if link and strsub(link,1,3) == "url" then
        local editbox = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(editbox)
        editbox:Insert(strsub(link, 5))
        editbox:HighlightText()
        return
    end
    originalSetHyperlink(self, link, ...)
end

-- Slash command /rl to reload UI
SLASH_RELOAD1 = "/rl"
SlashCmdList["RELOAD"] = function()
    ReloadUI()
end
