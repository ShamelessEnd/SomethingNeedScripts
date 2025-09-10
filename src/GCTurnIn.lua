require "ARUtils"
require "Logging"
require "Navigation"
require "Purchase"
require "ServerData"
require "UINav"
require "Utils"

function BailGCTurnIn()
  while not IsPlayerAvailable() do
    CloseAddonFast("GrandCompanySupplyReward")
    CloseAddonFast("SelectYesno")
    CloseAddonFast("GrandCompanySupplyList")
    CloseAddonFast("GrandCompanyExchange")
    CloseAddonFast("ShowExchangeCurrencyDialog")
    CloseAddonFast("SelectString")
    CloseAddonFast("SelectIconString")
    yield("/wait 0.1")
  end
end

function GCTurnIn()
  yield("/ays deliver")
  yield("/wait 1")
  if not WaitWhile(function () return ARIsBusy() end, 900, 1) then
    ARAbortAllTasks()
    BailGCTurnIn()
  end
  yield("/wait 1")
end

function GCMissionSubmit()
  yield("/at y")
  GoToGCHQ()
  if not InteractWith("Serpent Personnel Officer", "SelectString", 5.5) then
    return
  end

  Callback("SelectString", true, 0)
  AwaitAddonReady("GrandCompanySupplyList")
  for i = 7,0,-1 do
    local node_i = GetNodeListIndex(i, 4)
    local text = GetNewNodeText("GrandCompanySupplyList", 1, 22, node_i, 5, 10)
    local hq_index = string.find(text, "")
    if hq_index and hq_index > 0 then
      local hq_count = tonumber(string.sub(text, hq_index+3))
      local required_count = tonumber(GetNewNodeText("GrandCompanySupplyList", 1, 22, node_i, 5, 7))
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
    local item = GetNewNodeText("ContentsInfoDetail", 1, 2, job_id - 2, 4)
    local count = GetNewNodeText("ContentsInfoDetail", 1, 2, job_id - 2, 7)
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
