require "ARUtils"
require "Logging"
require "Navigation"
require "UINav"

function OpenCurrencyWindow() return OpenCommandWindow("currency", "Currency") end

function GetWeeklyTomeCount(max_cap)

    local function getTomeCount(get_total)

        local function toNumberStripComma(str)
            local comma_index, _ = string.find(str, ",")
            if not comma_index or comma_index <= 1 then
                return tonumber(str) or 0
            end
            a, b = str:match("([%d]+),([%d]+)")
            return tonumber(table.concat({ a, b })) or 0
        end


        local node = 6
        if get_total then
            node = 5
        end

        local currency_text = GetNewNodeText("Currency", 1, 16, 200408, node)
        while StringIsEmpty(currency_text) do
            yield("/wait 0.1")
            currency_text = GetNewNodeText("Currency", 1, 16, 200408, node)
        end

        local current_tomes, cap_tomes = currency_text:match("([%d,]+)/([%d,]+)")
        current_tomes = toNumberStripComma(current_tomes)
        cap_tomes = toNumberStripComma(cap_tomes)


        Logging.Debug(currency_text..": "..current_tomes.."/"..cap_tomes)
        return current_tomes, cap_tomes
    end

    if not OpenCurrencyWindow() then
        return nil, nil, nil, nil
    end

    while not IsNodeVisible("Currency", 1, 16, 200408) do
        Callback("Currency", true, 12, 1)
        yield("/wait 0.1")
    end

    current_weekly_tomes, cap_weekly_tomes = getTomeCount(false)
    if not current_weekly_tomes or not cap_weekly_tomes then
        return nil, nil, nil, nil
    end

    if max_cap and max_cap < cap_weekly_tomes then cap_weekly_tomes = max_cap end

    current_total_tomes, cap_total_tomes = getTomeCount(true)
    if not current_total_tomes or not cap_total_tomes then
        return current_weekly_tomes, cap_weekly_tomes, nil, nil
    end

    CloseAddonFast("Currency")
    return current_weekly_tomes, cap_weekly_tomes, current_total_tomes, cap_total_tomes
end

function EnableActionStance(action, status)
    local timeout = 5
    while not HasStatusId(status) and timeout > 0 do
        Actions.ExecuteAction(action)
        WaitUntil(function () return HasStatusId(status) end, 3)
        timeout = timeout - 1
    end
end

function EnableTankStance()
    local job = GetClassJobId()
    if job == 19 then -- PLD
        EnableActionStance(28, 79)
    elseif job == 21 then -- WAR
        EnableActionStance(48, 91)
    elseif job == 32 then -- DRK
        EnableActionStance(3629, 743)
    elseif job == 37 then -- GNB
        EnableActionStance(16142, 1833)
    end
end

function PreDutyRunChecks()
    yield("/bmai on")
    yield("/bmrai on")
    EnableTankStance()
end

function RunDutyUntilCap(duty, cap)
    local current_weekly_tomes, cap_weekly_tomes, current_total_tomes, cap_total_tomes = GetWeeklyTomeCount(cap)
    while current_weekly_tomes < cap_weekly_tomes and current_total_tomes < cap_total_tomes do
        PreDutyRunChecks()
        ADRun(duty, 1)
        WaitUntil(ADIsStopped, nil, 1)
        current_weekly_tomes, cap_weekly_tomes, current_total_tomes, cap_total_tomes = GetWeeklyTomeCount(cap)
    end
end

function CapCharacters(character_table)
    yield("/xlenablecollection Questionable")
    yield("/wait 4")
    for _, char in pairs(character_table) do
        if char.duty and (not char.cap or char.cap > 0) then
            if ARRelogTo(char.id) then
                RunDutyUntilCap(char.duty, char.cap)
            end
        end
    end
    yield("/xldisablecollection Questionable")
end
