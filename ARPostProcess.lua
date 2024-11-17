
minInventorySpace = 40
minVentureCount = 100

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
  yield("/runmacro ARPostUndercut")
  if GetInventoryFreeSlotCount() < minInventorySpace or GetItemCount(21072) < minVentureCount then
    yield("/runmacro GCTurnIn")
    yield("/runmacro ReturnToBell")
  end
end
