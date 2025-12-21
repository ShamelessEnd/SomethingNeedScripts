require "ARUtils"
require "Logging"
require "Navigation"
require "UINav"
require "Utils"

function OpenCurrencyWindow() return OpenCommandWindow("currency", "Currency") end

function GetWeeklyTomeCount(max_cap)
    if not OpenCurrencyWindow() then return nil end

    while not IsNodeVisible("Currency", 1, 16, 200408) do
        Callback("Currency", true, 12, 1)
        yield("/wait 0.1")
    end

    local function parseTomes(node)
        local currency_text
        WaitWhile(function ()
            currency_text = GetNewNodeText("Currency", 1, 16, 200408, node)
            return StringIsEmpty(currency_text)
        end)

        local current_tomes, cap_tomes = StringSplit(currency_text, "/")
        return ParseInt(current_tomes), ParseInt(cap_tomes)
    end

    local current_weekly, cap_weekly = parseTomes(6)
    local current_total, cap_total = parseTomes(5)
    CloseAddonFast("Currency")

    if max_cap and (not cap_weekly or max_cap < cap_weekly) then cap_weekly = max_cap end

    if not current_weekly or not cap_weekly then Logging.Warning("failed to read weekly tome count") end
    if not current_total or not cap_total then Logging.Error("failed to read total tome count") end

    return current_weekly, cap_weekly, current_total, cap_total
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

function PreRunDutyChecks()
    yield("/bmai on")
    yield("/bmrai on")
    EnableTankStance()
end

function RunDutyUntilCap(duty, cap)
    local function isCapped()
        local current_weekly, cap_weekly, current_total, cap_total = GetWeeklyTomeCount(cap)
        if current_weekly and cap_weekly and current_weekly >= cap_weekly then return true end
        if current_total and cap_total and current_total >= cap_total then return true end
        return false
    end
    while not isCapped() do
        PreRunDutyChecks()
        ADRun(duty, 1)
        WaitUntil(ADIsStopped, nil, 1)
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
