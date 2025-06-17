-- Action Bar Styler for WoW Classic with Bartender4, Dominos, and Default UI Support

local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()

  local backdrop = {
    bgFile = "Interface\\BUTTONS\\WHITE8X8",
    edgeFile = "Interface\\Buttons\\WHITE8X8",
    tile = false,
    tileSize = 32,
    edgeSize = 1,
    insets = { left = 0, right = 0, top = 0, bottom = 0 }
  }

  local function applyBackground(bu, isLeaveButton)
    if not bu or bu.bg then return end
    if bu:GetFrameLevel() < 1 then bu:SetFrameLevel(1) end
    bu.bg = CreateFrame("Frame", nil, bu, "BackdropTemplate")
    bu.bg:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
    bu.bg:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
    bu.bg:SetFrameLevel(bu:GetFrameLevel() - 1)
    bu.bg.backdropInfo = backdrop
    bu.bg:ApplyBackdrop()
    bu.bg:SetBackdropColor(0, 0, 0, 1)
    bu.bg:SetBackdropBorderColor(0, 0, 0, 0)

    local nt = bu:GetNormalTexture()
    if not isLeaveButton then
      if nt then nt:SetAlpha(0) end
      hooksecurefunc(bu, "SetNormalTexture", function(self)
        if self:GetNormalTexture() then self:GetNormalTexture():SetAlpha(0) end
      end)
    else
      if nt then
        nt:SetTexCoord(0.1, 0.9, 0.1, 0.9)
        nt:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
        nt:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
      end
    end
  end

  local function stripAllTextures(bu)
    for i = 1, bu:GetNumRegions() do
      local region = select(i, bu:GetRegions())
      if region and region:IsObjectType("Texture") then
        local name = region:GetName()
        if name and (name:find("Icon") or name:find("Cooldown")) then
          -- keep icon and cooldown
        else
          region:SetTexture(nil)
          region:Hide()
        end
      end
    end
  end

  local function styleButton(bu)
    if not bu or bu.styled then return end
    local name = bu:GetName() or (bu.GetParent and bu:GetParent() and bu:GetParent():GetName()) or ""
    local icon = bu.icon or _G[name .. "Icon"]
    local count = _G[name .. "Count"]
    local border = _G[name .. "Border"]
    local hotkey = _G[name .. "HotKey"]
    local cooldown = _G[name .. "Cooldown"]
    local nameText = _G[name .. "Name"]
    local flash = _G[name .. "Flash"]
    local normal = _G[name .. "NormalTexture"]
    local highlight = _G[name .. "Highlight"]
    local checked = _G[name .. "Checked"]
    local pushed = _G[name .. "Pushed"]
    local shadow = _G[name .. "Shadow"]

    -- Nuke stray textures
    stripAllTextures(bu)

    if border then border:SetTexture(nil) end
    if highlight then highlight:SetTexture(nil) end
    if checked then checked:SetTexture(nil); checked:Hide() end
    if pushed then pushed:SetTexture(nil); pushed:Hide() end
    if shadow then shadow:SetTexture(nil); shadow:Hide() end
    if flash then flash:SetTexture(nil); flash:Hide() end

    if hotkey then hotkey:ClearAllPoints(); hotkey:SetPoint("TOPLEFT", bu, -2, -2) end
    if nameText then nameText:Hide() end

    if icon then
      icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
      icon:SetPoint("TOPLEFT", bu, "TOPLEFT", 3, -3)
      icon:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -3, 3)
    end

    if cooldown then
      cooldown:SetPoint("TOPLEFT", bu, "TOPLEFT", 1, -1)
      cooldown:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -1, 1)
    end

    if normal then
      normal:SetTexture(nil)
      normal:SetAlpha(0)
      hooksecurefunc(bu, "SetNormalTexture", function(self)
        local tex = self:GetNormalTexture()
        if tex then tex:SetTexture(nil); tex:SetAlpha(0) end
      end)

      if bu.SetNormalAtlas then
        hooksecurefunc(bu, "SetNormalAtlas", function(self)
          local tex = self:GetNormalTexture()
          if tex then tex:SetTexture(nil); tex:SetAlpha(0) end
        end)
      end
    end

    applyBackground(bu)
    bu.styled = true
  end

  -- Bartender4 buttons
  if IsAddOnLoaded("Bartender4") then
    for i = 1, 10 do
      local bar = _G["BT4Bar" .. i]
      if bar and bar.buttons then
        for _, button in ipairs(bar.buttons) do
          styleButton(button)
        end
      end
    end
  end

  -- Dominos buttons
  if IsAddOnLoaded("Dominos") then
    for i = 1, 120 do
      local bu = _G["DominosActionButton" .. i]
      if bu then styleButton(bu) end
    end
    for i = 1, 10 do
      local bu = _G["StanceButton" .. i]
      if bu then styleButton(bu) end
    end
  end

  -- Default Blizzard bars
  C_Timer.After(0.5, function()
    local blizzBars = {
      "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton",
      "MultiBarLeftButton", "MultiBarRightButton", "StanceButton"
    }

    for _, prefix in ipairs(blizzBars) do
      for i = 1, 12 do
        local button = _G[prefix .. i]
        if button then styleButton(button) end
      end
    end
  end)
end)
