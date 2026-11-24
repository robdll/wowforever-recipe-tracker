local _, ns = ...
local Util = ns.Util
local Known = ns.KnownRecipes
local Discovery = ns.Discovery
local Alert = ns.AlertPopup

local VendorAlert = {}
ns.VendorAlert = VendorAlert

function VendorAlert:OnMerchant()
  local items = Discovery:ScanMerchant()
  for _, entry in ipairs(items) do
    if not Known:IsKnown(entry.recipeID) then
      local recipe = ns.Data.GetRecipe(entry.recipeID)
      local profSkill = recipe and Known:GetProfessionSkill(recipe.professionKey) or 0
      if Known:CanLearn(recipe or { id = entry.recipeID }, profSkill) then
        local key = Util.SnoozeKey("vendor", entry.vendorKey, entry.recipeID)
        local vendorName = UnitName("npc") or "Vendor"
        local recipeName = recipe and recipe.name or ("Recipe " .. entry.recipeID)
        Alert:Show(
          "vendor",
          key,
          entry.recipeID,
          "Vendor sells a recipe you can learn",
          string.format("%s at %s\n\n%s (%s)", vendorName, Util.PlayerZone(), recipeName, Util.FormatMoney(entry.price))
        )
      end
    end
  end
end

-- Merchant events and proximity polling are handled in Core/Main.lua.