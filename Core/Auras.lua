----------------------
-- Lanacan Aura Skins
-- Custom styling for Blizzard default aura icons on Target and Focus frames
--
-- This addon modifies the appearance of buff and debuff icons by:
-- - Cropping the icon texture to remove default Blizzard borders
-- - Applying a custom colored border (black for buffs, debuff type colors for debuffs)
-- - Adding a subtle shadow backdrop behind icons for improved clarity
--
-- Hooks Blizzard's TargetFrame aura update function to dynamically maintain styling.
----------------------

-- Simple white square texture used for borders and shadows
local SQUARE_TEXTURE = "Interface\\Buttons\\WHITE8X8"

-- Backdrop configuration for shadow effect around aura icons
local backdrop = {
  bgFile = nil,                -- No background fill
  edgeFile = SQUARE_TEXTURE,   -- White square used as border texture
  tile = false,                -- No tiling
  tileSize = 32,
  edgeSize = 1,               -- Border thickness (1 pixel)
  insets = { left = 0, right = 0, top = 0, bottom = 0 }, -- No inset padding
}

---
-- Apply custom skin to a single aura button (buff or debuff)
-- @param b The aura button frame to style
-- This function crops the icon, adds border and shadow, and marks the button styled.
---
local function applySkin(b)
  if not b or b.styled then return end  -- Skip if nil or already styled

  local name = b:GetName()
  if not name then return end            -- Should not happen, but be safe

  -- Determine if the button is a debuff by name pattern
  local isDebuff = name:match("Debuff")
  local icon = _G[name .. "Icon"]
  if icon then
    -- Crop icon texture coords to remove default border space
    icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

    -- Reposition icon inside button with 2-pixel inset padding
    icon:ClearAllPoints()
    icon:SetPoint("TOPLEFT", b, "TOPLEFT", 2, -2)
    icon:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", -2, 2)

    b.icon = icon
  end

  -- Create or reuse border texture behind the icon
  local border = _G[name .. "Border"] or b:CreateTexture(name .. "Border", "BACKGROUND", nil, -7)
  border:SetTexture(SQUARE_TEXTURE)
  border:SetTexCoord(0, 1, 0, 1)
  border:SetDrawLayer("BACKGROUND", -7)

  if isDebuff then
    -- Get debuff type color or default to black if unknown
    local debuffIndex = tonumber(name:match("%d+"))
    local debuffType = select(5, UnitDebuff("target", debuffIndex))
    local color = DebuffTypeColor[debuffType or "none"] or { r = 0, g = 0, b = 0 }
    border:SetVertexColor(color.r, color.g, color.b)
  else
    -- Buffs get solid black border
    border:SetVertexColor(0, 0, 0)
  end

  border:SetAllPoints(b)
  b.border = border

  -- Create shadow frame behind the aura button for subtle depth
  local shadow = CreateFrame("Frame", nil, b, BackdropTemplateMixin and "BackdropTemplate")
  shadow:SetPoint("TOPLEFT", b, "TOPLEFT", 0, 0)
  shadow:SetPoint("BOTTOMRIGHT", b, "BOTTOMRIGHT", 0, 0)
  shadow:SetFrameLevel(b:GetFrameLevel() - 1) -- Behind button
  shadow:SetBackdrop(backdrop)
  shadow:SetBackdropBorderColor(0, 0, 0, 1) -- Solid black shadow
  b.bg = shadow

  -- Mark this button as styled to prevent reapplying skin
  b.styled = true
end

---
-- Apply skins to all buffs and debuffs on Target and Focus frames.
-- Called on aura update to maintain consistent custom styling.
---
local function updateAuraSkins()
  -- TargetFrame buffs and FocusFrame buffs
  for i = 1, MAX_TARGET_BUFFS do
    applySkin(_G["TargetFrameBuff" .. i])
    applySkin(_G["FocusFrameBuff" .. i])
  end

  -- TargetFrame debuffs and FocusFrame debuffs
  for i = 1, MAX_TARGET_DEBUFFS do
    applySkin(_G["TargetFrameDebuff" .. i])
    applySkin(_G["FocusFrameDebuff" .. i])
  end
end

-- Create frame to hook into Blizzard aura update events after login
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function()
  -- Hook Blizzard's aura update to apply our custom skins dynamically
  hooksecurefunc("TargetFrame_UpdateAuras", updateAuraSkins)
end)
