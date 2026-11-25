local _, ns = ...
local Util = ns.Util

local Discovery = {}
ns.Discovery = Discovery

local function vendorKey()
  local name = UnitName("npc") or "Unknown vendor"
  local zone = Util.PlayerZone()
  return string.format("%s@%s", name, zone)
end

function Discovery:ScanMerchant()
  if not (MerchantFrame and MerchantFrame:IsShown()) then
    return {}
  end
  local found = {}
  local vkey = vendorKey()
  local numItems
  if C_MerchantFrame and C_MerchantFrame.GetNumItems then
    numItems = C_MerchantFrame.GetNumItems()
  else
    numItems = GetMerchantNumItems and GetMerchantNumItems() or 0
  end
  for index = 1, numItems do
    local link
    if C_MerchantFrame and C_MerchantFrame.GetItemLink then
      link = C_MerchantFrame.GetItemLink(index)
    else
      link = GetMerchantItemLink(index)
    end
    local itemID = Util.ItemIDFromLink(link)
    if itemID then
      local recipeID = ns.Data.ResolveRecipeForItem(itemID)
      if recipeID then
        local price = 0
        if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
          local info = C_MerchantFrame.GetItemInfo(index)
          if info then
            price = info.price or 0
          end
        else
          price = select(3, GetMerchantItemInfo(index)) or 0
        end
        local limited = false
        if C_MerchantFrame and C_MerchantFrame.GetItemInfo then
          local info = C_MerchantFrame.GetItemInfo(index)
          limited = info and info.numAvailable and info.numAvailable >= 0
        end
        found[#found + 1] = {
          recipeID = recipeID,
          itemID = itemID,
          price = price,
          limited = limited,
          vendorKey = vkey,
        }
        local recipe = ns.Data.GetRecipe(recipeID)
        if recipe then
          recipe.sources = recipe.sources or {}
          recipe.sources.vendors = recipe.sources.vendors or {}
          local exists = false
          for _, v in ipairs(recipe.sources.vendors) do
            if v.name == UnitName("npc") and v.zone == Util.PlayerZone() then
              exists = true
              break
            end
          end
          if not exists then
            recipe.sources.vendors[#recipe.sources.vendors + 1] = {
              name = UnitName("npc") or "Vendor",
              zone = Util.PlayerZone(),
              price = price,
              limited = limited,
              discovered = true,
            }
          end
        end
        ns.DB:RecordVendorDiscovery(vkey, recipeID, {
          itemID = itemID,
          price = price,
          zone = Util.PlayerZone(),
        })
      end
    end
  end
  return found
end

function Discovery:RecordLoot(itemID)
  local recipeID = ns.Data.ResolveRecipeForItem(itemID)
  if not recipeID then
    return
  end
  local guid = UnitGUID("mouseover") or UnitGUID("target")
  local npcID = Util.NpcIDFromGUID(guid)
  if not npcID then
    return
  end
  ns.DB:RecordMobDiscovery(npcID, recipeID, {
    zone = Util.PlayerZone(),
    at = Util.GetTime(),
  })
  if ns.Data.InvalidateMobIndex then
    ns.Data.InvalidateMobIndex(npcID)
  end
  local recipe = ns.Data.GetRecipe(recipeID)
  if recipe then
    recipe.sources = recipe.sources or {}
    recipe.sources.mobs = recipe.sources.mobs or {}
    recipe.sources.mobs[#recipe.sources.mobs + 1] = {
      name = UnitName(guid and "target" or "mouseover") or ("NPC " .. npcID),
      zone = Util.PlayerZone(),
      npcID = npcID,
      discovered = true,
    }
  end
end