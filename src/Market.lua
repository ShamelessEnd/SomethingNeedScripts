require "Callback"
require "Logging"
require "UINav"
require "Utils"

function OpenMarketBoard()
  return InteractWith("Market Board", "ItemSearch")
end

function CloseMarketBoard()
  CloseAddon("ItemSearch")
end

function CloseItemListings(other)
  Logging.Trace("closing item listings")
  CloseAddon("ItemSearchResult", other)
end

function OpenItemListings(attempts, addon, ...)
  Logging.Trace("opening item listings")

  for i = 1, attempts do
    Callback(addon, true, ...)
    if AwaitAddonReady("ItemSearchResult", 2) then
      yield("/wait 0.5")
      for wait_time = 1, 100 do
        local msg_text = GetNodeText("ItemSearchResult", 26)
        if string.find(msg_text, "Please wait") then
          break
        end
        if string.find(msg_text, "No items found") then
          return true
        end
        if string.find(GetNodeText("ItemSearchResult", 2), "hit") then
          if not StringIsEmpty(GetNodeText("ItemSearchResult", 5, 1, 10)) then
            return true
          end
        end
        yield("/wait 0.1")
      end
      CloseItemListings(addon)
    end
    yield("/wait 0.5")
  end

  return false
end

function GetItemListingPrice(listing_index)
  local price_text = string.gsub(GetNodeText("ItemSearchResult", 5, listing_index, 10), "%D", "")
  if StringIsEmpty(price_text) then
    return 0
  else
    return tonumber(price_text)
  end
end

function GetItemListingCount(listing_index)
  local count_text = string.gsub(GetNodeText("ItemSearchResult", 5, listing_index, 9), "%D", "")
  if StringIsEmpty(count_text) then
    return 0
  else
    return tonumber(count_text)
  end
end

function GetItemHistoryPrice(history_index)
  local hist_price_text = string.gsub(GetNodeText("ItemHistory", 3, history_index + 1, 6), "%D", "")
  if StringIsEmpty(hist_price_text) then
    return 0
  else
    return tonumber(hist_price_text)
  end
end

function IsItemHistoryMannequin(history_index)
  local history_list_index = 41000 + history_index - 1
  if history_index <= 1 then
    history_list_index = 4
  end
  return IsNodeVisible("ItemHistory", 1, 10, history_list_index, 8, 9)
end

function GetItemHistoryPriceList(count)
  while GetItemHistoryPrice(1) == 0 do
    if IsNodeVisible("ItemHistory", 1, 11) and string.find(GetNodeText("ItemHistory", 2), "No items found") then
      Logging.Debug("no history")
      return {}, 0
    end
    yield("/wait 0.1")
  end

  local history_list = {}
  local history_count = 0
  for i = 1, 20 do
    if history_count >= count then
      break
    end
    if not IsItemHistoryMannequin(i) then
      local next_history_price = GetItemHistoryPrice(i)
      if next_history_price <= 0 then
        break
      end
      history_count = history_count + 1
      history_list[history_count] = next_history_price
    end
  end

  table.sort(history_list)
  for i = 1, 2 do
    if (history_count > 2) then
      table.remove(history_list, 1)
      table.remove(history_list)
      history_count = history_count - 2
    else
      break
    end
  end

  return history_list, history_count
end

function GetItemHistoryTrimmedMean()
  Logging.Debug("fetching item history")
  Callback("ItemSearchResult", true, 0)
  if not AwaitAddonReady("ItemHistory", 5) then
    Logging.Debug("failed to open item history")
    return 0
  end

  local history_list, history_count = GetItemHistoryPriceList(10)

  local history_total = 0
  for _, history_price in pairs(history_list) do
    history_total = history_total + history_price
  end

  local history_trimmed_mean = history_total / history_count
  Logging.Debug("history_trimmed_mean: "..history_trimmed_mean)

  CloseAddon("ItemHistory", "ItemSearchResult")
  return history_trimmed_mean
end

function OpenMarketItem(item_index)
  Logging.Trace("OpenMarketItem "..item_index)
  return OpenItemListings(10, "ItemSearch", 5, item_index - 1)
end

function MarketSearchItem(item_name)
  Logging.Trace("MarketSearchItem")
  Callback("ItemSearch", true, 7, -1, 0, -1, -1, -1, -1, -1)
  while IsNodeVisible("ItemSearch", 1, 142, 148) do
    yield("/wait 0.1")
  end
  Callback("ItemSearch", true, 0, -1, 0, item_name, item_name, 100, 100, 34)
end

function FindMarketItem(item_name)
  if not IsAddonReady("ItemSearch") then
    return nil
  end

  MarketSearchItem(item_name)
  while not IsNodeVisible("ItemSearch", 1, 142, 148) or IsNodeVisible("ItemSearch", 1, 140) do
    if IsNodeVisible("ItemSearch", 1, 140) then
      local msg_text = GetNodeText("ItemSearch", 10)
      if string.find(msg_text, "Please wait") then
        MarketSearchItem(item_name)
      elseif string.find(msg_text, "No matching items") then
        return nil
      end
    end
    yield("/wait 0.1")
  end
  yield("/wait 0.1")

  local count_text = string.gsub(GetNodeText("ItemSearch", 3), "[%d]+-", "")
  for i = 1, tonumber(count_text) do
    if GetNodeText("ItemSearch", 11, i, 4) == item_name then
      return i
    end
  end
  return nil
end

function BuyMarketItem(list_index)
  Logging.Trace("buying item listing at "..list_index)
  Callback("ItemSearchResult", true, 2, list_index - 1)
  if not AwaitAddonReady("SelectYesno", 3) then
    return false
  end

  local gil_before = GetGil()
  Callback("SelectYesno", true, 0)
  AwaitAddonGone("SelectYesno")

  local timeout_count = 0
  while GetGil() == gil_before do
    timeout_count = timeout_count + 0.1
    if timeout_count > 3 then
      return false
    end
    yield("/wait 0.1")
  end
  yield("/wait 0.5")

  return true
end
