require "Logging"
require "Utils"

local _game_folder =  os.getenv("USERPROFILE").."\\Documents\\My Games\\FINAL FANTASY XIV - A Realm Reborn"
function SetGameFolder(folder) _game_folder = folder end

-- ItemODR
--   ID | Name      | DL | Variable       | Note
-- -----------------------------------------------------
-- 0x56 | Unknown   | ?? | ???            | ??
-- 0x4E | Retainers | 04 | Retainer Count | followed by [Retainer Count] 'Retainer' sections
-- 0x52 | Retainer  | 08 | Retainer ID    | followed by an 'Inventory' section
-- 0x6E | Inventory | 04 | Slot Count     | followed by [Slot Count] 'Slot' sections
-- 0x69 | Slot      | 04 | Slot|Container | 2 shorts: Slot Index, Container Index

function ReadItemODRData(file, bytes)
  local xor_key = 0x73 -- xor encryption byte for ITEMODR.DAT
  return ReadXORData(file, xor_key, bytes)
end

function ReadItemODRSectionHeader(file)
  return ReadItemODRData(file, 1), ReadItemODRData(file, 1) -- id, length
end

function ReadItemODRExpectedBlock(file, expected_id, expected_length)
  local id, length = ReadItemODRSectionHeader(file)
  if id ~= expected_id or length ~= expected_length then Logging.Debug("expected block not found") return nil end
  return ReadItemODRData(file, length)
end

function ParseItemODRInventory(file, page_offset, count)
  if count == nil then Logging.Error("nil inventory count") return nil end
  local inventory = {}
  for i = 0, count - 1 do
    local id, length = ReadItemODRSectionHeader(file)
    if id ~= 0x69 or length ~= 4 then Logging.Error("expected slot not found") return nil end
    local slot = ReadItemODRData(file, 2)
    local page = ReadItemODRData(file, 2)
    if slot == nil or page == nil then Logging.Error("could not read slot data") return nil end
    inventory[i] = {
      internal = { slot = slot, page = page_offset + page },
      visible = { slot = i % 35, page = i // 35 }
    }
  end
  return inventory
end

function ParseItemODRRetainers(file, count)
  local retainers = {}
  for _ = 1, count do
    local rid = ReadItemODRExpectedBlock(file, 0x52, 8)
    if rid == nil then Logging.Error("could not read retainer id") return nil end
    retainers[rid] = ParseItemODRInventory(file, 10000, ReadItemODRExpectedBlock(file, 0x6E, 4))
    if retainers[rid] == nil then Logging.Error("could not fetch inventory for retainer "..rid) return nil end
  end
  return retainers
end

function ParseItemODR(cid)
  local filepath = _game_folder.."\\FFXIV_CHR"..string.format("%016X", cid).."\\".."ITEMODR.DAT"
  Logging.Debug("parsing item ODR from ".. filepath)
  local file = assert(io.open(filepath, 'rb'))
  local _ = file:read(17) -- skip first 17 bytes

  local inventory_index = 1
  local inventories = {
    { 'inventory', nil, 0 },
    { 'armoury', 'Main', 3500 },
    { 'armoury', 'Off', 3200 },
    { 'armoury', 'Head', 3201 },
    { 'armoury', 'Body', 3202 },
    { 'armoury', 'Hand', 3203 },
    { 'armoury', 'Waist', 3204 },
    { 'armoury', 'Legs', 3205 },
    { 'armoury', 'Feet', 3206 },
    { 'armoury', 'Neck', 3207 },
    { 'armoury', 'Ears', 3208 },
    { 'armoury', 'Wrist', 3209 },
    { 'armoury', 'Ring', 3300 },
    { 'armoury', 'Soul', 3400 },
    { 'saddle', nil, 4000 },
    { 'saddle2', nil, 4100 },
  }

  local data = {}
  local function addData(inventory, inv_data)
    if inventory[2] then
      if not data[inventory[1]] then data[inventory[1]] = {} end
      data[inventory[1]][inventory[2]] = inv_data
    else
      data[inventory[1]] = inv_data
    end
  end

  while data.inventory == nil or data.retainers == nil do
    local id, length = ReadItemODRSectionHeader(file)
    if id == nil or length == nil then
      break
    elseif id == 0x6E then
      if length ~= 4 then Logging.Debug("bad inventory length") break end
      local next_inv = inventories[inventory_index]
      if next_inv then
        inventory_index = inventory_index + 1
        local parsed_inv = ParseItemODRInventory(file, next_inv[3], ReadItemODRData(file, length))
        if parsed_inv == nil then Logging.Debug("bad inventory data") break end
        addData(next_inv, parsed_inv)
      else
        _ = file:read(length) -- skip
      end
    elseif id == 0x4E and data.retainers == nil then
      if length ~= 4 then Logging.Debug("bad retainers length") break end
      data.retainers = ParseItemODRRetainers(file, ReadItemODRData(file, length))
      if data.retainers == nil then Logging.Debug("bad retainers data") break end
    else
      _ = file:read(length) -- skip
    end
  end

  file:close()

  if data.inventory == nil then Logging.Error("failed to find character inventory data") return nil end
  if data.retainers == nil then Logging.Error("failed to find retainers inventory data") return nil end
  return data
end
