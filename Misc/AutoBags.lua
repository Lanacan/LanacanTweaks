-- AutoBags Classic Addon
-- Opens all bags at vendor or bank, closes when leaving
-- Configuration

local AUTO_OPEN_BAGS_AT_VENDOR = true  -- true/false: auto open bags at vendor
local AUTO_OPEN_BAGS_AT_BANK   = true  -- true/false: auto open bags at bank

local frame = CreateFrame("Frame")

-- Open regular player bags (backpack + 4 bags)
local function OpenAllPlayerBags()
    for bag = 0, 4 do  -- 0 is backpack, 1-4 are regular bags
        OpenBag(bag)
    end
end

-- Open all bank bags (bank frame + bank bags)
local function OpenAllBankBags()
    -- First open the bank frame itself (bagID -1)
    BankFrame:Show()
    -- Then open regular bank bags (bags 5-11 in Classic)
    for bag = 5, 11 do
        OpenBag(bag)
    end
end

-- Close all bags (both player and bank)
local function CloseAllBagsFully()
    for bag = 0, 11 do  -- Close all possible bags
        CloseBag(bag)
    end
    if BankFrame:IsShown() then
        BankFrame:Hide()
    end
end

-- Events
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_CLOSED")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("BANKFRAME_CLOSED")

frame:SetScript("OnEvent", function(_, event)
    if event == "MERCHANT_SHOW" and AUTO_OPEN_BAGS_AT_VENDOR then
        OpenAllPlayerBags()
    elseif event == "MERCHANT_CLOSED" and AUTO_OPEN_BAGS_AT_VENDOR then
        CloseAllBagsFully()
    elseif event == "BANKFRAME_OPENED" and AUTO_OPEN_BAGS_AT_BANK then
        OpenAllBankBags()
        -- Small delay to ensure bank is fully loaded
        C_Timer.After(0.2, OpenAllBankBags)
    elseif event == "BANKFRAME_CLOSED" and AUTO_OPEN_BAGS_AT_BANK then
        CloseAllBagsFully()
    end
end)