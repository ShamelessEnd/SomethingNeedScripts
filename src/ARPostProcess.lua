require "ARPostPurchase"
require "ARPostUndercut"
require "ARUtils"
require "Navigation"
require "GCTurnIn"

local _default_thresholds = {
  inv = 40,
  venture = nil,
  repair = nil,
}

function ARPostProcess(thresholds)
  local ar_data = GetARCharacterData()
  if ar_data == nil then
    return
  end

  if thresholds == nil then
    thresholds = _default_thresholds
  end

  if ar_data.Enabled == true then
    ARPostUndercut()
    local lacks_inv_space = thresholds.inv ~= nil and GetInventoryFreeSlotCount() < thresholds.inv
    local lacks_ventures = thresholds.venture ~= nil and GetItemCount(21072) < thresholds.venture
    if lacks_inv_space or lacks_ventures then
      GCTurnIn()
      ReturnToBell()
    end
  end

  if ar_data.WorkshopEnabled == true then
    local lacks_repairs = thresholds.repair ~= nil and GetItemCount(10373) < thresholds.repair
    if lacks_repairs then
      ARPostPurchase()
    end
  end
end
