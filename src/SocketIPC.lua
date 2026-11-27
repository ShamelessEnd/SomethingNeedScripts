require "Logging"
require "Socket"
require "Utils"

local _MSG_SEP = "#"
local _UNKNOWN_COMMAND = "UNKNOWN"
local _ACK_COMMAND = "ACK"
local _DONE_COMMAND = "DONE"
local _CLOSE_COMMAND = "CLOSE"
local _SHUTDOWN_COMMAND = "EXIT"
local _CERULEAM_COMMAND = "TANKS"

function ParseSocketMessage(msg)
  if not msg then return nil end
  local parts = { StringSplit(msg, _MSG_SEP) }
  if TableSize(parts) < 2 then return { raw = msg } end
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
  elseif cmd == _DONE_COMMAND then
    base["command"] = table.remove(parts, 1)
    if TableSize(parts) < 2 then return base end
    base["done_time"] = tonumber(table.remove(parts, 1))
    base["done_cmd"] = table.remove(parts, 1)
  elseif cmd == _CERULEAM_COMMAND then
    base["command"] = table.remove(parts, 1)
    base["name"] = table.remove(parts, 1)
    base["world"] = table.remove(parts, 1)
    base["stacks"] = tonumber(table.remove(parts, 1))
  elseif cmd == _CLOSE_COMMAND then
    base["command"] = table.remove(parts, 1)
  elseif cmd == _SHUTDOWN_COMMAND then
    base["command"] = table.remove(parts, 1)
    if TableSize(parts) < 1 then return base end
    base["pid"] = tonumber(table.remove(parts, 1))
  end

  return base
end

function GetProcessSocket(create)
  local pid = GetProcessId()
  if not pid or pid <= 0 then return nil end
  if not create and not HasSocket(pid) then return nil end
  return OpenSocket(pid, create)
end

function CreateRandomSocket(prefix)
  if not prefix then prefix = GetProcessId() or 0 end
  local uuid = UUID() or 0
  return CreateSocket(prefix.."."..uuid)
end

local function SendCommand(socket, msg)
  local encoded = table.concat(msg, _MSG_SEP)
  if encoded and socket.send(encoded) then return ParseSocketMessage(encoded) end
  return nil
end

function SendAckCommand(socket, msg)
  return SendCommand(socket, { os.time(), _ACK_COMMAND, msg.time, msg.command })
end

function SendDoneCommand(socket, msg)
  return SendCommand(socket, { os.time(), _DONE_COMMAND, msg.time, msg.command })
end

function SendCeruleumCommand(socket, name, world, stacks)
  return SendCommand(socket, { os.time(), _CERULEAM_COMMAND, name, world, stacks })
end

local function FindOpenCommand(cmd_name)
  local sockets = ListSockets()
  for _, socket in pairs(sockets) do
    local s = OpenSocket(socket)
    if s then
      local msg = nil
      local commands = {}
      repeat
        msg = ParseSocketMessage(s.read())
        if msg then
          if msg.command == cmd_name then
            commands[msg.time] = msg
          elseif msg.command == _ACK_COMMAND and msg.ack_cmd == cmd_name then
            commands[msg.time] = nil
          elseif msg.command == _DONE_COMMAND and msg.ack_cmd == cmd_name then
            commands[msg.time] = nil
          elseif msg.command == _CLOSE_COMMAND then
            commands = {}
            break
          end
        end
      until not msg
      local _, cmd = next(commands)
      if cmd and SendAckCommand(s, cmd) then return s, cmd end
      s.close()
    end
  end
  return nil, nil
end

function FindOpenCeruleumCommand() return FindOpenCommand(_CERULEAM_COMMAND) end

function HasShutdownCommand(cleanup)
  local socket = GetProcessSocket()
  if not socket then return false end
  local msg = nil
  repeat
    msg = socket.read()
    local parsed = ParseSocketMessage(msg)
    if parsed and parsed.command == _SHUTDOWN_COMMAND and parsed.pid == socket.id then
      SendAckCommand(socket, parsed)
      if cleanup then socket.remove() else socket.close() end
      return true
    end
  until not msg
  socket.close()
  return false
end
