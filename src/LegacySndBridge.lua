import "System.Numerics"

function LogDebug(msg)
  -- Currently Broken
end

function GetCharacterName()
  return Player.Entity.Name
end

function GetPlayerContentId()
  return Player.Entity.ContentId
end

function GetPlayerGC()
  return Player.GrandCompany
end

function IsPlayerAvailable()
  return Player.Available and not Player.IsBusy
end

function IsPlayerOccupied()
  return Player.IsBusy
end

function GetHomeWorld()
  return Player.Entity.HomeWorld
end

function GetCurrentWorld()
  return Player.Entity.CurrentWorld
end

function GetPlayerRawXPos()
  return Player.Entity.Position[0]
end

function GetPlayerRawYPos()
  return Player.Entity.Position[1]
end

function GetPlayerRawZPos()
  return Player.Entity.Position[2]
end

function GetLevel()
  return Player.Job.Level
end

function GetHP()
  return Player.Entity.CurrentHp
end

function GetMaxHP()
  return Player.Entity.MaxHp
end

function GetCurrentBait()
  return Player.FishingBait
end

function GetClassJobId()
  return Player.Job.Id
end

function HasStatusId(id)
  for i = 0, Player.Status.Count - 1 do
    if Player.Status[i].StatusId == id then
      return true
    end
  end
  return false
end

function GetStatusTimeRemaining(id)
  for i = 0, Player.Status.Count - 1 do
    if Player.Status[i].StatusId == id then
      return Player.Status[i].RemainingTime
    end
  end
  return 0
end

function GetCharacterCondition(id)
  return Svc.Condition[id]
end

function IsPlayerDead()
  return Svc.Condition[2]
end

function GetInventoryFreeSlotCount()
  return Inventory.GetFreeInventorySlots()
end

function GetItemCount(id)
  return Inventory.GetItemCount(id)
end

function GetItemIdInSlot(page, slot)
  -- wrong or broken
  -- return Inventory.GetInventoryItem(page, slot).ItemId
  -- return Svc.GameInventory:GetInventoryItems(page)[slot].ItemId
  return 0
end

function GetItemCountInSlot(page, slot)
  -- wrong or broken
  -- return Inventory.GetInventoryItem(page, slot).Count
  -- return Svc.GameInventory:GetInventoryItems(page)[slot].Quantity
  return 0
end

function GetGil()
  return Inventory.GetItemCount(1)
end

function GetItemName(id)
  return Excel.Item:GetRow(id).Name
end

function TargetClosestEnemy()
  yield("/targetenemy")
end

function HasTarget()
  return Entity.Target ~= nil
end

function ClearTarget()
  Player.Entity:ClearTarget()
end

function GetTargetName()
  if HasTarget() then
    return Entity.Target.Name
  end
  return ""
end

function GetDistanceToTarget()
  if HasTarget() then
    return Entity.Target.DistanceTo
  end
  return 0
end

function GetTargetRawXPos()
  if HasTarget() then
    return Entity.Target.Position[0]
  end
  return 0
end

function GetTargetRawYPos()
  if HasTarget() then
    return Entity.Target.Position[1]
  end
  return 0
end

function GetTargetRawZPos()
  if HasTarget() then
    return Entity.Target.Position[2]
  end
  return 0
end

function IsTargetInCombat()
  if HasTarget() then
    return Entity.Target.IsInCombat
  end
  return false
end

function IsTargetMounted()
 if HasTarget() then
    return Entity.Target.IsMounted
  end
  return false
end

function GetTargetFateID()
 if HasTarget() then
    return Entity.Target.FateId
  end
  return 0
end

function GetDistanceToObject(name)
  local obj = Entity.GetEntityByName(name)
  if obj then
    return obj.DistanceTo
  end
  return 0
end

function GetObjectRawXPos(name)
  local obj = Entity.GetEntityByName(name)
  if obj then
    return obj.Position[0]
  end
  return 0
end

function GetObjectRawYPos(name)
  local obj = Entity.GetEntityByName(name)
  if obj then
    return obj.Position[1]
  end
  return 0
end

function GetObjectRawZPos(name)
  local obj = Entity.GetEntityByName(name)
  if obj then
    return obj.Position[2]
  end
  return 0
end

function IsAddonReady(target)
  return Addons.GetAddon(target).Ready
end

function IsAddonVisible(target)
  return IsAddonReady(target)
end

function IsNodeVisible(target, ...)
  if Addons.GetAddon(target).Exists then
    return Addons.GetAddon(target):GetNode(...).IsVisible
  end
  return false
end

function GetNewNodeText(target, ...)
  if Addons.GetAddon(target).Exists then
    return Addons.GetAddon(target):GetNode(...).Text
  end
  return ""
end

function GetNodeText(target, ...)
  -- no longer functions with old indexes
  -- must update to use GetNewNodeText, which uses the same indexes as IsNodeVisible
  return ""
end

function GetZoneID()
  return Svc.ClientState.TerritoryType
end

function IsInZone(zone)
  return GetZoneID() == zone
end

function GetZoneName(zone)
  return Excel.TerritoryType[zone].PlaceName.Name
end

function TerritorySupportsMounting()
  return Player.CanMount
end

function GetAetherytesInZone(zone)
  local aetherytes = {}
  local aetheryteList = Svc.AetheryteList
  for i = 0, aetheryteList.Count - 1 do
    local aetheryte = aetheryteList[i]
    if aetheryte.TerritoryId == zone then
      table.insert(aetherytes, aetheryte.AetheryteId)
    end
  end
  return aetherytes
end

function IsAetheryteUnlocked(id)
  return Instances.Telepo:IsAetheryteUnlocked(id)
end

function NavIsReady()
  return IPC.vnavmesh.IsReady()
end

function PathfindAndMoveTo(x, y, z, fly)
  IPC.vnavmesh.PathfindAndMoveTo(Vector3(x, y, z), fly)
end

function PathfindInProgress()
  return IPC.vnavmesh.PathfindInProgress()
end

function PathStop()
  IPC.vnavmesh.Stop()
end

function PathIsRunning()
  IPC.vnavmesh.IsRunning()
end

function NavRebuild()
  IPC.vnavmesh.Rebuild()
end

function NavBuildProgress()
  return IPC.vnavmesh.BuildProgress()
end

function GetDistanceToPoint(x, y, z)
  return Vector3.Distance(Vector3(x, y, z), Player.Entity.Position)
end

function LifestreamAbort()

end

function ARSetSuppressed()

end

function ARGetRegisteredEnabledCharacters()

end

function ARGetCharacterData()

end

function ExecuteGeneralAction()

end

function LifestreamIsBusy()

end

function LifestreamTeleport()

end

function LifestreamTeleportToFC()

end

function LifestreamTeleportToApartment()

end

function LifestreamExecuteCommand()

end

function ADIsStopped()

end

function QuestionableIsRunning()

end

function IsQuestAccepted()

end

function LeaveDuty()

end

function GetPartyMemberName()

end

function GetDistanceToPartyMember()

end

function GetPartyLeadIndex()

end

function GetPartyMemberHP()

end

function IsPartyMemberInCombat()

end

function GetPartyMemberHPP()

end

function OpenRegularDuty()

end

function SetDFUnrestricted()

end

function QueryMeshPointOnFloorX()

end

function QueryMeshPointOnFloorY()

end

function QueryMeshPointOnFloorZ()

end

function GetPartyMemberWorldName()

end

function IsInFate()

end

function GetFateMaxLevel()

end

function GetNearestFate()

end

function GetPartyMemberRawXPos()

end

function GetPartyMemberRawYPos()

end

function GetPartyMemberRawZPos()

end

function GetPartyMemberMaxHP()

end

function ADRun()

end

function ARIsBusy()

end

function DropboxSetItemQuantity()

end

function DropboxStart()

end

function DropboxIsBusy()

end

function ARGetCharacterCIDs()

end

function SetAutoHookState()

end

function ARGetMultiModeEnabled()

end

function ARSetMultiModeEnabled()

end

function ARAbortAllTasks()

end

function ARFinishCharacterPostProcess()

end

function DeliverooIsTurnInRunning()
  -- deprecated
  return false
end
