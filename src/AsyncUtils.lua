require "Logging"

local function toLuaData(data)
  if type(data) ~= "table" then
    return tostring(data)
  end
  local str = "{"
  local first = true
  for k,v in pairs(data) do
    if first then
      first = false
    else
      str = str..","
    end
    if type(k) == "number" then
      str = str.." ["..k.."] = "..toLuaData(v)
    else
      str = str.." "..toLuaData(k).." = "..toLuaData(v)
    end
  end
  return str.." }"
end

local function toLuaArgs(args)
  if not args then return "" end
  local args_str = ""
  local first = true
  for i = 1, #args do
    if first then
      first = false
    else
      args_str = args_str..", "
    end
    args_str = args_str..toLuaData(args[i])
  end
  return args_str
end

function RunAsync(requires, calls)
  local lua_code = ""
  for _, required in pairs(requires) do
      lua_code = lua_code.."require \""..required.."\"\n"
  end
  for func, args in pairs(calls) do
    lua_code = lua_code..func.."("..toLuaArgs(args)..")\n"
  end
  Engines.NLua.Run(lua_code)
end
