
function WalkToBell()
  yield("/target Summoning Bell")
  if GetTargetName() ~= "Summoning Bell" then
    return false
  end
  if GetDistanceToTarget() > 20 then
    return false
  end
  if GetDistanceToTarget() > 1 then
    yield("/facetarget")
    yield("/lockon on")
    yield("/automove on")
    yield("/lockon off")
    timeout = 0
    while GetDistanceToTarget() > 1 do
      timeout = timeout + 1
      if timeout > 300 then
        break
      end
      yield("/wait 0.1")
    end
    yield("/automove off")
  end
end


WalkToBell()
