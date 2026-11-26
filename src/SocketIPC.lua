require "Logging"
require "Socket"
require "Utils"

local _MSG_SEP = "#"
local _UNKNOWN_COMMAND = "UNKNOWN"
local _SHUTDOWN_COMMAND = "EXIT"
local _ACK_COMMAND = "ACK"

function ParseSocketMessage(msg)
    local parts = { StringSplit(msg, _MSG_SEP) }
    if TableSize(parts) < 2 then return nil end
    local time = tonumber(table.remove(parts, 1))
    local cmd = parts[1]
    local base = {
        raw = msg,
        time = time,
        command = _UNKNOWN_COMMAND,
        args = parts,
    }

    if cmd == _ACK_COMMAND then
        base["command"] = table.remove(parts, 1)
        if TableSize(parts) < 2 then return base end
        base["ack_time"] = tonumber(table.remove(parts, 1))
        base["ack_cmd"] = table.remove(parts, 1)
    elseif cmd == _SHUTDOWN_COMMAND then
        base["command"] = table.remove(parts, 1)
        if TableSize(parts) < 1 then return base end
        base["pid"] = tonumber(table.remove(parts, 1))
    end

    return base
end

function SendSocketAck(socket, received)
    local msg = {
        os.time(),
        _ACK_COMMAND,
        received.time,
        received.command,
    }
    socket.send(table.concat(msg, _MSG_SEP))
end

function GetProcessSocket(create)
    if not System.GetProcessId then return nil end
    local pid = System.GetProcessId()
    if not pid or pid <= 0 then return nil end
    if not create and not HasSocket(pid) then return nil end
    return OpenSocket(pid, create)
end

function GetCharacterSocket(create)
    local cid = GetPlayerContentId()
    if not cid then return nil end
    if not create and not HasSocket(cid) then return nil end
    return OpenSocket(cid, create)
end

function HasShutdownCommand(cleanup)
    local socket = GetProcessSocket()
    if not socket then return false end
    local msg = nil
    repeat
        msg = socket.read()
        local parsed = ParseSocketMessage(msg)
        if parsed and parsed.command == _SHUTDOWN_COMMAND and parsed.pid == socket.id then
            SendSocketAck(socket, parsed)
            if cleanup then socket.remove() else socket.close() end
            return true
        end
    until not msg
    socket.close()
    return false
end
