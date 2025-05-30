-- ChatCopy.lua

-- Table to store frames
local frames = {}

-- Create the copy frame
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

copyFrame:SetMovable(true)
copyFrame:EnableMouse(true)
copyFrame:RegisterForDrag("LeftButton")
copyFrame:SetScript("OnDragStart", copyFrame.StartMoving)
copyFrame:SetScript("OnDragStop", copyFrame.StopMovingOrSizing)

-- ScrollFrame
local scrollFrame = CreateFrame("ScrollFrame", nil, copyFrame, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 10, -35)
scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

-- EditBox
local editBox = CreateFrame("EditBox", nil, scrollFrame)
editBox:SetMultiLine(true)
editBox:SetFontObject(ChatFontNormal)
editBox:SetWidth(550)
editBox:SetAutoFocus(false)
editBox:SetScript("OnEscapePressed", function()
    copyFrame:Hide()
end)
scrollFrame:SetScrollChild(editBox)

-- Close Button
local closeButton = CreateFrame("Button", nil, copyFrame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", copyFrame, "TOPRIGHT")

-- Function to extract lines from chat
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

-- Function to copy chat
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

-- Add copy button to chat frame
local function AddCopyButtonToChatFrame(chatFrame)
    local name = chatFrame:GetName()
    if not name then return end

    --print("ChatCopy: Button added to", name) --For Debuging. 

    -- Create the copy button
    local button = CreateFrame("Button", nil, chatFrame)
    button:SetSize(20, 20)
    button:SetPoint("TOPRIGHT", chatFrame, "TOPRIGHT", -4, -4)
    button:SetFrameStrata("HIGH")
    button:SetFrameLevel(1000)
    button:SetNormalTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
    button:SetHighlightTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Highlight")
    button:SetPushedTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Down")
    button:SetScript("OnClick", function()
        CopyChat(chatFrame)
    end)
    button:Hide()

    -- Create a transparent overlay frame for mouse detection
    local hoverFrame = CreateFrame("Frame", nil, chatFrame)
    hoverFrame:SetAllPoints(chatFrame)
    hoverFrame:SetFrameStrata("HIGH")
    hoverFrame:SetFrameLevel(999)
    hoverFrame:EnableMouse(true)
    hoverFrame:SetScript("OnEnter", function()
        button:Show()
    end)
    hoverFrame:SetScript("OnLeave", function()
        if not button:IsMouseOver() then
            button:Hide()
        end
    end)

    -- Ensure button doesn't hide when it's hovered
    button:SetScript("OnLeave", function()
        if not hoverFrame:IsMouseOver() then
            button:Hide()
        end
    end)

    table.insert(frames, chatFrame)
end

-- Add copy button to all chat windows
for i = 1, NUM_CHAT_WINDOWS do
    local frame = _G["ChatFrame" .. i]
    if frame then
        AddCopyButtonToChatFrame(frame)
    end
end
