
local retainer_count = 9
local default_undercut_floor = 14500
local retainer_sell_tables = {
  [2] = {
    -- config
    [0] = { exclude=false, unlist=false },
    --   id, price floor, force list, stack size, max listings, min keep, name
    { 13115,      399900,       true,          1,           20,        0, "Jet Black"                  },
    { 13114,      299900,       true,          1,           20,        0, "Pure White"                 },
    { 13708,       49500,      false,          2,            5,        0, "Pastel Pink"                },
    { 13116,       14500,      false,          2,            5,        0, "Metallic Silver"            },
    { 13117,       14500,      false,          2,            5,        0, "Metallic Gold"              },
    { 13723,       11500,      false,          2,            5,        0, "Metallic Purple"            },
    { 13716,       11500,      false,          2,            5,        0, "Dark Purple"                },
    { 13721,        9500,      false,          2,            3,        0, "Sky Blue"                   },
    { 13719,        5500,      false,          2,            3,        0, "Metallic Yellow"            },
    { 13720,        5500,      false,          2,            3,        0, "Metallic Green"             },
    { 13717,        5500,      false,          2,            3,        0, "Metallic Red"               },
    { 13722,        5500,      false,          2,            3,        0, "Metallic Blue"              },
    { 13709,        5500,      false,          2,            3,        0, "Dark Red"                   },
    { 13713,        5500,      false,          2,            3,        0, "Pastel Blue"                },
  },
  [9] = {
    [0] = { exclude=false, unlist=false },
    --   id, price floor, force list, stack size, max listings, min keep, name
    { 28588,      249500,      false,          1,            1,        0, "Urban Coat"                 },
    { 40405,       49500,      false,          1,            1,        0, "Plain Pajama Shirt"         },
    { 40413,       49500,      false,          1,            1,        0, "Chocobo Pajama Shirt"       },
    { 33662,       49500,      false,          1,            1,        0, "Frontier Pumps"             },
    { 10393,       49500,      false,          1,            1,        0, "Thavnairian Bustier"        },
    {  7535,       49500,      false,          1,            1,        0, "Sailor Shirt"               },
    { 40404,       49500,      false,          1,            1,        0, "Plain Pajama Eye Mask"      },
    { 33869,       49500,      false,          1,            1,        0, "Frontier Cloth"             },
    { 33659,       49500,      false,          1,            1,        0, "Frontier Ribbon"            },
    {  7771,       29500,      false,          1,            1,        0, "Dress Material"             },
    { 40410,       29500,      false,          1,            1,        0, "Cactuar Pajama Bottoms"     },
    {  6586,       29500,      false,          1,            1,        0, "Manor Candelabra"           },
    { 22569,       29500,      false,          1,            1,        0, "Southern Kitchen"           },
    {  8796,       29500,      false,          1,            1,        0, "Shipping Crate"             },
    { 40630,       29500,      false,          1,            1,        0, "Imitation Moonlit Window"   },
    { 35869,       19500,      false,          1,            1,        0, "Wristlet of Happiness"      },
    { 24004,       19500,      false,          1,            1,        0, "Whisperfine Woolen Coat"    },
    { 40408,       19500,      false,          1,            1,        0, "Cactuar Pajama Eye Mask"    },
    {  7546,       19500,      false,          1,            1,        0, "Light Steel Galerus"        },
    { 35870,       19500,      false,          1,            1,        0, "Hose of Happiness"          },
    { 35575,       19500,      false,          1,            1,        0, "Imitation Wooden Skylight"  },
    {  8547,       19500,      false,          1,            1,        0, "Coeurl Beach Maro"          },
    {  9734,       19500,      false,          1,            1,        0, "Oak Low Barrel Planter"     },
    {  9719,       19500,      false,          1,            1,        0, "Oriental Bathtub"           },
    {  8778,       19500,      false,          1,            1,        0, "Southern Seas Couch"        },
    { 16625,       14500,      false,          1,            1,        0, "Astral Silk Robe"           },
    { 33655,       14500,      false,          1,            1,        0, "Frontier Hat"               },
    {  7548,       14500,      false,          1,            1,        0, "Taffeta Shawl"              },
    { 37359,       14500,      false,          1,            1,        0, "Ivy Curtain"                },
    { 13069,       14500,      false,          1,            1,        0, "The Unending Journey"       },
    { 22440,       14500,      false,          1,            1,        0, "Hedge Partition"            },
    { 17025,       14500,      false,          1,            1,        0, "Ivy Pillar"                 },
    { 22558,       14500,      false,          1,            1,        0, "Bar Counter"                },
    { 38592,       14500,      false,          1,            1,        0, "Tatami Loft"                },
    { 37360,       14500,      false,          1,            1,        0, "Luminous Wooden Loft"       },
    {  8797,       14500,      false,          1,            1,        0, "Wine Barrel"                },
    { 30385,       14500,      false,          1,            1,        0, "Wooden Staircase Bookshelf" },
    { 15974,       14500,      false,          1,            1,        0, "Mounted Bookshelf"          },
    { 28639,       14500,      false,          1,            1,        0, "Leather Sofa"               },
    {  6590,       14500,      false,          1,            1,        0, "Deluxe Manor Fireplace"     },
    {  6535,       14500,      false,          1,            1,        0, "Manor Couch"                },
    {  6519,       14500,      false,          1,            1,        0, "Manor Stool"                },
    {  7109,       14500,      false,          1,            1,        0, "Manor Music Stool"          },
    {  7114,       14500,      false,          1,            1,        0, "Manor Music Stand"          },
    {  6569,       14500,      false,          1,            1,        0, "Manor Bookshelf"            },
    { 16781,       14500,      false,          1,            1,        0, "Troupe Stage"               },
    { 32224,       14500,      false,          1,            1,        0, "Swag Valance"               },
    {  7979,       14500,      false,          1,            1,        0, "Planter Partition"          },
    { 24536,       14500,      false,          1,            1,        0, "Botanist's Garden"          },
    { 24511,       14500,      false,          1,            1,        0, "Wooden Loft"                },
    { 24513,       14500,      false,          1,            1,        0, "Wooden Beam"                },
    {  8816,       14500,      false,          1,            1,        0, "Large Planter Box"          },
    {  6487,       14500,      false,          1,            1,        0, "Oaken Bench"                },
    {  8002,       14500,      false,          1,            1,        0, "Planter Box"                },
    { 24526,       14500,      false,          1,            1,        0, "Hanging Planter Shelf"      },
    { 28975,       14500,      false,          1,            1,        0, "Oldrose Wall Planter"       },
    { 22554,       14500,      false,          1,            1,        0, "Portable Stepladder"        },
    { 14045,       14500,      false,          1,            1,        0, "Orchestrion"                },
    {  6668,       14500,      false,          1,            1,        0, "Nymian Wall Lantern"        },
    { 17954,       14500,      false,          1,            1,        0, "Table Orchestrion"          },
    { 13075,       14500,      false,          1,            1,        0, "Oriental Round Table"       },
    { 14068,       14500,      false,          1,            1,        0, "Alpine Chandelier"          },
    { 32226,       14500,      false,          1,            1,        0, "Wood Slat Partition"        },
    {  6595,       14500,      false,          1,            1,        0, "Potted Maguey"              },
    { 41111,       14500,      false,          1,            1,        0, "Field of Hope Rug"          },
    {  8814,       14500,      false,          1,            1,        0, "Oasis Doormat"              },
    {  6549,       14500,      false,          1,            1,        0, "Riviera Wardrobe"           },
    {  6646,       14500,      false,          1,            1,        0, "Potted Spider Plant"        },
    { 24508,       14500,      false,          1,            1,        0, "Botanist's Dried Herbs"     },
    {  6645,       14500,      false,          1,            1,        0, "Potted Azalea"              },
    { 27296,       14500,      false,          1,            1,        0, "Wooden Handrail"            },
    { 38606,       14500,      false,          1,            1,        0, "Natural Wooden Beam"        },
    { 30403,       14500,      false,          1,            1,        0, "Factory Beam"               },
    {  7958,       14500,      false,          1,            1,        0, "Riviera Wall Shelf"         },
    {  8790,       14500,      false,          1,            1,        0, "Masonwork Stove"            },
    {  6596,       14500,      false,          1,            1,        0, "Astroscope"                 },
    { 28823,       14500,      false,          1,            1,        0, "Pirate's Beret of Aiming"   },
    { 38561,       14500,      false,          1,            1,        0, "Blue Sweet Pea Necklace"    },
    { 44148,        4500,      false,          0,            1,        0, "Sterling Silver Ingot"      },
    { 44150,        4500,      false,          0,            1,        0, "Blackseed Cotton Cloth"     },
    { 44151,        4500,      false,          0,            1,        0, "Purussaurus Leather"        },
    { 44147,        4500,      false,          0,            1,        0, "Maraging Steel Ingot"       },
    {  8155,        4500,      false,          0,            1,        0, "Mastercraft Demimateria"    },
    { 16908,        4500,      false,          0,            1,        0, "Tempered Glass"             },
  }
}

local log_level = 3
function LogMessage(message) yield(""..message) end
function LogDebug(message) if log_level <= 0 then LogMessage(message) end end
function LogInfo(message) if log_level <= 1 then LogMessage(message) end end

function StringIsEmpty(s) return s == nil or s == "" end

function CallbackCommand(target, update, ...)
  -- even with all these checks, /callback will randomly crash, so fallback to /pcall
  local command = "/pcall "..target.." "..tostring(update)
  for _, arg in pairs({...}) do
    command = command.." "..tostring(arg)
  end
  return command
end

function Callback(target, update, ...)
  local command = CallbackCommand(target, update, ...)
  while true do
    if IsAddonReady(target) then
      yield(command)
      break
    end
    yield("/wait 0.1")
  end
end

function CallbackTimeout(timeout, target, update, ...)
  local command = CallbackCommand(target, update, ...)
  local timeout_count = 0
  while timeout_count < timeout do
    if IsAddonReady(target) then
      yield(command)
      return true
    end
    yield("/wait 0.1")
    timeout_count = timeout_count + 0.1
  end
  return false
end

function AwaitAddonReady(addon_name, timeout)
  if timeout == nil or timeout <= 0 then
    -- /waitaddon slows things down a lot, but might be more reliable
    -- yield("/waitaddon "..addon_name)
    while not IsAddonReady(addon_name) or not IsAddonVisible(addon_name) do
      yield("/wait 0.1")
    end
  else
    local timeout_count = 0
    while not IsAddonReady(addon_name) or not IsAddonVisible(addon_name) do
      yield("/wait 0.1")
      timeout_count = timeout_count + 0.1
      if timeout_count >= timeout then
        return false
      end
    end
  end
  return true
end

function AwaitAddonGone(addon_name)
  while IsAddonReady(addon_name) or IsAddonVisible(addon_name) do
    yield("/wait 0.1")
  end
end

function CloseAndAwaitOther(addon_name, other_addon_name)
  Callback(addon_name, true, -1)
  AwaitAddonGone(addon_name)
  AwaitAddonReady(other_addon_name)
end

function ClearTalkAndAwait(addon_name)
  while not IsAddonVisible(addon_name) do
    if IsAddonVisible("Talk") and IsAddonReady("Talk") then
      Callback("Talk", true, 1)
    end
    yield("/wait 0.1")
  end
  AwaitAddonReady(addon_name)
end

function OpenRetainerList()
  LogDebug("opening RetainerList")
  if not IsAddonVisible("RetainerList") then
    yield("/runmacro WalkToBell")
    if GetTargetName() ~= "Summoning Bell" or GetDistanceToTarget() > 3.59 then
      return false
    end
    yield("/interact")
  end
  AwaitAddonReady("RetainerList")
  return true
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
  while IsAddonReady("RetainerSellList") or IsAddonVisible("RetainerSellList") do
    if IsAddonReady("SelectYesno") or IsAddonVisible("SelectYesno") then
      Callback("SelectYesno", true, 0)
      break
    end
    yield("/wait 0.1")
  end
  AwaitAddonReady("SelectString")
end

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
    AwaitAddonReady("ItemSearchResult")

    for wait_time = 1, 120 do
      if string.find(GetNodeText("ItemSearchResult", 2), "hit") then
        return true
      end
      if string.find(GetNodeText("ItemSearchResult", 26), "Please wait") then
        break
      end
      yield("/wait 0.1")
    end
    CloseItemListings()
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
  LogDebug("fetching item history")
  Callback("ItemSearchResult", true, 0)
  AwaitAddonReady("ItemHistory")

  local history_list = { GetItemHistoryPrice(1) }
  while history_list[1] == 0 do
    if IsNodeVisible("ItemHistory", 1, 11) and string.find(GetNodeText("ItemHistory", 2), "No items found") then
      LogDebug("no history")
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
  LogDebug("history_trimmed_mean: "..history_trimmed_mean)

  CloseAndAwaitOther("ItemHistory", "ItemSearchResult")
  return history_trimmed_mean
end

function RoundUpToNext(x, increment)
  return math.floor(((x + increment - 1) // increment) * increment + 0.5)
end

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
  elseif p1 > h3r and h3r > 100000 then
    return h3r - 10
  else
    return RoundUpToNext(p1, 10) - 10
  end
end

function GetUndercutPrice()
  LogDebug("calculating suggested price")
  if not OpenItemListings(10) then
    LogDebug("failed to open item listings")
    return 0
  end

  local p1 = GetItemListingPrice(1)
  while p1 == 0 do
    if string.find(GetNodeText("ItemSearchResult", 26), "No items found") then
      LogDebug("no listings")
      break
    end
    yield("/wait 0.1")
    p1 = GetItemListingPrice(1)
  end

  local p2 = GetItemListingPrice(2)
  local p3 = GetItemListingPrice(3)
  LogDebug("list prices: "..p1..", "..p2..", "..p3)

  local hist = GetItemHistoryTrimmedMean()

  CloseItemListings()
  return CalculateUndercutPrice(p1, p2, p3, hist)
end

function GetCurrentItemSellPrice()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNodeText("RetainerSell", 15, 4))
end

function GetCurrentItemSellCount()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNodeText("RetainerSell", 11, 4))
end

function ConfirmItemSellAndClose()
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 0)
  AwaitAddonGone("RetainerSell")
  AwaitAddonReady("RetainerSellList")
end

function ApplyPriceUpdateAndClose(new_price)
  LogDebug("applying new price "..new_price)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 2, string.format("%.0f", new_price))
  ConfirmItemSellAndClose()
end

function ApplyItemSellCount(new_count)
  LogDebug("applying item sell count "..new_count)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 3, new_count)
end

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
  LogInfo("  Returning all listed items to retainer inventory")
  while GetSellListCount() > 0 do
    ReturnItemToRetainer(1, 1)
  end
end

function GetRetainerItemCount(item_page, page_slot)
  local page_addon = "RetainerGrid"..item_page
  AwaitAddonReady(page_addon)
  if not IsNodeVisible(page_addon, 1, 2, 3 + page_slot, 2) then
    -- need to swap pages, but that doesn't seem possible right now with callbacks
    LogDebug("cannot load item count, page is not loaded")
    return -1
  end
  local count_text = GetNodeText(page_addon, 37 - page_slot, 2, 8)
  if StringIsEmpty(count_text) then
    return 1
  end
  return tonumber(count_text)
end

function OpenItemRetainerSell(item_page, page_slot)
  LogDebug("opening item from page "..item_page.." slot "..page_slot.." of retainer inventory")
  AwaitAddonReady("RetainerSellList")
  Callback("RetainerSellList", true, 2, 52 + item_page, page_slot)
  AwaitAddonReady("RetainerSell")
end

function FindItemsInRetainer(item_id)
  local item_stacks = {}
  for container = 10000, 10006 do
    for container_slot = 0, 24 do
      if GetItemIdInSlot(container, container_slot) == item_id then
        local item_slot = (container - 10000) * 25 + container_slot
        local item_page = item_slot // 35
        local page_slot = item_slot % 35
        local item_count = GetRetainerItemCount(item_page, page_slot)
        LogDebug("found "..item_count.." items for "..item_id.." at slot "..item_slot.." ("..item_page.."."..page_slot..")")
        table.insert(item_stacks, { page = item_page, slot = page_slot, count = item_count })
      end
    end
  end
  return item_stacks
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
    LogDebug("cannot fill stack_size "..stack_size.." with available items ("..item_stack.count.."), skipping")
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
      LogDebug("item price is too low, bailing")
      return 0, 0
    end
  end

  LogDebug("listing item "..num_listings.." times")
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

  LogDebug("listed "..stack_size.." item(s) x"..num_listings.." at price "..list_price)
  return num_listings, list_price
end

function ListItemForSale(sell_entry, max_slots, found_item)
  local item_id = sell_entry[1]
  local price_floor = sell_entry[2]
  local force_list = sell_entry[3]
  local stack_size = sell_entry[4]
  local max_listings = sell_entry[5]
  local save_count = sell_entry[6]
  LogInfo("  Listing item "..item_id)
  
  local list_price = -1
  if found_item ~= nil then
    list_price = found_item.price
    max_listings = max_listings - found_item.count
  end

  if max_listings < max_slots then
    max_slots = max_listings
  end
  if max_slots <= 0 then
    LogInfo("    No slots available, skipping item")
    return 0
  end

  local num_listings = 0
  for _, item_stack in pairs(FindItemsInRetainer(item_id)) do
    LogDebug("processing stack "..item_stack.count.." at "..item_stack.page.."."..item_stack.slot)
    if item_stack.count <= 0 then
      LogDebug("cannot process stack, failed to fetch item count")
    elseif save_count > 0 then
      if item_stack.count < save_count then
        save_count = save_count - item_stack.count
        item_stack.count = 0
      else
        item_stack.count = item_stack.count - save_count
        save_count = 0
      end
      LogDebug("reducing count to save min_keep items. new count "..item_stack.count.." (save_count="..save_count..")")
    end
 
    if item_stack.count > 0 then
      local listings_added = 0
      listings_added, list_price = ListItemForSaleFromStack(item_stack, stack_size, max_slots, price_floor, force_list, list_price)
      num_listings = num_listings + listings_added
      max_slots = max_slots - listings_added
      if list_price == 0 then
        LogDebug("failed to fetch item price, bailing")
        break
      end
      if max_slots <= 0 then
        LogDebug("max slots reached, bailing")
        break
      end
    end
  end

  LogInfo("    Listed item "..item_id.." "..num_listings.." times, at "..list_price)
  return num_listings
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
  LogDebug("undercutting all items")
  local item_count = GetSellListCount()
  local last_item_name = ""
  local last_item_price = 0
  local last_sell_entry = nil
  local returned_count = 0
  local found_items = nil
  if sell_table ~= nil then
    found_items = {}
  end

  LogInfo("  Found "..item_count.." items listed")
  if item_count > 0 then
    for item_number = 1, item_count do
      local item_index = item_number - returned_count
      if not OpenItemSell(item_index, 5) then
        LogInfo("failed to open ItemSell, aborting")
        break
      end

      local item_name = GetNodeText("RetainerSell", 18)
      LogInfo("  Undercutting item "..item_number.." "..item_name)

      local current_price = GetCurrentItemSellPrice()
      LogInfo("    current price: "..current_price)

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
        if found_items[item_id] == nil then
          found_items[item_id] = { count=1, price=undercut_price }
        else
          found_items[item_id].count = found_items[item_id].count + 1
        end
      end

      local floor_price = default_undercut_floor
      if sell_entry ~= nil then
        floor_price = sell_entry[2]
      end

      if undercut_price <= 0 then
        LogInfo("    failed to calculate price, skipping item")
        CloseItemSell()
      elseif undercut_price == current_price then
        LogInfo("    price target unchanged, skipping item")
        CloseItemSell()
      elseif undercut_price < floor_price then
        if sell_entry ~= nil and sell_entry[3] == true then
          LogInfo("    new price too low ("..undercut_price.."), using floor price "..floor_price)
          ApplyPriceUpdateAndClose(floor_price)
        else
          LogInfo("    new price too low ("..undercut_price.." < "..floor_price.."), removing listings")
          CloseItemSell()
          if return_function(item_index, 5) then
            returned_count = returned_count + 1
          end
          if sell_entry ~= nil then
            found_items[sell_entry[1]].count = sell_entry[5]
          end
        end
      else
        ApplyPriceUpdateAndClose(undercut_price)
        LogInfo("    price updated: "..undercut_price)
      end

      last_item_name = item_name
      last_item_price = undercut_price
      last_sell_entry = sell_entry
    end
  end
  return found_items
end

function UndercutRetainerItems(retainer_index)
  local retainer_name = GetNodeText("RetainerList", 2, retainer_index, 13)
  LogInfo("Undercutting items for retainer "..retainer_index.." "..retainer_name)
  if GetNodeText("RetainerList", 2, retainer_index, 5) == "None" then
    LogInfo("  Skipping retainer "..retainer_index.." - No items listed")
    return
  end

  OpenRetainer(retainer_index)
  OpenSellListInventory()
  UndercutItems(ReturnItemToInventory)
  CloseSellList()
  CloseRetainer()
end

function SellRetainerItems(retainer_index, sell_table)
  if sell_table == nil then
    UndercutRetainerItems(retainer_index)
    return
  end
  
  if sell_table[0].exclude == true then
    LogInfo("Skipping excluded retainer  "..retainer_index)
    return
  end

  local retainer_name = GetNodeText("RetainerList", 2, retainer_index, 13)
  LogInfo("Listing sale items for retainer "..retainer_index.." "..retainer_name)

  OpenRetainer(retainer_index)
  OpenSellListRetainer()

  local sale_slots = 0
  local found_items = nil
  if sell_table[0].unlist == true then
    ReturnAllItemsToRetainer()
    sale_slots = 20
  else
    found_items = UndercutItems(ReturnItemToRetainer, sell_table)
    sale_slots = 20 - GetSellListCount()
  end

  for i, sell_entry in pairs(sell_table) do
    if i ~= 0 then
      local found_item = nil
      if found_items ~= nil then
        found_item = found_items[sell_entry[1]]
      end
      sale_slots = sale_slots - ListItemForSale(sell_entry, sale_slots, found_item)
      if sale_slots <= 0 then
        LogDebug("no open slots remaining")
        break
      end
    end
  end

  CloseSellList()
  CloseRetainer()
end

function ARPostUndercut()
  LogInfo("ARPostUndercut")
  ARSetSuppressed(true)
  yield("/xldisablecollection ARPostUndercutSuppress")
  if OpenRetainerList() then
    for i = 1, retainer_count do
      SellRetainerItems(i, retainer_sell_tables[i])
    end
    CloseRetainerList()
  end
  yield("/xlenablecollection ARPostUndercutSuppress")
  ARSetSuppressed(false)
end


ARPostUndercut()
