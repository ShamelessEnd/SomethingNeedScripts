
Logging = { Level = 0 }

Logging.Echo = function (msg) if msg then yield("/e "..msg) end end
Logging.Message = function (level, prefix, msg)
  if msg and level >= Logging.Level then
    local log_msg = prefix..msg
    -- Logging.Echo(log_msg)
    LogDebug("[SomethingNeedScripts] "..log_msg)
  end
end

Logging.Trace   = function (msg) Logging.Message(-1, "-- ", msg) end
Logging.Debug   = function (msg) Logging.Message(0, "", msg) end
Logging.Info    = function (msg) Logging.Message(1, "", msg) end
Logging.Warning = function (msg) Logging.Message(2, "WARNING: ", msg) end
Logging.Error   = function (msg) Logging.Message(3, "ERROR: ", msg) end
