
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

function IsInZone()

end

function NavIsReady()

end

function LifestreamAbort()

end

function ARSetSuppressed()

end

function ARGetRegisteredEnabledCharacters()

end

function ARGetCharacterData()

end

function IsAddonReady()

end

function IsNodeVisible()

end

function GetNodeText()

end

function GetTargetName()

end

function IsAddonVisible()

end

function GetDistanceToTarget()

end

function ExecuteGeneralAction()

end

function LifestreamIsBusy()

end

function LifestreamTeleport()

end

function GetDistanceToObject()

end

function GetTargetRawXPos()

end

function GetTargetRawYPos()

end

function GetTargetRawZPos()

end

function PathfindAndMoveTo()

end

function GetDistanceToPoint()

end

function PathStop()

end

function NavRebuild()

end

function LifestreamTeleportToFC()

end

function LifestreamTeleportToApartment()

end

function LifestreamExecuteCommand()

end

function GetObjectRawXPos()

end

function GetObjectRawYPos()

end

function GetObjectRawZPos()

end

function NavBuildProgress()

end

function PathIsRunning()

end

function PathfindInProgress()

end

function ADIsStopped()

end

function QuestionableIsRunning()

end

function IsAetheryteUnlocked()

end

function GetZoneID()

end

function GetZoneName()

end

function GetAetherytesInZone()

end

function IsQuestAccepted()

end

function LeaveDuty()

end

function TargetClosestEnemy()

end

function HasTarget()

end

function GetPartyMemberName()

end

function GetDistanceToPartyMember()

end

function ClearTarget()

end

function IsTargetMounted()

end

function GetPartyLeadIndex()

end

function GetPartyMemberHP()

end

function IsPartyMemberInCombat()

end

function GetTargetFateID()

end

function IsTargetInCombat()

end

function GetPartyMemberHPP()

end

function OpenRegularDuty()

end

function SetDFUnrestricted()

end

function TerritorySupportsMounting()

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
