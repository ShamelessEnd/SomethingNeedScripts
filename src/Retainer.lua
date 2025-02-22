require "Callback"
require "Inventory"
require "Logging"
require "UINav"
require "Utils"

-- Navigation

function OpenRetainerList()
  return InteractWith("Summoning Bell", "RetainerList")
end

function CloseRetainerList()
  LogDebug("closing RetainerList")
  Callback("RetainerList", true, -1)
  yield("/wait 1")
end

function OpenRetainer(retainer_index)
  LogDebug("opening retainer "..retainer_index)
  Callback("RetainerList", true, 2, retainer_index - 1)
  ClearTalkAndAwait("SelectString")
end

function CloseRetainer()
  LogDebug("closing retainer")
  Callback("SelectString", true, -1)
  ClearTalkAndAwait("RetainerList")
end

function OpenSellListRetainer()
  LogDebug("opening retainer inventory sell list")
  Callback("SelectString", true, 3)
  AwaitAddonReady("RetainerSellList")
end

function OpenSellListInventory()
  LogDebug("opening player inventory sell list")
  Callback("SelectString", true, 2)
  AwaitAddonReady("RetainerSellList")
end

function CloseSellList()
  LogDebug("closing retainer sell list")
  Callback("RetainerSellList", true, -1)
  while IsAddonReady("RetainerSellList") do
    if IsAddonReady("SelectYesno") then
      Callback("SelectYesno", true, 0)
      break
    end
    yield("/wait 0.1")
  end
  AwaitAddonReady("SelectString")
end

function OpenRetainerInventory()
  LogDebug("opening retainer inventory")
  Callback("SelectString", true, 0)
  AwaitAddonReady("InventoryRetainerLarge")
end

function CloseRetainerInventory()
  LogDebug("closing retainer inventory")
  CloseAndAwaitOther("InventoryRetainerLarge", "SelectString")
end

function OpenSellListItemContext(item_index, timeout)
  -- this is flaky if you're moving/clicking the mouse at the same time
  -- hence the timeout/retry logic
  LogDebug("opening item "..item_index.." context menu")
  Callback("RetainerSellList", true, 0, item_index - 1, 1)
  return AwaitAddonReady("ContextMenu", timeout)
end

function OpenItemSell(item_index, attempts)
  for i = 1, attempts do
    if OpenSellListItemContext(item_index, 1) then
      LogDebug("opening item "..item_index.." sell menu")
      if CallbackTimeout(1, "ContextMenu", true, 0, 0) then
        if AwaitAddonReady("RetainerSell", 1) then
          return true
        end
      end
    end
  end
  return false
end

function CloseItemSell()
  LogDebug("closing item sell menu")
  CloseAndAwaitOther("RetainerSell", "RetainerSellList")
end

function CloseItemListings()
  LogDebug("closing item listings")
  CloseAndAwaitOther("ItemSearchResult", "RetainerSell")
end

function OpenItemListings(attempts)
  LogDebug("opening item listings")

  for i = 1, attempts do
    Callback("RetainerSell", true, 4)
    if AwaitAddonReady("ItemSearchResult", 2) then
      for wait_time = 1, 100 do
        if string.find(GetNodeText("ItemSearchResult", 26), "Please wait") then
          break
        end
        if string.find(GetNodeText("ItemSearchResult", 2), "hit") then
          return true
        end
        yield("/wait 0.1")
      end
      CloseItemListings()
    end
    yield("/wait 0.5")
  end

  return false
end

function OpenItemRetainerSell(item_page, page_slot)
  LogDebug("opening item from page "..item_page.." slot "..page_slot.." of retainer inventory")
  AwaitAddonReady("RetainerSellList")
  Callback("RetainerSellList", true, 2, 52 + item_page, page_slot)
  AwaitAddonReady("RetainerSell")
end

function ConfirmItemSellAndClose()
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 0)
  AwaitAddonGone("RetainerSell")
  AwaitAddonReady("RetainerSellList")
end

-- Read UI

function GetSellListCount()
  local item_full_text = GetNodeText("RetainerSellList", 3)
  local count_start, count_end
  while count_start == nil or count_end == nil do
    count_start, count_end = string.find(item_full_text, "%d+")
  end
  local item_count = string.sub(item_full_text, count_start, count_end - count_start + 1)
  LogDebug("found "..item_count.." items for sale on retainer ("..item_full_text..")")
  return tonumber(item_count)
end

function GetCurrentItemSellPrice()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNodeText("RetainerSell", 15, 4))
end

function GetCurrentItemSellCount()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNodeText("RetainerSell", 11, 4))
end

function GetRetainerName(retainer_index)
  local name = nil
  local retry_count = 3
  for i = 1, retry_count do
    name = GetNodeText("RetainerList", 2, retainer_index, 13)
    if not StringIsEmpty(name) then
      break
    end
    yield("/wait 0.5")
  end
  return name
end

-- Move Items

function ReturnItemToTarget(item_index, target_id, attempts)
  for i = 1, attempts do
    if OpenSellListItemContext(item_index, 1) then
      local sell_count = GetSellListCount()
      if CallbackTimeout(1, "ContextMenu", true, 0, target_id) then
        local timeout_count = 0
        while sell_count == GetSellListCount() do
          yield("/wait 0.1")
          timeout_count = timeout_count + 0.1
          if timeout_count >= 5 then
            return false
          end
        end
        return true
      end
    end
  end
  return false
end

function ReturnItemToInventory(item_index, attempts)
  LogDebug("returning item "..item_index.." to inventory")
  return ReturnItemToTarget(item_index, 2, attempts)
end

function ReturnItemToRetainer(item_index, attempts)
  LogDebug("returning item"..item_index.." to retainer")
  return ReturnItemToTarget(item_index, 1, attempts)
end

function ReturnAllItemsToRetainer()
  while GetSellListCount() > 0 do
    ReturnItemToRetainer(1, 1)
  end
end

function EntrustSingleItem(item_id, item_stack)
  LogDebug("entrusting item "..item_id.." at "..item_stack.page.."."..item_stack.slot.." to retainer")
  local retry_timeout = 1
  local fail_timeout = 0
  while GetItemIdInSlot(item_stack.page, item_stack.slot) == item_id do
    if fail_timeout >= 5 then
      LogWarning("failed to entrust item, skipping")
      break
    elseif retry_timeout >= 1 then
      Callback("InventoryExpansion", true, 14, 48 + item_stack.page, item_stack.slot)
      retry_timeout = 0
    end
    yield("/wait 0.1")
    retry_timeout = retry_timeout + 0.1
    fail_timeout = fail_timeout + 0.1
  end
end

function EntrustInventoryItems(sell_table)
  OpenRetainerInventory()
  local inventory = FindItemsInCharacterInventory()
  for _, sell_entry in pairs(sell_table) do
    local item_id = sell_entry[1]
    local item_stacks = inventory[item_id] or {}
    for _, stack in pairs(item_stacks) do EntrustSingleItem(item_id, stack) end
  end
  CloseRetainerInventory()
end

-- Sell Items

function ApplyItemSellCount(new_count)
  LogDebug("applying item sell count "..new_count)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 3, new_count)
end

function ApplyPriceUpdateAndClose(new_price)
  LogDebug("applying new price "..new_price)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 2, string.format("%.0f", new_price))
  ConfirmItemSellAndClose()
end
