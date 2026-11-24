local _, ns = ...

--- Tracks which Blizzard recipe IDs the character already knows.
local Known = {
  cache = {},
  dirty = true,
}
ns.KnownRecipes = Known

local function recipeKnown(recipeID)
  if C_TradeSkillUI and C_TradeSkillUI.IsRecipeKnown then
    local ok, known = pcall(C_TradeSkillUI.IsRecipeKnown, recipeID)
    if ok then
      return known
    end
  end
  return false
end

function Known:Refresh()
  wipe(self.cache)
  if C_Professions and C_Professions.GetProfessions then
    local prof1, prof2, archaeology, fishing, cooking = C_Professions.GetProfessions()
    local slots = { prof1, prof2, archaeology, fishing, cooking }
    for _, slot in ipairs(slots) do
      if slot then
        local info = C_Professions.GetProfessionInfo(slot)
        if info and info.professionID then
          self:ScanProfession(info.professionID, info.profession)
        end
      end
    end
  end
  if C_TradeSkillUI and C_TradeSkillUI.GetAllRecipeIDs then
    local ok, ids = pcall(C_TradeSkillUI.GetAllRecipeIDs)
    if ok and ids then
      for _, recipeID in ipairs(ids) do
        if recipeKnown(recipeID) then
          self.cache[recipeID] = true
        end
      end
    end
  end
  self.dirty = false
end

function Known:ScanProfession(professionID, professionSlot)
  if not (C_TradeSkillUI and C_TradeSkillUI.GetRecipeIDsForProfession) then
    return
  end
  local ok, ids = pcall(C_TradeSkillUI.GetRecipeIDsForProfession, professionID)
  if not ok or not ids then
    return
  end
  for _, recipeID in ipairs(ids) do
    if recipeKnown(recipeID) then
      self.cache[recipeID] = true
    end
  end
end

function Known:MarkDirty()
  self.dirty = true
end

function Known:IsKnown(recipeID)
  if self.dirty then
    self:Refresh()
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

function Known:CanLearn(entry, playerSkill)
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
  local prof1, prof2 = C_Professions.GetProfessions()
  for _, slot in ipairs({ prof1, prof2 }) do
    if slot then
      local info = C_Professions.GetProfessionInfo(slot)
      if info and info.professionName and ns.Data and ns.Data.ProfessionByKey then
        local key = ns.Data.ProfessionKeyFromName(info.professionName)
        if key == professionKey then
          return info.skillLevel or 0
        end
      end
    end
  end
  return 0
end