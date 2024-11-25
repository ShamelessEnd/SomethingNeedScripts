
--           ITEMODR.DAT format
--   ID | Name      | DL | Variable       | Note
-- -----------------------------------------------------
-- 0x56 | Unknown   | ?? | ???            | idk what this actually does. I read the length byte and skip it
-- 0x6E | Inventory | 04 | Slot Count     | Expects [Slot Count] 'Slot' sections to follow
-- 0x69 | Slot      | 04 | Slot/Container | 2 shorts, Slot Index and Container Index
-- 0x4E | Retainers | 04 | Retainer Count | Expects [Retainer Count] 'Retainer' sections to follow
-- 0x52 | Retainer  | 08 | Retainer ID    | Has an 'Inventory' section directly following

local game_folder =  "D:\\Documents\\My Games\\FINAL FANTASY XIV - A Realm Reborn"
local debug = false
function LogDebug(message) if debug then yield(""..message) end end
local xor = 0x73 -- xor encryption byte

function ReadXORData(f, k, n)
  local x = 0
  for i = 0, n - 1 do
    b = f:read(1)
    if b == nil then LogDebug("read nil") return nil end
    x = x + ((string.byte(b) ~ k) << (8 * i))
  end
  return x
end

function ReadIdentifier(f)
  return ReadXORData(f, xor, 1), ReadXORData(f, xor, 1)
end

function ReadBlock(f, eid, elen)
  local id, len = ReadIdentifier(f)
  if id ~= eid or len ~= elen then LogDebug("bad block") return nil end
  return ReadXORData(f, xor, len)
end

function ParseInventory(f, o, n)
  if n == nil then LogDebug("nil count") return nil end
  local inventory = {}
  for i = 0, n - 1 do
    local id, len = ReadIdentifier(f)
    if id ~= 0x69 or len ~= 4 then LogDebug("not slot") return nil end
    s = ReadXORData(f, xor, 2)
    p = ReadXORData(f, xor, 2)
    if s == nil or p == nil then LogDebug("bad slot") return nil end
    inventory[i] = {
      internal = { slot = s, page = o + p },
      visible = { slot = i % 35, page = i // 35 }
    }
  end
  return inventory
end

function ParseRetainers(f, n)
  local retainers = {}
  for _ = 1, n do
    local rid = ReadBlock(f, 0x52, 8)
    if rid == nil then LogDebug("bad rid") return nil end
    retainers[rid] = ParseInventory(f, 10000, ReadBlock(f, 0x6E, 4))
    if retainers[rid] == nil then LogDebug("bad rinv") return nil end
  end
  return retainers
end

function ParseItemOrder(cid)
  local file = game_folder.."\\FFXIV_CHR"..string.format("%016X", cid).."\\".."ITEMODR.DAT"
  local f = assert(io.open(file, 'rb'))
  f:read(17) -- skip first 17 bytes

  local data = {}
  while true do
    local id, len = ReadIdentifier(f)
    if id == nil or len == nil then
      break
    elseif id == 0x6E and data.inventory == nil then
      if len ~= 4 then LogDebug("bad clen") return nil end
      data.inventory = ParseInventory(f, 0, ReadXORData(f, xor, len))
      if data.inventory == nil then LogDebug("bad cinv") return nil end
    elseif id == 0x4E and data.retainers == nil then
      if len ~= 4 then LogDebug("bad rlen") return nil end
      data.retainers = ParseRetainers(f, ReadXORData(f, xor, len))
      if data.retainers == nil then LogDebug("bad ret") return nil end
    else
      f:read(len)
    end
  end

  f:close()
  return data
end

function GetARCharacterData()
  local char = GetCharacterName(true)
  local cids = ARGetCharacterCIDs()
  for i = 0, cids.Count - 1 do
    local data = ARGetCharacterData(cids[i])
    if data.Name.."@"..data.World == char then
      return data
    end
  end
  return nil
end


local charData = GetARCharacterData()
local itemOdr = ParseItemOrder(charData.CID)
for i, s in pairs(itemOdr.inventory) do
  yield("  "..i.." ("..s.visible.page.."."..s.visible.slot..")-["..s.internal.page.."."..s.internal.slot.."]: "..GetItemIdInSlot(s.internal.page, s.internal.slot))
end
