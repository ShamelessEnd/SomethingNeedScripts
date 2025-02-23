require "Market"
require "Navigation"
require "ServerNav"

local _materia_table = {
  --   id, count, price
  { 41759,  7900,  4000 }, -- Crit 11
  { 41772,  1900, 12500 }, -- Crit 12
  { 41758, 12900,  4500 }, -- Dhit 11
  { 41771,  1900, 14500 }, -- Dhit 12
  { 41760,  7900,  4000 }, -- Det  11
  { 41773,  1900, 14000 }, -- Det  12
}
function GoPurchaseMateria(gil_floor) GoPurchaseAllItems(_materia_table, gil_floor) end

local _submarine_table = {
  --   id, count, price
  { 10373,   900,  3400 }, -- Repair Mats
}
function GoPurchaseSubRepairMats(gil_floor) GoPurchaseItems(_submarine_table, gil_floor) end

function ShouldBuyMarketItem(list_index, max_price, gil_floor)
  if not AwaitAddonReady("ItemSearchResult", 1) then
    Logging.Error("ItemSearchResult not open")
    return nil
  end

  local list_price = GetItemListingPrice(list_index)
  if list_price <= 0 then
    Logging.Error("failed to fetch listing price")
    return nil
  end
  if list_price > max_price then
    Logging.Trace("cant buy item: price "..list_price.." > "..max_price)
    return nil
  end

  local list_count = GetItemListingCount(list_index)
  if list_count <= 0 then
    Logging.Error("failed to fetch list count")
    return nil
  end

  if not gil_floor or gil_floor < 0 then gil_floor = 0 end
  if GetGil() - (list_price * list_count) < gil_floor then
    Logging.Info("insufficient gil to buy listing")
    return nil
  end

  Logging.Trace("can purchase "..list_count.." @ "..list_price)
  return list_count
end

function PurchaseItem(item_table, gil_floor)
  local item_id = item_table[1]
  local max_count  = item_table[2]
  local max_price  = item_table[3]

  local item_name = GetItemName(item_id)
  if type(item_name) ~= "string" or string.len(item_name) <= 0 then
    Logging.Error("failed to fetch item name "..item_id)
    return false
  end

  local search_index = FindMarketItem(item_name)
  if not search_index then
    Logging.Error("failed to find item "..item_id.." "..item_name)
    return false
  end

  if not OpenMarketItem(search_index) then
    Logging.Error("failed to open market item "..search_index)
    return false
  end

  local buy_count = 0
  local next_purchase = ShouldBuyMarketItem(1, max_price, gil_floor)
  local fail_count = 0
  while next_purchase and GetItemCount(item_id) < max_count do
    if BuyMarketItem(1) then
      buy_count = buy_count + next_purchase
    else
      CloseItemListings("ItemSearch")

      fail_count = fail_count + 1
      if fail_count >= 5 then
        Logging.Error("repeated failures to buy market item, aborting")
        return false
      end

      Logging.Warning("failed to buy market item, retrying")
      if not OpenMarketItem(search_index) then
        Logging.Error("failed to re-open market item "..search_index)
        return false
      end
    end
    next_purchase = ShouldBuyMarketItem(1, max_price, gil_floor)
  end
  Logging.Info("purchased "..buy_count.."x "..item_name)

  CloseItemListings("ItemSearch")
  return true
end

function GoPurchaseItems(buy_tables, gil_floor)
  local reduced_buy_tables = {}
  for _, item_table in pairs(buy_tables) do
    if GetItemCount(item_table[1]) < item_table[2] then
      table.insert(reduced_buy_tables, item_table)
    end
  end

  if TableIsEmpty(reduced_buy_tables) then
    return false
  end

  if not NavToMarketBoard() then return false end
  if not OpenMarketBoard() then return false end
  for _, item_table in pairs(reduced_buy_tables) do
    if not PurchaseItem(item_table, gil_floor) then
      CloseMarketBoard()
      return false
    end
  end
  CloseMarketBoard()
  return true
end

function GoPurchaseDCItems(buy_tables, gil_floor)
  Logging.Trace("purchasing items in current dc")
  if not IsInLimsa() then TeleportToLimsa() end

  local start_server = GetServerData()
  local server_list = ServerNavTable[start_server.region][start_server.dc]

  if not GoPurchaseItems(buy_tables, gil_floor) then return false end
  for dest_id, dest_name in pairs(server_list) do
    if dest_id ~= start_server.id then
      if not WorldVisitTo(dest_name) then
        Logging.Error("failed to travel to server "..dest_name)
        return false
      end
      if not GoPurchaseItems(buy_tables, gil_floor) then return false end
    end
  end

  local home_server = GetHomeServerData()
  if not IsInHomeWorld() and start_server.dc == home_server.dc then
    WorldVisitTo(home_server.name)
  end

  Logging.Trace("purchasing complete")
  return true
end

function GoPurchaseAllItems(buy_tables, gil_floor)
  local start_dc = GetServerData().dc
  if not GoPurchaseDCItems(buy_tables, gil_floor) then return false end

  local doPurchaseAllItems = function (region, dc_name)
    if dc_name ~= start_dc then
      if not DCTravelTo(region, dc_name) then
        Logging.Error("failed to DC travel to "..dc_name)
        return false
      end
      if not GoPurchaseDCItems(buy_tables, gil_floor) then return false end
    end
    return true
  end

  local home_region = GetHomeServerData().region
  for dc_name, _ in pairs(ServerNavTable[home_region]) do
    if not doPurchaseAllItems(home_region, dc_name) then return false end
  end
  if home_region ~= "OCE" then
    for dc_name, _ in pairs(ServerNavTable.OCE) do
      if not doPurchaseAllItems("OCE", dc_name) then return false end
    end
  end

  ReturnToBell()
  return true
end
