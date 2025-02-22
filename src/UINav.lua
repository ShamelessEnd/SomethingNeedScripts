require "Callback"
require "Logging"

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

function CloseAndAwaitOther(addon_name, other_addon_name)
  repeat
    Callback(addon_name, true, -1)
  until AwaitAddonGone(addon_name, 2)
  AwaitAddonReady(other_addon_name)
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

function InteractWith(target, addon)
  Logging.Debug("opening "..target.." - "..addon)
  if IsAddonVisible(addon) then
    return AwaitAddonReady(addon, 5)
  end

  yield("/target "..target)
  if GetTargetName() ~= target or GetDistanceToTarget() > 4.597 then
    Logging.Error("not in range of "..target)
    return false
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
