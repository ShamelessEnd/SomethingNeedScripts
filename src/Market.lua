require "Callback"
require "Logging"
require "UINav"
require "Utils"

function OpenMarketBoard()
  return InteractWith("Market Board", "ItemSearch")
end

function CloseItemListings(other)
  Logging.Trace("closing item listings")
  CloseAndAwaitOther("ItemSearchResult", other)
end

function OpenItemListings(attempts, addon, ...)
  Logging.Trace("opening item listings")

  for i = 1, attempts do
    Callback(addon, true, ...)
    if AwaitAddonReady("ItemSearchResult", 2) then
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

function GetItemHistoryPrice(history_index)
  local hist_price_text = string.gsub(GetNodeText("ItemHistory", 3, history_index + 1, 6), "%D", "")
  if StringIsEmpty(hist_price_text) then
    return 0
  else
    return tonumber(hist_price_text)
  end
end

function GetItemHistoryTrimmedMean()
  Logging.Debug("fetching item history")
  Callback("ItemSearchResult", true, 0)
  if not AwaitAddonReady("ItemHistory", 5) then
    Logging.Debug("failed to open item history")
    return 0
  end

  local history_list = { GetItemHistoryPrice(1) }
  while history_list[1] == 0 do
    if IsNodeVisible("ItemHistory", 1, 11) and string.find(GetNodeText("ItemHistory", 2), "No items found") then
      Logging.Debug("no history")
      return 0
    end
    yield("/wait 0.1")
    history_list[1] = GetItemHistoryPrice(1)
  end

  local history_count = 1
  for i = 2, 10 do
    history_list[i] = GetItemHistoryPrice(i)
    if (history_list[i] <= 0) then
      break
    else
      history_count = history_count + 1
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

  local history_total = 0
  for _, history_price in pairs(history_list) do
    history_total = history_total + history_price
  end

  local history_trimmed_mean = history_total / history_count
  Logging.Debug("history_trimmed_mean: "..history_trimmed_mean)

  CloseAndAwaitOther("ItemHistory", "ItemSearchResult")
  return history_trimmed_mean
end
