require "Logging"

function StringIsEmpty(s) return s == nil or s == "" end

function StringStartsWith(s, prefix) return string.sub(s, 1, string.len(prefix)) == prefix end

function IsInCombat() return GetCharacterCondition(26) end

function IsMounted() return GetCharacterCondition(4) end

function TableIsEmpty(t) return next(t) == nil end

function TableSize(t) local count = 0 for _, _ in pairs(t) do count = count + 1 end return count end

function RoundUpToNext(x, increment) return math.floor(((x + increment - 1) // increment) * increment + 0.5) end

function IsCasting() return GetCharacterCondition(27) end

function HasFood() return HasStatusId(48) end

function GetFoodTime() return GetStatusTimeRemaining(48) end

function Sprint() ExecuteGeneralAction(4) end

function WaitForPlayerReady(timeout, sleep)
  return WaitUntil(function () return not IsPlayerOccupied() and IsPlayerAvailable() end, timeout, sleep)
end

function WaitForNavReady(timeout, sleep)
  return WaitUntil(function () return NavIsReady() and IsPlayerAvailable() end, timeout, sleep)
end

function Dismount()
  while IsMounted() do
    yield("/mount")
    yield("/wait 0.1")
  end
end

function ReadXORData(file, key, bytes)
  local x = 0
  for i = 0, bytes - 1 do
    local data = file:read(1)
    if data == nil then Logging.Debug("read nil data") return nil end
    x = x + ((string.byte(data) ~ key) << (8 * i))
  end
  return x
end

function WaitWhile(condition, timeout, sleep)
  if not sleep then sleep = 0.1 end
  local timeout_count = 0
  while condition() do
    if timeout then
      if timeout_count > timeout then
        return false
      end
      timeout_count = timeout_count + sleep
    end
    yield("/wait "..sleep)
  end
  return true
end

function WaitUntil(condition, timeout, sleep)
  return WaitWhile(function () return not condition() end, timeout, sleep)
end
