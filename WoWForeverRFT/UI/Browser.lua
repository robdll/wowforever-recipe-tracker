local addonName, ns = ...
local Known = ns.KnownRecipes
local Sources = ns.Sources
local Theme = ns.Theme

local Browser = {}
ns.Browser = Browser

local frame
local selectedProfession
local rows = {}
local initialized = false

local function ensureFrame()
  if frame then
    return frame
  end
  frame = _G[ns.Constants.BROWSER_FRAME_NAME]
  if not frame then
    return nil
  end
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:RegisterForDrag("LeftButton")
  frame:SetScript("OnDragStart", frame.StartMoving)
  frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
  frame.Title:SetText("WoW-Forever Recipe Tracker")
  Theme.ApplyTitle(frame.Title)
  local meta = ns.Data.Meta
  frame.CatalogNote:SetText(
    string.format(
      "Catalog: %s recipes (%s). Sources: Battle.net + in-game discovery.",
      tostring(meta.recipeCount),
      meta.generatedAt or "unknown build"
    )
  )
  return frame
end

local function clearRows()
  for _, row in ipairs(rows) do
    row:Hide()
    row:SetParent(nil)
  end
  wipe(rows)
end

local function createRecipeRow(parent, index, recipe)
  local row = CreateFrame("Button", nil, parent, "BackdropTemplate")
  row:SetSize(220, 22)
  row:SetPoint("TOPLEFT", 0, -(index - 1) * 24)
  row:SetBackdrop({
    bgFile = "Interface\\Buttons\\WHITE8x8",
    edgeFile = nil,
    tile = false,
  })
  local known = Known:IsKnown(recipe.id)
  local bgAlpha = known and 0.08 or 0.18
  local c = known and ns.Constants.COLORS.known or ns.Constants.COLORS.unknown
  row:SetBackdropColor(c.r, c.g, c.b, bgAlpha)

  local label = row:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  label:SetPoint("LEFT", 6, 0)
  label:SetWidth(210)
  label:SetJustifyH("LEFT")
  local skill = recipe.skill or 0
  label:SetText(string.format("%s%s  (%d)", known and "✓ " or "○ ", recipe.name, skill))
  Theme.ApplyListLabel(label, known)

  row:SetScript("OnEnter", function(self)
    self:SetBackdropColor(c.r, c.g, c.b, bgAlpha + 0.15)
  end)
  row:SetScript("OnLeave", function(self)
    self:SetBackdropColor(c.r, c.g, c.b, bgAlpha)
  end)
  row:SetScript("OnClick", function()
    Browser:ShowRecipeDetail(recipe)
  end)
  row:Show()
  rows[#rows + 1] = row
  return row
end

function Browser:RefreshList()
  local f = ensureFrame()
  if not f or not selectedProfession then
    return
  end
  clearRows()
  local recipes = ns.Data.GetRecipesForProfession(selectedProfession)
  table.sort(recipes, function(a, b)
    local ka = Known:IsKnown(a.id)
    local kb = Known:IsKnown(b.id)
    if ka ~= kb then
      return not ka
    end
    return (a.skill or 0) < (b.skill or 0)
  end)
  local list = f.RecipeList
  local height = math.max(1, #recipes * 24)
  list:SetHeight(height)
  for i, recipe in ipairs(recipes) do
    createRecipeRow(list, i, recipe)
  end
end

function Browser:ShowRecipeDetail(recipe)
  local f = ensureFrame()
  if not f or not recipe then
    return
  end
  f.DetailTitle:SetText(recipe.name or ("Recipe " .. recipe.id))
  local known = Known:IsKnown(recipe.id)
  Theme.ApplyListLabel(f.DetailTitle, known)

  local detail = f.DetailList
  for i = detail:GetNumChildren(), 1, -1 do
    local child = select(i, detail:GetChildren())
    if child then
      child:Hide()
      child:SetParent(nil)
    end
  end

  local lines = Sources:FormatRecipeSources(recipe)
  local y = 0
  for _, line in ipairs(lines) do
    local font = line.muted and "GameFontDisableSmall" or "GameFontHighlightSmall"
    local fs = detail:CreateFontString(nil, "OVERLAY", font)
    fs:SetPoint("TOPLEFT", 0, -y)
    fs:SetWidth(200)
    fs:SetJustifyH("LEFT")
    fs:SetText(line.text)
    if line.gap then
      local c = ns.Constants.COLORS.gap
      fs:SetTextColor(c.r, c.g, c.b)
    end
    y = y + (line.height or 18)
  end
  detail:SetHeight(math.max(1, y + 10))
end

local function professionMenuInit(self, level)
  local info = UIDropDownMenu_CreateInfo()
  for _, prof in ipairs(ns.Data.Professions) do
    info.text = prof.name
    info.value = prof.key
    info.func = function(btn)
      selectedProfession = btn.value
      UIDropDownMenu_SetText(frame.ProfMenu, prof.name)
      Browser:RefreshList()
      Browser:ShowRecipeDetail(nil)
      frame.DetailTitle:SetText("Select a recipe")
    end
    info.checked = (selectedProfession == prof.key)
    UIDropDownMenu_AddButton(info, level)
  end
end

function Browser:EnsureInit()
  if initialized then
    return true
  end
  local f = ensureFrame()
  if not f then
    return false
  end
  UIDropDownMenu_Initialize(f.ProfMenu, professionMenuInit)
  if not selectedProfession and ns.Data.Professions[1] then
    selectedProfession = ns.Data.Professions[1].key
    UIDropDownMenu_SetText(f.ProfMenu, ns.Data.Professions[1].name)
  end
  f:Hide()
  f:SetScript("OnShow", function()
    ns.Debug:Mark("browser_open")
    Known:RefreshProfessions()
    local recipes = ns.Data.GetRecipesForProfession(selectedProfession)
    Known:WarmRecipes(recipes, function()
      Browser:RefreshList()
      ns.Debug:Mark("browser_recipes_warmed")
    end)
  end)
  initialized = true
  ns.Debug:Mark("browser_initialized")
  return true
end

function Browser:Toggle()
  if not Browser:EnsureInit() then
    return
  end
  local f = ensureFrame()
  if not f then
    return
  end
  if f:IsShown() then
    f:Hide()
  else
    f:Show()
  end
end

function Browser:Open()
  if not Browser:EnsureInit() then
    return
  end
  local f = ensureFrame()
  if f then
    f:Show()
  end
end

function Browser:SelectRecipe(recipeID)
  if not Browser:EnsureInit() then
    return
  end
  local recipe = ns.Data.GetRecipe(recipeID)
  if recipe and recipe.professionKey then
    selectedProfession = recipe.professionKey
    local f = ensureFrame()
    if f then
      for _, prof in ipairs(ns.Data.Professions) do
        if prof.key == recipe.professionKey then
          UIDropDownMenu_SetText(f.ProfMenu, prof.name)
          break
        end
      end
    end
    Browser:Open()
    Browser:RefreshList()
    Browser:ShowRecipeDetail(recipe)
  end
end