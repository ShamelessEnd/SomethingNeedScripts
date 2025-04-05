require "Logging"

function GetARCharacterData(cid)
  if not cid then cid = GetPlayerContentId() end
  if not cid then return nil end
  Logging.Debug("fetching AR character data "..cid)
  local data = ARGetCharacterData(cid)
  if data ~= nil and type(data) == "userdata" then
    return data
  end
  return nil
end
