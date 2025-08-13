require "Logging"
require "Utils"

function GetARCharacterData(cid)
  cid = cid or GetPlayerContentId()
  if not cid then return nil end
  Logging.Debug("fetching AR character data "..cid)
  local data = ARGetCharacterData(cid)
  if data and data.CID == cid then
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

function ARGetRetainerCount(cid)
  local ar_data = GetARCharacterData(cid)
  if not ar_data then return 0 end
  return ar_data.RetainerData.Count
end

function ARFindFishCharacterToLevel(level)
  local fish_job_id = 18
  local function hasFishingRetainer(retainer_data)
    if not retainer_data then return false end
    for i = 0, retainer_data.Count - 1 do
      if retainer_data[i].Job == fish_job_id then
        return true
      end
    end
    return false
  end

  local found = nil
  local found_level = level or GetMaxLevel()
  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local ar_data = GetARCharacterData(cid)
    if ar_data and ar_data.Enabled and hasFishingRetainer(ar_data.RetainerData) then
      local char_level = GetARJobLevel(ar_data, fish_job_id)
      if char_level > 0 and char_level < found_level then
        found = cid
        found_level = char_level
      end
    end
  end
  return found
end

function ARHasCrafterToLevel(cid, level)
  local target_level = level or GetMaxLevel()
  local ar_data = GetARCharacterData(cid)
  if not ar_data then return false end
  for job_id = 8,15 do
    local job_level = GetARJobLevel(ar_data, job_id)
    if job_level > 0 and job_level < target_level then
      return true
    end
  end
  return false
end

function ARApplyToAllCharacters(cids, lambda, condition, timeout)
  for _, cid in pairs(cids) do
    if not condition or condition(cid) then
      if ARRelogTo(cid, timeout) then
        lambda(cid)
      end
    end
  end
end
