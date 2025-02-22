require "ARUtils"
require "Logging"
require "Utils"

function Sprint() ExecuteGeneralAction(4) end

function IsInHousingDistrict()
  return IsInZone(341) or IsInZone(340) or IsInZone(339) or IsInZone(641) or IsInZone(979)
end

function IsInGCTown()
  return (GetPlayerGC() == 1 and IsInZone(129)) or (GetPlayerGC() == 2 and IsInZone(132)) or (GetPlayerGC() == 3 and IsInZone(130))
end

function IsInCompanyWorkshop()
  return IsInZone(423) or IsInZone(424) or IsInZone(425) or IsInZone(653) or IsInZone(984);
end

function WaitForNavReady()
  while not NavIsReady() do
    yield("/wait 0.1")
  end
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

function NavigateToTarget(target, stop_dist, fly, timeout)
  yield("/target "..target)
  if GetTargetName() ~= target then
    return false
  end

  WaitForNavReady()
  local target_x = GetTargetRawXPos()
  local target_y = GetTargetRawYPos()
  local target_z = GetTargetRawZPos()
  PathfindAndMoveTo(target_x, target_y, target_z, fly)
  Sprint()

  local timeout_count = 0
  while GetDistanceToPoint(target_x, target_y, target_z) > stop_dist do
    if timeout_count > timeout then
      PathStop()
      return false
    end
    timeout_count = timeout_count + 0.1
    yield("/wait 0.1")
  end

  PathStop()
  yield("/target "..target)
  return GetTargetName() == target
end

function GoToMarketBoard()
  if IsInCompanyWorkshop() then
    ReturnToBell()
  end
  if NavigateToTarget("Market Board", 3, false, 20) then
    return true
  end
  ReturnToBell()
  NavRebuild()
  return NavigateToTarget("Market Board", 3, false, 30)
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
    LifestreamTeleport(8, 0)
    yield("/wait 7")
  else
    yield("/wait 5")
  end
end

function ReturnToBell()
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
