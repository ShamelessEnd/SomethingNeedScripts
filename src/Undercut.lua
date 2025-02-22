require "Inventory"
require "Logging"
require "Market"
require "Retainer"
require "Utils"

local _default_floor_price = 14500
function SetDefaultFloorPrice(price) _default_floor_price = price end

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

function GetSellEntryByName(sell_table, item_name)
  if sell_table ~= nil then
    for i, sell_entry in pairs(sell_table) do
      if sell_entry[7] ~= nil and string.find(item_name, sell_entry[7]) then
        return sell_entry
      end
    end
  end
  return nil
end

function UndercutItems(return_function, sell_table)
  Logging.Debug("undercutting all items")
  local item_count = GetSellListCount()
  local last_item_name = ""
  local last_item_price = 0
  local last_sell_entry = nil
  local returned_count = 0
  local listed_items = {}

  Logging.Info("  Found "..item_count.." items listed")
  if item_count > 0 then
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
        undercut_price = GetUndercutPrice()
        sell_entry = GetSellEntryByName(sell_table, item_name)
      end

      if sell_entry ~= nil then
        local item_id = sell_entry[1]
        if listed_items[item_id] == nil then
          listed_items[item_id] = { count=1, price=undercut_price }
        else
          listed_items[item_id].count = listed_items[item_id].count + 1
        end
      end

      local floor_price = _default_floor_price
      if sell_entry ~= nil then
        floor_price = sell_entry[2]
      end

      if undercut_price <= 0 then
        Logging.Info("    failed to calculate price, skipping item")
        CloseItemSell()
      elseif undercut_price == current_price then
        Logging.Info("    price target unchanged, skipping item")
        CloseItemSell()
      elseif undercut_price < floor_price then
        Logging.Info("    new price too low ("..undercut_price.." < "..floor_price..")")
        if sell_entry ~= nil and sell_entry[3] == true then
          Logging.Info("      using floor price")
          ApplyPriceUpdateAndClose(floor_price)
        else
          Logging.Info("      removing listing")
          CloseItemSell()
          if return_function(item_index, 5) then
            returned_count = returned_count + 1
          end
          if sell_entry ~= nil then
            listed_items[sell_entry[1]].count = sell_entry[5]
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
  end
  return listed_items
end

function UndercutRetainerItems(retainer_index)
  if GetNodeText("RetainerList", 2, retainer_index, 5) == "None" then
    Logging.Debug("skipping retainer "..retainer_index.." - no items listed")
    return
  end

  OpenRetainer(retainer_index)
  OpenSellListInventory()
  UndercutItems(ReturnItemToInventory)
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
  local item_id = sell_entry[1]
  local price_floor = sell_entry[2]
  local force_list = sell_entry[3]
  local stack_size = sell_entry[4]
  local max_listings = sell_entry[5]
  local save_count = sell_entry[6]
  Logging.Trace("listing item "..item_id)

  if max_slots <= 0 then
    Logging.Debug("no slots available, skipping item")
    return 0
  end
  
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
  for _, item_stack in pairs(item_stacks) do
    Logging.Debug("processing stack "..item_stack.count.." at "..item_stack.page.."."..item_stack.slot)
    local original_count = item_stack.count
    if item_stack.count <= 0 then
      Logging.Debug("cannot process stack, failed to fetch item count")
    elseif save_count > 0 then
      if item_stack.count < save_count then
        save_count = save_count - item_stack.count
        item_stack.count = 0
      else
        item_stack.count = item_stack.count - save_count
        save_count = 0
      end
      Logging.Debug("reducing count to save min_keep items. new count "..item_stack.count.." (save_count="..save_count..")")
    end
 
    if item_stack.count > 0 then
      local listings_added = 0
      listings_added, list_price = ListItemForSaleFromStack(item_stack, stack_size, max_slots, price_floor, force_list, list_price)
      item_stack.count = original_count - (listings_added * stack_size)
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
    Logging.Info("    Listed item "..item_id.." "..num_listings.." times, at "..list_price)
  end
  return num_listings
end

function SellRetainerItems(retainer_index, retainer_name, sell_table, unlist)
  OpenSellListRetainer()

  local sale_slots = 0
  local listed_items = {}
  if unlist then
    Logging.Info("  Returning all listed items to retainer "..retainer_index.." inventory")
    ReturnAllItemsToRetainer()
    sale_slots = 20
  else
    Logging.Info("  Undercutting existing items for retainer "..retainer_index)
    listed_items = UndercutItems(ReturnItemToRetainer, sell_table)
    sale_slots = 20 - GetSellListCount()
  end

  local inventory = FindItemsInRetainerInventory(retainer_name)

  Logging.Info("  Listing sale items for retainer "..retainer_index)
  for _, sell_entry in pairs(sell_table) do
    local item_id = sell_entry[1]
    local item_stacks = inventory[item_id]
    if item_stacks ~= nil then
      sale_slots = sale_slots - ListItemForSale(sell_entry, sale_slots, item_stacks, listed_items[item_id])
      if sale_slots <= 0 then
        Logging.Debug("no open slots remaining")
        break
      end
    end
  end

  CloseSellList()
end
