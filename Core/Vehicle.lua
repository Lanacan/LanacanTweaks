----------------------
-- Lanacan Vehicle Exit Button
-- Displays a simple "EXIT" button when the player is in a vehicle or on a taxi.
-- Clicking the button either requests early landing (taxi) or exits the vehicle.
-- Avoids loading if the "vUI" addon is detected.
-- Designed for WoW Classic compatibility.
----------------------

-- Create a new Button frame named "Vehicle Button" attached to the UIParent (main UI frame)
local vehicle = CreateFrame("Button", "Vehicle Button", UIParent)

-- Register a basic event to detect when the player enters the world (loads into the game)
vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Event handler function: show or hide the vehicle button based on vehicle state
function vehicle:VehicleOnEvent(event)
    if CanExitVehicle() then
        self:Show()  -- Show the button if player is in a vehicle

        -- Create and configure button label if not already created
        vehicle.text = vehicle.text or vehicle:CreateFontString(nil, "OVERLAY")
        vehicle.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")
        vehicle.text:SetTextColor(1, 1, 1, 1)
        vehicle.text:SetText("EXIT")

        -- Anchor text inside the button and center it
        vehicle.text:SetPoint("TOPLEFT", vehicle, "TOPLEFT", 1, 0)
        vehicle.text:SetPoint("BOTTOMRIGHT", vehicle, "BOTTOMRIGHT", 0, 0)
        vehicle.text:SetJustifyH("CENTER")
    else
        self:Hide()  -- Hide if not in a vehicle
    end
end

-- Click handler function: handles what happens when button is clicked
function vehicle:VehicleOnClick()
    if UnitOnTaxi("player") then
        -- If on a taxi (flight path), request early landing
        TaxiRequestEarlyLanding()
        print("Requested early landing from flightpath.")
    else
        -- If in a controllable vehicle, exit it
        VehicleExit()
        print("Exiting vehicle.")
    end

    self:Hide()  -- Hide button after action
end

-- Check for conflicting UI addon (vUI) and prevent load if present
if IsAddOnLoaded("vUI") then
    return  -- Exit script if vUI is active
else
    -- Setup and configure the vehicle button

    -- Anchor button just below the minimap
    vehicle:SetPoint("TOP", Minimap, "BOTTOM", 0, 20)

    -- Set button size (width x height)
    vehicle:SetSize(100, 20)

    -- Set draw layer order; TOOLTIP was overridden by MEDIUM
    vehicle:SetFrameStrata("MEDIUM")
    vehicle:SetFrameLevel(10)

    vehicle:EnableMouse(true)  -- Enable mouse interaction
    vehicle:RegisterForClicks("AnyUp")  -- Trigger on any mouse button release

    -- Set scripts for clicking and event handling
    vehicle:SetScript("OnClick", vehicle.VehicleOnClick)
    vehicle:SetScript("OnEvent", vehicle.VehicleOnEvent)

    -- Register vehicle-related events to update button visibility
    vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
    vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
    vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
    vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
    vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
    vehicle:RegisterEvent("VEHICLE_UPDATE")

    -- Hide the button initially (until conditions are met)
    vehicle:Hide()
end
