local _, ns = ...
local Known = ns.KnownRecipes
local Util = ns.Util

local MobTooltip = {}
ns.MobTooltip = MobTooltip

local TOOLTIP_HEADER = "RFT recipe drops"
local hooked

local function appendRecipeLines(tooltip, npcID)
  if not tooltip or not npcID then
    return
  end
  if not ns.Data.HasMobRecipes(npcID) then
    return
  end
  local recipes = ns.Data.GetMobRecipes(npcID)
  if not recipes or #recipes == 0 then
    return
  end
  tooltip:AddLine(" ")
  tooltip:AddLine(TOOLTIP_HEADER, 0.9, 0.78, 0.45)
  local limit = math.min(#recipes, 8)
  for i = 1, limit do
    local recipe = recipes[i]
    if recipe then
      local known = Known:IsKnownCached(recipe.id)
      local c = known and ns.Constants.COLORS.known or ns.Constants.COLORS.unknown
      local prefix = known and "|cff88dd77" or "|cffffd166"
      tooltip:AddDoubleLine(
        prefix .. (recipe.name or "?") .. "|r",
        recipe.professionName or "",
        c.r,
        c.g,
        c.b,
        0.6,
        0.6,
        0.6
      )
    end
  end
  if #recipes > limit then
    tooltip:AddLine(string.format("… and %d more in /rft", #recipes - limit), 0.55, 0.55, 0.55)
  end
end

local function onLegacyTooltip(tooltip)
  local ok, _, unit = pcall(function()
    return tooltip:GetUnit()
  end)
  if not ok or not unit or not UnitExists(unit) then
    return
  end
  local npcID = Util.NpcIDFromGUID(UnitGUID(unit))
  appendRecipeLines(tooltip, npcID)
end

function MobTooltip:Init()
  if hooked then
    return
  end
  hooked = true
  ns.Debug:Mark("mob_tooltip_init")

  local ok, err = pcall(function()
    if TooltipDataProcessor
      and TooltipDataProcessor.AddTooltipPostCall
      and Enum
      and Enum.TooltipDataType
      and Enum.TooltipDataType.Unit
    then
      TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
        if not data or not data.guid then
          return
        end
        local npcID = Util.NpcIDFromGUID(data.guid)
        appendRecipeLines(tooltip, npcID)
      end)
      return
    end
    if GameTooltip and GameTooltip.HookScript then
      GameTooltip:HookScript("OnTooltipSetUnit", function(tooltip)
        onLegacyTooltip(tooltip)
      end)
    end
  end)

  if not ok and ns.Debug:IsEnabled() then
    print("|cffff6600RFT|r tooltip hook failed: " .. tostring(err))
  end
  ns.Debug:Mark("mob_tooltip_init_done")
end