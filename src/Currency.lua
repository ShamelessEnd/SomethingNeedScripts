require "Callback"
require "LegacySndBridge"
require "UINav"
require "Utils"

local function parseTomes(...)
  local args = { ... }
  local currency_text
  WaitWhile(function ()
    currency_text = GetNewNodeText("Currency", 1, 16, table.unpack(args))
    return StringIsEmpty(currency_text)
  end)

  local current_tomes, cap_tomes = StringSplit(currency_text, "/")
  return ParseInt(current_tomes), ParseInt(cap_tomes)
end

function OpenCurrencyWindow() return OpenCommandWindow("currency", "Currency") end

function GetWeeklyTomeCount()
  if not OpenCurrencyWindow() then return nil end

  RepeatUntil(
    function () Callback("Currency", true, 12, 1) end,
    function () return IsNodeVisible("Currency", 1, 16, 200408) end
  )

  local current_weekly, cap_weekly = parseTomes(200408, 6)
  local current_total, cap_total = parseTomes(200408, 5)
  CloseAddonFast("Currency")

  if not current_weekly or not cap_weekly then Logging.Warning("failed to read weekly tome count") end
  if not current_total or not cap_total then Logging.Error("failed to read total tome count") end

  return current_weekly, cap_weekly, current_total, cap_total
end

function GetUncappedTomeCount()
  if not OpenCurrencyWindow() then return nil end

  RepeatUntil(
    function () Callback("Currency", true, 12, 1) end,
    function () return IsNodeVisible("Currency", 1, 16, 200407) end
  )

  local current_total, cap_total = parseTomes(200407, 5)
  CloseAddonFast("Currency")

  if not current_total or not cap_total then Logging.Error("failed to read total tome count") end

  return current_total, cap_total
end

