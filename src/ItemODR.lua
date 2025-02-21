require "Logging"
require "Utils"

local _game_folder =  "D:\\Documents\\My Games\\FINAL FANTASY XIV - A Realm Reborn"
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
  if id ~= expected_id or length ~= expected_length then LogDebug("expected block not found") return nil end
  return ReadItemODRData(file, length)
end

function ParseItemODRInventory(file, page_offset, count)
  if count == nil then LogError("nil inventory count") return nil end
  local inventory = {}
  for i = 0, count - 1 do
    local id, length = ReadItemODRSectionHeader(file)
    if id ~= 0x69 or length ~= 4 then LogError("expected slot not found") return nil end
    local slot = ReadItemODRData(file, 2)
    local page = ReadItemODRData(file, 2)
    if slot == nil or page == nil then LogError("could not read slot data") return nil end
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
    if rid == nil then LogError("could not read retainer id") return nil end
    retainers[rid] = ParseItemODRInventory(file, 10000, ReadItemODRExpectedBlock(file, 0x6E, 4))
    if retainers[rid] == nil then LogError("could not fetch inventory for retainer "..rid) return nil end
  end
  return retainers
end

function ParseItemODR(cid)
  local filepath = _game_folder.."\\FFXIV_CHR"..string.format("%016X", cid).."\\".."ITEMODR.DAT"
  LogDebug("parsing item ODR from ".. filepath)
  local file = assert(io.open(filepath, 'rb'))
  local _ = file:read(17) -- skip first 17 bytes

  local data = {}
  while data.inventory == nil or data.retainers == nil do
    local id, length = ReadItemODRSectionHeader(file)
    if id == nil or length == nil then
      break
    elseif id == 0x6E and data.inventory == nil then
      if length ~= 4 then LogDebug("bad inventory length") break end
      data.inventory = ParseItemODRInventory(file, 0, ReadItemODRData(file, length))
      if data.inventory == nil then LogDebug("bad inventory data") break end
    elseif id == 0x4E and data.retainers == nil then
      if length ~= 4 then LogDebug("bad retainers length") break end
      data.retainers = ParseItemODRRetainers(file, ReadItemODRData(file, length))
      if data.retainers == nil then LogDebug("bad retainers data") break end
    else
      _ = file:read(length) -- skip
    end
  end

  file:close()

  if data.inventory == nil then LogError("failed to find character inventory data") return nil end
  if data.retainers == nil then LogError("failed to find retainers inventory data") return nil end
  return data
end
