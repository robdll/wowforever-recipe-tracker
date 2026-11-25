local _, ns = ...
local Util = ns.Util
local Known = ns.KnownRecipes
local Discovery = ns.Discovery
local Alert = ns.AlertPopup

local VendorAlert = {}
ns.VendorAlert = VendorAlert

local lastScanAt = 0
local SCAN_COOLDOWN = 1.0

function VendorAlert:OnMerchant()
  if not (ns.Gameplay and ns.Gameplay.IsReady()) then
    return
  end
  if not (MerchantFrame and MerchantFrame:IsShown()) then
    local nearNpc = UnitExists("npc") and CheckInteractDistance and CheckInteractDistance("npc", 3)
    if not nearNpc then
      return
    end
  end
  local now = GetTime and GetTime() or 0
  if now - lastScanAt < SCAN_COOLDOWN then
    return
  end
  lastScanAt = now

  local ok, items = pcall(function()
    return Discovery:ScanMerchant()
  end)
  if not ok or type(items) ~= "table" then
    return
  end

  for _, entry in ipairs(items) do
    if not Known:IsKnownCached(entry.recipeID) and not Known:IsKnown(entry.recipeID) then
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