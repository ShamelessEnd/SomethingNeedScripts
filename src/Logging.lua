local _log_level = 0

function SetLogLevel(level) _log_level = level end
function LogMessage(message) yield(""..message) end
function LogTrace(message) if _log_level <= -1 then LogMessage("-- "..message) end end
function LogDebug(message) if _log_level <= 0 then LogMessage(message) end end
function LogInfo(message) if _log_level <= 1 then LogMessage(message) end end
function LogWarning(message) if _log_level <= 2 then LogMessage("WARNING: "..message) end end
function LogError(message) if _log_level <= 3 then LogMessage("ERROR: "..message) end end
