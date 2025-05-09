require "ARUtils"
require "Navigation"
require "Purchase"
require "ServerData"

function BailGCTurnIn()
  local dellyrooStop = true
  while dellyrooStop do
    yield("/deliveroo disable")
    yield("/wait 1")
    dellyrooStop = DeliverooIsTurnInRunning()
  end
  yield("/pcall GrandCompanySupplyReward True -1 <wait.2>")
  yield("/pcall SelectYesno True -1 <wait.2>")
  yield("/pcall GrandCompanySupplyList True -1 <wait.1>")
  yield("/pcall GrandCompanyExchange True -1 <wait.1>")
  yield("/pcall SelectString True -1 <wait.2>")
end

function GCTurnIn()
  GoToGCHQ()
  yield("/deliveroo enable")
  yield("/wait 3")
  local dellyroo = true
  local timeout = 0
  while dellyroo do
    dellyroo = DeliverooIsTurnInRunning()
    yield("/wait 1")
    if timeout == 1000 then
      BailGCTurnIn()
      yield("/wait 1")
      return
    end
    timeout = timeout + 1
  end
  yield("/wait 1")
end

function GCMissionSubmit()
  yield("/at y")
  GoToGCHQ()
  if not InteractWith("Serpent Personnel Officer", "SelectString") then
    return
  end

  Callback("SelectString", true, 0)
  AwaitAddonReady("GrandCompanySupplyList")
  for i = 7,0,-1 do
    local text = GetNodeText("GrandCompanySupplyList", 6, i+2, 6)
    local hq_index = string.find(text, "")
    if hq_index and hq_index > 0 then
      local hq_count = tonumber(string.sub(text, hq_index+3))
      local required_count = tonumber(GetNodeText("GrandCompanySupplyList", 6, i+2, 9))
      if hq_count and required_count and hq_count >= required_count then
        Callback("GrandCompanySupplyList", true, 1, i, "")
        Callback("SelectYesno", true, 0)
        while not IsAddonReady("GrandCompanySupplyReward") do
          if IsAddonReady("SelectYesno") then Callback("SelectYesno", true, 0) end
          yield("/wait 0.1")
        end
        Callback("GrandCompanySupplyReward", true, 0)
        while not IsAddonReady("GrandCompanySupplyList") do
          if IsAddonReady("SelectYesno") then Callback("SelectYesno", true, 0) end
          yield("/wait 0.1")
        end
        AwaitAddonReady("GrandCompanySupplyList")
      end
    end
  end

  Callback("GrandCompanySupplyList", true, -1)
  Callback("SelectString", true, -1)
end

function GetGCSupplyMissions()
  OpenMainCommandWindow("Timers", "ContentsInfo")
  if not IsAddonReady("ContentsInfoDetail") then
    repeat
      Callback("ContentsInfo", true, 12, 1, "")
    until AwaitAddonReady("ContentsInfoDetail", 1)
  end

  local missions = {}
  for job_id = 8,15 do
    local item = GetNodeText("ContentsInfoDetail", 120 - job_id, 5)
    local count = GetNodeText("ContentsInfoDetail", 120 - job_id, 2)
    if not StringIsEmpty(item) and not StringIsEmpty(count) then
      local item_id = nil
      if StringEndsWith(item, "...") then
        item_id = FindItemId(string.sub(item, 1, string.len(item) - 3))
      else
        item_id = GetItemId(item)
      end
      local item_count = tonumber(count)
      if item_id and item_count then
        missions[job_id] = {
          item = item_id,
          count = item_count,
        }
      end
    end
  end

  CloseAddonFast("ContentsInfoDetail")
  CloseAddonFast("ContentsInfo")
  return missions
end

function DoDailyGCSupplyMissions(price_limit, gil_floor)
  if not price_limit then price_limit = 150000 end

  local missions = GetGCSupplyMissions()
  local buy_table = {}
  for job_id, mission in pairs(missions) do
    if GetJobLevel(job_id) < GetMaxLevel() then
      buy_table[job_id] = {
        mission.item,
        mission.count,
        price_limit / mission.count,
        true,
        true,
      }
    end
  end
  if not TableIsEmpty(buy_table) then
    GoPurchaseDCItems(buy_table, gil_floor, true)
    GCMissionSubmit()

    local data = GetARCharacterData()
    if data and data.Enabled == true then
      WaitForPlayerReady()
      ReturnToBell()
    end
  end
end

function DoDailyGCSupplyMissionsAll(cids, price_limit, gil_floor)
  ARApplyToAllCharacters(cids, function () DoDailyGCSupplyMissions(price_limit, gil_floor) end, ARHasCrafterToLevel)
end
