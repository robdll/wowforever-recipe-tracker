local _, ns = ...
local Util = ns.Util

local DB = {}
ns.DB = DB

local defaults = {
  schema = 1,
  snoozes = {},
  discovered = {
    vendors = {},
    mobs = {},
    trainers = {},
  },
  minimap = { angle = 220, hide = false },
}

function DB:Init()
  if WoWForeverRFTDB == nil then
    WoWForeverRFTDB = {}
  end
  self.saved = Util.MergeDefaults(WoWForeverRFTDB, defaults)
  WoWForeverRFTDB = self.saved
end

function DB:GetSnooze(key)
  local untilAt = self.saved.snoozes[key]
  if not untilAt then
    return false
  end
  if untilAt <= Util.GetTime() then
    self.saved.snoozes[key] = nil
    return false
  end
  return true, untilAt
end

function DB:SetSnooze(key, seconds)
  self.saved.snoozes[key] = Util.GetTime() + (seconds or ns.Constants.SNOOZE_SECONDS)
end

function DB:RecordVendorDiscovery(vendorKey, recipeID, meta)
  if not self.saved.discovered.vendors[vendorKey] then
    self.saved.discovered.vendors[vendorKey] = {}
  end
  self.saved.discovered.vendors[vendorKey][recipeID] = meta or true
end

function DB:RecordMobDiscovery(npcID, recipeID, meta)
  if not self.saved.discovered.mobs[npcID] then
    self.saved.discovered.mobs[npcID] = {}
  end
  self.saved.discovered.mobs[npcID][recipeID] = meta or true
end

function DB:GetDiscoveredVendorSources(vendorKey)
  return self.saved.discovered.vendors[vendorKey] or {}
end

function DB:GetDiscoveredMobSources(npcID)
  return self.saved.discovered.mobs[npcID] or {}
end