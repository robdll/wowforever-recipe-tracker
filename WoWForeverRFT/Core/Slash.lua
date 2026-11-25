local addonName, ns = ...

local function printHelp()
  print("|cffc9a227WoW-Forever Recipe Tracker|r")
  print("/rft — toggle recipe browser")
  print("/rft sources — echo data build info")
  print("/rft refresh — rescan known recipes")
  print("/rft minimap — show minimap button")
  print("/rft snooze clear — clear all snoozes")
  print("/rft debug — toggle load timing debug output")
end

local function registerSlash()
  SlashCmdList["WOWFOREVERRFT"] = function(msg)
    msg = (msg or ""):lower()
    if msg == "" or msg == "toggle" then
      ns.Browser:Toggle()
    elseif msg == "sources" then
      local meta = ns.Data.Meta
      print(string.format(
        "Catalog build: %s | patch %s | %s recipes",
        meta.generatedAt or "?",
        meta.patch or "?",
        tostring(meta.recipeCount)
      ))
    elseif msg == "refresh" then
      ns.KnownRecipes:RefreshProfessions()
      print("Known recipe cache refreshed (profession scan).")
    elseif msg == "debug" then
      local on = ns.Debug:Toggle()
      print("RFT debug is now " .. (on and "ON" or "OFF"))
    elseif msg == "minimap" then
      ns.Minimap:Restore()
    elseif msg == "snooze clear" then
      wipe(ns.DB.saved.snoozes)
      print("Snoozes cleared.")
    else
      printHelp()
    end
  end
  SLASH_WOWFOREVERRFT1 = "/rft"
  SLASH_WOWFOREVERRFT2 = "/wowforeverrft"
end

ns.Slash = { Init = registerSlash }