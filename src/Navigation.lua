require "Logging"

local _apartment_bell_overrides = { 78 } -- Behemoth
function SetApartmentBellOverrides(overrides) _apartment_bell_overrides = overrides end

function IsInHousingDistrict()
  return IsInZone(341) or IsInZone(340) or IsInZone(339) or IsInZone(641) or IsInZone(979)
end

function IsInGCTown()
  return (GetPlayerGC() == 1 and IsInZone(129)) or (GetPlayerGC() == 2 and IsInZone(132)) or (GetPlayerGC() == 3 and IsInZone(130))
end

function IsInCompanyWorkshop()
  return IsInZone(423) or IsInZone(424) or IsInZone(425) or IsInZone(653) or IsInZone(984);
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

function TeleportToBellZone()
  local home_world = GetHomeWorld()
  for _, world in pairs(_apartment_bell_overrides) do
    if home_world == world then
      yield("/li Apartment")
      yield("/wait 7")
      return
    end
  end
  yield("/li fc")
  yield("/wait 1")
  if LifestreamIsBusy() == false then
    LogInfo("no registered fc or override, falling back to Hawkers")
    LifestreamTeleport(8, 0)
    yield("/wait 7")
  end
end

function ReturnToBell()
  TeleportToBellZone()
  local timeout = 0
  while LifestreamIsBusy() == true or (IsInZone(129) == false and IsInHousingDistrict() == false) or NavIsReady() == false or IsPlayerAvailable() == false do
    yield("/wait 1")
    timeout = timeout + 1
    if timeout == 18 then
      LogWarning("teleport to bell zone timed out, retrying")
      LifestreamAbort()
      yield("/wait 1")
      TeleportToBellZone()
    end
    if timeout > 36 then
      LogError("failed to teleport to bell zone")
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
    WalkToTarget("Summoning Bell")
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

  ExecuteGeneralAction(4) -- sprint
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
