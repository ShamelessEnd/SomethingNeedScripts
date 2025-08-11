require "ARUtils"
require "Fishing"
require "GCTurnIn"
require "Navigation"
require "Purchase"
require "Undercut"

local _default_tables = {
  [1] = nil,
  [2] = nil,
}

local _default_thresholds = {
  inv = 40,
  venture = nil,
  repair = {
    min = 200,
    max = 900,
    price = 3400,
    gil_floor = nil,
  },
  fish = {
    food = 4673,
    offset = 0,
    pre_time = -450,
    end_buf = 150,
  },
}

function ARPostProcess(retainer_tables, thresholds)
  local ar_data = GetARCharacterData()
  if not ar_data then return end
  if not retainer_tables then retainer_tables = _default_tables end
  if not thresholds then thresholds = _default_thresholds end

  local last_multi = ARKillMulti()

  if ar_data.Enabled == true then
    UndercutAndSellAllRetainers(retainer_tables)
    local lacks_inv_space = thresholds.inv ~= nil and GetInventoryFreeSlotCount() < thresholds.inv
    local lacks_ventures = thresholds.venture ~= nil and GetItemCount(21072) < thresholds.venture
    if lacks_inv_space or lacks_ventures then
      GCTurnIn()
      ReturnToBell()
    end
  end

  if ar_data.WorkshopEnabled == true and thresholds.repair then
    local lacks_repairs = thresholds.repair.min ~= nil and GetItemCount(10373) < thresholds.repair.min
    if lacks_repairs then
      if not IsInHousingDistrict() then
        ReturnToFC()
      end
      GoPurchaseItems({{ 10373, thresholds.repair.max, thresholds.repair.price }}, thresholds.repair.gil_floor)
      ReturnToFC()
    end
  end

  if thresholds.fish then
    local fisher = ARFindFishCharacterToLevel()
    if fisher and IsTimeToGoFish(thresholds.fish.offset, thresholds.fish.pre_time, thresholds.fish.end_buf) then
      ARRelogTo(fisher)
      GoDoOceanFishing(thresholds.fish.food, thresholds.fish.offset)
      ReturnToBell()
    end
  end

  if last_multi then
    Logout()
    ARSetMultiModeEnabled(true)
  end
end

function ARPostSimple(thresholds)
  local ar_data = GetARCharacterData()
  if not ar_data then return end
  if not thresholds then thresholds = _default_thresholds end

  if ar_data.Enabled == true then
    local lacks_inv_space = thresholds.inv ~= nil and GetInventoryFreeSlotCount() < thresholds.inv
    local lacks_ventures = thresholds.venture ~= nil and GetItemCount(21072) < thresholds.venture
    if lacks_inv_space or lacks_ventures then
      GCTurnIn()
      ReturnToFC()
    end
  end
end
