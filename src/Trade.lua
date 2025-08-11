require "Logging"
require "Navigation"
require "Utils"

function TradeGilTo(target, trade_gil)
  if trade_gil <= 0 then return end

  Logging.Info("trading "..trade_gil.." to "..target)
  local end_gil = GetItemCount(1) - trade_gil

  if not NavToTarget(target, 2, false, 5) then
    Logging.Error("failed to find target "..target)
    return
  end

  yield("/wait 0.2")
  while (GetItemCount(1) > end_gil) do
    while not IsAddonReady("Trade") do
      yield("/trade")
      yield("/wait 0.2")
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

  yield("/wait 1")

  local start_gil = GetItemCount(1)
  local trade_gil = (math.floor(start_gil / 1000000) - 1) * 1000000
  TradeGilTo(target, trade_gil)

  ReturnToFC()
end

function CollectGilTo(target, server, exclude)
  local target_server_data = FindServerData(server)
  if not target_server_data then return end

  local chars = ARGetCharacterCIDs()
  for i = 0, chars.Count - 1 do
    local cid = chars[i]
    if not TableContains(exclude, cid) then
      local data = GetARCharacterData(cid)
      if data and data.Gil > 5000000 then
        local server_data = FindServerData(data.World)
        if server_data and server_data.dc == target_server_data.dc then
          ARRelogTo(cid)
          GoTradeAllGilTo(target, target_server_data.name)
        end
      end
    end
  end

  Logging.Notify("gil collection complete")
end
