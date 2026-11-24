local _, ns = ...

local Util = {}
ns.Util = Util

function Util.GetTime()
  return time and time() or GetTime()
end

function Util.FormatMoney(copper)
  if not copper or copper <= 0 then
    return "—"
  end
  if GetCoinTextureString then
    return GetCoinTextureString(copper)
  end
  local gold = math.floor(copper / 10000)
  local silver = math.floor((copper % 10000) / 100)
  local cop = copper % 100
  if gold > 0 then
    return string.format("%dg %ds %dc", gold, silver, cop)
  end
  if silver > 0 then
    return string.format("%ds %dc", silver, cop)
  end
  return string.format("%dc", cop)
end

function Util.Trim(s)
  if not s then
    return ""
  end
  return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

function Util.SafeItemName(itemID)
  if not itemID then
    return nil
  end
  local name = GetItemInfo(itemID)
  if name then
    return name
  end
  if Item and Item.CreateFromItemID then
    local item = Item:CreateFromItemID(itemID)
    item:ContinueOnItemLoad(function()
      -- Name will resolve on next UI refresh.
    end)
  end
  return "item:" .. tostring(itemID)
end

function Util.ItemIDFromLink(link)
  if not link then
    return nil
  end
  local id = link:match("item:(%d+)")
  return id and tonumber(id) or nil
end

function Util.NpcIDFromGUID(guid)
  if not guid then
    return nil
  end
  local unitType, _, _, _, _, npcID = strsplit("-", guid)
  if unitType == "Creature" or unitType == "Vehicle" then
    return tonumber(npcID)
  end
  return nil
end

function Util.PlayerZone()
  return GetRealZoneText() or GetZoneText() or "Unknown"
end

function Util.Subzone()
  return GetSubZoneText() or ""
end

function Util.SnoozeKey(kind, id, extra)
  extra = extra or ""
  return string.format("%s:%s:%s", kind, tostring(id), tostring(extra))
end

function Util.CopyTable(src)
  local dst = {}
  if type(src) ~= "table" then
    return dst
  end
  for k, v in pairs(src) do
    if type(v) == "table" then
      dst[k] = Util.CopyTable(v)
    else
      dst[k] = v
    end
  end
  return dst
end

function Util.MergeDefaults(saved, defaults)
  if type(saved) ~= "table" then
    return Util.CopyTable(defaults)
  end
  for k, v in pairs(defaults) do
    if saved[k] == nil then
      if type(v) == "table" then
        saved[k] = Util.CopyTable(v)
      else
        saved[k] = v
      end
    elseif type(v) == "table" and type(saved[k]) == "table" then
      Util.MergeDefaults(saved[k], v)
    end
  end
  return saved
end