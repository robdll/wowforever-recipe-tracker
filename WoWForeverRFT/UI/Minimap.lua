local addonName, ns = ...

local Minimap = {}
ns.Minimap = Minimap

local button

local function updatePosition(btn)
  local angle = math.rad(ns.DB.saved.minimap.angle or 220)
  local x = math.cos(angle) * 80
  local y = math.sin(angle) * 80
  btn:SetPoint("CENTER", Minimap, "CENTER", x, y)
end

function Minimap:Create()
  if button or ns.DB.saved.minimap.hide then
    return
  end
  button = CreateFrame("Button", ns.Constants.MINIMAP_BUTTON_NAME, Minimap)
  button:SetSize(32, 32)
  button:SetFrameStrata("MEDIUM")
  button:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
  button:SetNormalTexture(ns.Constants.ALERT_ICON)
  button:SetPushedTexture(ns.Constants.ALERT_ICON)
  button:SetScript("OnClick", function(_, mouseBtn)
    if mouseBtn == "RightButton" then
      ns.DB.saved.minimap.hide = true
      button:Hide()
      print("|cffc9a227RFT|r minimap button hidden. Use /rft minimap to restore.")
      return
    end
    ns.Browser:Toggle()
  end)
  button:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:SetText("WoW-Forever Recipe Tracker")
    GameTooltip:AddLine("Left-click: recipe browser", 1, 1, 1)
    GameTooltip:AddLine("Right-click: hide button", 0.8, 0.8, 0.8)
    GameTooltip:Show()
  end)
  button:SetScript("OnLeave", GameTooltip_Hide)
  button:RegisterForDrag("LeftButton")
  button:SetScript("OnDragStart", function(self)
    self:SetScript("OnUpdate", function(s)
      local mx, my = Minimap:GetCenter()
      local px, py = GetCursorPosition()
      local scale = Minimap:GetEffectiveScale()
      px, py = px / scale, py / scale
      local angle = math.deg(math.atan2(py - my, px - mx))
      ns.DB.saved.minimap.angle = angle
      updatePosition(s)
    end)
  end)
  button:SetScript("OnDragStop", function(self)
    self:SetScript("OnUpdate", nil)
  end)
  updatePosition(button)
end

function Minimap:Show()
  if ns.DB.saved.minimap.hide then
    return
  end
  if not button then
    self:Create()
  end
  if button then
    button:Show()
  end
end

function Minimap:Restore()
  ns.DB.saved.minimap.hide = false
  if not button then
    self:Create()
  end
  if button then
    button:Show()
  end
end