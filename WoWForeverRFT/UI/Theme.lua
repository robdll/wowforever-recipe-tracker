local _, ns = ...

ns.Theme = {
  ApplyTitle = function(fontString)
    fontString:SetFontObject(GameFontNormalLarge)
    local c = ns.Constants.COLORS.header
    fontString:SetTextColor(c.r, c.g, c.b)
  end,
  ApplyListLabel = function(fontString, known)
    fontString:SetFontObject(GameFontHighlight)
    local c = known and ns.Constants.COLORS.known or ns.Constants.COLORS.unknown
    fontString:SetTextColor(c.r, c.g, c.b)
  end,
  ApplyMuted = function(fontString)
    fontString:SetFontObject(GameFontDisable)
    local c = ns.Constants.COLORS.muted
    fontString:SetTextColor(c.r, c.g, c.b)
  end,
}