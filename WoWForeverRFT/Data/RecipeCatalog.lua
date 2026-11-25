-- Recipe catalog for WoW-Forever Recipe Tracker.
-- Regenerate with: python scripts/generate_recipe_data.py
-- Source: Battle.net static-forever-{region} profession/recipe endpoints.
-- Trainer, vendor, and mob fields may be empty until filled by the build script
-- or discovered in-game.

local _, ns = ...

---@class RFTCatalogMeta
local meta = {
  game = "forever",
  patch = "1.60.1",
  apiNamespace = "static-forever-us",
  generatedAt = "seed",
  recipeCount = 24,
  note = "Seed catalog for offline development. Run scripts/generate_recipe_data.py for full ~2494 recipes.",
}

local professions = {
  {
    key = "alchemy",
    id = 171,
    name = "Alchemy",
    icon = "Trade_Alchemy",
    recipes = {
      { id = 2330, name = "Minor Healing Potion", skill = 1, craftedItemID = 118, sources = {} },
      { id = 2331, name = "Minor Mana Potion", skill = 25, craftedItemID = 2455, sources = {} },
      { id = 2332, name = "Elixir of Lion's Strength", skill = 50, craftedItemID = 2457, sources = {
        trainers = { { name = "Alchemy Trainer", zone = "Multiple", skill = 50 } },
      } },
      { id = 2333, name = "Lesser Mana Potion", skill = 80, craftedItemID = 3385, sources = {} },
      { id = 2334, name = "Healing Potion", skill = 110, craftedItemID = 929, sources = {} },
    },
  },
  {
    key = "blacksmithing",
    id = 164,
    name = "Blacksmithing",
    icon = "Trade_BlackSmithing",
    recipes = {
      { id = 2657, name = "Rough Sharpening Stone", skill = 1, craftedItemID = 2862, sources = {} },
      { id = 2660, name = "Rough Grinding Stone", skill = 25, craftedItemID = 3470, sources = {} },
      { id = 2663, name = "Copper Chain Belt", skill = 35, craftedItemID = 2850, sources = {
        trainers = { { name = "Blacksmithing Trainer", zone = "Multiple", skill = 35 } },
      } },
      { id = 2664, name = "Runed Copper Bracers", skill = 90, craftedItemID = 2852, sources = {} },
    },
  },
  {
    key = "engineering",
    id = 202,
    name = "Engineering",
    icon = "Trade_Engineering",
    recipes = {
      { id = 3919, name = "Rough Boomstick", skill = 50, craftedItemID = 4362, sources = {} },
      { id = 3920, name = "Copper Tube", skill = 30, craftedItemID = 4361, sources = {} },
      { id = 3922, name = "Handcrafted High-Powered Rifle", skill = 150, craftedItemID = 4367, sources = {
        vendors = { { name = "Engineering Supplies", zone = "Ironforge", price = 3000, limited = false } },
      } },
    },
  },
  {
    key = "leatherworking",
    id = 165,
    name = "Leatherworking",
    icon = "Trade_LeatherWorking",
    recipes = {
      { id = 2149, name = "Handstitched Leather Boots", skill = 1, craftedItemID = 2302, sources = {} },
      { id = 2152, name = "Light Armor Kit", skill = 25, craftedItemID = 2304, sources = {} },
      { id = 2153, name = "Handstitched Leather Pants", skill = 30, craftedItemID = 2303, sources = {
        trainers = { { name = "Leatherworking Trainer", zone = "Multiple", skill = 30 } },
      } },
    },
  },
  {
    key = "tailoring",
    id = 197,
    name = "Tailoring",
    icon = "Trade_Tailoring",
    recipes = {
      { id = 2963, name = "Bolt of Linen Cloth", skill = 1, craftedItemID = 2996, sources = {} },
      { id = 2964, name = "Linen Cloak", skill = 30, craftedItemID = 2570, sources = {} },
      { id = 2968, name = "Red Linen Shirt", skill = 40, craftedItemID = 2575, sources = {} },
    },
  },
  {
    key = "enchanting",
    id = 333,
    name = "Enchanting",
    icon = "Trade_Engraving",
    recipes = {
      { id = 7418, name = "Enchant Bracer - Minor Health", skill = 1, craftedItemID = nil, sources = {} },
      { id = 7420, name = "Enchant Chest - Minor Health", skill = 25, craftedItemID = nil, sources = {} },
    },
  },
  {
    key = "cooking",
    id = 185,
    name = "Cooking",
    icon = "INV_Misc_Food_15",
    recipes = {
      { id = 2538, name = "Charred Wolf Meat", skill = 1, craftedItemID = 2681, sources = {} },
      { id = 2539, name = "Spiced Wolf Meat", skill = 50, craftedItemID = 2680, sources = {
        trainers = { { name = "Cooking Trainer", zone = "Multiple", skill = 50 } },
      } },
    },
  },
}

-- Static mob drop hints (sparse; expand via generate script or in-game discovery)
local mobDrops = {
  [448] = { -- Hogger (example npc)
    { recipeID = 2332, chance = nil, zone = "Elwynn Forest" },
  },
  [7068] = { -- Firemane Scalebane (example)
    { recipeID = 2664, chance = 0.02, zone = "Azshara" },
  },
}

-- Recipe items sold by vendors (itemID -> recipeID) when the item teaches a recipe
local itemToRecipe = {
  -- Populated at runtime from recipe scroll items and merchant scans.
}

local recipeByID = {}
local professionByKey = {}
local mobRecipeIndex = nil

for _, prof in ipairs(professions) do
  professionByKey[prof.key] = prof
  for _, recipe in ipairs(prof.recipes) do
    recipe.professionKey = prof.key
    recipe.professionName = prof.name
    recipeByID[recipe.id] = recipe
    if recipe.recipeItemID then
      itemToRecipe[recipe.recipeItemID] = recipe.id
    end
  end
end

ns.Data = {
  Meta = meta,
  Professions = professions,
  ProfessionByKey = professionByKey,
  RecipeByID = recipeByID,
  ItemToRecipe = itemToRecipe,
  MobDrops = mobDrops,
}

function ns.Data.ProfessionKeyFromName(name)
  if not name then
    return nil
  end
  local lower = name:lower()
  for key, prof in pairs(professionByKey) do
    if prof.name:lower() == lower then
      return key
    end
  end
  return lower:gsub("%s+", "_")
end

function ns.Data.GetRecipesForProfession(key)
  local prof = professionByKey[key]
  return prof and prof.recipes or {}
end

function ns.Data.GetRecipe(recipeID)
  return recipeByID[recipeID]
end

local function ensureMobRecipeIndex()
  if mobRecipeIndex then
    return
  end
  mobRecipeIndex = {}
  for npcID, drops in pairs(mobDrops) do
    local list = mobRecipeIndex[npcID]
    if not list then
      list = {}
      mobRecipeIndex[npcID] = list
    end
    for _, drop in ipairs(drops) do
      local recipe = drop.recipeID and recipeByID[drop.recipeID]
      if recipe then
        list[#list + 1] = recipe
      end
    end
  end
end

function ns.Data.InvalidateMobIndex(npcID)
  if mobRecipeIndex and npcID then
    mobRecipeIndex[npcID] = nil
  end
end

function ns.Data.HasMobRecipes(npcID)
  if not npcID then
    return false
  end
  if mobDrops[npcID] then
    return true
  end
  if ns.DB and ns.DB.GetDiscoveredMobSources then
    local disc = ns.DB:GetDiscoveredMobSources(npcID)
    return disc and next(disc) ~= nil
  end
  return false
end

function ns.Data.GetMobRecipes(npcID)
  if not npcID then
    return nil
  end
  ensureMobRecipeIndex()
  local out = {}
  local static = mobRecipeIndex[npcID]
  if static then
    for i = 1, #static do
      out[#out + 1] = static[i]
    end
  end
  local discovered = ns.DB and ns.DB:GetDiscoveredMobSources(npcID) or nil
  if discovered then
    for recipeID in pairs(discovered) do
      local recipe = recipeByID[recipeID]
      if recipe then
        out[#out + 1] = recipe
      end
    end
  end
  if #out == 0 then
    return nil
  end
  return out
end

function ns.Data.GetMobDrops(npcID)
  local static = mobDrops[npcID]
  local discovered = ns.DB and ns.DB:GetDiscoveredMobSources(npcID) or {}
  local out = {}
  if static then
    for _, row in ipairs(static) do
      out[#out + 1] = row
    end
  end
  for recipeID, meta in pairs(discovered) do
    out[#out + 1] = {
      recipeID = recipeID,
      chance = meta and meta.chance,
      zone = meta and meta.zone,
      discovered = true,
    }
  end
  return out
end

function ns.Data.ResolveRecipeForItem(itemID)
  if itemToRecipe[itemID] then
    return itemToRecipe[itemID]
  end
  if C_Item and C_Item.GetItemSpell then
    local spellID = select(2, C_Item.GetItemSpell(itemID))
    if spellID and recipeByID[spellID] then
      return spellID
    end
  end
  local name = GetItemInfo(itemID)
  if name and name:find("Recipe:", 1, true) then
    for id, recipe in pairs(recipeByID) do
      if recipe.name and name:find(recipe.name, 1, true) then
        return id
      end
    end
  end
  return nil
end