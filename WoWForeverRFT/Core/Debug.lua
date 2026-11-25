local _, ns = ...

local Debug = {
  enabled = false,
  marks = {},
  t0 = GetTime and GetTime() or 0,
}
ns.Debug = Debug

function Debug:Mark(label)
  local t = (GetTime and GetTime() or 0) - self.t0
  self.marks[#self.marks + 1] = { label = label, t = t }
  if self.enabled then
    print(string.format("|cff88ff88RFT debug|r [%.3fs] %s", t, label))
  end
end

function Debug:Toggle()
  self.enabled = not self.enabled
  if self.enabled then
    print("|cff88ff88RFT debug ON|r — timing marks will print.")
    for _, m in ipairs(self.marks) do
      print(string.format("  [%.3fs] %s", m.t, m.label))
    end
  else
    print("|cff88ff88RFT debug OFF|r")
  end
  return self.enabled
end

function Debug:IsEnabled()
  return self.enabled
end