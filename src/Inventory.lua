require "ARUtils"
require "ItemODR"
require "Logging"

local lazy_inventory_data = {}
local loaded_inventory_data = false
function GetLazyInventoryData()
  local retry_count = 3
  while not loaded_inventory_data and retry_count > 0 do
    LoadLazyInventoryData()
    retry_count = retry_count - 1
  end

  return lazy_inventory_data
end

function LoadLazyInventoryData()
  Logging.Debug("attempting to load inventory data")
  local char_data = GetARCharacterData()
  if char_data == nil then
    Logging.Error("failed to load character data")
    return
  end
  local inv_data = ParseItemODR(char_data.CID)
  if inv_data == nil then
    Logging.Error("failed to load inventory data")
    return
  end

  for inv_type, inv_type_data in pairs(inv_data) do
    if inv_type ~= 'retainers' then
      lazy_inventory_data[inv_type] = inv_type_data
    end
  end
  lazy_inventory_data.retainers = {}
  if char_data.RetainerData.Count > 0 then
    for i = 0, char_data.RetainerData.Count - 1 do
      local retainer_data = char_data.RetainerData[i]
      lazy_inventory_data.retainers[retainer_data.Name] = inv_data.retainers[retainer_data.RetainerID]
    end
  end

  Logging.Debug("inventory data loaded")
  loaded_inventory_data = true
end

function FindItemsInInventory(inventory_map)
  Logging.Debug("searching for items in inventory")
  local items = {}
  if inventory_map == nil then
    return items
  end
  for _, mapping in pairs(inventory_map) do
    local item_id = GetItemIdInSlot(mapping.internal.page, mapping.internal.slot)
    local item_stack = {
      page = mapping.visible.page,
      slot = mapping.visible.slot,
      count = GetItemCountInSlot(mapping.internal.page, mapping.internal.slot),
    }
    if items[item_id] == nil then
      items[item_id] = { item_stack }
    else
      table.insert(items[item_id], item_stack)
    end
  end
  return items
end

function FindItemsInRetainerInventory(name) return FindItemsInInventory(GetLazyInventoryData().retainers[name]) end
function FindItemsInCharacterInventory() return FindItemsInInventory(GetLazyInventoryData().inventory) end
function FindItemsInCharacterArmoury(slot) return FindItemsInInventory(GetLazyInventoryData().armoury[slot]) end
