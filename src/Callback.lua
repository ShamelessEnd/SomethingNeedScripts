require "Logging"

function CallbackCommand(target, update, ...)
  -- even with all these checks, /callback will randomly crash, so fallback to /pcall
  local command = "/pcall "..target.." "..tostring(update)
  for _, arg in pairs({...}) do
    if type(arg) == "string"then
      if string.find(arg, " ") then
        command = command.." \""..arg.."\""
      else
        command = command.." "..arg
      end
    else
        command = command.." "..tostring(arg)
    end
  end
  Logging.Trace(command)
  return command
end

function Callback(target, update, ...)
  local command = CallbackCommand(target, update, ...)
  while not IsAddonReady(target) do
    yield("/wait 0.1")
  end
  yield(command)
end

function CallbackTimeout(timeout, target, update, ...)
  local command = CallbackCommand(target, update, ...)
  local timeout_count = 0
  while timeout_count < timeout do
    if IsAddonReady(target) then
      yield(command)
      return true
    end
    yield("/wait 0.1")
    timeout_count = timeout_count + 0.1
  end
  Logging.Error("callback command timed out: "..command)
  return false
end
