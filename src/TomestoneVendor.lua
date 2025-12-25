require "Navigation"
require "LegacySndBridge"
require "UINav"

local function getTomesToSpend() return ParseInt(vendor_addon:GetAtkValue(84).ValueString) end

function BuyItem(vendor_item, wanted_item)
    tomes = getTomesToSpend()

    item_name = GetItemName(wanted_item.id)
    if wanted_item.amount <= 0 then
        Logging.Debug("Skipping buying "..item_name..", desired amount is "..wanted_item.amount)
        return tomes
    end

    owned_amount = GetItemCount(wanted_item.id)
    remaining = wanted_item.amount - owned_amount

    if remaining <= 0 then
        Logging.Debug("Skipping buying "..item_name..", "..owned_amount.." already in inventory")
        return tomes
    end

    while remaining > 0 and tomes >= vendor_item.cost do
        local max_by_stack = math.min(99, remaining)
        local max_by_currency = math.floor(tomes / vendor_item.cost)

        local buy_amount = math.min(max_by_stack, max_by_currency)

        if buy_amount <= 0 then
            break
        end

        Logging.Debug("Buying "..buy_amount.."x "..item_name)
        Callback("ShopExchangeCurrency", true, 0, vendor_item.index, buy_amount)
        SelectYesno(true)

        local function purchaseComplete()
            local tomes_left = getTomesToSpend()
            return GetItemCount(wanted_item.id) > owned_amount and tomes_left ~= tomes
        end
        if WaitUntil(purchaseComplete, 5) then
            remaining = remaining - buy_amount
            tomes = tomes - (buy_amount * vendor_item.cost)
        end
    end

    return tomes
end

function GetAmountOfItemsInList(vendor_addon)
    return ParseInt(vendor_addon:GetAtkValue(4).ValueString)
end

function GetItemList(vendor_addon)
    local items = {}
    count = GetAmountOfItemsInList(vendor_addon)

    for i = 0, count-1 do
        item_id = ParseInt(vendor_addon:GetAtkValue(1064 + i).ValueString)

        if item_id and item_id >= 0 then
            cost = ParseInt(vendor_addon:GetAtkValue(454 + i).ValueString)

            items[item_id] = {
                index = i,
                cost = cost
            }
        end
    end

    return items
end

function SpendTomestone(item_table, minimum_tomes)
    current_tomes, _ = GetUncappedTomeCount()

    if current_tomes < minimum_tomes then
        Logging.Debug("Not enough tomes to spend")
        return
    end

    if not IsInZone(1186) or not GetDistanceToObject("Zircon") then
        LifestreamTo("nexus")

        WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
    end
    NavToObject("Zircon", 3, false, 30)
    InteractWith("Zircon", "SelectIconString", 3)
    if AwaitAddonReady("SelectIconString", 5) then
        Callback("SelectIconString", true, 3)
        yield("/wait 2")
        
        if AwaitAddonReady("ShopExchangeCurrency") then
            vendor_addon = Addons.GetAddon("ShopExchangeCurrency")

            -- Check if we're actually in the correct tomes page (sanity check)
            icon_atk = ParseInt(vendor_addon:GetAtkValue(85).ValueString)
            currency = GetItemFromIcon(icon_atk)
            if not currency then
                Logging.Error("Failed to find currency for exchange")
                return CloseAddonFast("ShopExchangeCurrency")
            end

            if currency.Name ~= "Allagan Tomestone of Mathematics" then
                Logging.Error("Found wrong currency, aborting")
                return CloseAddonFast("ShopExchangeCurrency")
            end

            tomes_to_spend = getTomesToSpend()
            if not tomes_to_spend then
                Logging.Error("Couldn't read amount of tomes to spend, aborting")
                return CloseAddonFast("ShopExchangeCurrency")
            end

            if minimum_tomes and tomes_to_spend < minimum_tomes then
                Logging.Debug("Not enough tomes to spend")
                return CloseAddonFast("ShopExchangeCurrency")
            end

            Logging.Debug("Spending up to "..tomes_to_spend.." "..currency.Name)

            vendor_items = GetItemList(vendor_addon)

            for i, item in ipairs(item_table) do
                Logging.Debug("Attempting to buy item "..GetItemName(item.id))

                vendor_item = vendor_items[item.id]

                if not vendor_item then
                    Logging.Error("Item "..item.id.." not found in vendor, skipping")
                end

                if item.amount > 0 and tomes_to_spend < vendor_item.cost then
                    Logging.Debug("Not enough tomes left to buy, finishing")
                    break
                end

                tomes_to_spend = BuyItem(vendor_item, item)
            end

        end
        return CloseAddonFast("ShopExchangeCurrency")
    end
end