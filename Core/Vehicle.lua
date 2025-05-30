-- Create a new Button frame named "Vehicle Button" attached to UIParent (the main UI frame)
local vehicle = CreateFrame("Button", "Vehicle Button", UIParent)

-- Register event to detect when the player enters the world (loads into the game)
vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Function to handle showing or hiding the vehicle button based on whether player can exit a vehicle
function vehicle:VehicleOnEvent(event)
    -- Check if the player can exit the vehicle (meaning player is currently in a vehicle)
	if CanExitVehicle() then
        self:Show()  -- Show the button
        
        -- Create a FontString for the button text if it doesn't exist already
        vehicle.text = vehicle:CreateFontString(nil, "OVERLAY")		
        vehicle.text:SetFont(STANDARD_TEXT_FONT, 16, "OUTLINE")  -- Set font style and size
        vehicle.text:SetTextColor(1, 1, 1, 1)  -- Set text color to white (RGBA)
        
        vehicle.text:SetText("EXIT")  -- Set button label to "EXIT"
        
        -- Position the text to fill the button area, centered horizontally
        vehicle.text:SetPoint("TOPLEFT", vehicle, "TOPLEFT", 1, 0)
        vehicle.text:SetPoint("BOTTOMRIGHT", vehicle, "BOTTOMRIGHT", 0, 0)
        vehicle.text:SetJustifyH("CENTER")
    else
        self:Hide()  -- Hide the button if player cannot exit vehicle (not in a vehicle)
    end
end

-- Function called when the vehicle button is clicked
function vehicle:VehicleOnClick()	
    if (UnitOnTaxi("player")) then  -- Check if player is currently on a taxi (flight path)
        TaxiRequestEarlyLanding()  -- Request to land early from the flight path
        print("Requested early landing from flightpath.")  -- Print confirmation to chat
    else
        VehicleExit()  -- Exit the vehicle if not on a taxi
        print("Exiting vehicle.")  -- Print confirmation to chat
    end
	
	self:Hide()  -- Hide the button after click (no longer needed)
end


-- Check if the addon "vUI" is loaded (to avoid conflicts)
if IsAddOnLoaded("vUI") then
	return  -- If vUI is loaded, do nothing (exit this script)
else
	-- Otherwise, configure and set up the vehicle button
	
	-- Position the button below the minimap with an offset
	vehicle:SetPoint("TOP", Minimap, "BOTTOM", 0, -5)
	
	-- Set the button's size (width x height)
	vehicle:SetSize(100, 20)
	
	-- Set frame strata and level to control draw order in UI layers
	vehicle:SetFrameStrata("TOOLTIP")
	vehicle:SetFrameStrata("MEDIUM")  -- Note: This overrides previous line; probably want only one strata here
	vehicle:SetFrameLevel(10)
	
	vehicle:EnableMouse(true)  -- Enable mouse interaction
	
	vehicle:RegisterForClicks("AnyUp")  -- Register to handle any mouse button release
	
	vehicle:SetScript("OnClick", vehicle.VehicleOnClick)  -- Bind click event to handler function
	
	-- Register various events related to vehicle state and action bars to update the button visibility
	vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
	vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
	vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
	vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
	vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
	vehicle:RegisterEvent("VEHICLE_UPDATE")
	
	vehicle:Hide()  -- Start hidden by default
	
	vehicle:SetScript("OnEvent", vehicle.VehicleOnEvent)  -- Bind event handler to update button visibility and text
end
