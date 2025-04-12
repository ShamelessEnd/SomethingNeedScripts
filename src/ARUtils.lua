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

function ARFindFishCharacterToLevel(level)
  local function hasFishingRetainer(retainer_data)
    if not retainer_data then return false end
    for i = 0, retainer_data.Count - 1 do
      if retainer_data[i].Job == 18 then
        return true
      end
    end
    return false
  end

  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local ar_data = GetARCharacterData(cid)
    if ar_data and ar_data.Enabled and ar_data.ClassJobLevelArray[17] < level and hasFishingRetainer(ar_data.RetainerData) then
      return chars[i]
    end
  end
  return nil
end
