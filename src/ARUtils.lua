require "Logging"

function GetARCharacterData()
  Logging.Debug("fetching AR character data")
  local char = GetCharacterName(true)
  local data = ARGetCharacterData(GetPlayerContentId())
  if data ~= nil and type(data) == "userdata" and data.Name.."@"..data.World == char then
    return data
  end
  return nil
end
