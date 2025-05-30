-- Function: stringPatternMatch
-- Purpose: Compares two format strings to check if their pattern sequences (like %s, %d) match in order.
-- This helps ensure that the translation string has the same argument structure as the original.
function stringPatternMatch(oldString, newString)
    -- Extract format patterns (e.g., %s, %d) from both strings
    local oldPattern = string.gmatch(oldString, "%%.");
    local newPattern = string.gmatch(newString, "%%.");
    
    -- Iterate through both pattern lists simultaneously
    local oldPatternIteration = oldPattern();
    local newPatternIteration = newPattern();
    while oldPatternIteration ~= nil or newPatternIteration ~= nil do
        -- If the patterns do not match at any position, return false
        if oldPatternIteration ~= newPatternIteration then
            return false;
        end
        -- Advance to the next pattern in both strings
        oldPatternIteration = oldPattern();
        newPatternIteration = newPattern();
    end

    -- All patterns matched
    return true;
end

-- Table: translateTable
-- Purpose: Holds alternate, simplified versions of various loot, XP, faction, and skill messages
-- This is useful for customizing the in-game text formatting (e.g., shortening verbose messages).
local translateTable = {
    -- Loot messages (Classic WoW style)
    ["CURRENCY_GAINED"] = "+ %s",
    ["LOOT_ITEM"] = "+ %s : %s",
    ["LOOT_ITEM_MULTIPLE"] = "+ %s : %s x%d",
    ["LOOT_ITEM_SELF"] = "+ %s",
    ["LOOT_ITEM_SELF_MULTIPLE"] = "+ %s x%d",
    ["LOOT_ITEM_PUSHED_SELF"] = "+ %s",
    ["LOOT_ITEM_PUSHED_SELF_MULTIPLE"] = "+ %s x%d",
    ["YOU_LOOT_MONEY"] = "+ %s",
    ["LOOT_MONEY_SPLIT"] = "+ %s (Shared)",

    -- Crafted items
    ["CREATED_ITEM"] = "+ %s : %s (craft)",
    ["CREATED_ITEM_MULTIPLE"] = "+ %s : %s x%d (craft)",
    ["TRADESKILL_LOG_FIRSTPERSON"] = "+ %s (craft)",
    ["TRADESKILL_LOG_THIRDPERSON"] = "+ %s : %s (craft)",

    -- Experience gain messages
    ["COMBATLOG_XPGAIN_FIRSTPERSON"] = "%s : +%d xp",
    ["COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"] = "+%d xp",
    ["COMBATLOG_XPGAIN_FIRSTPERSON_GROUP"] = "%s : +%d xp (+%d group)",
    ["COMBATLOG_XPGAIN_FIRSTPERSON_RAID"] = "%s : +%d xp (-%d raid)",
    ["COMBATLOG_XPGAIN_EXHAUSTION1"] = "%s : +%d xp (%s %s)",
    ["COMBATLOG_XPGAIN_EXHAUSTION1_GROUP"] = "%s : +%d xp (%s %s, +%d group)",
    ["COMBATLOG_XPGAIN_EXHAUSTION1_RAID"] = "%s : +%d xp (%s %s, -%d raid)",

    -- Faction reputation messages
    ["FACTION_STANDING_CHANGED"] = "%s : %s",
    ["FACTION_STANDING_INCREASED"] = "%s + %d",
    ["FACTION_STANDING_DECREASED"] = "%s - %d",
    ["FACTION_STANDING_INCREASED_GENERIC"] = "%s +",
    ["FACTION_STANDING_DECREASED_GENERIC"] = "%s -",

    -- Skill rank-up message
    ["SKILL_RANK_UP"] = "%s = %d"
}

-- Iterate through the translation table
-- If the original global message (_G[k]) exists and its pattern matches the new one,
-- replace the original global message string with the translated version
for k, v in pairs(translateTable) do
    if _G[k] ~= nil and stringPatternMatch(_G[k], v) == true then
        _G[k] = v
    end
end
