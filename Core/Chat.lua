-------------
-- CHAT --
-------------

-- Create a frame to listen for addon and player events
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")           -- Fired when an addon (including this one) loads
frame:RegisterEvent("PLAYER_ENTERING_WORLD")  -- Fired when player logs in or zones

frame:SetScript("OnEvent", function(self, event)
    -- Customize general chat frame fading behavior and tab transparency
    CHAT_FRAME_FADE_TIME = 0.15                     -- How fast the chat fades out
    CHAT_FRAME_FADE_OUT_TIME = 1                     -- How long the chat remains visible before fading
    CHAT_TAB_HIDE_DELAY = 0                          -- Delay before hiding tabs (0 = instant)
    CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1    -- Fully opaque tab when selected and mouse over
    CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0      -- Invisible tab when selected and mouse not over
    CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1    -- Fully opaque tab when alerting and mouse over
    CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 1      -- Fully opaque tab when alerting and no mouse
    CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1      -- Fully opaque tab when normal and mouse over
    CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0        -- Invisible tab when normal and no mouse

    -- Enable fading for all default chat frames (1 to 7)
    for i = 1, 7 do
        _G["ChatFrame"..i]:SetFading(1)
    end

    -- Hide Blizzard's default chat menu button permanently
    if ChatFrameMenuButton then
        ChatFrameMenuButton:HookScript("OnShow", ChatFrameMenuButton.Hide)
        ChatFrameMenuButton:Hide()
    end

    -- Table to track which frames have been processed to avoid duplicates
    local processedFrames = {}

    -- Function to style and modify a single chat frame
    local function ProcessFrame(frame)
        if processedFrames[frame] then return end  -- Skip if already processed

        local name = frame:GetName()

        -- Hide the chat frame's button frame (minimize, maximize buttons)
        if _G[name.."ButtonFrame"] then
            _G[name.."ButtonFrame"]:Hide()
        end

        -- Hide the edit box borders for cleaner look
        if _G[name.."EditBoxLeft"] then
            _G[name.."EditBoxLeft"]:Hide()
            _G[name.."EditBoxMid"]:Hide()
            _G[name.."EditBoxRight"]:Hide()
        end

        -- Reposition and style the chat edit box (where you type messages)
        local editbox = _G[name.."EditBox"]
        if editbox then
            editbox:ClearAllPoints()
            editbox:SetPoint("BOTTOMLEFT", ChatFrame1, "TOPLEFT", -7, 25)
            editbox:SetPoint("BOTTOMRIGHT", ChatFrame1, "TOPRIGHT", 10, 25)
            editbox:SetAltArrowKeyMode(false) -- Allow arrow keys without Alt
        end

        -- Hide scrollbar if it exists (clean UI)
        if frame.ScrollBar then
            frame.ScrollBar:Hide()
            frame.ScrollBar.Show = function() end -- Disable showing again
        end

        -- Hide scroll to bottom button if it exists
        if frame.ScrollToBottomButton then
            frame.ScrollToBottomButton:Hide()
            frame.ScrollToBottomButton.Show = function() end
        end

        -- Voice chat button handling (may not exist in Classic)
        if ChatFrameChannelButton then
            frame:EnableMouse(true)
            ChatFrameChannelButton:EnableMouse(true)
            ChatFrameChannelButton:SetAlpha(0) -- Initially hidden

            -- Fade in button on mouse enter
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

        processedFrames[frame] = true -- Mark frame as processed
    end

    -- Process all default chat frames to apply our styling
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            ProcessFrame(chatFrame)

            -- Remove textures from chat tabs to create a minimalist look
            local tab = _G["ChatFrame"..i.."Tab"]
            if tab then
                if _G["ChatFrame"..i.."TabLeft"] then _G["ChatFrame"..i.."TabLeft"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabMiddle"] then _G["ChatFrame"..i.."TabMiddle"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabRight"] then _G["ChatFrame"..i.."TabRight"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedLeft"] then _G["ChatFrame"..i.."TabSelectedLeft"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedMiddle"] then _G["ChatFrame"..i.."TabSelectedMiddle"]:SetTexture(nil) end
                if _G["ChatFrame"..i.."TabSelectedRight"] then _G["ChatFrame"..i.."TabSelectedRight"]:SetTexture(nil) end
                tab:SetAlpha(1.0) -- Fully opaque tabs
            end
        end
    end

    -- Hook the function that creates temporary chat windows to style them as well
    local old_OpenTemporaryWindow = FCF_OpenTemporaryWindow
    FCF_OpenTemporaryWindow = function(...)
        local frame = old_OpenTemporaryWindow(...)
        ProcessFrame(frame)
        return frame
    end

    -- Override the mouse scroll behavior on chat frames for enhanced scrolling
    function FloatingChatFrame_OnMouseScroll(self, delta)
        if delta > 0 then
            if IsShiftKeyDown() then
                self:ScrollToTop()  -- Scroll all the way up with Shift + scroll up
            else
                self:ScrollUp()     -- Scroll up normally
            end
        elseif delta < 0 then
            if IsShiftKeyDown() then
                self:ScrollToBottom() -- Scroll all the way down with Shift + scroll down
            else
                self:ScrollDown()     -- Scroll down normally
            end
        end
    end

    -- Chat copy functionality: create a frame where chat text can be copied
    local copyFrame, copyEditBox, copyScrollFrame

    local function CreateCopyFrame()
        copyFrame = CreateFrame("Frame", "CopyFrame", UIParent)
        copyFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = false,
            tileSize = 32,
            edgeSize = 15,
            insets = {left = 1, right = 1, top = 1, bottom = 1}
        })
        copyFrame:SetSize(540, 300)
        copyFrame:SetPoint("CENTER")
        copyFrame:SetFrameStrata("DIALOG")
        tinsert(UISpecialFrames, "CopyFrame") -- Allow ESC key to close frame
        copyFrame:Hide()

        -- Edit box inside copy frame to show the copied text
        copyEditBox = CreateFrame("EditBox", "CopyBox", copyFrame)
        copyEditBox:SetMultiLine(true)
        copyEditBox:SetMaxLetters(99999)
        copyEditBox:EnableMouse(true)
        copyEditBox:SetAutoFocus(false)
        copyEditBox:SetFontObject(ChatFontNormal)
        copyEditBox:SetSize(500, 300)
        copyEditBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)

        -- Scroll frame for the edit box
        copyScrollFrame = CreateFrame("ScrollFrame", "CopyScroll", copyFrame, "UIPanelScrollFrameTemplate")
        copyScrollFrame:SetPoint("TOPLEFT", 8, -10)
        copyScrollFrame:SetPoint("BOTTOMRIGHT", -30, 8)
        copyScrollFrame:SetScrollChild(copyEditBox)
    end

    -- Add a small copy button to each chat frame to open the copy window
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame"..i]
        if chatFrame then
            local copyButton = CreateFrame("Button", nil, chatFrame)
            copyButton:SetSize(20, 20)
            copyButton:SetPoint("TOPRIGHT", chatFrame, 10, -5)

            -- Uncomment and set custom textures for the copy button if desired
            -- copyButton:SetNormalTexture("Interface\\AddOns\\YourAddon\\Textures\\copynormal")
            -- copyButton:SetHighlightTexture("Interface\\AddOns\\YourAddon\\Textures\\copyhighlight")

            copyButton:SetScript("OnClick", function()
                if not copyFrame then CreateCopyFrame() end

                local text = ""
                -- Collect all chat messages visible in this chat frame
                for j = 1, chatFrame:GetNumMessages() do
                    local line = chatFrame:GetMessageInfo(j)
                    -- Filter out certain protected hyperlinks (like player names)
                    if line and not strmatch(line, '[^|]-|K[vq]%d-[^|]-|k') then
                        text = text..line.."\n"
                    end
                end

                -- Replace raid target icons with text equivalents
                text = text:gsub("|T13700([1-8])[^|]+|t", "{rt%1}")
                -- Remove any remaining texture tags (icons)
                text = text:gsub("|T[^|]+|t", "")

                copyFrame:Show()
                copyEditBox:SetText(text)
            end)
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
    ChatFrame_AddMessageEventFilter(event, function(self, event, str, ...)
        for _, pattern in pairs(urlPatterns) do
            -- Replace URLs with clickable, colored links
            local result, match = gsub(str, pattern, "|cff0394ff|Hurl:%1|h[%1]|h|r")
            if match > 0 then
                return false, result, ...  -- Return modified message
            end
        end
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
