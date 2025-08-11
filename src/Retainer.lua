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
  CloseAddon("RetainerList")
end

function OpenRetainer(retainer_index)
  Logging.Debug("opening retainer "..retainer_index)
  Callback("RetainerList", true, 2, retainer_index - 1)
  ClearTalkAndAwait("SelectString")
end

function CloseRetainer()
  Logging.Debug("closing retainer")
  Callback("SelectString", true, -1)
  ClearTalkAndAwait("RetainerList")
end

function OpenSellListRetainer()
  Logging.Debug("opening retainer inventory sell list")
  Callback("SelectString", true, 3)
  AwaitAddonReady("RetainerSellList")
end

function OpenSellListInventory()
  Logging.Debug("opening player inventory sell list")
  Callback("SelectString", true, 2)
  AwaitAddonReady("RetainerSellList")
end

function CloseSellList()
  Logging.Debug("closing retainer sell list")
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
  Logging.Debug("opening retainer inventory")
  Callback("SelectString", true, 0)
  AwaitAddonReady("InventoryRetainerLarge")
end

function CloseRetainerInventory()
  Logging.Debug("closing retainer inventory")
  CloseAddon("InventoryRetainerLarge", "SelectString")
end

function OpenSellListItemContext(item_index, timeout)
  -- this is flaky if you're moving/clicking the mouse at the same time
  -- hence the timeout/retry logic
  Logging.Debug("opening item "..item_index.." context menu")
  Callback("RetainerSellList", true, 0, item_index - 1, 1)
  return AwaitAddonReady("ContextMenu", timeout)
end

function OpenItemSell(item_index, attempts)
  for i = 1, attempts do
    if OpenSellListItemContext(item_index, 1) then
      Logging.Debug("opening item "..item_index.." sell menu")
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
  Logging.Debug("closing item sell menu")
  CloseAddon("RetainerSell", "RetainerSellList")
end

function OpenItemRetainerSell(item_page, page_slot)
  Logging.Debug("opening item from page "..item_page.." slot "..page_slot.." of retainer inventory")
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

function GetSellListCount(timeout)
  local timeout_count = 0
  repeat
    local full_text = GetNewNodeText("RetainerSellList", 1, 14, 19)
    local slash_index, _ = string.find(full_text, "/")
    if slash_index and slash_index > 1 then
      local count_text = string.sub(full_text, 1, slash_index - 1)
      if count_text then
        Logging.Debug("found "..count_text.." items for sale on retainer ("..full_text..")")
        return tonumber(count_text)
      end
    end
    yield("/wait 0.1")
    timeout_count = timeout_count + 0.1
  until timeout and timeout_count > timeout
  Logging.Error("GetSellListCount timed out")
  return nil
end

function GetCurrentItemSellPrice()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNewNodeText("RetainerSell", 1, 8, 10, 5))
end

function GetCurrentItemSellCount()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNewNodeText("RetainerSell", 1, 12, 14, 5))
end

function GetRetainerName(retainer_index)
  local name = nil
  local retry_count = 3
  for i = 1, retry_count do
    name = GetNewNodeText("RetainerList", 1, 27, GetNodeListIndex(retainer_index - 1, 4, 41000), 2, 3)
    if not StringIsEmpty(name) then
      break
    end
    yield("/wait 0.1")
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
  Logging.Debug("returning item "..item_index.." to inventory")
  return ReturnItemToTarget(item_index, 2, attempts)
end

function ReturnItemToRetainer(item_index, attempts)
  Logging.Debug("returning item"..item_index.." to retainer")
  return ReturnItemToTarget(item_index, 1, attempts)
end

function ReturnAllItemsToRetainer()
  while GetSellListCount() > 0 do
    ReturnItemToRetainer(1, 1)
  end
end

function EntrustSingleItem(item_id, item_stack)
  Logging.Debug("entrusting item "..item_id.." at "..item_stack.page.."."..item_stack.slot.." to retainer")
  local retry_timeout = 1
  local fail_timeout = 0
  while GetItemIdInSlot(item_stack.page, item_stack.slot) == item_id do
    if fail_timeout >= 5 then
      Logging.Warning("failed to entrust item, skipping")
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

-- Sell Items

function ApplyItemSellCount(new_count)
  Logging.Debug("applying item sell count "..new_count)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 3, new_count)
end

function ApplyPriceUpdateAndClose(new_price)
  Logging.Debug("applying new price "..new_price)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 2, string.format("%.0f", new_price))
  ConfirmItemSellAndClose()
end
