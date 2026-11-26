require "Logging"
require "Utils"

local _socket_folder = os.getenv("USERPROFILE")
function SetSocketFolder(folder) _socket_folder = folder end

local function RegisterSocket(id)
  local path = _socket_folder.."\\sns.sock.idx"
  local f = io.open(path, "a")
  if not f then return false end
  f:write("+", id, "@", os.time(), "\n")
  f:close()
  return true
end

local function DeregisterSocket(id)
  local path = _socket_folder.."\\sns.sock.idx"
  local f = io.open(path, "a")
  if not f then return false end
  f:write("-", id, "@", os.time(), "\n")
  f:close()
  return true
end

local function SendMessage(fa, fr, msg)
  if StringContains(msg, "\n") then
    Logging.Error("message cannot contain newlines")
    return false
  end

  if io.type(fa) ~= "file" or io.type(fr) ~= "file" then
    Logging.Error("socket closed")
    return false
  end

  fa:write(msg, "\n")
  fa:flush()
  fr:seek("end")

  return true
end

local function ReadMessage(fr)
  if io.type(fr) ~= "file" then
    Logging.Error("socket closed")
    return nil
  end

  local cur = fr:seek()
  local line = fr:read("L")

  if not line then return nil end
  if line:sub(-1) ~= "\n" then
    Logging.Warning("discarding partial message read")
    fr:seek("set", cur)
    return nil
  end

  return line:gsub("\r?\n$", "")
end

local function CloseSocket(fa, fr)
  if io.type(fa) == "file" then
    fa:close()
  end
  if io.type(fr) == "file" then
    fr:close()
  end
end

local function BuildSocket(id, path, fa, fr)
  return {
    id = id,
    path = path,
    send = function (msg) return SendMessage(fa, fr, msg) end,
    read = function () return ReadMessage(fr) end,
    close = function () CloseSocket(fa, fr) end,
    remove = function () CloseSocket(fa, fr) DeregisterSocket(id) return os.remove(path) end
  }
end

function CreateSocket(id, overwrite)
  local path = _socket_folder.."\\"..id..".sock"
  local f = io.open(path, "r")
  local registered = HasSocket(id)
  local exists = f ~= nil
  if f then f:close() end

  if registered or exists then
    if not overwrite then
      Logging.Error("Socket "..id.." already exists")
      return nil
    end
    if exists and not os.remove(path) then
      Logging.Error("Failed to remove existing socket "..id)
      return nil
    end
    if registered and not DeregisterSocket(id) then
      Logging.Error("Failed to deregister existing socket "..id)
      return nil
    end
  end

  local fa = io.open(path, "a")
  if not fa then return nil end

  local fr = io.open(path, "r")
  if not fr then
    fa:close()
    os.remove(path)
    return nil
  end

  if not RegisterSocket(id) then
    fa:close()
    fr:close()
    os.remove(path)
    return nil
  end

  return BuildSocket(id, path, fa, fr)
end

function OpenSocket(id, create)
  local path = _socket_folder.."\\"..id..".sock"
  local f = io.open(path, "r")
  if not f and not create then
    Logging.Error("socket does not exist")
    return nil
  end

  local fa = io.open(path, "a")
  if not fa then
    if f then f:close() end
    return nil
  end

  local fr = f or io.open(path, "r")
  if not fr then
    fa:close()
    if not f then os.remove(path) end
    return nil
  end

  if not f and not RegisterSocket(id) then
    fa:close()
    fr:close()
    os.remove(path)
    return nil
  end

  return BuildSocket(id, path, fa, fr)
end

function ListSockets(cleanup)
  local path = _socket_folder.."\\sns.sock.idx"
  local f = io.open(path, "r")
  if not f then
    return {}
  end

  local sockets = {}
  for l in f:lines() do
    local op, id, ts = l:match("^([+-])([^@]+)@(%d+)$")
    if op == "+" then
      sockets[id] = id
    else
      sockets[id] = nil
    end
  end

  f:close()
  if cleanup and TableIsEmpty(sockets) then os.remove(path) end
  return sockets
end

function HasSocket(id)
  local sid = tostring(id)
  return ListSockets()[sid] ~= nil
end
