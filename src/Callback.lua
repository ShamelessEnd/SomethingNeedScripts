require "Logging"

CallbackConfig = {
  ExitOnDC = false,
  PCall = nil,
}

function IsPCallAvailable()
  if CallbackConfig.PCall == nil then
    CallbackConfig.PCall = IPC.IsInstalled("PandorasBox")
  end
  return CallbackConfig.PCall
end

function CallbackCommand(target, update, ...)
  -- even with all these checks, /callback will randomly crash, so use /pcall when available
  local prefix
  if IsPCallAvailable() then prefix = "/pcall " else prefix = "/callback " end
  local command = prefix..target.." "..tostring(update)
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

function TryCallback(target, update, ...)
  local command = CallbackCommand(target, update, ...)
  if IsAddonReady(target) then
    yield(command)
  end
end

function Callback(target, update, ...)
  if CallbackConfig.ExitOnDC then
    CallbackErrorCheck(target, update, ...)
  else
    CallbackUnsafe(target, update, ...)
  end
end

function CallbackUnsafe(target, update, ...)
  local command = CallbackCommand(target, update, ...)
  while not IsAddonReady(target) do
    yield("/wait 0.1")
  end
  yield(command)
end

function CallbackTimeout(timeout, target, update, ...)
  local command = CallbackCommand(target, update, ...)
  local timeout_count = 0
  local error_check_count = 0
  while timeout_count < timeout do
    if IsAddonReady(target) then
      yield(command)
      return true
    end
    yield("/wait 0.1")
    timeout_count = timeout_count + 0.1
    error_check_count = error_check_count + 0.1
    if CallbackConfig.ExitOnDC and error_check_count > 1 then
      ExitGameIfServerError(10)
      error_check_count = 0
    end
  end
  Logging.Error("callback command timed out: "..command)
  return false
end

function CallbackErrorCheck(target, update, ...)
  local command = CallbackCommand(target, update, ...)
  local error_check_count = 0
  while not IsAddonReady(target) do
    yield("/wait 0.1")
    error_check_count = error_check_count + 0.1
    if error_check_count > 1 then
      ExitGameIfServerError(10)
      error_check_count = 0
    end
  end
  yield(command)
end

function GetServerError()
  if InstancedContent.GetCurrentContentId() ~= 0 or not IsAddonReady("Dialogue") then return nil end
  local error_text = GetNewNodeText("Dialogue", 1, 5)
  if not error_text or error_text == "" then return nil end
  local error_val = tonumber(error_text)
  if error_val == 0 then return nil end
  return error_val
end

function ExitGameIfServerError(timeout)
  local timeout_count = 0
  local server_error = GetServerError()
  while server_error do
    if not timeout or timeout_count > timeout then
      yield("/click Dialogue Ok")
      CallbackUnsafe("_TitleMenu", true, 12, 1)
      return
    end
    yield("/wait 1")
    timeout_count = timeout_count + 1
    server_error = GetServerError()
  end
end
