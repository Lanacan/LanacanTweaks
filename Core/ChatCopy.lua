----------------------
-- Lanacan ChatCopy
-- Adds a small button to each default chat window that opens a movable, scrollable window
-- allowing players to copy the entire chat history.
--
-- Features:
-- - Click-to-copy button on all default chat frames, positioned at bottom-right.
-- - Scrollable multiline edit box for viewing and copying chat text.
-- - Button alpha fades in on mouseover and remains minimally visible otherwise.
----------------------

-- Configuration for copy button positioning and alpha transparency
local BUTTON_POSITION = { "TOPLEFT", 4, -4 }
--local BUTTON_POSITION = { "BOTTOMRIGHT", -4, 4 }
local BUTTON_ALPHA_IDLE = 0.15
local BUTTON_ALPHA_HOVER = 1.0

local frames = {}  -- Tracks chat frames with attached copy buttons

---
-- Create and style the hidden copy frame containing the scrollable edit box
---
local copyFrame = CreateFrame("Frame", "ChatCopyFrame", UIParent, "BackdropTemplate")
copyFrame:SetSize(600, 400)
copyFrame:SetPoint("CENTER")
copyFrame:SetBackdrop({
    bgFile = "Interface/Tooltips/UI-Tooltip-Background",
    edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
copyFrame:SetBackdropColor(0, 0, 0, 1)
copyFrame:Hide()

-- Enable dragging of the copy frame
copyFrame:SetMovable(true)
copyFrame:EnableMouse(true)
copyFrame:RegisterForDrag("LeftButton")
copyFrame:SetScript("OnDragStart", copyFrame.StartMoving)
copyFrame:SetScript("OnDragStop", copyFrame.StopMovingOrSizing)

---
-- Scroll frame and edit box inside the copy frame for displaying copied chat text
---
local scrollFrame = CreateFrame("ScrollFrame", nil, copyFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -35)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

local editBox = CreateFrame("EditBox", nil, scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(550)
editBox:SetAutoFocus(false)
editBox:SetScript("OnEscapePressed", function() copyFrame:Hide() end)
scrollFrame:SetScrollChild(editBox)

-- Close button for the copy frame
local closeButton = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT")

---
-- Extract all visible messages from a given chat frame
-- @param chatFrame The chat frame to extract messages from
-- @return table Array of message strings
---
local function GetLines(chatFrame)
    local lines = {}
    local numMessages = chatFrame:GetNumMessages()
    for i = 1, numMessages do
        local message = chatFrame:GetMessageInfo(i)
        if message and message ~= "" then
            table.insert(lines, message)
        end
    end
    return lines
end

---
-- Show the copy frame with the full chat text from the specified chat frame
-- @param chatFrame The chat frame to copy text from
---
local function CopyChat(chatFrame)
    copyFrame:Show()
    copyFrame:SetFrameStrata("DIALOG")
    copyFrame:ClearAllPoints()
    copyFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)

    local lines = GetLines(chatFrame)
    local text = table.concat(lines, "\n")
    editBox:SetText(text)
    editBox:HighlightText()
end

---
-- Add the copy button to a given chat frame with mouseover fade effects
-- @param chatFrame The chat frame to add the button to
---
local function AddCopyButtonToChatFrame(chatFrame)
    local name = chatFrame:GetName()
    if not name then return end

    local button = CreateFrame("Button", nil, chatFrame)
    button:SetSize(20, 20)
    button:SetPoint(unpack(BUTTON_POSITION))
    button:SetFrameStrata("HIGH")
    button:SetFrameLevel(1000)
    button:SetAlpha(BUTTON_ALPHA_IDLE)
    button:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    button:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
    button:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Down")
    button:SetScript("OnClick", function() CopyChat(chatFrame) end)

    button:EnableMouse(true)
    button:SetScript("OnEnter", function() button:SetAlpha(BUTTON_ALPHA_HOVER) end)
    button:SetScript("OnLeave", function() button:SetAlpha(BUTTON_ALPHA_IDLE) end)

    table.insert(frames, chatFrame)
end

-- Add copy button to all default chat windows on load
for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame" .. i]
    if frame then
        AddCopyButtonToChatFrame(frame)
    end
end
