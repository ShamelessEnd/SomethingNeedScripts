require "Callback"
require "Inventory"
require "Logging"
require "Navigation"
require "UINav"
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

function TradeItemFromSlot(stack)
  if not CallbackTimeout(2, "InventoryExpansion", true, 12, 48 + stack.page, stack.slot) then
    Logging.Error("failed to trade - inventory not open")
    return false
  end
  if AwaitAddonReady("InputNumeric", 2) then
    CallbackTimeout(2, "InputNumeric", true, stack.count)
    AwaitAddonGone("InputNumeric", 2)
  end
  yield("/wait 0.1")
  return true
end

-- call from OnChatMessage triggered macro
function TradeCeruleumOnTellMessage(password)
  if not TriggerData then return end
  if tostring(TriggerData.type) ~= "TellIncoming: 13" then return end
  if password and tostring(TriggerData.message) ~= password then return end
  if not IsAddonReady("Trade") then return end

  Logging.Echo("ceruleum trade request from "..tostring(TriggerData.sender))

  local inventory = FindItemsInCharacterInventory()
  local item_stacks = inventory[10155] or {}
  local stack_count = 0
  for _, stack in pairs(item_stacks) do
    if not TradeItemFromSlot(stack) then return end
    stack_count = stack_count + 1
    if stack_count >= 5 then break end
  end
  if stack_count <= 0 then
    Logging.Error("no ceruleum to trade")
    CallbackTimeout(2, "Trade", true, -1)
  elseif not CallbackTimeout(2, "Trade", true, 0) then
    Logging.Error("failed to trade - trade window closed")
  end
end

function TradeCeruleumOnceFromTarget(password)
  local start_count = GetItemCount(10155)
  yield("/wait 0.2")
  while not IsAddonReady("Trade") do
    yield("/trade")
    yield("/wait 0.5")
  end
  repeat
    if password then yield("/t <t> "..password) end
  until AwaitAddonGone("Trade", 8)
  return WaitUntil(function () return GetItemCount(10155) > start_count end, 3)
end

function NavToGridaniaTrade(server)
  LifestreamTo(server)

  if not IsInZone(132) then
    TeleportToGridania()
  end

  yield("/wait 1")
end

function GoTradeAllGilTo(target, server)
  NavToGridaniaTrade(server)

  local start_gil = GetItemCount(1)
  local trade_gil = (math.floor(start_gil / 1000000) - 1) * 1000000
  TradeGilTo(target, trade_gil)

  ReturnToFC()
end

function GoFetchCeruleumFrom(target, server, min_tanks, password)
  NavToGridaniaTrade(server)

  Logging.Info("trading ceruleum from "..target)
  if NavToTarget(target, 2, false, 5) then
    repeat
      if not TradeCeruleumOnceFromTarget(password) then break end
    until GetItemCount(10155) >= min_tanks
  else
    Logging.Error("failed to find target "..target)
  end

  ReturnToFC()
end

function CollectGilTo(target, server, exclude)
  local target_server_data = FindServerData(server)
  if not target_server_data then return end

  local cids = ARGetCharacterCIDs()
  local function goCollect(cid) GoTradeAllGilTo(target, target_server_data.name) end
  local function collectIf(cid)
    local data = GetARCharacterData(cid)
    if TableContains(exclude, cid) then return false end
    if not data or data.Gil < 5000000 then return false end
    local server_data = FindServerData(data.World)
    if not server_data or server_data.dc ~= target_server_data.dc then return false end
    return true
  end

  ARApplyToAllCharacters(cids, goCollect, collectIf)

  Logging.Notify("gil collection complete")
end

function CollectCeruleumFrom(target, server, exclude, password)
  local target_server_data = FindServerData(server)
  if not target_server_data then return end

  local cids = ARGetCharacterCIDs()
  local function goCollect(cid)
    GoFetchCeruleumFrom(target, target_server_data.name, 5000, password)
  end
  local function collectIf(cid)
    local data = GetARCharacterData(cid)
    if TableContains(exclude, cid) then return false end
    if not data or data.Ceruleum >= 1000 then return false end
    local server_data = FindServerData(data.World)
    if not server_data or server_data.dc ~= target_server_data.dc then return false end
    return true
  end

  ARApplyToAllCharacters(cids, goCollect, collectIf)

  Logging.Notify("ceruleum collection complete")
end
