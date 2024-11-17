
function IsInGCTown()
  return (GetPlayerGC() == 1 and IsInZone(129)) or (GetPlayerGC() == 2 and IsInZone(132)) or (GetPlayerGC() == 3 and IsInZone(130));
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


GoToGCHQ()
