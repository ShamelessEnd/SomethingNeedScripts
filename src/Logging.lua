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

local function sTrunc(str, str_lim)
  local str_len = str:len()
  if str_len > str_lim then
    Logging.Warning("message too long ("..str_len.."), truncating to limit ("..str_lim..")")
    return str:sub(1, str_lim)
  end
  return str
end

local function logConsole(msg) LogDebug("[SomethingNeedScripts] "..msg) end
local function logEcho(msg) yield(sTrunc("/e "..msg, 500)) end

Logging.Message = function (level, prefix, msg)
  if msg == nil then return end
  msg = prefix..sFix(msg)

  if level >= Logging.LogLevel then logConsole(msg) end
  if level >= Logging.EchoLevel then logEcho(msg) end
end

Logging.Trace   = function (msg) Logging.Message(-1, "-- ", msg) end
Logging.Debug   = function (msg) Logging.Message(0, "", msg) end
Logging.Info    = function (msg) Logging.Message(1, "", msg) end
Logging.Warning = function (msg) Logging.Message(2, "WARNING: ", msg) end
Logging.Error   = function (msg) Logging.Message(3, "ERROR: ", msg) end

Logging.Echo = function (...)
  local args = table.pack(...)

  local s
  for i = 1, args.n do
    if i == 1 then s = sFix(args[i]) else s = s..", "..sFix(args[i]) end
  end

  logConsole(s)
  logEcho(s)
end

Logging.Notify = function (msg) Logging.Echo("[Notification] "..sFix(msg)) end
