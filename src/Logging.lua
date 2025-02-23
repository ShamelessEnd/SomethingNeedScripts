
Logging = {
  Level = 0,
  EchoOn = false,
}

local function sTable(data)
  if type(data) ~= "table" then
    return data
  end
  local str = "{"
  local first = true
  for k,v in pairs(data) do
    if first then
      first = false
    else
      str = str..","
    end
    str = str.." "..k..": "..sTable(v)
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

Logging.Echo = function (msg) msg = sTable(msg) if msg then yield(sTrunc("/e "..msg)) end end
Logging.Message = function (level, prefix, msg)
  msg = sTable(msg)
  if msg and level >= Logging.Level then
    local log_msg = prefix..msg
    if Logging.EchoOn then
      Logging.Echo(log_msg)
    end
    LogDebug("[SomethingNeedScripts] "..log_msg)
  end
end

Logging.Trace   = function (msg) Logging.Message(-1, "-- ", msg) end
Logging.Debug   = function (msg) Logging.Message(0, "", msg) end
Logging.Info    = function (msg) Logging.Message(1, "", msg) end
Logging.Warning = function (msg) Logging.Message(2, "WARNING: ", msg) end
Logging.Error   = function (msg) Logging.Message(3, "ERROR: ", msg) end
