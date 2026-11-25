local addonName, ns = ...
ns.Constants = {
  ADDON_NAME = addonName,
  VERSION = "1.0.1",
  SNOOZE_SECONDS = 30 * 60,
  ALERT_ICON = "Interface\\Icons\\INV_Misc_Book_09",
  PROFESSION_ICON_FALLBACK = "Interface\\Icons\\Trade_Engineering",
  COLORS = {
    known = { r = 0.35, g = 0.85, b = 0.45 },
    unknown = { r = 1.0, g = 0.82, b = 0.2 },
    muted = { r = 0.55, g = 0.55, b = 0.55 },
    header = { r = 0.9, g = 0.78, b = 0.45 },
    gap = { r = 0.95, g = 0.45, b = 0.35 },
  },
  EVENT_FRAME_NAME = addonName .. "EventFrame",
  BROWSER_FRAME_NAME = addonName .. "Browser",
  MINIMAP_BUTTON_NAME = addonName .. "MinimapButton",
}

-- Forever is WOW_PROJECT_CAMELOT (18); fall back to the literal when the constant is missing.
ns.Constants.IS_FOREVER = WOW_PROJECT_ID == (WOW_PROJECT_CAMELOT or 18)