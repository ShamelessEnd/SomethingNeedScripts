
function IsInHousingDistrict()
  return IsInZone(341) or IsInZone(340) or IsInZone(339) or IsInZone(641) or IsInZone(979);
end

function TeleportToBellZone()
  if GetHomeWorld() == 78 then
    -- Behemoth override
    yield("/li Apartment")
    yield("/wait 7")
    return
  end
  yield("/li fc")
  yield("/wait 1")
  if LifestreamIsBusy() == false then
    -- fallback to limsa hawkers
    LifestreamTeleport(8, 0)
    yield("/wait 7")
  end
end

function ReturnToBell()
  TeleportToBellZone()
  timeout = 0
  while LifestreamIsBusy() == true or (IsInZone(129) == false and IsInHousingDistrict() == false) or NavIsReady() == false or IsPlayerAvailable() == false do
    yield("/wait 1")
    timeout = timeout + 1
    if timeout == 18 then
      LifestreamAbort()
      yield("/wait 1")
      TeleportToBellZone()
    end
    if timeout > 36 then
      LifestreamAbort()
      return
    end
  end
  yield("/wait 1")
  if IsInZone(129) then
    yield("/li hawkers")
    yield("/wait 5")
    while LifestreamIsBusy() == true do
      yield("/wait 1")
    end
  end
  if IsInHousingDistrict() == false or GetDistanceToObject("Apartment Building Entrance") < 20 then
    -- walk to bell if at hawkers or apartment
    yield("/runmacro WalkToBell")
  end
end


ReturnToBell()
