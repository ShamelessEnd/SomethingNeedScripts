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
  local cid = GetPlayerContentId()
  local char_data = GetARCharacterData(cid)
  if char_data == nil then
    Logging.Info("failed to load AR character data - no retainer data will be available")
  end
  local inv_data = ParseItemODR(cid)
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
  if char_data and char_data.RetainerData.Count > 0 then
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
      visible = mapping.visible,
      internal = mapping.internal,
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

function MoveItemsToArmouryChest(items)
  local inv_types = { InventoryType.Inventory1, InventoryType.Inventory2, InventoryType.Inventory3, InventoryType.Inventory4 }
  for _, inv in pairs(inv_types) do
    local inv_items = Inventory.GetInventoryContainer(inv).Items
    for i = 0, inv_items.Count - 1 do
      local item = inv_items[i]
      local id = item.ItemId
      local dest = item.ArmouryContainer
      if id and id > 0 and dest and dest ~= InventoryType.Invalid and dest ~= inv and TableContains(items, id) then
        repeat
          item:MoveItemSlot(item.ArmouryContainer)
        until WaitUntil(function () return item.ItemId ~= id end, 1)
      end
    end
  end
end

function RetrieveItemsFromRetainer(item_ids)
  local source_types = {
    InventoryType.RetainerPage1,
    InventoryType.RetainerPage2,
    InventoryType.RetainerPage3,
    InventoryType.RetainerPage4,
    InventoryType.RetainerPage5,
    InventoryType.RetainerPage6,
    InventoryType.RetainerPage7
  }
  local dest_types = { InventoryType.Inventory1, InventoryType.Inventory2, InventoryType.Inventory3, InventoryType.Inventory4 }
  MoveItems(item_ids, source_types, dest_types)
end

function MoveItems(item_ids, source_types, dest_types)
  local function firstFreeContainer()
    for _, i in pairs(dest_types) do
      local container = Inventory.GetInventoryContainer(i)
      if container and container.FreeSlots > 0 then return i end
    end
    return InventoryType.Invalid
  end

  for _, inv in pairs(source_types) do
    local inv_items = Inventory.GetInventoryContainer(inv).Items
    for i = 0, inv_items.Count - 1 do
      local item = inv_items[i]
      local id = item.ItemId
      local dest = firstFreeContainer()
      if not id or id <= 0 then
        Logging.Debug("invalid item id")
      elseif not TableContains(item_ids, id) then
        Logging.Debug("non matching item")
      elseif not dest or dest == InventoryType.Invalid then
        Logging.Error("no valid destination slot to move item into")
      elseif dest ~= inv then
        repeat
          item:MoveItemSlot(dest)
        until WaitUntil(function () return item.ItemId ~= id end)
      end
    end
  end
end

function GetInternalInventoryItem(internal_page, internal_slot)
  local inventory_type = ToInventoryType(internal_page)
  if inventory_type == InventoryType.Invalid then
    Logging.Error("invalid internal page")
    return
  end
  return Inventory.GetInventoryItemBySlot(inventory_type, internal_slot)
end

function ToInventoryType(container_id)
  if container_id == 0 then return InventoryType.Inventory1
  elseif container_id == 1 then return InventoryType.Inventory2
  elseif container_id == 2 then return InventoryType.Inventory3
  elseif container_id == 3 then return InventoryType.Inventory4

  elseif container_id == 1000 then return InventoryType.EquippedItems

  elseif container_id == 2000 then return InventoryType.Currency
  elseif container_id == 2001 then return InventoryType.Crystals
  elseif container_id == 2003 then return InventoryType.Mail
  elseif container_id == 2004 then return InventoryType.KeyItems
  elseif container_id == 2005 then return InventoryType.HandIn
  elseif container_id == 2007 then return InventoryType.DamagedGear
  elseif container_id == 2009 then return InventoryType.Examine

  elseif container_id == 3200 then return InventoryType.ArmoryOffHand
  elseif container_id == 3201 then return InventoryType.ArmoryHead
  elseif container_id == 3202 then return InventoryType.ArmoryBody
  elseif container_id == 3203 then return InventoryType.ArmoryHands
  elseif container_id == 3204 then return InventoryType.ArmoryWaist
  elseif container_id == 3205 then return InventoryType.ArmoryLegs
  elseif container_id == 3206 then return InventoryType.ArmoryFeets
  elseif container_id == 3207 then return InventoryType.ArmoryEar
  elseif container_id == 3208 then return InventoryType.ArmoryNeck
  elseif container_id == 3209 then return InventoryType.ArmoryWrist
  elseif container_id == 3300 then return InventoryType.ArmoryRings
  elseif container_id == 3400 then return InventoryType.ArmorySoulCrystal
  elseif container_id == 3500 then return InventoryType.ArmoryMainHand

  elseif container_id == 4000 then return InventoryType.SaddleBag1
  elseif container_id == 4001 then return InventoryType.SaddleBag2
  elseif container_id == 4100 then return InventoryType.PremiumSaddleBag1
  elseif container_id == 4101 then return InventoryType.PremiumSaddleBag2

  elseif container_id == 10000 then return InventoryType.RetainerPage1
  elseif container_id == 10001 then return InventoryType.RetainerPage2
  elseif container_id == 10002 then return InventoryType.RetainerPage3
  elseif container_id == 10003 then return InventoryType.RetainerPage4
  elseif container_id == 10004 then return InventoryType.RetainerPage5
  elseif container_id == 10005 then return InventoryType.RetainerPage6
  elseif container_id == 10006 then return InventoryType.RetainerPage7
  elseif container_id == 11000 then return InventoryType.RetainerEquippedItems
  elseif container_id == 12000 then return InventoryType.RetainerGil
  elseif container_id == 12001 then return InventoryType.RetainerCrystals
  elseif container_id == 12002 then return InventoryType.RetainerMarket

  elseif container_id == 20000 then return InventoryType.FreeCompanyPage1
  elseif container_id == 20001 then return InventoryType.FreeCompanyPage2
  elseif container_id == 20002 then return InventoryType.FreeCompanyPage3
  elseif container_id == 20003 then return InventoryType.FreeCompanyPage4
  elseif container_id == 20004 then return InventoryType.FreeCompanyPage5
  elseif container_id == 22000 then return InventoryType.FreeCompanyGil
  elseif container_id == 22001 then return InventoryType.FreeCompanyCrystals

  elseif container_id == 25000 then return InventoryType.HousingExteriorAppearance
  elseif container_id == 25001 then return InventoryType.HousingExteriorPlacedItems
  elseif container_id == 25002 then return InventoryType.HousingInteriorAppearance
  elseif container_id == 25003 then return InventoryType.HousingInteriorPlacedItems1
  elseif container_id == 25004 then return InventoryType.HousingInteriorPlacedItems2
  elseif container_id == 25005 then return InventoryType.HousingInteriorPlacedItems3
  elseif container_id == 25006 then return InventoryType.HousingInteriorPlacedItems4
  elseif container_id == 25007 then return InventoryType.HousingInteriorPlacedItems5
  elseif container_id == 25008 then return InventoryType.HousingInteriorPlacedItems6
  elseif container_id == 25009 then return InventoryType.HousingInteriorPlacedItems7
  elseif container_id == 25010 then return InventoryType.HousingInteriorPlacedItems8

  elseif container_id == 27000 then return InventoryType.HousingExteriorStoreroom
  elseif container_id == 27001 then return InventoryType.HousingInteriorStoreroom1
  elseif container_id == 27002 then return InventoryType.HousingInteriorStoreroom2
  elseif container_id == 27003 then return InventoryType.HousingInteriorStoreroom3
  elseif container_id == 27004 then return InventoryType.HousingInteriorStoreroom4
  elseif container_id == 27005 then return InventoryType.HousingInteriorStoreroom5
  elseif container_id == 27006 then return InventoryType.HousingInteriorStoreroom6
  elseif container_id == 27007 then return InventoryType.HousingInteriorStoreroom7
  elseif container_id == 27008 then return InventoryType.HousingInteriorStoreroom8
  end

  return InventoryType.Invalid
end
