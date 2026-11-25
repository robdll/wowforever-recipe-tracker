local _, ns = ...
local Util = ns.Util
local Known = ns.KnownRecipes
local Sources = ns.Sources
local Alert = ns.AlertPopup

local MobAlert = {}
ns.MobAlert = MobAlert

local INSPECT_COOLDOWN = 1.0
local lastInspectByGuid = {}

local function canInspect(unit)
  if not unit or not UnitExists(unit) then
    return false
  end
  if UnitIsPlayer and UnitIsPlayer(unit) then
    return false
  end
  if UnitIsFriend and UnitIsFriend("player", unit) then
    return false
  end
  return true
end

function MobAlert:InspectUnit(unit)
  if not (ns.Gameplay and ns.Gameplay.IsReady()) then
    return
  end
  if not canInspect(unit) then
    return
  end
  local guid = UnitGUID(unit)
  if not guid then
    return
  end
  local now = GetTime and GetTime() or 0
  local last = lastInspectByGuid[guid]
  if last and now - last < INSPECT_COOLDOWN then
    return
  end
  lastInspectByGuid[guid] = now

  local npcID = Util.NpcIDFromGUID(guid)
  if not npcID then
    return
  end
  if not ns.Data.HasMobRecipes(npcID) then
    return
  end
  local recipes = Sources:RecipesFromMob(npcID)
  for _, recipe in ipairs(recipes) do
    if not Known:IsKnownCached(recipe.id) and not Known:IsKnown(recipe.id) then
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