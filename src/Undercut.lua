require "Inventory"
require "Logging"
require "Market"
require "Retainer"
require "Utils"

--[[

sell_table = {
  { id, price_floor, force_list, stack_size, max_listings, min_keep },
  ...
}

retainer_table = {
  config = { exclude=boolean, undercut=boolean, unlist=boolean, entrust=boolean, floor=number },
  sell_table = sell_table
}

retainer_tables = {
  [retainer_index] = retainer_table,
  ...
}
  set exclude to skip retainer entirely, or use nil retainer_table
  set undercut and leave sell_table=nil to undercut only
  set unlist to remove all items from mb and re-list them from scratch
  set entrust to entrust sell_table items from inventory to retainer
  set floor to the lowest price to undercut items to

]]--

function CalculateUndercutPrice(p1, p2, p3, h)
  if h <= 0 then
    return 0
  elseif p1 <= 0 then
    return RoundUpToNext(h * 1.25, 10000) - 10
  end

  local hh = 0.4 * h
  local h2 = 2 * h
  local hr = RoundUpToNext(h, 10000)
  local h3r = RoundUpToNext(3 * h, 10000)
  if p2 <= 0 then p2 = hr end
  if p3 <= 0 then p3 = hr end

  if p3 < hh then
    return hr - 10
  elseif p2 < hh or (p2 < (0.5 * p3) and p3 < h2) then
    return RoundUpToNext(p3, 10) - 10
  elseif p1 < hh or (p1 < (0.5 * p2) and p2 < h2) then
    return RoundUpToNext(p2, 10) - 10
  elseif p1 > h3r and h3r > 50000 then
    return h3r - 10
  else
    return RoundUpToNext(p1, 10) - 10
  end
end

function GetUndercutPrice()
  Logging.Debug("calculating suggested price")
  if not OpenItemListings(10, "RetainerSell", 4) then
    Logging.Error("failed to open item listings")
    return 0
  end

  local p1 = GetItemListingPrice(1)
  local p2 = GetItemListingPrice(2)
  local p3 = GetItemListingPrice(3)
  Logging.Debug("list prices: "..p1..", "..p2..", "..p3)

  local hist = GetItemHistoryTrimmedMean()

  CloseItemListings("RetainerSell")
  return CalculateUndercutPrice(p1, p2, p3, hist)
end

function ParseSellEntry(raw_sell_entry)
  if raw_sell_entry.parsed_entry then return raw_sell_entry.parsed_entry end
  raw_sell_entry.parsed_entry = {
    id = raw_sell_entry[1],
    price_floor = raw_sell_entry[2] or 0,
    force_list = raw_sell_entry[3] == true,
    stack_size = raw_sell_entry[4] or 1,
    max_listings = raw_sell_entry[5] or 20,
    min_keep = raw_sell_entry[6] or 0,
  }
  return raw_sell_entry.parsed_entry
end

function GetSellEntryByName(sell_table, item_name)
  if sell_table then
    for i, raw_sell_entry in pairs(sell_table) do
      if not raw_sell_entry.item_name then
        raw_sell_entry.item_name = GetItemName(raw_sell_entry[1])
      end
      if item_name == raw_sell_entry.item_name then
        return ParseSellEntry(raw_sell_entry)
      end
    end
  end
  return nil
end

function UndercutItems(return_function, sell_table, undercut_other, default_floor)
  if undercut_other then
    Logging.Debug("undercutting all items")
  else
    Logging.Debug("undercutting sell_table items")
  end

  local item_count = GetSellListCount(5)
  if not item_count or item_count <= 0 then return {} end
  Logging.Info("  Found "..item_count.." items listed")

  local last_item_name = ""
  local last_item_price = 0
  local last_sell_entry = nil
  local returned_count = 0
  local listed_items = {}
  for item_number = 1, item_count do
    local item_index = item_number - returned_count
    if not OpenItemSell(item_index, 5) then
      Logging.Error("failed to open ItemSell, aborting")
      break
    end

    local item_name = GetNodeText("RetainerSell", 18)
    local current_price = GetCurrentItemSellPrice()
    Logging.Info("  Undercutting item "..item_number.." "..item_name)
    Logging.Debug("    current_price: "..current_price)

    local undercut_price = 0
    local sell_entry = nil
    if last_item_name == item_name then
      undercut_price = last_item_price
      sell_entry = last_sell_entry
    else
      sell_entry = GetSellEntryByName(sell_table, item_name)
      if sell_entry or undercut_other then
        undercut_price = GetUndercutPrice()
      end
    end

    if sell_entry then
      local item_id = sell_entry.id
      if listed_items[item_id] then
        listed_items[item_id].count = listed_items[item_id].count + 1
      else
        listed_items[item_id] = { count=1, price=undercut_price }
      end
    end

    local floor_price = default_floor or 0
    if sell_entry and sell_entry.price_floor then
      floor_price = sell_entry.price_floor
    end

    if undercut_price <= 0 then
      Logging.Info("    failed to calculate price, skipping item")
      CloseItemSell()
    elseif undercut_price == current_price then
      Logging.Info("    price target unchanged, skipping item")
      CloseItemSell()
    elseif undercut_price < floor_price then
      Logging.Info("    new price too low ("..undercut_price.." < "..floor_price..")")
      if sell_entry and sell_entry.force_list then
        Logging.Info("      using floor price")
        ApplyPriceUpdateAndClose(floor_price)
      else
        Logging.Info("      removing listing")
        CloseItemSell()
        if return_function(item_index, 5) then
          returned_count = returned_count + 1
        end
        if sell_entry then
          -- set count to max to prevent future re-trying to list same item
          listed_items[sell_entry.id].count = sell_entry.max_listings
        end
      end
    else
      ApplyPriceUpdateAndClose(undercut_price)
      Logging.Info("    price updated: "..current_price.." -> "..undercut_price)
    end

    last_item_name = item_name
    last_item_price = undercut_price
    last_sell_entry = sell_entry
  end
  return listed_items
end

function UndercutRetainerItems(retainer_index, floor)
  if GetNodeText("RetainerList", 2, retainer_index, 5) == "None" then
    Logging.Debug("skipping retainer "..retainer_index.." - no items listed")
    return
  end

  OpenRetainer(retainer_index)
  OpenSellListInventory()
  UndercutItems(ReturnItemToInventory, nil, true, floor)
  CloseSellList()
  CloseRetainer()
end

function ListItemForSaleFromStack(item_stack, stack_size, max_slots, price_floor, force_list, list_price)
  local num_listings = 1
  if stack_size > 0 then
    num_listings = item_stack.count // stack_size
  else
    stack_size = item_stack.count
  end
  if num_listings > max_slots then
    num_listings = max_slots
  end
  if num_listings <= 0 then
    Logging.Debug("cannot fill stack_size "..stack_size.." with available items ("..item_stack.count.."), skipping")
    return 0, list_price
  end

  OpenItemRetainerSell(item_stack.page, item_stack.slot)

  if list_price <= 0 then
    list_price = GetUndercutPrice()
    if list_price <= 0 then
      list_price = RoundUpToNext(price_floor * 2, 10000) - 10
    elseif list_price < price_floor then
      if force_list then
        list_price = RoundUpToNext(price_floor, 10) - 10
      else
        list_price = 0
      end
    end
    if list_price <= 0 then
      CloseItemSell()
      Logging.Debug("item price is too low, bailing")
      return 0, 0
    end
  end

  Logging.Debug("listing item "..num_listings.." times")
  for i = 1, num_listings do
    if i > 1 then
      OpenItemRetainerSell(item_stack.page, item_stack.slot)
    end

    if stack_size > 0 and stack_size ~= GetCurrentItemSellCount() then
      ApplyItemSellCount(stack_size)
    end

    local current_price = GetCurrentItemSellPrice()
    if list_price ~= current_price then
      ApplyPriceUpdateAndClose(list_price)
    else
      ConfirmItemSellAndClose()
    end
  end

  Logging.Debug("listed "..stack_size.." item(s) x"..num_listings.." at price "..list_price)
  return num_listings, list_price
end

function ListItemForSale(sell_entry, max_slots, item_stacks, listed_item)
  Logging.Trace("listing item "..sell_entry.id)

  if max_slots <= 0 then
    Logging.Debug("no slots available, skipping item")
    return 0
  end

  local max_listings = sell_entry.max_listings
  if max_listings <= 0 then
    Logging.Debug("no listings desired, skipping item")
    return 0
  end

  local list_price = -1
  if listed_item ~= nil then
    list_price = listed_item.price
    max_listings = max_listings - listed_item.count
    if max_listings <= 0 then
      Logging.Debug("max listings already fulfilled, skipping item")
      return 0
    end
  end

  if max_listings < max_slots then
    max_slots = max_listings
  end

  local num_listings = 0
  local min_keep = sell_entry.min_keep
  for _, item_stack in pairs(item_stacks) do
    Logging.Debug("processing stack "..item_stack.count.." at "..item_stack.page.."."..item_stack.slot)
    local original_count = item_stack.count
    if item_stack.count <= 0 then
      Logging.Debug("cannot process stack, failed to fetch item count")
    elseif min_keep > 0 then
      if item_stack.count < min_keep then
        min_keep = min_keep - item_stack.count
        item_stack.count = 0
      else
        item_stack.count = item_stack.count - min_keep
        min_keep = 0
      end
      Logging.Debug("reducing count to save min_keep items. new count "..item_stack.count.." (save_count="..min_keep..")")
    end

    if item_stack.count > 0 then
      local listings_added = 0
      listings_added, list_price = ListItemForSaleFromStack(item_stack, sell_entry.stack_size, max_slots, sell_entry.price_floor, sell_entry.force_list, list_price)
      item_stack.count = original_count - (listings_added * sell_entry.stack_size)
      num_listings = num_listings + listings_added
      max_slots = max_slots - listings_added
      if list_price == 0 then
        Logging.Debug("failed to fetch item price, bailing")
        break
      end
      if max_slots <= 0 then
        Logging.Debug("max slots reached, bailing")
        break
      end
    end
  end

  if num_listings > 0 then
    Logging.Info("    Listed item "..sell_entry.id.." "..num_listings.." times, at "..list_price)
  end
  return num_listings
end

function SellRetainerItems(retainer_index, retainer_name, sell_table, unlist, undercut, floor)
  OpenSellListRetainer()

  local sale_slots = 0
  local listed_items = {}
  if unlist then
    Logging.Info("  Returning all listed items to retainer "..retainer_index.." inventory")
    ReturnAllItemsToRetainer()
    sale_slots = 20
  else
    Logging.Info("  Undercutting existing items for retainer "..retainer_index)
    listed_items = UndercutItems(ReturnItemToRetainer, sell_table, undercut, floor)
    sale_slots = 20 - GetSellListCount()
  end

  local inventory = FindItemsInRetainerInventory(retainer_name)

  Logging.Info("  Listing sale items for retainer "..retainer_index)
  for _, raw_sell_entry in pairs(sell_table) do
    local item_stacks = inventory[raw_sell_entry[1]]
    if item_stacks ~= nil then
      local sell_entry = ParseSellEntry(raw_sell_entry)
      sale_slots = sale_slots - ListItemForSale(sell_entry, sale_slots, item_stacks, listed_items[sell_entry.id])
      if sale_slots <= 0 then
        Logging.Debug("no open slots remaining")
        break
      end
    end
  end

  CloseSellList()
end

function EntrustSellTableItems(sell_table)
  OpenRetainerInventory()
  local inventory = FindItemsInCharacterInventory()
  for _, raw_sell_entry in pairs(sell_table) do
    local item_id = raw_sell_entry[1]
    local item_stacks = inventory[item_id] or {}
    for _, stack in pairs(item_stacks) do EntrustSingleItem(item_id, stack) end
  end
  CloseRetainerInventory()
end

function UndercutAndSellRetainerItems(retainer_index, retainer_table)
  if not retainer_table then
    Logging.Info("  Skipping retainer without a retainer_table  "..retainer_index)
    return
  end

  if retainer_table.config.exclude then
    Logging.Info("  Skipping excluded retainer  "..retainer_index)
    return
  end

  local retainer_name = GetRetainerName(retainer_index)
  if StringIsEmpty(retainer_name) then
    Logging.Error("  Skipping retainer that does not exist "..retainer_index)
    return
  end
  Logging.Info("Processing retainer "..retainer_index.." "..retainer_name)

  if not retainer_table.sell_table then
    if retainer_table.config.undercut then
      Logging.Info("  Only undercutting items for retainer "..retainer_index)
      UndercutRetainerItems(retainer_index, retainer_table.config.floor)
    else
      Logging.Info("  Skipping retainer without a sell_table "..retainer_index)
    end
    return
  end

  OpenRetainer(retainer_index)
  if retainer_table.config.entrust then
    Logging.Info("  Entrusting items to retainer "..retainer_index.." from inventory")
    EntrustSellTableItems(retainer_table.sell_table)
  end
  SellRetainerItems(retainer_index, retainer_name, retainer_table.sell_table, retainer_table.config.unlist, retainer_table.config.undercut, retainer_table.config.floor)
  CloseRetainer()
end

function UndercutAndSellAllRetainers(retainer_tables)
  Logging.Info("UndercutAndSellAllRetainerss")
  ARSetSuppressed(true)
  yield("/xldisablecollection UndercutAndSellAllRetainers")
  yield("/wait 0.5")
  if OpenRetainerList() then
    local retainer_count = ARGetRetainerCount()
    for i, retainer_table in pairs(retainer_tables) do
      if i > retainer_count then break end
      UndercutAndSellRetainerItems(i, retainer_table)
    end
    CloseRetainerList()
  end
  yield("/xlenablecollection UndercutAndSellAllRetainers")
  yield("/wait 1")
  ARSetSuppressed(false)
end
