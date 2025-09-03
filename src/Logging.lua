require "LegacySndBridge"

Logging = {
  LogLevel = 0,
  EchoLevel = 2,
}

local function sFix(data)
  if type(data) ~= "table" then
    return tostring(data)
  end
  local str = "{"
  local first = true
  for k,v in pairs(data) do
    if first then
      first = false
    else
      str = str..","
    end
    str = str.." "..k..": "..sFix(v)
  end
  return str.." }"
end

local function sTrunc(str)
  local str_lim = 500
  local str_len = string.len(str)
  if str_len > str_lim then
    Logging.Warning("message too long ("..str_len.."), truncating to limit ("..str_lim..")")
    return string.sub(str, 1, 500)
  end
  return str
end

Logging.Message = function (level, prefix, msg)
  if msg == nil then return end

  msg = prefix..sFix(msg)
  if level >= Logging.LogLevel then
    LogDebug("[SomethingNeedScripts] "..msg)
  end
  if level >= Logging.EchoLevel then
    Logging.Echo(msg)
  end
end

Logging.Trace   = function (msg) Logging.Message(-1, "-- ", msg) end
Logging.Debug   = function (msg) Logging.Message(0, "", msg) end
Logging.Info    = function (msg) Logging.Message(1, "", msg) end
Logging.Warning = function (msg) Logging.Message(2, "WARNING: ", msg) end
Logging.Error   = function (msg) Logging.Message(3, "ERROR: ", msg) end

Logging.Echo = function (msg)
  local s = sTrunc("/e "..sFix(msg))
  yield(s)
  Logging.Info(s)
end

Logging.Notify = function (msg) Logging.Echo("[Notification] "..sFix(msg)) end
