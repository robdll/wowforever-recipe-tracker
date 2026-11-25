local addonName, ns = ...

local frame = CreateFrame("Frame", ns.Constants.EVENT_FRAME_NAME)

local gameplayReady = false
local gameplayEventsRegistered = false

local GAMEPLAY_DEFER_SEC = 2.0
local VENDOR_POLL_SEC = 30.0

local function registerGameplayEvents()
  if gameplayEventsRegistered then
    return
  end
  gameplayEventsRegistered = true
  frame:RegisterEvent("MERCHANT_SHOW")
  frame:RegisterEvent("MERCHANT_UPDATE")
  frame:RegisterEvent("TRADE_SKILL_LIST_UPDATE")
  frame:RegisterEvent("TRADE_SKILL_DATA_SOURCE_CHANGED")
  frame:RegisterEvent("CHAT_MSG_LOOT")
  frame:RegisterEvent("PLAYER_TARGET_CHANGED")
  frame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
  ns.Debug:Mark("gameplay_events_registered")
end

local function enableGameplay()
  if gameplayReady then
    return
  end
  gameplayReady = true
  ns.Debug:Mark("gameplay_enable_start")
  registerGameplayEvents()
  if ns.Minimap and ns.Minimap.Show then
    ns.Minimap:Show()
  end
  if C_Timer and C_Timer.After then
    C_Timer.After(1.0, function()
      if ns.MobTooltip and ns.MobTooltip.Init then
        ns.MobTooltip:Init()
      end
    end)
    C_Timer.After(VENDOR_POLL_SEC, function()
      if not (C_Timer and C_Timer.NewTicker) then
        return
      end
      C_Timer.NewTicker(VENDOR_POLL_SEC, function()
        if not gameplayReady then
          return
        end
        if MerchantFrame and MerchantFrame:IsShown() then
          return
        end
        if UnitExists("npc") and CheckInteractDistance and CheckInteractDistance("npc", 3) then
          ns.VendorAlert:OnMerchant()
        end
      end)
    end)
  end
  ns.Debug:Mark("gameplay_enable_done")
end

local function onAddonLoaded(name)
  if name ~= addonName then
    return
  end
  ns.Debug:Mark("addon_loaded_begin")
  ns.DB:Init()
  ns.Slash.Init()
  ns.Debug:Mark("addon_loaded_core_ready")
  frame:RegisterEvent("PLAYER_ENTERING_WORLD")
  if not ns.Constants.IS_FOREVER then
    print("|cffff6600RFT|r loaded outside WoW: Forever (project id " .. tostring(WOW_PROJECT_ID) .. ").")
  end
  print("|cffc9a227WoW-Forever Recipe Tracker|r loaded. Type |cff88ff88/rft|r.")
  ns.Debug:Mark("addon_loaded_end")
end

local function onPlayerEnteringWorld(_, isLogin, isReload)
  ns.Debug:Mark("player_entering_world")
  if C_Timer and C_Timer.After then
    C_Timer.After(GAMEPLAY_DEFER_SEC, enableGameplay)
  else
    enableGameplay()
  end
  if isLogin or isReload then
    ns.Debug:Mark(string.format("entering_world login=%s reload=%s", tostring(isLogin), tostring(isReload)))
  end
end

local handlers = {
  ADDON_LOADED = onAddonLoaded,
  PLAYER_ENTERING_WORLD = onPlayerEnteringWorld,
  MERCHANT_SHOW = function()
    if gameplayReady then
      ns.VendorAlert:OnMerchant()
    end
  end,
  MERCHANT_UPDATE = function()
    if gameplayReady then
      ns.VendorAlert:OnMerchant()
    end
  end,
  TRADE_SKILL_LIST_UPDATE = function()
    if gameplayReady and ns.KnownRecipes then
      ns.KnownRecipes:RefreshProfessions()
    end
  end,
  TRADE_SKILL_DATA_SOURCE_CHANGED = function()
    if gameplayReady and ns.KnownRecipes then
      ns.KnownRecipes:RefreshProfessions()
    end
  end,
  CHAT_MSG_LOOT = function(_, message)
    if not gameplayReady then
      return
    end
    local itemID = message and message:match("item:(%d+)")
    if itemID then
      ns.Discovery:RecordLoot(tonumber(itemID))
    end
  end,
  PLAYER_TARGET_CHANGED = function()
    if gameplayReady and UnitExists("target") then
      ns.MobAlert:InspectUnit("target")
    end
  end,
  UPDATE_MOUSEOVER_UNIT = function()
    if gameplayReady and UnitExists("mouseover") then
      ns.MobAlert:InspectUnit("mouseover")
    end
  end,
}

frame:RegisterEvent("ADDON_LOADED")

frame:SetScript("OnEvent", function(_, event, ...)
  local handler = handlers[event]
  if handler then
    handler(event, ...)
  end
end)

ns.Gameplay = {
  IsReady = function()
    return gameplayReady
  end,
}