require "Logging"
require "ServerData"
require "Utils"

function GetARCharacterData(cid)
  cid = cid or GetPlayerContentId()
  if not cid then
    yield("/wait 0.1")
    cid = GetPlayerContentId()
  end
  if not cid then return nil end
  local data = ARGetCharacterData(cid)
  if not data then
    yield("/wait 0.1")
    data = ARGetCharacterData(cid)
  end
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
    RepeatUntil(function () yield("/ays relog "..name) end, ARIsBusy, nil, 1)
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

function ARFindCids(names)
  local cids = {}
  for i, name in pairs(names) do
    cids[i] = ARFindCid(name)
  end
  return cids
end

function ARGetRetainerCount(cid)
  local ar_data = GetARCharacterData(cid)
  if not ar_data then return 0 end
  return ar_data.RetainerData.Count
end

function ARFindRetainer(name, server_id)
  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local ar_data = GetARCharacterData(cid)
    if ar_data.World == GetServerData(server_id).name and ar_data.RetainerData then
      local retainer_data = ar_data.RetainerData
      for j = 0, retainer_data.Count - 1 do
        if retainer_data[j].Name == name then
          return retainer_data[j]
        end
      end
    end
  end
  return nil
end

function ARHasFishingRetainer(retainer_data)
  local fish_job_id = 18
  if not retainer_data then
    local ar_data = ARGetCharacterData()
    if ar_data then retainer_data = ar_data.RetainerData end
    if not retainer_data then return nil end
  end
  local min_fish_level = nil
  for i = 0, retainer_data.Count - 1 do
    if retainer_data[i].Job == fish_job_id then
      local fish_level = retainer_data[i].Level
      if not min_fish_level or fish_level < min_fish_level then
        min_fish_level = fish_level
      end
    end
  end
  return min_fish_level
end

function ARFindAllFishCharactersToLevel(level, natural_order)
  level = level or GetMaxLevel()
  local fish_job_id = 18

  local found = {}
  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local ar_data = GetARCharacterData(cid)
    if ar_data and ar_data.Enabled and ar_data.RetainerData then
      local min_fish_level = ARHasFishingRetainer(ar_data.RetainerData)
      if min_fish_level and min_fish_level < level then
        local char_fish_level = GetARJobLevel(ar_data, fish_job_id)
        if char_fish_level and char_fish_level > 0 then
          table.insert(found, {
            i = i,
            cid = cid,
            char_fish_level = char_fish_level,
            fish_level_diff = char_fish_level - min_fish_level,
          })
        end
      end
    end
  end

  if not natural_order then
    table.sort(found, function (a, b)
      if a.fish_level_diff < b.fish_level_diff then return true end
      if a.fish_level_diff > b.fish_level_diff then return false end
      if a.char_fish_level < b.char_fish_level then return true end
      if a.char_fish_level > b.char_fish_level then return false end
      return a.i < b.i
    end)
  end
  return TableMapValueTo(found, function (v) return v.cid end)
end

function ARFindFishCharacterToLevel(level) return ARFindAllFishCharactersToLevel(level, false)[1] end

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
  cids = ToTable(cids)
  if not cids then
    Logging.Error("invalid cids")
    return
  end
  for _, cid in pairs(cids) do
    if not condition or condition(cid) then
      if ARRelogTo(cid, timeout) then
        lambda(cid)
      end
    end
  end
end

function TimeUntilARTask()
  local chars = ARGetCharacterCIDs()

  local min_seconds = nil
  local now = os.time()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]

    local char_data = ARGetCharacterData(cid)

    if char_data.Enabled then
      local time_until_venture = IPC.AutoRetainer.GetClosestRetainerVentureSecondsRemaining(cid)

      if time_until_venture then
        Logging.Debug(time_until_venture.." seconds for retainer venture for "..char_data.Name.."@"..char_data.World)

        if not min_seconds or time_until_venture < min_seconds then min_seconds = time_until_venture end
        if min_seconds <= 0 then return 0 end
      end
    end

    if char_data.WorkshopEnabled then
      local sub_data = char_data.OfflineSubmarineData

      for j = 0, sub_data.Count -1 do
        local return_time = sub_data[j].ReturnTime

        if return_time then
          local time_until_sub = return_time - now

          Logging.Debug(time_until_sub.." seconds for submarine for "..char_data.Name.."@"..char_data.World)

          if not min_seconds or time_until_sub < min_seconds then min_seconds = time_until_sub end
          if min_seconds <= 0 then return 0 end
        end
      end
    end
  end
  Logging.Debug("Time until next task: "..min_seconds.." seconds")
  return min_seconds
end

function ARItemSell()
  BellOrEnter()
  yield("/ays itemsell")
  yield("/wait 1")
  WaitWhile(function () return ARIsBusy() or not IsPlayerAvailable() end, 300, 1)
end
