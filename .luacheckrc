std = "lua51"
max_line_length = 120
ignore = {
  "111", -- setting non-standard global (WoW slash commands)
  "112", -- mutating non-standard global
  "113", -- accessing undefined global (WoW API)
  "131", -- unused argument (event handlers)
  "142", -- setting read-only field
  "211", -- unused local (addonName in chunk header)
  "212", -- unused argument (method style)
  "213", -- unused variable
  "431", -- shadowing
  "432", -- shadowing
  "541", -- empty if branch (API stubs)
  "611", -- unused line (selectedRecipeID for future use)
}
globals = {
  "SlashCmdList",
  "SLASH_WOWFOREVERRFT1",
  "SLASH_WOWFOREVERRFT2",
  "WoWForeverRFTDB",
  "WOW_PROJECT_CAMELOT",
  "WOW_PROJECT_ID",
}
files["WoWForeverRFT/**/*.lua"] = {
  read_globals = {
    "CreateFrame",
    "UIParent",
    "Minimap",
    "MerchantFrame",
    "GameTooltip",
    "GameTooltip_Hide",
    "GetItemInfo",
    "GetMerchantItemLink",
    "GetMerchantNumItems",
    "GetMerchantItemInfo",
    "GetCoinTextureString",
    "GetRealZoneText",
    "GetZoneText",
    "GetSubZoneText",
    "UnitGUID",
    "UnitName",
    "UnitExists",
    "UnitIsPlayer",
    "UnitIsFriend",
    "CheckInteractDistance",
    "time",
    "GetTime",
    "hooksecurefunc",
    "UIDropDownMenu_Initialize",
    "UIDropDownMenu_SetText",
    "UIDropDownMenu_AddButton",
    "UIDropDownMenu_CreateInfo",
    "UIFrameFlash",
    "C_Timer",
    "C_TradeSkillUI",
    "C_Professions",
    "C_MerchantFrame",
    "C_Item",
    "C_NamePlate",
    "TooltipDataProcessor",
    "Enum",
    "Item",
    "InCombatLockdown",
  },
}