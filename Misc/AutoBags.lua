-----------------------------
-- AutoBags Classic - Lanacan
-- WoW Classic Addon to automatically open all bags when interacting with vendors or banks,
-- and close them when leaving. Designed for convenience while selling or managing inventory.
-- Behavior is configurable via the two boolean settings at the top of the file.
-----------------------------

-- === Configuration ===
local AUTO_OPEN_BAGS_AT_VENDOR = true  -- true = auto open at vendor; false = disable
local AUTO_OPEN_BAGS_AT_BANK   = true  -- true = auto open at bank; false = disable

-- === Event Handler Frame ===
local frame = CreateFrame("Frame")

-- === Open regular player bags (backpack + 4 bags) ===
local function OpenAllPlayerBags()
    for bag = 0, 4 do
        OpenBag(bag)
    end
end

-- === Open bank interface and all bank bags (bag IDs 5–11) ===
local function OpenAllBankBags()
    BankFrame:Show() -- Open the default bank frame (bagID -1)
    for bag = 5, 11 do
        OpenBag(bag)
    end
end

-- === Close all bags (player + bank) and hide bank frame if open ===
local function CloseAllBagsFully()
    for bag = 0, 11 do
        CloseBag(bag)
    end
    if BankFrame:IsShown() then
        BankFrame:Hide()
    end
end

-- === Register bag-related events ===
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("BANKFRAME_CLOSED")

-- === Respond to events ===
frame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" and AUTO_OPEN_BAGS_AT_VENDOR then
        OpenAllPlayerBags()

    elseif event == "MERCHANT_CLOSED" and AUTO_OPEN_BAGS_AT_VENDOR then
        CloseAllBagsFully()

    elseif event == "BANKFRAME_OPENED" and AUTO_OPEN_BAGS_AT_BANK then
        OpenAllBankBags()
        -- Call again after a short delay to ensure all bank bags are loaded
        C_Timer.After(0.2, OpenAllBankBags)

    elseif event == "BANKFRAME_CLOSED" and AUTO_OPEN_BAGS_AT_BANK then
        CloseAllBagsFully()
    end
end)
