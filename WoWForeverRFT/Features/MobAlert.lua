local _, ns = ...
local Util = ns.Util
local Known = ns.KnownRecipes
local Sources = ns.Sources
local Alert = ns.AlertPopup

local MobAlert = {}
ns.MobAlert = MobAlert

function MobAlert:InspectUnit(unit)
  if not unit or not UnitExists(unit) then
    return
  end
  if UnitIsPlayer and UnitIsPlayer(unit) then
    return
  end
  if UnitIsFriend and UnitIsFriend("player", unit) then
    return
  end
  local guid = UnitGUID(unit)
  local npcID = Util.NpcIDFromGUID(guid)
  if not npcID then
    return
  end
  local recipes = Sources:RecipesFromMob(npcID)
  for _, recipe in ipairs(recipes) do
    if not Known:IsKnown(recipe.id) then
      local profSkill = Known:GetProfessionSkill(recipe.professionKey)
      if Known:CanLearn(recipe, profSkill) then
        local key = Util.SnoozeKey("mob", npcID, recipe.id)
        local name = UnitName(unit) or ("NPC " .. npcID)
        Alert:Show(
          "mob",
          key,
          recipe.id,
          "Mob drops a recipe you can learn",
          string.format("%s (%s)\n\n%s", name, Util.PlayerZone(), recipe.name)
        )
      end
    end
  end
end

-- Events are registered in Core/Main.lua.