require "ARPostUndercut"
require "ARUtils"
require "Navigation"
require "GCTurnIn"

function ARPostProcess(min_inv_space, min_venture_count)
  if IsARActiveCharacter() then
    ARPostUndercut()
    local lacks_inv_space = min_inv_space ~= nil and GetInventoryFreeSlotCount() < min_inv_space
    local lacks_ventures = min_venture_count ~= nil and GetItemCount(21072) < min_venture_count
    if lacks_inv_space or lacks_ventures then
      GCTurnIn()
      ReturnToBell()
    end
  end
end
