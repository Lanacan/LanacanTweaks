
-- Hide bag and micro menu buttons
local hiddenElements = {
    MainMenuBarBackpackButton,
    CharacterMicroButton,
    SpellbookMicroButton,
    TalentMicroButton,
    AchievementMicroButton,
    QuestLogMicroButton,
    GuildMicroButton,
    LFDMicroButton,
    EJMicroButton,
    StoreMicroButton,
    MainMenuMicroButton
}

for _, frame in ipairs(hiddenElements) do
    if frame then
        frame:Hide()
        frame.Show = function() end
    end
end

-- Reposition main action bar to be centered and slightly above the bottom
MainMenuBar:ClearAllPoints()
MainMenuBar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 10)
MainMenuBar.SetPoint = function() end
