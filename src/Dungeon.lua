require "ARUtils"
require "Logging"
require "Navigation"
require "UINav"

function OpenCurrencyWindow() return OpenCommandWindow("currency", "Currency") end

function GetWeeklyTomeCount(max_cap)
    if not OpenCurrencyWindow() then
        return nil, nil
    end

    while not IsNodeVisible("Currency", 1, 16, 200408) do
        Callback("Currency", true, 12, 1)
        yield("/wait 0.1")
    end

    local currency_text = GetNewNodeText("Currency", 1, 16, 200408, 6)
    while StringIsEmpty(currency_text) do
        yield("/wait 0.1")
        currency_text = GetNewNodeText("Currency", 1, 16, 200408, 6)
    end

    local slash_index, _ = string.find(currency_text, "/")
    if not slash_index or slash_index <= 1 then
        return nil, nil
    end

    local current_tomes = tonumber(string.sub(currency_text, 1, slash_index - 1)) or 0
    local cap_tomes = tonumber(string.sub(currency_text, slash_index + 1, string.len(currency_text))) or 0
    Logging.Debug(currency_text..": "..current_tomes.."/"..cap_tomes)
    if max_cap and max_cap < cap_tomes then cap_tomes = max_cap end

    CloseAddonFast("Currency")
    return current_tomes, cap_tomes
end

function RunDutyUntilCap(duty, cap)
    local current_tomes, cap_tomes = GetWeeklyTomeCount(cap)
    while current_tomes < cap_tomes do
        ADRun(duty, 1)
        WaitUntil(ADIsStopped, nil, 1)
        current_tomes, cap_tomes = GetWeeklyTomeCount(cap)
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
