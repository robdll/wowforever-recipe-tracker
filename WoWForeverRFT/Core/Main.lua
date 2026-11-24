local addonName, ns = ...

local frame = CreateFrame("Frame", ns.Constants.EVENT_FRAME_NAME)

local function onAddonLoaded(name)
  if name ~= addonName then
    return
  end
  ns.DB:Init()
  ns.Browser:Init()
  ns.Minimap:Show()
  ns.MobTooltip:Init()
  ns.Slash.Init()
  if not ns.Constants.IS_FOREVER then
    print("|cffff6600RFT|r loaded outside WoW: Forever (project id " .. tostring(WOW_PROJECT_ID) .. ").")
  end
  print("|cffc9a227WoW-Forever Recipe Tracker|r loaded. Type |cff88ff88/rft|r.")
end

local handlers = {
  ADDON_LOADED = onAddonLoaded,
  MERCHANT_SHOW = function()
    ns.VendorAlert:OnMerchant()
  end,
  MERCHANT_UPDATE = function()
    ns.VendorAlert:OnMerchant()
  end,
  TRADE_SKILL_LIST_UPDATE = function()
    ns.KnownRecipes:MarkDirty()
  end,
  TRADE_SKILL_DATA_SOURCE_CHANGED = function()
    ns.KnownRecipes:MarkDirty()
  end,
  CHAT_MSG_LOOT = function(_, message)
    local itemID = message and message:match("item:(%d+)")
    if itemID then
      ns.Discovery:RecordLoot(tonumber(itemID))
    end
  end,
  PLAYER_TARGET_CHANGED = function()
    if UnitExists("target") then
      ns.MobAlert:InspectUnit("target")
    end
  end,
  UPDATE_MOUSEOVER_UNIT = function()
    if UnitExists("mouseover") then
      ns.MobAlert:InspectUnit("mouseover")
    end
  end,
  NAME_PLATE_UNIT_ADDED = function(_, unit)
    ns.MobAlert:InspectUnit(unit)
  end,
}

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("MERCHANT_SHOW")
frame:RegisterEvent("MERCHANT_UPDATE")
frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
frame:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
frame:RegisterEvent("CHAT_MSG_LOOT")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
frame:RegisterEvent("NAME_PLATE_UNIT_ADDED")

frame:SetScript("OnEvent", function(_, event, ...)
  local handler = handlers[event]
  if handler then
    handler(event, ...)
  end
end)

-- Periodic vendor proximity scan (no merchant frame open)
C_Timer.After(5, function()
  C_Timer.NewTicker(8, function()
    if MerchantFrame and MerchantFrame:IsShown() then
      return
    end
    if UnitExists("npc") and CheckInteractDistance and CheckInteractDistance("npc", 3) then
      ns.VendorAlert:OnMerchant()
    end
  end)
end)