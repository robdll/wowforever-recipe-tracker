local _, ns = ...

--- Tracks which Blizzard recipe IDs the character already knows.
local Known = {
  cache = {},
}
ns.KnownRecipes = Known

local function recipeKnown(recipeID)
  if not recipeID then
    return false
  end
  if C_TradeSkillUI and C_TradeSkillUI.IsRecipeKnown then
    local ok, known = pcall(C_TradeSkillUI.IsRecipeKnown, recipeID)
    if ok then
      return known == true
    end
  end
  return false
end

--- Scans profession APIs only (never bulk GetAllRecipeIDs).
function Known:RefreshProfessions()
  wipe(self.cache)
  if not (C_Professions and C_Professions.GetProfessions) then
    return
  end
  local ok, prof1, prof2, archaeology, fishing, cooking = pcall(C_Professions.GetProfessions)
  if not ok then
    return
  end
  for _, slot in ipairs({ prof1, prof2, archaeology, fishing, cooking }) do
    if slot then
      local pok, info = pcall(C_Professions.GetProfessionInfo, slot)
      if pok and info and info.professionID then
        self:ScanProfession(info.professionID)
      end
    end
  end
  ns.Debug:Mark("known_recipes_profession_scan_done")
end

function Known:ScanProfession(professionID)
  if not (C_TradeSkillUI and C_TradeSkillUI.GetRecipeIDsForProfession) then
    return
  end
  local ok, ids = pcall(C_TradeSkillUI.GetRecipeIDsForProfession, professionID)
  if not ok or type(ids) ~= "table" then
    return
  end
  for _, recipeID in ipairs(ids) do
    if self.cache[recipeID] or recipeKnown(recipeID) then
      self.cache[recipeID] = true
    end
  end
end

function Known:WarmRecipes(recipes, onDone)
  if type(recipes) ~= "table" or #recipes == 0 then
    if onDone then
      onDone()
    end
    return
  end
  local index = 1
  local batch = 20
  local function step()
    local limit = math.min(index + batch - 1, #recipes)
    for i = index, limit do
      local entry = recipes[i]
      if entry and entry.id and not self.cache[entry.id] then
        if recipeKnown(entry.id) then
          self.cache[entry.id] = true
        end
      end
    end
    index = limit + 1
    if index > #recipes then
      if onDone then
        onDone()
      end
      return
    end
    if C_Timer and C_Timer.After then
      C_Timer.After(0, step)
    else
      step()
    end
  end
  step()
end

function Known:IsKnown(recipeID)
  if not recipeID then
    return false
  end
  if self.cache[recipeID] then
    return true
  end
  if recipeKnown(recipeID) then
    self.cache[recipeID] = true
    return true
  end
  return false
end

function Known:IsKnownCached(recipeID)
  return self.cache[recipeID] == true
end

function Known:CanLearn(entry, playerSkill)
  if not entry or not entry.id then
    return false
  end
  if self:IsKnown(entry.id) then
    return false
  end
  local req = entry.skill or entry.requiredSkill or 0
  if playerSkill == nil then
    return true
  end
  return playerSkill >= req
end

function Known:GetProfessionSkill(professionKey)
  if not (C_Professions and C_Professions.GetProfessions) then
    return 0
  end
  local ok, prof1, prof2 = pcall(C_Professions.GetProfessions)
  if not ok then
    return 0
  end
  for _, slot in ipairs({ prof1, prof2 }) do
    if slot then
      local pok, info = pcall(C_Professions.GetProfessionInfo, slot)
      if pok and info and info.professionName and ns.Data and ns.Data.ProfessionKeyFromName then
        local key = ns.Data.ProfessionKeyFromName(info.professionName)
        if key == professionKey then
          return info.skillLevel or 0
        end
      end
    end
  end
  return 0
end

-- Kept for slash command compatibility.
function Known:MarkDirty() end

function Known:Refresh()
  self:RefreshProfessions()
end