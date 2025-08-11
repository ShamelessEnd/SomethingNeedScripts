import "System.Numerics"

function LogDebug(msg)
  -- Currently Broken
end

function ExecuteGeneralAction(action)
  Actions.ExecuteGeneralAction(action)
end

function GetCharacterName(includeWorld)
  if includeWorld then
    return Player.Entity.Name.."@"..Excel.World:GetRow(Player.Entity.HomeWorld).Name
  end
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
  return Player.Entity.Position.X
end

function GetPlayerRawYPos()
  return Player.Entity.Position.Y
end

function GetPlayerRawZPos()
  return Player.Entity.Position.Z
end

function GetLevel(jobId)
  if jobId == nil then
    return Player.Job.Level
  end
  return Player.GetJob(jobId).Level
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

function IsInFate()
  return Fates.CurrentFate ~= nil
end

function GetInventoryFreeSlotCount()
  return Inventory.GetFreeInventorySlots()
end

function GetItemCount(id, includeHQ)
  if includeHQ == false then
    return Inventory.GetItemCount(id)
  end
  return Inventory.GetItemCount(id) + Inventory.GetHqItemCount(id)
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
    return Entity.Target.Position.X
  end
  return 0
end

function GetTargetRawYPos()
  if HasTarget() then
    return Entity.Target.Position.Y
  end
  return 0
end

function GetTargetRawZPos()
  if HasTarget() then
    return Entity.Target.Position.Z
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
    return obj.Position.X
  end
  return 0
end

function GetObjectRawYPos(name)
  local obj = Entity.GetEntityByName(name)
  if obj then
    return obj.Position.Y
  end
  return 0
end

function GetObjectRawZPos(name)
  local obj = Entity.GetEntityByName(name)
  if obj then
    return obj.Position.Z
  end
  return 0
end

function GetPartyMemberName(index)
  local member = Svc.Party[index]
  if member then
    return member.Name.TextValue
  end
  return ""
end

function GetDistanceToPartyMember(index)
  local member = Svc.Party[index]
  if member then
    return Vector3.Distance(member.Position, Player.Entity.Position)
  end
  return 0
end

function GetPartyLeadIndex()
  return Svc.Party.PartyLeaderIndex
end

function GetPartyMemberHP(index)
  local member = Svc.Party[index]
  if member then
    return member.CurrentHP
  end
  return 0
end

function GetPartyMemberMaxHP(index)
  local member = Svc.Party[index]
  if member then
    return member.MaxHP
  end
  return 0
end

function GetPartyMemberHPP(index)
  return GetPartyMemberHP(index) / GetPartyMemberMaxHP(index) * 100
end

function IsPartyMemberInCombat(index)
  -- hack because Entity.GetPartyMember(index) does not work
  local member = Entity.GetEntityByName(GetPartyMemberName(index))
  if member then
    return member.IsInCombat
  end
  return false
end

function GetPartyMemberRawXPos(index)
  local member = Svc.Party[index]
  if member then
    return member.Position.X
  end
  return 0
end

function GetPartyMemberRawYPos(index)
  local member = Svc.Party[index]
  if member then
    return member.Position.Y
  end
  return 0
end

function GetPartyMemberRawZPos(index)
  local member = Svc.Party[index]
  if member then
    return member.Position.Z
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
    local text = Addons.GetAddon(target):GetNode(...).Text
    if text then
      return text:match("^%s*(.-)%s*$") -- trim
    end
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
  IPC.Lifestream.Abort()
end

function LifestreamIsBusy()
  return IPC.Lifestream.IsBusy()
end

function LifestreamTeleport(aetheryteId, subIndex)
  return IPC.Lifestream.Teleport(aetheryteId, subIndex)
end

function LifestreamTeleportToFC()
  return IPC.Lifestream.TeleportToFC()
end

function LifestreamTeleportToApartment()
  return IPC.Lifestream.TeleportToApartment()
end

function LifestreamExecuteCommand(command)
  IPC.Lifestream.ExecuteCommand(command)
end

function ARSetSuppressed(suppressed)
  -- not available
end

function ARGetCharacterCIDs()
  return IPC.AutoRetainer.GetRegisteredCharacters()
end

function ARGetCharacterData(cid)
  return IPC.AutoRetainer.GetOfflineCharacterData(cid)
end

function ARGetMultiModeEnabled()
  return IPC.AutoRetainer.GetMultiModeEnabled()
end

function ARSetMultiModeEnabled(enabled)
  IPC.AutoRetainer.SetMultiModeEnabled(enabled)
end

function ARAbortAllTasks()
  IPC.AutoRetainer.AbortAllTasks()
end

function ARFinishCharacterPostProcess()
  -- not available
end

function ARIsBusy()
  return IPC.AutoRetainer.IsBusy()
end

function QuestionableIsRunning()
  return IPC.Questionable.IsRunning()
end

function IsQuestAccepted(id)
  return Quests.IsQuestAccepted(id)
end

function ADRun(duty, count)
  IPC.AutoDuty.Run(duty, count, false)
end

function ADIsStopped()
  return IPC.AutoDuty.IsStopped()
end

function LeaveDuty()
  InstancedContent.LeaveCurrentContent()
end

function OpenRegularDuty(duty)
  Instances.DutyFinder:OpenRegularDuty(duty)
end

function SetDFUnrestricted(unrestricted)
  Instances.DutyFinder.IsUnrestrictedParty = unrestricted
end

function SetAutoHookState(enabled)
  IPC.AutoHook.SetPluginState(enabled)
end

function DeliverooIsTurnInRunning()
  -- removed
  return false
end
