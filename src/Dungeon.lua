require "ARUtils"
require "Currency"
require "Logging"
require "Navigation"
require "TomestoneVendor"
require "UINav"
require "Utils"

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

function RunDutyUntilCap(duty, cap, tomestone_config)
    local function isCapped()
        local current_weekly, cap_weekly, current_total, cap_total = GetWeeklyTomeCount(cap)
        if cap and (not cap_weekly or cap < cap_weekly) then cap_weekly = cap end

        if current_weekly and cap_weekly and current_weekly >= cap_weekly then return true end
        if current_total and cap_total and current_total >= cap_total then return true end
        if (not current_weekly) and (not cap_weekly) and (not current_total) and (not cap_total) then return true end
        return false
    end
    while not isCapped() do
        PreRunDutyChecks()

        if tomestone_config and tomestone_config.item_table and tomestone_config.minimum_tomes then
            SpendTomestone(tomestone_config.item_table, tomestone_config.minimum_tomes)
        end

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
                RunDutyUntilCap(char.duty, char.cap, char.tomestone)
            end
        end
    end
    yield("/xldisablecollection Questionable")
end
