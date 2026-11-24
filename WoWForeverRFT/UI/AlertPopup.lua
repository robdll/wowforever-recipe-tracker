local addonName, ns = ...
local Util = ns.Util

local Alert = {}
ns.AlertPopup = Alert

local popup

local function ensurePopup()
  if popup then
    return popup
  end
  popup = CreateFrame("Frame", addonName .. "Alert", UIParent, "BackdropTemplate")
  popup:SetSize(360, 160)
  popup:SetPoint("CENTER", 0, 120)
  popup:SetBackdrop({
    bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile = true,
    tileSize = 32,
    edgeSize = 32,
    insets = { left = 11, right = 12, top = 12, bottom = 11 },
  })
  popup:SetFrameStrata("DIALOG")
  popup:Hide()

  popup.title = popup:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  popup.title:SetPoint("TOP", 0, -16)
  popup.title:SetText("Recipe available")

  popup.body = popup:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  popup.body:SetPoint("TOP", 0, -44)
  popup.body:SetWidth(320)

  popup.snooze = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
  popup.snooze:SetSize(120, 22)
  popup.snooze:SetPoint("BOTTOMLEFT", 24, 16)
  popup.snooze:SetText("Snooze 30m")

  popup.open = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
  popup.open:SetSize(100, 22)
  popup.open:SetPoint("BOTTOM", 0, 16)
  popup.open:SetText("Open RFT")

  popup.dismiss = CreateFrame("Button", nil, popup, "UIPanelButtonTemplate")
  popup.dismiss:SetSize(90, 22)
  popup.dismiss:SetPoint("BOTTOMRIGHT", -24, 16)
  popup.dismiss:SetText("Dismiss")

  popup.dismiss:SetScript("OnClick", function()
    popup:Hide()
  end)
  popup.open:SetScript("OnClick", function()
    if popup.recipeID then
      ns.Browser:SelectRecipe(popup.recipeID)
    else
      ns.Browser:Open()
    end
    popup:Hide()
  end)
  return popup
end

function Alert:Show(kind, key, recipeID, title, detail)
  if ns.DB:GetSnooze(key) then
    return
  end
  local p = ensurePopup()
  p.snoozeKey = key
  p.recipeID = recipeID
  p.title:SetText(title or "Unknown recipe opportunity")
  p.body:SetText(detail or "")
  p.snooze:SetScript("OnClick", function()
    ns.DB:SetSnooze(key, ns.Constants.SNOOZE_SECONDS)
    p:Hide()
  end)
  if not p:IsShown() then
    p:Show()
  end
  if UIFrameFlash then
    UIFrameFlash(p, 0.25, 0.25, 2, false, 0, 0)
  end
end