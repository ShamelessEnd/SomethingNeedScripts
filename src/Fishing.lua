require "Callback"
require "Character"
require "Logging"
require "Navigation"
require "UINav"
require "Utils"

function IsGathering()
  return GetCharacterCondition(6)
end

function IsFishingWaiting()
  return GetCharacterCondition(43) and not GetCharacterCondition(42)
end

function IsInCutScene()
  return GetCharacterCondition(35)
end

function GetTimeToNextBoat(offset)
  offset = offset or 0
  local interval = 2 * 60 * 60
  local dt = os.date("*t")
  local hour = tonumber(dt.hour)
  local min = tonumber(dt.min)
  local sec = tonumber(dt.sec)
  if not hour or not min or not sec then return nil end
  local time_past = 60 * (60 * math.fmod(hour, 2) + min) + sec + offset
  return interval - math.fmod(time_past, interval)
end

function GoToOceanFishing()
  if not IsInLimsa() or GetDistanceToObject("Dryskthota") > 100 then
    TeleportToLimsa()
    yield("/li Arcanists")
    yield("/wait 3")
    WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
  end
  NavToObject("Dryskthota", 3, false, 30)
end

function BuyOceanFishingBaitAndRepair()
  local oceanBuyBait = {
    [0] = 29714,
    [1] = 29715,
    [2] = 29716,
  }

  if not NavToObject("Merchant & Mender", 3, false, 10) then return end

  if not InteractWith("Merchant & Mender", "SelectIconString") then return end
  Callback("SelectIconString", true, 0)
  if AwaitAddonReady("Shop", 3) then
    for i, id in pairs(oceanBuyBait) do
      while GetItemCount(id) < 200 do
        local last_count = GetItemCount(id)
        Callback("Shop", true, 0, i, 99)
        Callback("Shop", true, 7, i)
        if AwaitAddonReady("SelectYesno", 1) then
          Callback("SelectYesno", true, 0)
          AwaitAddonGone("SelectYesno", 1)
          WaitWhile(function () return GetItemCount(id) == last_count end, 1)
        end
      end
    end
    Callback("Shop", true, -1)
    AwaitAddonGone("Shop", 1)
  end
  WaitForNavReady()

  if not InteractWith("Merchant & Mender", "SelectIconString") then return end
  Callback("SelectIconString", true, 1)
  if AwaitAddonReady("Repair", 3) then
    Callback("Repair", true, 0)
    if AwaitAddonReady("SelectYesno", 2) then
      Callback("SelectYesno", true, 0)
      AwaitAddonGone("SelectYesno", 1)
    end
    Callback("Repair", true, -1)
    AwaitAddonGone("Repair", 1)
  end
  WaitForNavReady()
end

function DoOceanFishing()
  local oceanMapBait = {
    ["Galadion Bay"] = 29716,
    ["Rhotano Sea"] = 29716,
    ["The Ciedalaes"] = 29714,
    ["The Bloodbrine Sea"] = 29715,
    ["Rothlyt Sound"] = 29716,
    ["The Northern Strait of Merlthor"] = 29714,
    ["The Southern Strait of Merlthor"] = 29715,
  }

  WaitForNavReady()
  NavToPoint(7, 7, -6, 0.5, false, 60)

  local bait = oceanMapBait[GetNodeText("IKDFishingLog", 20)]
  if bait then
    repeat yield("/bait "..GetItemName(bait)) until WaitUntil(function () return GetCurrentBait() == bait end, 1)
  end

  SetAutoHookState(true)
  repeat yield("/ac cast") until WaitUntil(IsFishingWaiting, 0.5)
  WaitWhile(IsGathering, 420, 1)
  SetAutoHookState(false)
end

function GetFishingZoneTimeLeft()
  if not IsAddonReady("IKDFishingLog") then return 0 end
  local time_text = GetNodeText("IKDFishingLog", 18)
  if StringIsEmpty(time_text) then return 0 end
  local colon_index, _ = string.find(time_text, ":")
  if not colon_index or colon_index <= 1 then return 0 end
  local minute = tonumber(string.sub(time_text, 1, colon_index - 1)) or 0
  local second = tonumber(string.sub(time_text, colon_index + 1, string.len(time_text))) or 0
  return minute * 60 + second
end

function DoOceanFishingRoute()
  local function isBetweenFishingZones()
    if IsAddonReady("IKDResult") then return false end
    if IsInCutScene() or not IsPlayerAvailable() or not IsAddonReady("IKDFishingLog") then
      return true
    end
    if GetFishingZoneTimeLeft() < 40 then return true end
    return false
  end

  WaitUntil(function () return GetZoneID() == 900 end, 200)
  while true do
    if not WaitWhile(isBetweenFishingZones, 100, 1) then return end
    if IsAddonReady("IKDResult") then
      repeat Callback("IKDResult", true, -1) until AwaitAddonGone("IKDResult", 1)
      WaitWhile(function () return IsInCutScene() or not IsPlayerAvailable() end, 60)
      WaitForNavReady()
      return
    end
    DoOceanFishing()
  end
end

function IsTimeToGoFish(offset, pre_threshold, end_buffer)
  pre_threshold = pre_threshold or 0
  end_buffer = end_buffer or 0
  local time = GetTimeToNextBoat(offset)
  return time < pre_threshold or time > (105) * 60 + end_buffer
end

function GoDoOceanFishing(food, offset)
  if GetClassJobId() ~= 18 then return end

  GoToOceanFishing()
  EquipRecommendedGear()
  BuyOceanFishingBaitAndRepair()

  NavToObject("Dryskthota", 3, false, 10)
  WaitUntil(function () local time = GetTimeToNextBoat(offset) return time > 105 * 60 + 5 and time < 120 * 60 - 5 end)

  InteractWith("Dryskthota", "SelectString")
  Callback("SelectString", true, 0)
  if not AwaitAddonReady("SelectYesno", 3) then return end
  repeat
    Callback("SelectYesno", true, 0)
  until AwaitAddonGone("SelectYesno", 1)

  if food then
    yield("/wait 1")
    yield("/item "..GetItemName(food))
    yield("/item "..GetItemName(food))
  end

  if not AwaitAddonReady("ContentsFinderConfirm", 16 * 60) then return end
  Callback("ContentsFinderConfirm", true, 8)

  DoOceanFishingRoute()
end
