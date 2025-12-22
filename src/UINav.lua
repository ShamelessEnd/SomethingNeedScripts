require "Callback"
require "Logging"
require "Utils"

function AwaitAddonReady(addon_name, timeout)
  return WaitUntil(function () return IsAddonReady(addon_name) end, timeout)
end

function AwaitAddonGone(addon_name, timeout)
  return WaitWhile(function () return IsAddonVisible(addon_name) end, timeout)
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
  While(
    function () TryCallback("Talk", true, 1) end,
    function () return not IsAddonReady(addon_name) end
  )
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
    local text = GetNewNodeText("_TextError", 1, 2)
    if not StringIsEmpty(text) then return text end
  end
  return nil
end

function OpenCommandWindow(command, window)
  if not window then window = command end
  if IsAddonReady(window) then return true end
  local timeout_count = 0
  repeat
    if timeout_count > 5 then
      return false
    end
    yield("/"..command)
    timeout_count = timeout_count + 1
  until AwaitAddonReady(window, 1)
  return true
end

function SelectStringOption(text)
  if not AwaitAddonReady("SelectString", 5) then return false end
  for i = 0,11 do
    if StringStartsWith(GetNewNodeText("SelectString", 1, 3, GetNodeListIndex(i, 5), 2), text) then
      Callback("SelectString", true, i)
      return true
    end
  end
  return false
end

function SelectIconStringOption(text)
  if not AwaitAddonReady("SelectIconString", 5) then return false end
  for i = 0,11 do
    if StringStartsWith(GetNewNodeText("SelectIconString", 1, 3, GetNodeListIndex(i, 5), 2), text) then
      Callback("SelectIconString", true, i)
      return true
    end
  end
  return false
end

function SelectYesno(option)
  if not AwaitAddonReady("SelectYesno", 2) then return false end
  if option == true or option == 0 then
    Callback("SelectYesno", true, 0)
  else
    Callback("SelectYesno", true, 1)
  end
  return AwaitAddonGone("SelectYesno", 2)
end

function Logout()
  while IsPlayerOccupied() do
    yield("/send ESCAPE")
    yield("/wait 1")
    MaybeCheckForServerError()
  end
  repeat
    yield("/logout")
  until AwaitAddonReady("SelectYesno", 3)
  Callback("SelectYesno", true, 0)
  AwaitAddonGone("SelectYesno")
  yield("/wait 2")
end

function ExitGameFromTitle()
  Callback("_TitleMenu", true, 12, 1)
end
