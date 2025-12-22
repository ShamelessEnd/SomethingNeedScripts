require "Callback"
require "Logging"

function StringIsEmpty(s) return s == nil or s == "" end

function StringStartsWith(s, prefix)
  if StringIsEmpty(s) or not prefix then return false end
  return s:sub(1, prefix:len()) == prefix
end

function StringEndsWith(s, suffix)
  if StringIsEmpty(s) or not suffix then return false end
  return s:sub(1 + s:len() - suffix:len()) == suffix
end

function StringTrim(s) if s == nil then return nil else return s:match("^%s*(.-)%s*$") end end

function StringSplit(s, sep)
  if StringIsEmpty(s) then return nil end
  if StringIsEmpty(sep) then return s end
  local t = {}
  for part in s:gmatch("([^"..sep.."]*)") do table.insert(t, part) end
  return table.unpack(t)
end

function IsInCombat() return GetCharacterCondition(26) end

function IsMounted() return GetCharacterCondition(4) end

function TableIsEmpty(t) return next(t) == nil end

function TableSize(t) local count = 0 for _, _ in pairs(t) do count = count + 1 end return count end

function TableContains(t, i) if t then for _, x in pairs(t) do if x == i then return true end end end return false end

function ToTable(c)
  if type(c) == "table" then return c end
  if c == nil or c.Count == nil then return nil end
  local t = {}
  for i = 0, c.Count - 1 do t[i+1] = c[i] end
  return t
end

function ParseInt(s) local n = s:gsub("%D", "") return tonumber(n) end

function RoundUpToNext(x, increment) return math.floor(((x + increment - 1) // increment) * increment + 0.5) end

function IsCasting() return GetCharacterCondition(27) end

function HasFood() return HasStatusId(48) end

function GetFoodTime() return GetStatusTimeRemaining(48) end

function Sprint() ExecuteGeneralAction(4) end

function GetNQItemCount(item_id) return GetItemCount(item_id, false) end

function GetHQItemCount(item_id) return GetItemCount(item_id) - GetNQItemCount(item_id) end

function GetJobLevel(job_id) return GetLevel(job_id - 1) end

function GetARJobLevel(ar_data, job_id) return ar_data.ClassJobLevelArray[job_id - 1] end

function GetMaxLevel() return 100 end

function GetNodeListIndex(i, base) if i == 0 then return base else return (base * 10000) + 1000 + i end end

function Target(target)
  yield("/target \""..target.."\"")
  yield("/wait 0.1")
  return WaitUntil(function () return GetTargetName() == target end, 1)
end

function GetItemId(name)
  local item = Excel.Item
  for i = 0, item.Count - 1 do
    if item:GetRow(i):GetProperty("Name") == name then return i end
  end
  return nil
end

function FindItemId(prefix)
  local item = Excel.Item
  for i = 0, item.Count - 1 do
    if StringStartsWith(item:GetRow(i):GetProperty("Name"), prefix) then return i end
  end
  return nil
end

function WaitForPlayerReady(timeout, sleep)
  return WaitUntil(function () return IsPlayerAvailable() end, timeout, sleep)
end

function WaitForNavReady(timeout, sleep)
  return WaitUntil(function () return NavIsReady() and IsPlayerAvailable() end, timeout, sleep)
end

function UseItem(id)
  if not id then return true end
  if not WaitForPlayerReady(5) then return false end
  yield("/item "..GetItemName(id))
  WaitForPlayerReady(5)
  return true
end

function Dismount()
  while IsMounted() do
    yield("/mount")
    yield("/wait 0.1")
    MaybeCheckForServerError()
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

function RepeatUntil(action, condition, timeout, sleep)
  if not sleep or sleep <= 0 then sleep = 0.1 end
  local timeout_count = 0
  local error_check_count = 0
  local error_check_threshold = 1
  if timeout and timeout < 0 then return false end
  if timeout and timeout < error_check_threshold then error_check_threshold = timeout end
  repeat
    if action then
      local result = action()
      if result ~= nil then return result end
    end
    if CallbackConfig.ExitOnDC then
      if error_check_count >= error_check_threshold then
        ExitGameIfServerError()
        error_check_count = 0
      end
      error_check_count = error_check_count + sleep
    end
    if timeout then
      if timeout_count >= timeout then return false end
      timeout_count = timeout_count + sleep
    end
    yield("/wait "..sleep)
  until condition()
  return true
end

function RepeatWhile(action, condition, timeout, sleep)
  return RepeatUntil(action, function () return not condition() end, timeout, sleep)
end

function While(action, condition, timeout, sleep)
  if not condition() then return true end
  return RepeatWhile(action, condition, timeout, sleep)
end

function WaitWhile(condition, timeout, sleep)
  return While(nil, condition, timeout, sleep)
end

function WaitUntil(condition, timeout, sleep)
  if condition() then return true end
  return RepeatUntil(nil, condition, timeout, sleep)
end
