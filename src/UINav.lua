require "Callback"
require "Logging"
require "Utils"

function AwaitAddonReady(addon_name, timeout)
  if timeout == nil or timeout <= 0 then
    -- /waitaddon slows things down a lot, but might be more reliable
    -- yield("/waitaddon "..addon_name)
    while not IsAddonReady(addon_name) do
      yield("/wait 0.1")
    end
  else
    local timeout_count = 0
    while not IsAddonReady(addon_name) do
      yield("/wait 0.1")
      timeout_count = timeout_count + 0.1
      if timeout_count >= timeout then
        return false
      end
    end
  end
  return true
end

function AwaitAddonGone(addon_name, timeout)
  if timeout == nil or timeout <= 0 then
    while IsAddonVisible(addon_name) do
      yield("/wait 0.1")
    end
  else
    local timeout_count = 0
    while IsAddonVisible(addon_name) do
      yield("/wait 0.1")
      timeout_count = timeout_count + 0.1
      if timeout_count >= timeout then
        return false
      end
    end
  end
  return true
end

function CloseAddon(addon_name, await_other)
  Logging.Trace("closing addon "..addon_name.." and awaiting "..tostring(await_other))
  repeat
    TryCallback(addon_name, true, -1)
  until AwaitAddonGone(addon_name, 1)
  if await_other then
    AwaitAddonReady(await_other)
  else
    yield("/wait 1")
  end
end

function CloseAddonFast(addon_name)
  Logging.Trace("closing addon "..addon_name.." without waiting")
  repeat
    TryCallback(addon_name, true, -1)
  until AwaitAddonGone(addon_name, 1)
end

function ClearTalkAndAwait(addon_name)
  while not IsAddonReady(addon_name) do
    if IsAddonReady("Talk") then
      Callback("Talk", true, 1)
    end
    yield("/wait 0.1")
  end
  AwaitAddonReady(addon_name)
end

function InteractWith(target, addon, range)
  if not range then range = 4.597 end

  if addon then
    Logging.Debug("opening "..target.." - "..addon)
    if IsAddonVisible(addon) then
      return AwaitAddonReady(addon, 5)
    end
  else
    Logging.Debug("interacting with "..target)
  end

  Target(target)
  if GetTargetName() ~= target or GetDistanceToTarget() > range then
    Logging.Error("not in range ("..range..") of "..target)
    return false
  end

  if not addon then
    yield("/interact")
    return true
  end

  local attempt_count = 0
  repeat
    attempt_count = attempt_count + 1
    if attempt_count > 3 then
      Logging.Error("could not open "..target)
      return false
    end
    yield("/interact")
  until AwaitAddonReady(addon, 3)
  return true
end

function GetErrorText()
  if IsAddonVisible("_TextError") then
    local text = GetNodeText("_TextError", 1)
    if not StringIsEmpty(text) then return text end
  end
  return nil
end

function OpenMainCommandWindow(command, window)
  if not window then window = command end
  if IsAddonReady(window) then return true end
  local timeout_count = 0
  repeat
    if timeout_count > 5 then
      return false
    end
    yield("/maincommand "..command)
    timeout_count = timeout_count + 1
  until AwaitAddonReady(window, 1)
  return true
end

function SelectStringOption(text)
  if not AwaitAddonReady("SelectString", 5) then return false end
  for i = 0,11 do
    if StringStartsWith(GetNodeText("SelectString", 2, i + 1, 3), text) then
      Callback("SelectString", true, i)
      return true
    end
  end
  return false
end
