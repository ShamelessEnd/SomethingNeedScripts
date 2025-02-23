require "ARUtils"
require "Logging"
require "Utils"

function IsInHousingDistrict()
  return IsInZone(341) or IsInZone(340) or IsInZone(339) or IsInZone(641) or IsInZone(979)
end

function IsInGCTown()
  return (GetPlayerGC() == 1 and IsInZone(129)) or (GetPlayerGC() == 2 and IsInZone(132)) or (GetPlayerGC() == 3 and IsInZone(130))
end

function IsInCompanyWorkshop()
  return IsInZone(423) or IsInZone(424) or IsInZone(425) or IsInZone(653) or IsInZone(984);
end

function IsInLimsa()
  return IsInZone(129)
end

function TeleportToLimsa()
  LifestreamTeleport(8, 0)
  yield("/wait 7")
  WaitForNavReady()
end

function IsInHomeWorld()
  return GetCurrentWorld() == GetHomeWorld()
end

function WaitForNavReady()
  WaitUntil(function () return NavIsReady() and IsPlayerAvailable() end)
end

function RebuildNavMesh()
  NavRebuild()
  yield("/wait 3")
  WaitUntil(function () return NavBuildProgress() < 0 end)
end

function WalkToTarget(target)
  yield("/target "..target)
  if GetTargetName() ~= target then
    return false
  end
  if GetDistanceToTarget() > 20 then
    return false
  end
  if GetDistanceToTarget() > 3 then
    yield("/facetarget")
    yield("/lockon on")
    yield("/automove on")
    yield("/lockon off")
    local timeout = 0
    while GetDistanceToTarget() > 1 do
      timeout = timeout + 1
      if timeout > 300 then
        break
      end
      yield("/wait 0.1")
    end
    yield("/automove off")
  end
  yield("/wait 0.1")
end

function NavToPoint(x, y, z, stop_dist, fly, timeout)
  local distance = GetDistanceToPoint(x, y, z)
  if distance <= stop_dist then
    return true
  end

  PathfindAndMoveTo(x, y, z, fly)
  yield("/wait 0.3")
  WaitWhile(function () return PathfindInProgress() end)

  if distance > 20 then Sprint() end

  local timeout_count = 0
  local rebuild_once = true
  while GetDistanceToPoint(x, y, z) > stop_dist do
    if timeout_count > timeout then
      PathStop()
      Logging.Warning("nav to point failed "..x..", "..y..", "..z)
      return false
    end
    if rebuild_once and timeout_count > 1 and not PathIsRunning() then
      RebuildNavMesh()
      rebuild_once = false
      PathfindAndMoveTo(x, y, z, fly)
    end
    timeout_count = timeout_count + 0.1
    yield("/wait 0.1")
  end

  PathStop()
  return true
end

function NavToTarget(target, stop_dist, fly, timeout)
  yield("/target "..target)
  if GetTargetName() ~= target then
    return false
  end

  WaitForNavReady()
  local x = GetTargetRawXPos()
  local y = GetTargetRawYPos()
  local z = GetTargetRawZPos()

  if not NavToPoint(x, y, z, stop_dist, fly, timeout) then
    return false
  end

  yield("/target "..target)
  return GetTargetName() == target
end

function NavToObject(object, stop_dist, fly, timeout)
  if not GetDistanceToObject(object) then
    return false
  end

  WaitForNavReady()
  local x = GetObjectRawXPos(object)
  local y = GetObjectRawYPos(object)
  local z = GetObjectRawZPos(object)

  if not NavToPoint(x, y, z, stop_dist, fly, timeout) then
    return false
  end

  yield("/target "..object)
  return true
end

function NavToMarketBoard()
  if NavToObject("Market Board", 3.3, false, 30) then
    return true
  end
  ReturnToBell()
  RebuildNavMesh()
  return NavToObject("Market Board", 3.3, false, 30)
end

function NavToAetheryte()
  return NavToTarget("aetheryte", 10, false, 9)
end

function InteractWithAetheryte()
  return InteractWith("aetheryte", "SelectString", 11.165)
end

function WorldVisitTo(server_name)
  if not NavToAetheryte() then
    TeleportToLimsa()
    if not NavToAetheryte() then
      Logging.Error("failed to nav to aetheryte")
      return false
    end
  end

  if not InteractWithAetheryte() then
    Logging.Error("failed to interact with aetheryte")
    return false
  end
  Callback("SelectString", true, 2)
  AwaitAddonReady("WorldTravelSelect")

  local curr_world = ""
  repeat
    yield("/wait 0.1")
    curr_world = GetNodeText("WorldTravelSelect", 7)
  until not StringIsEmpty(curr_world)
  if curr_world == server_name then
    Logging.Info("already on "..server_name)
    CloseAddon("WorldTravelSelect")
    return true
  end

  local dest_index = 3
  local dest_name = ""
  repeat
    yield("/wait 0.1")
    dest_name = GetNodeText("WorldTravelSelect", 4, dest_index, 4)
  until not StringIsEmpty(dest_name)

  local function doTravelToWorld(index)
    local start_world = GetCurrentWorld()
  
    Callback("WorldTravelSelect", true, index)
    AwaitAddonReady("SelectYesno")
    Callback("SelectYesno", true, 0)
  
    local same_world = function () return GetCurrentWorld() == start_world end
    if not WaitWhile(same_world, 600) then return false end
    WaitForNavReady()
    return true
  end

  repeat
    if dest_name == server_name then
      Logging.Debug("travelling to world "..server_name)
      return doTravelToWorld(dest_index - 1)
    end
    dest_index = dest_index + 1
    dest_name = GetNodeText("WorldTravelSelect", 4, dest_index, 4)
  until StringIsEmpty(dest_name)

  Logging.Error("failed to find server in list "..server_name)
  return false
end

function DCTravelTo(region, dc_name)
  if GetServerData().dc == dc_name then
    return true
  end

  LifestreamExecuteCommand(dc_name)

  local dest_servers = ServerNavTable[region][dc_name]
  local arrived = function () return not LifestreamIsBusy() and dest_servers[GetCurrentWorld()] end
  if not WaitUntil(arrived, 900, 1) then return false end
  WaitForNavReady()
  return true
end

function ReturnToHomeWorld()
  if IsInHomeWorld() then
    return true
  end

  local current_data = GetServerData()
  local home_data = GetHomeServerData()

  if current_data.dc == home_data.dc and WorldVisitTo(home_data.name) then
    return true
  end

  LifestreamExecuteCommand(home_data.name)
  local arrived = function () return not LifestreamIsBusy() and GetCurrentWorld() == home_data.id end
  if not WaitUntil(arrived, 900, 1) then return false end
  WaitForNavReady()
  return true
end

function TeleportToBellZone()
  if GetARCharacterData().WorkshopEnabled then
    LifestreamTeleportToFC()
    yield("/wait 7")
    return
  end

  local apt_dist = GetDistanceToObject("Apartment Building Entrance")
  if apt_dist ~= nil and apt_dist < 20 then
    return
  end

  LifestreamTeleportToApartment()
  yield("/wait 3")

  if not IsCasting() then
    Logging.Info("no registered fc or apartment, falling back to Hawkers")
    TeleportToLimsa()
  else
    yield("/wait 5")
  end
end

function ReturnToFC()
  LifestreamTeleportToFC()
  yield("/wait 7")
  WaitWhile(LifestreamIsBusy)
end

function ReturnToBell()
  if not ReturnToHomeWorld() then
    Logging.Error("failed to return to home world")
    return
  end

  local bell_target = "Summoning Bell"
  local bell_dist = GetDistanceToObject(bell_target)
  if bell_dist ~= nil and bell_dist < 3 then
    yield("/target "..bell_target)
    return
  end

  TeleportToBellZone()
  local timeout = 0
  while LifestreamIsBusy() == true or (IsInZone(129) == false and IsInHousingDistrict() == false) or NavIsReady() == false or IsPlayerAvailable() == false do
    yield("/wait 1")
    timeout = timeout + 1
    if timeout == 18 then
      Logging.Warning("teleport to bell zone timed out, retrying")
      LifestreamAbort()
      yield("/wait 1")
      TeleportToBellZone()
    end
    if timeout > 36 then
      Logging.Error("failed to teleport to bell zone")
      LifestreamAbort()
      return
    end
  end
  yield("/wait 1")
  if IsInZone(129) then
    yield("/li hawkers")
    yield("/wait 3")
    while LifestreamIsBusy() == true or NavIsReady() == false or IsPlayerAvailable() == false or GetTargetName() == "Aetheryte" do
      yield("/wait 0.1")
    end
    yield("/wait 1")
  end
  if IsInHousingDistrict() == false or GetDistanceToObject("Apartment Building Entrance") < 20 then
    -- walk to bell if at hawkers or apartment
    WalkToTarget(bell_target)
  end
end

function GoToGCHQ()
  yield("/li gc")
  yield("/wait 7")
  local timeout = 0
  while IsInGCTown() == false or NavIsReady() == false or IsPlayerAvailable() == false do
    yield("/wait 1")
    timeout = timeout + 1
    if timeout == 13 and IsInGCTown() == false then
      LifestreamAbort()
      yield("/li gc")
      yield("/wait 7")
    elseif timeout > 26 then
      LifestreamAbort()
      return
    end
  end

  Sprint()
  timeout = 0
  while LifestreamIsBusy() == true do
    yield("/wait 1")
    timeout = timeout + 1
    if timeout == 60 then
      LifestreamAbort()
      return
    end
  end
end
