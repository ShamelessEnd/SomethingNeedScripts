
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
  yield("/runmacro GoToGCHQ")
  yield("/deliveroo enable")
  yield("/wait 3")
  local dellyroo = true
  local timeout = 0
  while dellyroo do
    dellyroo = DeliverooIsTurnInRunning()
    yield("/wait 1")
    if timeout == 1000 then
      BailGCTurnIn()
      yield("/wait 2")
      return
    end
    timeout = timeout + 1
  end
  yield("/wait 2")
end


GCTurnIn()
