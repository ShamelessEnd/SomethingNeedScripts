require "Logging"

function GetARCharacterData()
  Logging.Debug("fetching AR character data")
  local data = ARGetCharacterData(GetPlayerContentId())
  if data ~= nil and type(data) == "userdata" then
    return data
  end
  return nil
end
