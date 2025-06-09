-- Cag + micro menu mouseover bar placed into the right lower corner.

local fadeAlpha = 0 -- hidden alpha
local showAlpha = 1 -- visible alpha
local fadeDuration = 0.3

local CornerMenuFrame = CreateFrame("Frame", "CornerMenuFrame", UIParent)
CornerMenuFrame:SetSize(256, 45)
CornerMenuFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 40)
CornerMenuFrame:SetAlpha(fadeAlpha)
CornerMenuFrame:SetFrameStrata("HIGH")

local BagButtonFrame = CreateFrame("Frame", nil, CornerMenuFrame)
BagButtonFrame:SetSize(256, 45)
BagButtonFrame:SetPoint("BOTTOMRIGHT", CornerMenuFrame, "BOTTOMRIGHT", 0, 0)

local MicroButtonsFrame = CreateFrame("Frame", nil, CornerMenuFrame)
MicroButtonsFrame:SetSize(256, 45)
MicroButtonsFrame:SetPoint("BOTTOMRIGHT", CornerMenuFrame, "BOTTOMRIGHT", 0, 1)

local BagButtons = {
	MainMenuBarBackpackButton,
	CharacterBag0Slot,
	CharacterBag1Slot,
	CharacterBag2Slot,
	CharacterBag3Slot,
	KeyRingButton
}

local MICRO_BUTTONS = {
	"CharacterMicroButton",
	"SpellbookMicroButton",
	"TalentMicroButton",
	"QuestLogMicroButton",
	"SocialsMicroButton",
	"LFGMicroButton",
	"MainMenuMicroButton",
	"HelpMicroButton"
}

for i, button in ipairs(BagButtons) do
	button:SetParent(BagButtonFrame)
	button:SetSize(32, 32)
	button:ClearAllPoints()
	if i == 1 then
		button:SetPoint("LEFT", BagButtonFrame, "LEFT", 5, 0)
	else
		button:SetPoint("LEFT", BagButtons[i-1], "RIGHT", 4, 0)
	end
	button:SetAlpha(fadeAlpha)
end

for i, name in ipairs(MICRO_BUTTONS) do
	local btn = _G[name]
	if btn then
		btn:SetParent(MicroButtonsFrame)
		btn:SetSize(32, 32)
		btn:ClearAllPoints()
		if i == 1 then
			btn:SetPoint("LEFT", MicroButtonsFrame, "LEFT", 5, 0)
		else
			btn:SetPoint("LEFT", _G[MICRO_BUTTONS[i-1]], "RIGHT", 4, 0)
		end
		btn:SetAlpha(fadeAlpha)
	end
end

local CornerMouseoverFrame = CreateFrame("Frame", "CornerMouseoverFrame", UIParent)
CornerMouseoverFrame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -5, 40)
CornerMouseoverFrame:SetSize(200, 45)
CornerMouseoverFrame:SetFrameStrata("BACKGROUND")

CornerMouseoverFrame:SetScript("OnEnter", function()
	UIFrameFadeIn(CornerMenuFrame, fadeDuration, CornerMenuFrame:GetAlpha(), showAlpha)
	for _, button in ipairs(BagButtons) do button:SetAlpha(showAlpha) end
	for _, name in ipairs(MICRO_BUTTONS) do
		local btn = _G[name]
		if btn then btn:SetAlpha(showAlpha) end
	end
end)

CornerMouseoverFrame:SetScript("OnLeave", function()
	UIFrameFadeOut(CornerMenuFrame, fadeDuration, CornerMenuFrame:GetAlpha(), fadeAlpha)
	for _, button in ipairs(BagButtons) do button:SetAlpha(fadeAlpha) end
	for _, name in ipairs(MICRO_BUTTONS) do
		local btn = _G[name]
		if btn then btn:SetAlpha(fadeAlpha) end
	end
end)
