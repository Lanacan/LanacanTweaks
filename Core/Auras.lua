-- Replace with your texture path or use a built-in texture
local SQUARE_TEXTURE = "Interface\\Buttons\\WHITE8X8"

-- Define a simple square border backdrop
-- This is used for creating a shadow/border effect behind aura icons
local backdrop = {
  bgFile = nil,             -- No background texture
  edgeFile = SQUARE_TEXTURE, -- Use the white square texture for the border
  tile = false,             -- Don't tile the edge texture
  tileSize = 32,            -- Not tiled, but size if needed
  edgeSize = 1,             -- Border thickness of 1 pixel
  insets = {                -- Insets for the border padding
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
}

-- Applies a custom visual style to a given buff or debuff button
-- This function modifies the appearance of individual aura icons by:
-- - cropping the icon texture
-- - repositioning the icon
-- - creating a custom colored border (color depends on debuff type)
-- - adding a shadow backdrop frame behind the icon
local function applySkin(b)
  if not b or b.styled then return end  -- Exit if button is nil or already styled

  local name = b:GetName()
  if not name then return end            -- Exit if button has no name

  local isDebuff = name:match("Debuff") -- Check if the aura is a debuff by name pattern
  local icon = _G[name .. "Icon"]       -- Get the icon texture associated with the button
  if icon then
    -- Crop the icon texture to remove default borders (TexCoord zoom)
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    -- Reset icon anchoring points for consistent placement inside the button
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)
    b.icon = icon
  end

  -- Create or retrieve the border texture for the aura button
  local border = _G[name .. "Border"] or b:CreateTexture(name .. "Border", "BACKGROUND", nil, -7)
  border:SetTexture(SQUARE_TEXTURE) -- Use the square texture for the border
  border:SetTexCoord(0, 1, 0, 1)
  border:SetDrawLayer("BACKGROUND", -7) -- Draw behind other elements

  if isDebuff then
    -- For debuffs, color the border based on debuff type (Poison, Curse, etc.)
    -- Get the debuff type from the unit's debuff at this slot index
    local debuffType = select(5, UnitDebuff("target", tonumber(name:match("%d+"))))
    local color = DebuffTypeColor[debuffType or "none"] or { r = 0, g = 0, b = 0 }
    border:SetVertexColor(color.r, color.g, color.b)
  else
    -- For buffs, use a black border color
    border:SetVertexColor(0, 0, 0)
  end
  border:SetAllPoints(b) -- Make the border cover the entire button area
  b.border = border

  -- Create a shadow frame behind the button to enhance visual separation
  local shadow = CreateFrame("Frame", nil, b, BackdropTemplateMixin and "BackdropTemplate")
  shadow:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
  shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
  shadow:SetFrameLevel(b:GetFrameLevel() - 1) -- Place behind the button
  shadow:SetBackdrop(backdrop)                 -- Apply the backdrop with border
  shadow:SetBackdropBorderColor(0, 0, 0, 1)    -- Black border color for shadow
  b.bg = shadow

  b.styled = true -- Mark the button as styled to avoid repeating this process
end

-- Updates and applies skins to all Target and Focus aura icons
-- Loops through all buff and debuff icons on TargetFrame and FocusFrame,
-- calling applySkin to ensure each aura button is visually customized
local function updateAuraSkins()
  for i = 1, MAX_TARGET_BUFFS do
    applySkin(_G["TargetFrameBuff" .. i])
    applySkin(_G["FocusFrameBuff" .. i])
  end

  for i = 1, MAX_TARGET_DEBUFFS do
    applySkin(_G["TargetFrameDebuff" .. i])
    applySkin(_G["FocusFrameDebuff" .. i])
  end
end

-- On player login, hook into the Blizzard function that updates the TargetFrame auras
-- This ensures that whenever the game updates aura icons on the TargetFrame,
-- our updateAuraSkins function runs to apply custom styling dynamically
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  hooksecurefunc("TargetFrame_UpdateAuras", updateAuraSkins)
end)
