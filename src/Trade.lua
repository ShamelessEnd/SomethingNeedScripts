require "Callback"
require "FreeCompany"
require "Inventory"
require "Logging"
require "Navigation"
require "UINav"
require "Utils"

function TradeGilTo(target, trade_gil)
  if trade_gil <= 0 then return 0 end

  Logging.Info("trading "..trade_gil.." to "..target)
  local end_gil = GetItemCount(1) - trade_gil

  if not NavToTarget(target, 2, false, 10) then
    Logging.Error("failed to find target "..target)
    return 0
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
  return trade_gil
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
  TradeCeruleumStacks(5)
end

function TradeCeruleumStacks(stacks, max_only)
  stacks = math.min(stacks, 5)
  local inventory = FindItemsInCharacterInventory()
  local item_stacks = inventory[10155] or {}
  local stack_count = 0
  for _, stack in pairs(item_stacks) do
    if stack.count >= 999 or not max_only then
      if not TradeItemFromSlot(stack) then return end
      stack_count = stack_count + 1
    end
    if stack_count >= stacks then break end
  end
  if stack_count <= 0 then
    Logging.Error("no ceruleum to trade")
    CallbackTimeout(2, "Trade", true, -1)
    return false
  elseif not CallbackTimeout(2, "Trade", true, 0) then
    Logging.Error("failed to trade - trade window closed")
    return false
  end
  return AwaitAddonGone("Trade", 5)
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

function GoTradeAllGilTo(target, server, limit)
  NavToGridaniaTrade(server)

  local start_gil = GetItemCount(1)
  local trade_gil = math.min((math.floor(start_gil / 1000000) - 1) * 1000000, limit)
  local traded_gil = TradeGilTo(target, trade_gil)

  ReturnToFC()
  return traded_gil
end

function GoTradeCeruleumStacksTo(target, server, stacks)
  if not stacks or stacks <= 0 then return false end

  local start_ceruleum = GetItemCount(10155)
  if start_ceruleum < stacks * 999 then
    Logging.Error("not enough ceruleum to trade")
    return false
  end

  NavToGridaniaTrade(server)

  if not NavToTarget(target, 2, false, 10) then
    Logging.Error("failed to find target "..target)
  else
    yield("/wait 0.2")
    while stacks > 0 do
      while not IsAddonReady("Trade") do
        yield("/trade")
        yield("/wait 0.2")
      end
      local to_trade = math.min(stacks, 5)
      if not TradeCeruleumStacks(to_trade, true) then
        while not AwaitAddonGone("Trade", 1) do Callback("Trade", true, -1) end
        break
      end
      stacks = stacks - to_trade
    end
  end

  ReturnToFC()
  return stacks <= 0
end

function GoFetchCeruleumFrom(target, server, min_tanks, password)
  NavToGridaniaTrade(server)

  Logging.Info("trading ceruleum from "..target)
  if NavToTarget(target, 2, false, 10) then
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
  local MAX_TRADED_GIL = 900000000
  local traded_gil = 0
  local function goCollect(cid)
    traded_gil = traded_gil + GoTradeAllGilTo(target, target_server_data.name, MAX_TRADED_GIL - traded_gil)
  end
  local function collectIf(cid)
    if traded_gil >= MAX_TRADED_GIL then return false end
    local data = GetARCharacterData(cid)
    if TableContains(exclude, cid) then return false end
    if not data or data.Gil < 5000000 then return false end
    local server_data = FindServerData(data.World)
    if not server_data or server_data.dc ~= target_server_data.dc then return false end
    return true
  end

  ARApplyToAllCharacters(cids, goCollect, collectIf)

  Logging.Notify("gil collection complete")
  Logging.Echo("total gil collected: "..traded_gil)
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

function TopUpCeruleumTanks(target, server, exclude, password, thresholds)
  if not thresholds then thresholds = { min_tanks = 4996, buy_stacks = 5 } end

  local target_server_data = FindServerData(server)
  if not target_server_data then return end

  local cids = ARGetCharacterCIDs()
  local cids_need_tanks = {}
  local cids_retainer_char = {}
  for i = 0, cids.Count - 1 do
    local cid = cids[i]
    local data = ARGetCharacterData(cid)
    if data then
      local server_data = FindServerData(data.World)
      if server_data and server_data.dc == target_server_data.dc and not TableContains(exclude, cid) then
        -- limit to max 120 stacks for target inventory
        if data.Ceruleum < thresholds.min_tanks and TableSize(cids_need_tanks) < math.floor(120 / thresholds.buy_stacks) then
            table.insert(cids_need_tanks, cid)
        end
        if data.Enabled == true then
          table.insert(cids_retainer_char, cid)
        end
      end
    end
  end

  local tanks_stacks_needed = TableSize(cids_need_tanks) * thresholds.buy_stacks
  local function goBuyTanks()
    local bought = GoBuyCeruleumTanks(tanks_stacks_needed)
    if not bought then
      Logging.Error("failed to buy tanks")
      return
    elseif bought == 0 then
      Logging.Info("not enough credits to buy tanks")
      return
    end
    if GoTradeCeruleumStacksTo(target, server, bought) then
      tanks_stacks_needed = tanks_stacks_needed - bought
    else
      Logging.Error("failed to trade tanks to target")
      return
    end
  end
  local function buyTanksIf() return tanks_stacks_needed > 0 end
  ARApplyToAllCharacters(cids_retainer_char, goBuyTanks, buyTanksIf)

  local function goCollectTanks() GoFetchCeruleumFrom(target, server, GetItemCount(10155) + (999 * thresholds.buy_stacks), password) end
  ARApplyToAllCharacters(cids_need_tanks, goCollectTanks)
end
