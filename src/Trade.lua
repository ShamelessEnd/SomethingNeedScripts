require "Logging"
require "Navigation"
require "Utils"

function TradeGilTo(target, trade_gil)
  Logging.Info("trading "..trade_gil.." to "..target)
  local end_gil = GetItemCount(1) - trade_gil

  Target(target)
  yield("/vnav movetarget")
  yield("/wait 5")

  while (GetItemCount(1) > end_gil) do
    while not IsAddonReady("Trade") do
      yield("/trade")
      yield("/wait 0.1")
    end
    Callback("Trade", true, 2)
    if AwaitAddonReady("InputNumeric", 2) then
      Callback("InputNumeric", true, 1000000)
      if AwaitAddonGone("InputNumeric", 2) then
        Callback("Trade", true, 0)
      end
    end
    while not AwaitAddonGone("Trade", 5) do
      Callback("Trade", true, -1)
    end
  end
end

function GoTradeAllGilTo(target, server)
  yield("/li "..server)
  yield("/wait 1")
  WaitWhile(function () return LifestreamIsBusy() end)
  WaitForNavReady()

  if not IsInZone(132) then
    yield("/tp Gridania")
    yield("/wait 7")
    WaitForNavReady()
  end

  yield("/wait 3")

  local start_gil = GetItemCount(1)
  local trade_gil = (math.floor(start_gil / 1000000) - 1) * 1000000
  if trade_gil > 0 then
    TradeGilTo(target, trade_gil)
  end

  ReturnToFC()
end

function CollectGilTo(target, server)
  local target_server_data = FindServerData(server)
  if not target_server_data then return end

  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    local data = ARGetCharacterData(cid)
    if data and data.Gil > 10000000 then
      local server_data = FindServerData(data.World)
      if server_data and server_data.dc == target_server_data.dc then
        ARRelogTo(cid)
        GoTradeAllGilTo(target, target_server_data.name)
      end
    end
  end

  Logging.Notify("gil collection complete")
end
