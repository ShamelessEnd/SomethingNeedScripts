
local minInventorySpace = 40
local minVentureCount = 100
local undercutAlways = false

function IsARActiveCharacter()
  local chars = ARGetRegisteredEnabledCharacters()
  for i = 0, chars.Count - 1 do
    if chars[i] == GetCharacterName(true) then
      return true
    end
  end
  return false
end


if IsARActiveCharacter() == true then
  if undercutAlways then
    yield("/runmacro ARPostUndercut")
  end
  if GetInventoryFreeSlotCount() < minInventorySpace or GetItemCount(21072) < minVentureCount then
    if not undercutAlways then
      yield("/runmacro ARPostUndercut")
    end
    yield("/runmacro GCTurnIn")
    yield("/runmacro ReturnToBell")
  end
end
