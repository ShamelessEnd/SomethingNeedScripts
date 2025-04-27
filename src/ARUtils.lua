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

function ARFindCid(name)
  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local ar_data = GetARCharacterData(cid)
    if ar_data then
      local cid_name = ar_data.Name.."@"..ar_data.World
      if StringStartsWith(cid_name, name) then
        return cid
      end
    end
  end
  return nil
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

  local found = nil
  local found_level = level
  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local ar_data = GetARCharacterData(cid)
    if ar_data and ar_data.Enabled and hasFishingRetainer(ar_data.RetainerData) then
      local char_level = ar_data.ClassJobLevelArray[17]
      if char_level > 0 and char_level < found_level then
        found = cid
        found_level = char_level
      end
    end
  end
  return found
end

function ARApplyToAllCharacters(cids, lambda, timeout)
  for _, cid in pairs(cids) do
    if ARRelogTo(cid, timeout) then
      lambda()
    end
  end
end
