require "Logging"
require "Utils"

function GetARCharacterData(cid)
  if not cid then cid = GetPlayerContentId() end
  if not cid then return nil end
  Logging.Debug("fetching AR character data "..cid)
  local data = ARGetCharacterData(cid)
  if data ~= nil and type(data) == "userdata" then
    return data
  end
  return nil
end

function ARRelogTo(cid, timeout)
  if GetPlayerContentId() == cid then
    return true
  end

  local data = GetARCharacterData(cid)
  if data then
    local name = ""..data.Name.."@"..data.World
    Logging.Debug("relogging to character "..name)
    while not ARIsBusy() do
      yield("/ays relog "..name)
      yield("/wait 1")
    end
    if WaitUntil(function () return cid == GetPlayerContentId() end, timeout, 1) then
      WaitForNavReady()
      yield("/wait 3")
      return true
    end
  end
  return false
end
