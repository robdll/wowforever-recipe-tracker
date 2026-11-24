local _, ns = ...
local Util = ns.Util

local Sources = {}
ns.Sources = Sources

local function appendSourceLines(lines, header, entries, formatter)
  if not entries or #entries == 0 then
    return
  end
  lines[#lines + 1] = { text = header, muted = false, height = 20 }
  for _, entry in ipairs(entries) do
    lines[#lines + 1] = { text = formatter(entry), muted = entry.discovered, height = 16 }
  end
end

function Sources:FormatRecipeSources(recipe)
  if not recipe then
    return { { text = "No recipe selected.", muted = true } }
  end
  local lines = {}
  local known = ns.KnownRecipes:IsKnown(recipe.id)
  lines[#lines + 1] = {
    text = known and "You know this recipe." or "You do not know this recipe yet.",
    muted = false,
    height = 20,
  }
  if recipe.skill then
    lines[#lines + 1] = { text = "Required skill: " .. recipe.skill, muted = true, height = 16 }
  end
  if recipe.craftedItemID then
    lines[#lines + 1] = {
      text = "Crafts: " .. (Util.SafeItemName(recipe.craftedItemID) or "?"),
      muted = true,
      height = 16,
    }
  end

  local src = recipe.sources or {}
  appendSourceLines(lines, "Trainers", src.trainers, function(t)
    local zone = t.zone or "?"
    local skill = t.skill and (" (skill " .. t.skill .. ")") or ""
    local tag = t.discovered and " [seen in-game]" or ""
    return string.format("• %s — %s%s%s", t.name or "Trainer", zone, skill, tag)
  end)
  appendSourceLines(lines, "Vendors", src.vendors, function(v)
    local price = v.price and Util.FormatMoney(v.price) or "?"
    local stock = ""
    if v.limited == true then
      stock = " [limited]"
    elseif v.limited == false then
      stock = " [unlimited]"
    end
    local tag = v.discovered and " [scanned]" or ""
    return string.format("• %s — %s, %s%s%s", v.name or "Vendor", v.zone or "?", price, stock, tag)
  end)
  appendSourceLines(lines, "Mob drops", src.mobs, function(m)
    local chance = m.chance and string.format(" (~%.1f%%)", m.chance * 100) or ""
    local tag = m.discovered and " [looted]" or ""
    return string.format("• %s — %s%s%s", m.name or ("NPC " .. tostring(m.npcID)), m.zone or "?", chance, tag)
  end)

  local hasAny = (src.trainers and #src.trainers > 0)
    or (src.vendors and #src.vendors > 0)
    or (src.mobs and #src.mobs > 0)
  if not hasAny then
    lines[#lines + 1] = {
      text = "No source data yet for this recipe.",
      gap = true,
      height = 18,
    }
    lines[#lines + 1] = {
      text = "Open relevant vendors or loot recipe items to teach RFT, or regenerate catalog data from Battle.net.",
      muted = true,
      height = 32,
    }
  end
  return lines
end

function Sources:RecipesFromMob(npcID)
  local result = {}
  local drops = ns.Data.GetMobDrops(npcID)
  for _, drop in ipairs(drops) do
    local recipeID = drop.recipeID
  local recipe = recipeID and ns.Data.GetRecipe(recipeID)
    if recipe then
      result[#result + 1] = recipe
    end
  end
  return result
end