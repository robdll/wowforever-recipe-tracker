local _, ns = ...
local Known = ns.KnownRecipes
local Sources = ns.Sources
local Util = ns.Util

local MobTooltip = {}
ns.MobTooltip = MobTooltip

local TOOLTIP_HEADER = "RFT recipe drops"
local hooked

local function appendRecipeLines(tooltip, unit)
  if not unit or not UnitExists(unit) then
    return
  end
  local guid = UnitGUID(unit)
  local npcID = Util.NpcIDFromGUID(guid)
  if not npcID then
    return
  end
  local recipes = Sources:RecipesFromMob(npcID)
  if #recipes == 0 then
    return
  end
  tooltip:AddLine(" ")
  tooltip:AddLine(TOOLTIP_HEADER, 0.9, 0.78, 0.45)
  table.sort(recipes, function(a, b)
    local ka = Known:IsKnown(a.id)
    local kb = Known:IsKnown(b.id)
    if ka ~= kb then
      return not ka
    end
    return a.name < b.name
  end)
  for _, recipe in ipairs(recipes) do
    local known = Known:IsKnown(recipe.id)
    local c = known and ns.Constants.COLORS.known or ns.Constants.COLORS.unknown
    local prefix = known and "|cff88dd77" or "|cffffd166"
    tooltip:AddDoubleLine(
      prefix .. recipe.name .. "|r",
      recipe.professionName or "",
      c.r,
      c.g,
      c.b,
      0.6,
      0.6,
      0.6
    )
  end
  tooltip:Show()
end

local function onTooltipSetUnit(tooltip)
  local _, unit = tooltip:GetUnit()
  if unit then
    appendRecipeLines(tooltip, unit)
  end
end

function MobTooltip:Init()
  if hooked then
    return
  end
  hooked = true
  if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
    TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tooltip, data)
      if not data or not data.guid then
        return
      end
      local unit = select(2, tooltip:GetUnit())
      if not unit then
        -- Fallback: reconstruct npc from GUID for unit tooltips
        local npcID = Util.NpcIDFromGUID(data.guid)
        if npcID then
          appendRecipeLines(tooltip, "mouseover")
        end
        return
      end
      appendRecipeLines(tooltip, unit)
    end)
  else
    GameTooltip:HookScript("OnTooltipSetUnit", onTooltipSetUnit)
    if GameTooltip.SetUnit then
      hooksecurefunc(GameTooltip, "SetUnit", function(self)
        local _, unit = self:GetUnit()
        if unit then
          C_Timer.After(0, function()
            appendRecipeLines(self, unit)
          end)
        end
      end)
    end
  end
end