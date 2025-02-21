require "Logging"

function IsARActiveCharacter()
  local chars = ARGetRegisteredEnabledCharacters()
  for i = 0, chars.Count - 1 do
    if chars[i] == GetCharacterName(true) then
      return true
    end
  end
  return false
end

function GetARCharacterData()
  LogDebug("fetching AR character data")
  local char = GetCharacterName(true)
  local data = ARGetCharacterData(GetPlayerContentId())
  ---@diagnostic disable-next-line: undefined-field
  if data ~= nil and type(data) == "userdata" and data.Name.."@"..data.World == char then
    return data
  end
  return nil
end
