require "ARUtils"
require "Logging"
require "ServerData"
require "UINav"
require "Utils"

function IsNavAvailable()
  return IPC.IsInstalled("vnavmesh") and IPC.IsInstalled("Lifestream")
end

function IsInHousingDistrict()
  return IsInZone(341) or IsInZone(340) or IsInZone(339) or IsInZone(641) or IsInZone(979)
end

function IsInGCTown()
  return (GetPlayerGC() == 1 and IsInZone(129)) or (GetPlayerGC() == 2 and IsInZone(132)) or (GetPlayerGC() == 3 and IsInZone(130))
end

function IsInTown()
  return IsInZone(129) or IsInZone(132) or IsInZone(130)
end

function IsInCompanyWorkshop()
  return IsInZone(423) or IsInZone(424) or IsInZone(425) or IsInZone(653) or IsInZone(984);
end

function IsInLimsa()
  return IsInZone(129)
end

function IsInHomeWorld()
  return GetCurrentWorld() == GetHomeWorld()
end

function TeleportToAetheryte(aetheryte)
  if IsAetheryteUnlocked(aetheryte) then
    LifestreamTeleport(aetheryte, 0)
    yield("/wait 7")
    WaitForNavReady()
    return true
  end
  return false
end

function TeleportToLimsa() TeleportToAetheryte(8) end

function TeleportToGridania() TeleportToAetheryte(2) end

function TeleportToUldah() TeleportToAetheryte(9) end

function TeleportToZone(zone)
  local aetherytes = GetAetherytesInZone(zone)
  for _, aetheryte in pairs(aetherytes) do
    if TeleportToAetheryte(aetheryte) then
      return true
    end
  end
  return false
end

function LifestreamTo(dest)
  yield("/li "..dest)
  yield("/wait 1")
  WaitWhile(function () return LifestreamIsBusy() end)
  WaitForNavReady()
end

function DoReturn()
  yield("/ac return")
  if AwaitAddonReady("SelectYesno", 5) then
    Callback("SelectYesno", true, 0)
    yield("/wait 7")
    WaitForNavReady()
    return true
  end
  return false
end

function RebuildNavMesh()
  NavRebuild()
  yield("/wait 3")
  WaitUntil(function () return NavBuildProgress() < 0 end)
end

function WalkToTarget(target, dist, timeout)
  dist = dist or 3
  if not Target(target) then
    return false
  end
  if GetDistanceToTarget() > 50 then
    return false
  end
  if GetDistanceToTarget() > dist then
    yield("/facetarget")
    yield("/lockon on")
    yield("/automove on")
    yield("/lockon off")
    if not WaitWhile(function () return GetDistanceToTarget() > dist end, timeout or 300) then
      yield("/automove off")
      return false
    end
    yield("/automove off")
  end
  yield("/wait 0.1")
  return true
end

function PathToNearestGroundPoint(x_t, y_t, z_t)
  local x_g
  local y_g
  local z_g
  local extent = 0
  While(
    function ()
      local vec_g = IPC.vnavmesh.PointOnFloor(Vector3(x_t, y_t, z_t), false, extent)
      x_g = vec_g.X
      y_g = vec_g.Y
      z_g = vec_g.Z
      extent = extent + 1
    end,
    function () return not x_g or not y_g or not z_g end
  )

  PathfindAndMoveTo(x_g, y_g, z_g, false)
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
      if rebuild_once then
        timeout_count = 2
      else
        Logging.Warning("nav to point failed "..x..", "..y..", "..z)
        return false
      end
    end
    if rebuild_once and timeout_count > 1 and not PathIsRunning() then
      Logging.Warning("nav to point timed out, rebuilding navmesh")
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
  if not Target(target) then
    return false
  end

  WaitForNavReady()
  local x = GetTargetRawXPos()
  local y = GetTargetRawYPos()
  local z = GetTargetRawZPos()

  if not NavToPoint(x, y, z, stop_dist, fly, timeout) then
    return false
  end

  return Target(target)
end

function NavToObject(object, stop_dist, fly, timeout)
  if not stop_dist then stop_dist = 4.597 end
  if fly == nil then fly = false end

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

  return Target(object)
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
  return NavToObject("aetheryte", 9, false, 15)
end

function InteractWithAetheryte()
  return InteractWith("aetheryte", "SelectString", 11.165)
end

function WorldVisitTo(server_name)
  if not IsInTown() or not NavToAetheryte() then
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
  if not SelectStringOption("Visit Another World Server") then
    Logging.Error("could not find world visit option")
    return false
  end
  AwaitAddonReady("WorldTravelSelect")

  local curr_world = ""
  repeat
    yield("/wait 0.1")
    curr_world = GetNewNodeText("WorldTravelSelect", 1, 8, 12)
  until not StringIsEmpty(curr_world)
  if curr_world == server_name then
    Logging.Info("already on "..server_name)
    CloseAddon("WorldTravelSelect")
    return true
  end

  local dest_name = ""
  repeat
    yield("/wait 0.1")
    dest_name = GetNewNodeText("WorldTravelSelect", 1, 14, 5, 4, 5)
  until not StringIsEmpty(dest_name)

  local function doTravelToWorld(index)
    local start_world = GetCurrentWorld()
  
    Callback("WorldTravelSelect", true, index)
    AwaitAddonReady("SelectYesno")
    Callback("SelectYesno", true, 0)

    local in_queue = function () return not IsAddonVisible("WorldTravelFinderReady") and not GetErrorText() end
    if not WaitWhile(in_queue, 600) then return false end
    if GetErrorText() then return nil end

    local same_world = function () return GetCurrentWorld() == start_world end
    if not WaitWhile(same_world, 60) then return false end
    WaitForNavReady()
    return true
  end

  local dest_index = 2
  repeat
    if dest_name == server_name then
      Logging.Debug("travelling to world "..server_name)
      return doTravelToWorld(dest_index)
    end
    dest_index = dest_index + 1
    dest_name = GetNewNodeText("WorldTravelSelect", 1, 14, GetNodeListIndex(dest_index - 2, 5), 4, 5)
  until StringIsEmpty(dest_name)

  Logging.Error("failed to find server in list "..server_name)
  return false
end

function DCTravelTo(region, dc_name)
  if GetServerData().dc == dc_name then
    return true
  end

  local dest_servers = ServerDataTable[region][dc_name]
  if not dest_servers then
    Logging.Error("invalid region.dc "..region.."."..dc_name)
    return false
  end

  Logging.Debug("travelling to dc "..dc_name.." ("..region..")")
  LifestreamExecuteCommand(dc_name)

  local arrived = function () return dest_servers[GetCurrentWorld()] end
  if not WaitUntil(arrived, 900, 0.5) then return false end
  LifestreamAbort() -- it might try to swap servers again if the one it randomly chose was congested
  Logging.Debug("arrived in world "..GetServerData().name)
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
    ReturnToFC()
    return
  end

  local apt_dist = GetDistanceToObject("Apartment Building Entrance")
  if IsInHousingDistrict() and apt_dist ~= nil and apt_dist < 20 then
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
  yield("/li fc")
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
    Target(bell_target)
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
    WaitWhile(function () return LifestreamIsBusy() == true or NavIsReady() == false or IsPlayerAvailable() == false or GetTargetName() == "Aetheryte" end)
    yield("/wait 1")
  end
  local apartmentDistance = GetDistanceToObject("Apartment Building Entrance")
  if IsInHousingDistrict() == false or (apartmentDistance and apartmentDistance < 50) then
    -- walk to bell if at hawkers or apartment
    WalkToTarget(bell_target, 2)
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
  if not WaitWhile(LifestreamIsBusy, 60, 1) then LifestreamAbort() end
end
