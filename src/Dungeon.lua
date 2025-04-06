require "ARUtils"
require "Logging"
require "Navigation"
require "UINav"

function OpenCurrencyWindow()
    if IsAddonReady("Currency") then return true end
    local timeout_count = 0
    repeat
        if timeout_count > 5 then
            return false
        end
        yield("/maincommand Currency")
        timeout_count = timeout_count + 1
    until AwaitAddonReady("Currency", 1)
    return true
end

function GetWeeklyTomeCount()
    if not OpenCurrencyWindow() then
        return nil, nil
    end

    while not IsNodeVisible("Currency", 1, 16, 200408) do
        Callback("Currency", true, 12, 1)
        yield("/wait 0.1")
    end

    local currency_text = GetNodeText("Currency", 66, 1)
    while StringIsEmpty(currency_text) do
        yield("/wait 0.1")
        currency_text = GetNodeText("Currency", 66, 1)
    end

    local slash_index, _ = string.find(currency_text, "/")
    if not slash_index or slash_index <= 1 then
        return nil, nil
    end

    local current_tomes = tonumber(string.sub(currency_text, 1, slash_index - 1)) or 0
    local cap_tomes = tonumber(string.sub(currency_text, slash_index + 1, string.len(currency_text))) or 0
    Logging.Debug(currency_text..": "..current_tomes.."/"..cap_tomes)

    CloseAddonFast("Currency")
    return current_tomes, cap_tomes
end

function RunDutyUntilCap(duty)
    local current_tomes, cap_tomes = GetWeeklyTomeCount()
    while current_tomes < cap_tomes do
        ADRun(duty, 1)
        WaitUntil(ADIsStopped, nil, 1)
        current_tomes, cap_tomes = GetWeeklyTomeCount()
    end
end

function CapCharacters(character_table)
    yield("/xlenablecollection Questionable")
    yield("/wait 4")
    for cid, config in pairs(character_table) do
        local data = GetARCharacterData(cid)
        if data then
            local name = ""..data.Name.."@"..data.World
            Logging.Debug("relogging to "..name)
            if cid ~= GetPlayerContentId() then
                while not ARIsBusy() do
                    yield("/ays relog "..name)
                    yield("/wait 1")
                end
                WaitUntil(function () return cid == GetPlayerContentId() end, 600, 1)
                WaitForNavReady()
                yield("/wait 3")
            end
            RunDutyUntilCap(config.duty)
        end
    end
    yield("/xldisablecollection Questionable")
end
