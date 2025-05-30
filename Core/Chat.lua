-------------
-- CHAT --
-------------

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event)
    -- Function to format timestamp
    local function AddTimestamp(msg)
        local timeStamp = date("|cff999999[%H:%M]|r")
        return timeStamp .. " " .. msg
    end

    -- Override AddMessage for each chat frame to prepend timestamp
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

    -- Chat frame fading settings
    CHAT_FRAME_FADE_TIME = 0.15
    CHAT_FRAME_FADE_OUT_TIME = 1
    CHAT_TAB_HIDE_DELAY = 0
    CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
    CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1
    CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
    CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0

    for i = 1, 7 do
        _G["ChatFrame"..i]:SetFading(true)
    end

    if ChatFrameMenuButton then
        ChatFrameMenuButton:HookScript("OnShow", ChatFrameMenuButton.Hide)
        ChatFrameMenuButton:Hide()
    end

    local processedFrames = {}

    local function ProcessFrame(frame)
        if processedFrames[frame] then return end

        local name = frame:GetName()

        if _G[name.."ButtonFrame"] then
            _G[name.."ButtonFrame"]:Hide()
        end

        if _G[name.."EditBoxLeft"] then
            _G[name.."EditBoxLeft"]:Hide()
            _G[name.."EditBoxMid"]:Hide()
            _G[name.."EditBoxRight"]:Hide()
        end

        local editbox = _G[name.."EditBox"]
        if editbox then
            editbox:ClearAllPoints()
            editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -7, 15)
            editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 10, 15)
            editbox:SetAltArrowKeyMode(false)
        end

        if frame.ScrollBar then
            frame.ScrollBar:Hide()
            frame.ScrollBar.Show = function() end
        end

        if frame.ScrollToBottomButton then
            frame.ScrollToBottomButton:Hide()
            frame.ScrollToBottomButton.Show = function() end
        end

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

    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            ProcessFrame(chatFrame)
			
			chatFrame:SetClampRectInsets(-10, 10, 0, 0)  -- moves left and right clamp 10 pixels outside screen edges
			chatFrame:SetClampedToScreen(true)

            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then
                if _G["ChatFrame"..i.."TabLeft"] then _G["ChatFrame"..i.."TabLeft"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabMiddle"] then _G["ChatFrame"..i.."TabMiddle"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabRight"] then _G["ChatFrame"..i.."TabRight"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedLeft"] then _G["ChatFrame"..i.."TabSelectedLeft"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedMiddle"] then _G["ChatFrame"..i.."TabSelectedMiddle"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedRight"] then _G["ChatFrame"..i.."TabSelectedRight"]:SetTexture(nil) end
                tab:SetAlpha(1.0)
            end
        end
    end

    local old_OpenTemporaryWindow = FCF_OpenTemporaryWindow
    FCF_OpenTemporaryWindow = function(...)
        local newFrame = old_OpenTemporaryWindow(...)
        ProcessFrame(newFrame)
        return newFrame
    end

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


-- URL highlighting patterns for various URL forms
local urlPatterns = {
    "(https://%S+%.%S+)",
    "(http://%S+%.%S+)",
    "(www%.%S+%.%S+)",
    "(%d+%.%d+%.%d+%.%d+:?%d*/?%S*)"  -- IP addresses with optional ports and paths
}

-- Add message filters to highlight URLs in chat messages
for _, event in pairs({
    "CHAT_MSG_SAY", "CHAT_MSG_YELL", "CHAT_MSG_WHISPER", "CHAT_MSG_WHISPER_INFORM",
    "CHAT_MSG_GUILD", "CHAT_MSG_OFFICER", "CHAT_MSG_PARTY", "CHAT_MSG_PARTY_LEADER",
    "CHAT_MSG_RAID", "CHAT_MSG_RAID_LEADER", "CHAT_MSG_RAID_WARNING",
    "CHAT_MSG_INSTANCE_CHAT", "CHAT_MSG_INSTANCE_CHAT_LEADER",
    "CHAT_MSG_BATTLEGROUND", "CHAT_MSG_BATTLEGROUND_LEADER",
    "CHAT_MSG_CHANNEL", "CHAT_MSG_SYSTEM"
}) do
    ChatFrame_AddMessageEventFilter(event, function(self, event, msg, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter, guid, ...)
        -- Highlight URLs in message
        for _, pattern in ipairs(urlPatterns) do
            msg = msg:gsub(pattern, "|cff0394ff|Hurl:%1|h[%1]|h|r")
        end

        -- Color player names if guid is valid string and sender exists
        if sender and guid and type(guid) == "string" and guid ~= "0" and guid ~= "" then
			local _, class = GetPlayerInfoByGUID(guid)
			if class then
				local color = RAID_CLASS_COLORS[class]
				if color then
					local colorCode = format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)

					-- Try to color the player's name in the hyperlink form: |Hplayer:Name|h[Name]|h
					msg = msg:gsub("(|Hplayer:"..sender.."|h)%[([^%]]+)%]|h", function(prefix, nameInBrackets)
						return prefix .. "[" .. colorCode .. nameInBrackets .. "|r]|h"
					end)

					-- Also color plain occurrences of the sender's name (e.g., in trade chat)
					msg = msg:gsub("(%f[%a])"..sender.."(%f[%A])", colorCode .. sender .. "|r")
				end
			end
		end


        -- Return false (do not block) and all original parameters, with updated msg
        return false, msg, sender, language, channelString, target, flags, unknown1, channelNumber, channelName, unknown2, counter, guid, ...
    end)
end




-- Override the default hyperlink handler to allow clicking URLs and inserting them in chat edit box
local originalSetHyperlink = ItemRefTooltip.SetHyperlink
function ItemRefTooltip:SetHyperlink(link, ...)
    if link and strsub(link, 1, 3) == "url" then
        local editbox = ChatEdit_ChooseBoxForSend()
        ChatEdit_ActivateChat(editbox)
        editbox:Insert(strsub(link, 5)) -- Insert the URL text into chat edit box
        editbox:HighlightText()
        return
    end
    originalSetHyperlink(self, link, ...)
end

-- === Slash Command to reload UI ===
SLASH_RELOAD1 = "/rl"
SlashCmdList["RELOAD"] = function()
    ReloadUI()
end

