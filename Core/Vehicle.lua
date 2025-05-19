local vehicle = CreateFrame("Button", "Vehicle Button", UIParent)
vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")

function vehicle:VehicleOnEvent(event)
	if CanExitVehicle() then
        self:Show()
		--Set the Text for Flight vs. Vehicle
		vehicle.text = vehicle:CreateFontString(nil, "OVERLAY")
		vehicle.text:SetFont(STANDARD_TEXT_FONT, 12, "OUTLINE")
		vehicle.text:SetTextColor(1, 1, 1, 1)
		
		vehicle.text:SetText("EXIT")
		vehicle.text:SetPoint("TOPLEFT", vehicle, "TOPLEFT", 1, 0)
		vehicle.text:SetPoint("BOTTOMRIGHT", vehicle, "BOTTOMRIGHT", 0, 0)
		vehicle.text:SetJustifyH("CENTER")
    else
        self:Hide()
    end
end

function vehicle:VehicleOnClick()	
    if (UnitOnTaxi("player")) then		
        TaxiRequestEarlyLanding()
		print("Requested early landing from flightpath.")
    else
        VehicleExit()
		print("Exiting vehicle.")
    end
	
	self:Hide()
end

vehicle:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, -20)
--vehicle:SetPoint("TOP", Minimap, "BOTTOM", 0, -5)
vehicle:SetSize(100, 20)
vehicle:SetFrameStrata("TOOLTIP")
vehicle:SetFrameStrata("MEDIUM")
vehicle:SetFrameLevel(10)
vehicle:EnableMouse(true)
vehicle:RegisterForClicks("AnyUp")
vehicle:SetScript("OnClick", vehicle.VehicleOnClick)
vehicle:RegisterEvent("PLAYER_ENTERING_WORLD")
vehicle:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
vehicle:RegisterEvent("UPDATE_MULTI_CAST_ACTIONBAR")
vehicle:RegisterEvent("UNIT_ENTERED_VEHICLE")
vehicle:RegisterEvent("UNIT_EXITED_VEHICLE")
vehicle:RegisterEvent("VEHICLE_UPDATE")
vehicle:Hide()
vehicle:SetScript("OnEvent", vehicle.VehicleOnEvent)



