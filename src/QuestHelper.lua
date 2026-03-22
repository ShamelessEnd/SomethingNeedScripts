require "ARUtils"
require "Fishing"
require "Inventory"
require "Logging"
require "Navigation"
require "Purchase"
require "Retainer"
require "UINav"
require "Utils"

local function buyChocoboIssuanceAdder()
  WaitUntil(IsPlayerAvailable)
  InteractWith("Serpent Quartermaster", "GrandCompanyExchange")
  Callback("GrandCompanyExchange", true, 2, 1)
  yield("/wait 1")
  Callback("GrandCompanyExchange", true, 0, 6, 1, 0, true, false)
  AwaitAddonReady("SelectYesno")
  Callback("SelectYesno", true, 0)
  AwaitAddonGone("SelectYesno")
  CloseAddon("GrandCompanyExchange")
  yield("/wait 5")
end

local function nameChocoboAdder()
  WaitUntil(IsPlayerAvailable)
  yield("/at n")
  NavToPoint(32.3, -0.05, 70.3, 3, false, 60)
  yield("/at y")
  if not AwaitAddonReady("InputString", 20) then
    InteractWith("Chocobo", "InputString")
  end
  yield("/wait 1")
  Callback("InputString", true, 0, "Choco", " ")
  yield("/wait 1")
  AwaitAddonReady("SelectYesno")
  Callback("SelectYesno", true, 0)
  AwaitAddonGone("SelectYesno")
  yield("/wait 5")
end

local function returnOrGridania() if not DoReturn() then TeleportToGridania() end end

local function enableQuestionableMulti()
  yield("/xlenablecollection Questionable")
  yield("/wait 15")
  IPC.Questionable.ClearQuestPriority()
  IPC.Questionable.AddQuestPriority("39")
  IPC.Questionable.AddQuestPriority("123")
  IPC.Questionable.AddQuestPriority("124")
  --IPC.Questionable.AddQuestPriority("21")
  --IPC.Questionable.AddQuestPriority("22")
  --IPC.Questionable.AddQuestPriority("46")
  --IPC.Questionable.AddQuestPriority("48")
  --IPC.Questionable.AddQuestPriority("67")
  --IPC.Questionable.AddQuestPriority("91")
  IPC.Questionable.AddQuestPriority("680")
  IPC.Questionable.AddQuestPriority("513")
  IPC.Questionable.AddQuestPriority("710")
  IPC.Questionable.AddQuestPriority("725")
  IPC.Questionable.AddQuestPriority("3860")
end

function QuestWatch(target_level, gc, silent)
  yield("/at y")
  yield("/wait 0.1")
  yield("/qst start")
  yield("/wait 1")

  local function returnToZone(zone)
    if IPC.Questionable.GetCurrentQuestId() and IPC.Questionable.GetCurrentStepData() and type(IPC.Questionable.GetCurrentStepData()) ~= "function" then
      zone = IPC.Questionable.GetCurrentStepData().TerritoryId or zone
    end
    if not TeleportToZone(zone) then
      Logging.Warning("no available teleport to original zone, trying aethernet")
      if zone == 148 then
        yield("/li Blue Badger")
      elseif zone == 133 then
        yield("/li Conjurer")
      else
        yield("/li "..GetZoneName(zone))
      end
      yield("/wait 5")
      WaitForNavReady()
      if not GetZoneID() == zone then
        Logging.Error("failed to return to original zone")
        LifestreamAbort()
      end
    end
  end

  local good_count = 0
  local fail_count = 0
  local stuck_count = 0
  local stop_count = 0
  local dead_count = 0
  local duty_count = 0
  local function resetCounts(isFail)
    stuck_count = 0
    stop_count = 0
    dead_count = 0
    duty_count = 0
    if isFail then
      fail_count = fail_count + 1
      good_count = 0
    else
      good_count = good_count + 1
      if good_count > 60 then
        fail_count = 0
      end
    end
  end

  local last_x = 0
  local last_y = 0
  local last_z = 0
  while not target_level or not IsPlayerAvailable() or GetLevel() < target_level or (gc and not Quests.IsQuestComplete(66219)) or not ADIsStopped() do
    if IsPlayerDead() and IsAddonVisible("SelectYesno") and StringStartsWith(GetNewNodeText("SelectYesno", 1, 2), "Return to ") then
      Logging.Warning("player dead, attempting to recover")
      yield("/qst stop")
      local zone = GetZoneID()

      Callback("SelectYesno", true, 0)
      AwaitAddonGone("SelectYesno")
      yield("/wait 3")
      WaitForNavReady()

      returnToZone(zone)
      yield("/qst start")
      yield("/wait 1")
    end

    if GetItemCount(31329) > 0 and ADIsStopped() and not IsInCombat() then
      yield("/qst stop")
      yield("/wait 5")
      if WaitForPlayerReady(10) then
        local coffer_count = GetItemCount(31329)
        repeat
          yield("/item "..GetItemName(31329))
          yield("/wait 3")
          WaitForPlayerReady()
        until GetItemCount(31329) < coffer_count
        EquipRecommendedGear()
      end
      yield("/qst start")
    end

    if IsQuestAccepted(65913) then
      --yield("/bmai off")
      yield("/bmrai off")
      if IsInCombat() then
        yield("/wrath auto on")
        TargetClosestEnemy()
      end
    elseif IPC.Questionable.GetCurrentStepData() and IPC.Questionable.GetCurrentStepData().InteractionType == "SinglePlayerDuty" then
      --yield("/bmai on")
      yield("/bmrai on")
      yield("/wrath auto on")
    elseif not ADIsStopped() or (InstancedContent.ContentTimeLeft and InstancedContent.ContentTimeLeft > 300) then
      --yield("/bmai on")
      yield("/bmrai on")
      yield("/wrath auto on")
    elseif IsInCombat() then
      --yield("/bmai on")
      yield("/bmrai on")
    else
      --yield("/bmai off")
      yield("/bmrai off")
      yield("/wrath auto off")
    end

    if IsInCombat() or IsPlayerDead() or not NavIsReady() or not IsPlayerAvailable(true) or NavBuildProgress() > 0 then
      last_x = 0
      last_y = 0
      last_z = 0
      resetCounts()
    elseif GetDistanceToPoint(last_x, last_y, last_z) < 2.5 then
      if PathIsRunning() then
        stuck_count = stuck_count + 1
        if stuck_count > 20 then
          Logging.Warning("nav stuck, rebuilding")
          if fail_count == 0 then
            yield("/vnav rebuild")
          elseif fail_count == 1 then
            yield("/qst reload")
          else
            yield("/qst stop")
            PathStop()
            if fail_count >= 3 then
              yield("/xldisablecollection Questionable")
              yield("/wait 2")
              if fail_count >= 4 then
                Logging.Warning("repeated nav stuck, resetting")
                local zone = GetZoneID()
                returnOrGridania()
                returnToZone(zone)
              end
              enableQuestionableMulti()
            end
            RebuildNavMesh()
            yield("/qst start")
          end
          resetCounts(true)
        end
      elseif not ADIsStopped() then
        duty_count = duty_count + 1
        if duty_count > 60 then
          Logging.Error("duty dead, aborting")
          Logging.Notify("failed to complete questing")
          yield("/qst stop")
          LeaveDuty()
          yield("/wait 5")
          WaitForNavReady()
          returnOrGridania()
          return
        end
      elseif not QuestionableIsRunning() then
        stop_count = stop_count + 1
        if stop_count > 5 then
          Logging.Warning("questing stopped, restarting")
          yield("/qst start")
          resetCounts(true)
        end
      else
        dead_count = dead_count + 1
        if dead_count > 5 and IsQuestAccepted(66236) then
          yield("/qst stop")
          if GetItemCount(6018) < 1 then
            buyChocoboIssuanceAdder()
          end
          nameChocoboAdder()
          yield("/qst reload")
          yield("/wait 0.1")
          yield("/qst start")
          resetCounts()
        elseif dead_count > 60 then
          Logging.Warning("questing dead, reloading")
          yield("/qst stop")
          local zone = GetZoneID()
          returnOrGridania()
          yield("/qst reload")
          returnToZone(zone)
          yield("/qst start")
          resetCounts(true)
        end
      end
    else
      last_x = GetPlayerRawXPos() or 0
      last_y = GetPlayerRawYPos() or 0
      last_z = GetPlayerRawZPos() or 0
      resetCounts()
    end

    if fail_count > 5 then
      Logging.Error("repeated failures, aborting")
      Logging.Notify("failed to complete questing")
      yield("/qst stop")
      returnOrGridania()
      return
    end

    yield("/wait 1")
  end

  yield("/qst stop")
  WaitForPlayerReady()
  if not silent then Logging.Notify("questing complete") end
  return true
end

function QuestMulti(chars, level, gc, names, index, count, aetherytes)
  for _, character in ipairs(chars) do
    local function isCharacter() return GetCharacterName(true) == character end
    if not isCharacter() then
      yield("/ays relog "..character)
      if WaitUntil(isCharacter, 300, 1) then WaitForNavReady() end
    end
    if isCharacter() then
      enableQuestionableMulti()
      if aetherytes and GetLevel() > 3 then
        if IsAetheryteUnlocked(2) then PartialGridaniaAethernet() end
        if IsAetheryteUnlocked(8) then
          PartialLimsaAethernet()
          PartialUldahAethernet()
        end
      end
      if IsInHousingDistrict() then returnOrGridania() end
      if QuestWatch(level, gc, true) then
        Logging.Info("levelling complete for "..character)
        if names and index and count then
          if TableIsEmpty(names) then
            Logging.Error("no retainers to create")
          else
            InitOceanFishingRetainers(names, index, count)
          end
        end
      else
        Logging.Info("levelling failed for "..character)
      end
      yield("/wait 5")
      returnOrGridania()
      yield("/wait 1")
    else
      Logging.Error("failed to find character "..character)
    end
  end

  yield("/xldisablecollection Questionable")
  yield("/wait 2")

  Logging.Notify("multi questing complete")
end

function UnlockTeleport()
  if GetLevel() > 3 then return end
  if IsInZone(132) then
    yield("/at n")
    NavToAetheryte()
    yield("/at y")
    yield("/wait 0.2")
    yield("/interact")
    yield("/wait 5")
    WaitUntil(function () return IsPlayerAvailable() and NavIsReady() end)
    PathfindAndMoveTo(155, -13, 159, false)
  end
  WaitUntil(function () return IsPlayerAvailable() and NavIsReady() and GetZoneID() == 148 end)
  NavToPoint(13.08, 0.56, 35.90, 7, false, 300)
  Target("aetheryte")
  yield("/wait 0.2")
  yield("/interact")
  yield("/wait 5")
  WaitUntil(function () return IsPlayerAvailable() and NavIsReady() end)
  yield("/wait 1")
  DoReturn()
end

local function enterAetherialFlow()
  NavToObject("Aetherial Flow", 3, false, 10)
  while not InteractWith("Aetherial Flow", "SelectYesno", 5) do yield("/wait 1") end
  Callback("SelectYesno", true, 0)
  yield("/wait 3")
  WaitUntil(function () return IsPlayerAvailable() and NavIsReady() and IsInZone(1245) end)
end

function FollowPartyLeaderFate()
  local function mountFenrir() while not IsMounted() and not IsInCombat() do PathStop() yield("/mount \"SDS Fenrir\"") WaitUntil(IsMounted, 3) end end
  while true do
    local lead_index = GetPartyLeadIndex()
    local x_t = GetPartyMemberRawXPos(lead_index)
    local y_t = GetPartyMemberRawYPos(lead_index)
    local z_t = GetPartyMemberRawZPos(lead_index)

    if IsPlayerDead() and IsAddonVisible("SelectYesno") and StringStartsWith(GetNewNodeText("SelectYesno", 1, 2), "Return to ") then
      Logging.Info("player dead, attempting to recover")
      Callback("SelectYesno", true, 0)
      AwaitAddonGone("SelectYesno")
      yield("/wait 3")
      WaitForNavReady()
    elseif GetDistanceToPoint(x_t, y_t, z_t) < 20 and IsInFate() then
      if IsMounted() then
        PathStop()
        Dismount()
      end
      if Fates.CurrentFate.MaxLevel < GetLevel() then
        yield("/levelsync on")
      end
      if GetDistanceToPoint(x_t, y_t, z_t) > 5 then
        PathfindAndMoveTo(x_t, y_t, z_t)
      end
      yield("/wait 1")
    else
      mountFenrir()
      if GetDistanceToPoint(x_t, y_t, z_t) > 5 then
        if IsMounted() then
          PathfindAndMoveTo(x_t, y_t+3, z_t, true)
        else
          PathfindAndMoveTo(x_t, y_t, z_t, false)
        end
        for i = 0,50 do
          yield("/wait 0.1")
          if not PathIsRunning() then
            break
          end
        end
      else
        yield("/wait 1")
      end
    end
  end
end

function FollowPartyLeader()
  while true do
    WaitForNavReady()
    if IsAddonReady("SelectYesno") and StringStartsWith(GetNewNodeText("SelectYesno", 1, 2), "Accept Teleport") then
      Callback("SelectYesno", true, 0)
    elseif IsAddonReady("SelectYesno") and StringStartsWith(GetNewNodeText("SelectYesno", 1, 2), "Accept Raise") then
      Callback("SelectYesno", true, 0)
    elseif IsAddonReady("ContentsFinderConfirm") then
      Callback("ContentsFinderConfirm", true, 8)
    elseif not HasTarget() then
      local lead_name = GetPartyMemberName(GetPartyLeadIndex())
      if not TerritorySupportsMounting() and StringIsEmpty(lead_name) then
        yield("/autofollow")
        LeaveDuty()
      else
        Target(GetPartyMemberName(GetPartyLeadIndex()))
      end
    elseif IsTargetMounted() and GetDistanceToTarget() < 5 then
      if not GetCharacterCondition(10) then yield("/ridepillion <t>") end
    elseif not TerritorySupportsMounting() then
      local flow = GetDistanceToObject("Aetherial Flow")
      if flow and flow < 20 then
        enterAetherialFlow()
      else
        NavToTarget(GetTargetName(), 1, false, 10)
      end
    elseif HasTarget() and GetDistanceToTarget() > 5 then
      yield("/follow")
      yield("/gaction jump")
    end
    if TerritorySupportsMounting() then
      yield("/wait 0.5")
    else
      yield("/wait 0.1")
    end
  end
end

function MountAndWaitPillion()
  while not IsMounted() do
    yield("/mount \"Draught Chocobo\"")
    yield("/wait 2")
  end

  local function isPartyMounted()
    for i = 0,7 do
      local name = GetPartyMemberName(i)
      if not StringIsEmpty(name) and (GetDistanceToPartyMember(i) > 0.1 or GetPartyMemberHPP(i) < 20) then
        return false
      end
    end
    return true
  end
  WaitUntil(function () return isPartyMounted() end)
end

function IsPartyInCombat(skipSelf)
  if not skipSelf and IsInCombat() then return true end
  local own_name = GetCharacterName()
  for i = 0,7 do
    local name = GetPartyMemberName(i)
    if not StringIsEmpty(name) and name ~= own_name then
      local old_target = GetTargetName()
      Target(name)
      local inCombat = GetTargetName() == name and IsTargetInCombat()
      if StringIsEmpty(old_target) then ClearTarget() else Target(old_target) end
      if inCombat then return true end
    end
  end
  return false
end

function KillMobs(targets)
  local function needKill()
    for _, count in ipairs(targets) do
      if count > 0 then return true end
    end
    return false
  end

  local partyCombat = IsPartyInCombat()
  while needKill() or partyCombat do
    if partyCombat then
      TargetClosestEnemy()
      yield("/wait 0.2")
    else
      for name, count in pairs(targets) do
        if count > 0 then
          Target(name)
          yield("/wait 0.2")
          if HasTarget() and GetDistanceToTarget() < 25 then
            break
          end
        end
      end
    end

    if HasTarget() and GetDistanceToTarget() < 25 then
      local name = GetTargetName()
      local killTimeout = 10
      local fateID = GetTargetFateID()
      local isFateMob = fateID and fateID > 0
      if isFateMob then
        killTimeout = 30
        yield("/levelsync on")
        yield("/wait 0.1")
      end
      yield("/wrath auto on")
      yield("/wait 0.1")
      if WaitWhile(HasTarget, killTimeout) and targets[name] then
        targets[name] = targets[name] - 1
      end
      yield("/wrath auto off")
      yield("/wait 0.1")
      if isFateMob then
        yield("/levelsync off")
        yield("/wait 0.5")
      end

      if (GetHP() / GetMaxHP()) < 0.5 then
        Target("<me>")
        yield("/wrath auto on")
        yield("/wait 1")
        WaitUntil(function () return (GetHP() / GetMaxHP()) > 0.2 end)
        yield("/wrath auto off")
        yield("/wait 0.1")
        WaitWhile(IsCasting)
        ClearTarget()
      end
    else
      yield("/wait 1")
      ClearTarget()
    end

    partyCombat = IsPartyInCombat()
  end
end

local function goToMobLocation(zone, aetheryte, x, y, z, timeout)
  KillMobs({})
  ResPartyMembers()
  if not IsInZone(zone) then
    while not TeleportToAetheryte(aetheryte) do yield("/wait 5") end
  end
  if TerritorySupportsMounting() then
    MountAndWaitPillion()
  end
  NavToPoint(x, y, z, 1, TerritorySupportsMounting(), timeout or 120)
  yield("/wait 0.2")
  Dismount()
  yield("/wait 0.2")
end

function ResPartyMembers()
  local resd = false
  for i = 0,7 do
    local name = GetPartyMemberName(i)
    if not StringIsEmpty(name) and (GetPartyMemberHP(i) < 0.1 and GetPartyMemberMaxHP(i) > 0.1) then
      Target(name)
      yield("/wait 0.2")
      yield("/ac Swiftcast <wait.1>")
      yield("/ac Raise <t> <wait.9>")
      resd = true
    end
  end
  return resd
end

function GoToKillMobs(zone, aetheryte, x, y, z, name, count, timeout)
  goToMobLocation(zone, aetheryte, x, y, z, timeout)
  local targets = {}
  targets[name] = count
  KillMobs(targets)
end

function GoToKillMobsMulti(zone, aetheryte, x, y, z, targets, timeout)
  goToMobLocation(zone, aetheryte, x, y, z,  timeout)
  KillMobs(targets)
end

local function isInParty(name)
  for i = 0, 7 do
    if GetPartyMemberName(i) == name then return true end
  end
  return false
end

local function isPartyInCombat()
  if IsInCombat() then return true end
  for i = 0, 7 do
    if GetPartyMemberName(i) ~= GetCharacterName() then
      if Entity.GetPartyMember(i).IsInCombat or (GetPartyMemberHP(i) / GetPartyMemberMaxHP(i)) < 0.8 then return true end      
    end
  end
  return false
end

local function getPartyCount()
  local count = 0
  for i = 0, 7 do
    if not StringIsEmpty(GetPartyMemberName(i)) then count = count + 1 end
  end
  return count
end

local function equipCombatJob(min_level)
  if GetClassJobId() ~= 18 then return true end
  repeat
    yield("/armoury")
  until AwaitAddonReady("ArmouryBoard", 1)
  local weapons = FindItemsInCharacterArmoury("Main")
  for id, _ in pairs(weapons) do
    yield("/equip "..id)
    if WaitUntil(function () return GetClassJobId() ~= 18 end, 3) then
      if GetLevel() >= min_level then
        EquipRecommendedGear()
        CloseAddonFast("ArmouryBoard")
        return true
      end
    end
  end
  CloseAddonFast("ArmouryBoard")
  return false
end

local function gcHuntLogInit(target)
  if not equipCombatJob(25) then
    Logging.Error("failed to swap to combat job")
    return
  end
  if isInParty(target) and Target(target) then return GetServerData(Entity.Target.HomeWorld).name end
  if not IsInGridania() or GetDistanceToObject("aetheryte") > 20 then TeleportToGridania() end
  repeat until Target(target)
  local world = GetServerData(Entity.Target.HomeWorld).name
  repeat
    yield("/t <t> hunt-log")
    if AwaitAddonReady("SelectYesno", 10) then
      if GetNewNodeText("SelectYesno", 1, 2):find(target) then
        SelectYesno(0)
        yield("/wait 2")
      else
        SelectYesno(1)
      end
    end
  until isInParty(target)
  return world
end

local function gcHuntCarryInit(sender)
  if not Target(sender) then return end
  yield("/invite <t>")
  if not WaitUntil(function () return isInParty(sender) end, 60) then return end
  if not IsInGridania() or GetDistanceToObject("aetheryte") > 20 then TeleportToGridania() end
end

function RidePillion(target)
  WaitUntil(function () return Target(target) end, 10, 1)
  if not NavToTarget(target, 2, false, 10) then return end
  repeat
    yield("/ridepillion <t>")
    yield("/wait 1")
  until not IsPlayerAvailable()
end

function TryRidePillion(target)
  if not NavToTarget(target, 2, false, 15) then return end
  yield("/ridepillion <t>")
  yield("/wait 1")
end

local function acceptTeleportTo(name, zone, timeout)
  if AwaitAddonReady("SelectYesno", timeout or 8) then
    if GetNewNodeText("SelectYesno", 1, 2):find(name) then
      SelectYesno(0)
      yield("/wait 4")
      return WaitForReadyInZone(zone, 30)
    else
      SelectYesno(1)
    end
  end
  return false
end

local function talkWithNpc(name)
  if NavToTarget(name, 2, false, 15) then
    InteractWith(name)
    yield("/at y")
    WaitUntil(function ()
      TryCallback("SelectIconString", true, 0)
      yield("/wait 0.2")
      TryCallback("JournalAccept", true, -1)
      return IsPlayerAvailable()
    end)
    yield("/at n")
    yield("/wait 0.1")
  end
end

local function gcHuntLogUnlockHalatali(target, fullname)
  if Quests.IsQuestComplete(66233) then return end
  repeat until Target(target)

  repeat yield("/t "..fullname.." unlock-halatali-quest") until acceptTeleportTo("Horizon", 140)
  RidePillion(target)
  WaitForPlayerReady()
  repeat talkWithNpc("Nedrick Ironheart") until IsQuestAccepted(66233)

  repeat yield("/t "..fullname.." unlock-halatali-dungeon") until acceptTeleportTo("Drybone", 145)
  RidePillion(target)
  WaitForPlayerReady()
  repeat talkWithNpc("Fafajoni") until Quests.IsQuestComplete(66233)
end

function IsAdderHuntLogComplete(...)
  repeat
    CloseAddonFast("MonsterNote")
    yield("/wait 0.3")
    if OpenCommandWindow("huntinglog", "MonsterNote") then
      Callback("MonsterNote", true, 3, 9, 2)
      if WaitUntil(function () return GetNewNodeText("MonsterNote", 1, 18, 19, 24):find("Order of the Twin Adder") end, 5) then
        yield("/send NUMPAD0")
        yield("/send NUMPAD0")
        yield("/send NUMPAD0")
        for i = 1, 30 do
          yield("/send DOWN")
        end
      end
    end
  until not StringIsEmpty(GetNewNodeText("MonsterNote", 1, 46, GetNodeListIndex(9, 5), 4))
  for _, arg in ipairs({...}) do
    if not IsNodeVisible("MonsterNote", 1, 46, GetNodeListIndex(arg, 6), 3) then
      CloseAddonFast("MonsterNote")
      return false
    end
  end
  CloseAddonFast("MonsterNote")
  return true
end

local function fightUntilLogComplete(sender, t1, t2)
  local x, y, z = GetPlayerXYZ()
  local check_in = 0
  yield("/bmrai on")
  yield("/wrath auto on")
  repeat
    if Fates.CurrentFate then
      if (GetHP() / GetMaxHP()) < 0.25 then
        yield("/levelsync off")
      elseif Fates.CurrentFate.MaxLevel < GetLevel() then
        yield("/levelsync on")
      end
    end
    yield("/wait 0.1")
    if not IsInCombat() then
      if isPartyInCombat() then
        TargetClosestEnemy()
      elseif Target(t1, 0.25) and check_in < 2 and math.abs(GetTargetRawYPos() - GetPlayerRawYPos()) < 15 then
        NavToTarget(t1, 3, false, 10)
        check_in = check_in + 1
      elseif t2 and Target(t2, 0.25) and check_in < 2 and math.abs(GetTargetRawYPos() - GetPlayerRawYPos()) < 15 then
        NavToTarget(t2, 3, false, 10)
        check_in = check_in + 1
      elseif Target(sender, 0.25) then
        NavToTarget(sender, 1, false, 15)
        yield("/wait 2")
        check_in = 0
      else
        yield("/bmrai off")
        NavToPoint(x, y, z, 2, false, 20)
        yield("/bmrai on")
      end
    elseif GetTargetRawYPos() and math.abs(GetTargetRawYPos() - GetPlayerRawYPos()) > 15 then
      yield("/bmrai off")
      NavToPoint(x, y, z, 2, false, 20)
      yield("/bmrai on")
    else
      CloseAddonFast("Trade")
      TargetClosestEnemy()
    end
  until IsAddonReady("Trade") and not IsInCombat()
  While(function ()
    CloseAddonFast("Trade")
    TargetClosestEnemy()
  end, isPartyInCombat)
  yield("/bmrai off")
  yield("/wrath auto off")
  NavToTarget(sender, 1, false, 10)
  local gil = GetGil()
  while GetGil() >= gil do
    if AwaitAddonReady("Trade", 0.2) then
      Callback("Trade", true, 2)
      if AwaitAddonReady("InputNumeric", 2) then
        Callback("InputNumeric", true, 1)
        if AwaitAddonGone("InputNumeric", 2) then
          Callback("Trade", true, 0)
        end
      end
      while not AwaitAddonGone("Trade", 5) do
        Callback("Trade", true, -1)
      end
    end
  end
  CloseAddonFast("Trade")
  if isPartyInCombat() then
    yield("/bmrai on")
    yield("/wrath auto on")
    RepeatWhile(TargetClosestEnemy, isPartyInCombat)
    yield("/bmrai off")
    yield("/wrath auto off")
  end
end

local function sendLogComplete(target)
  local gil = GetGil()
  RepeatUntil(function ()
    if not IsAddonReady("Trade") and not IsAddonReady("SelectYesno") and Target(target) and GetDistanceToTarget() < 3 then
      yield("/trade")
      yield("/wait 0.1")
    end
  end, function () return GetGil() > gil end)
  CloseAddonFast("Trade")
end

local function waitUntilHuntComplete(target, ...)
  local args = { ... }
  --return FollowUntil(function () return IsAdderHuntLogComplete(table.unpack(args)) end)
  return WaitUntil(function () return IsAdderHuntLogComplete(table.unpack(args)) end)
end

local function gcHuntLogEastThan(target, fullname)
  if IsAdderHuntLogComplete(0, 6, 8) then return end
  repeat yield("/t "..fullname.." hunt-east-than") until acceptTeleportTo("Drybone", 145)
  RidePillion(target)

  WaitForPlayerReady()
  waitUntilHuntComplete(target, 0)
  sendLogComplete(target)
  RidePillion(target)

  WaitForPlayerReady()
  waitUntilHuntComplete(target, 6, 8)
  sendLogComplete(target)
end

local function gcHuntLogEastShroud(target, fullname)
  if IsAdderHuntLogComplete(4) then return end
  repeat yield("/t "..fullname.." hunt-east-shroud") until acceptTeleportTo("Hawthorne", 152)
  RidePillion(target)

  WaitForPlayerReady()
  waitUntilHuntComplete(target, 4)
  sendLogComplete(target)
end

local function gcHuntLogNorthShroudHighlands(target, fullname)
  if IsAdderHuntLogComplete(7, 9) then return end
  repeat yield("/t "..fullname.." hunt-north-shroud") until acceptTeleportTo("Gridania", 132)
  yield("/li North Shroud")
  WaitForReadyInZone(154)
  RidePillion(target)

  WaitForPlayerReady()
  waitUntilHuntComplete(target, 7)
  sendLogComplete(target)
  RidePillion(target)

  WaitForPlayerReady()
  waitUntilHuntComplete(target, 9)
  sendLogComplete(target)
end

local function gcHuntLogLimsaUpper(target, fullname)
  if IsAdderHuntLogComplete(5) then return end
  repeat yield("/t "..fullname.." hunt-limsa-upper") until acceptTeleportTo("Aleport", 138)
  RidePillion(target)

  WaitForPlayerReady()
  waitUntilHuntComplete(target, 5)
  sendLogComplete(target)
end

local function gcHuntLogHalatali(target, fullname)
  while not IsAdderHuntLogComplete(1, 2, 3) do
    yield("/at y")
    yield("/pnotify s 1")
    repeat yield("/t "..fullname.." hunt-halatali") until acceptTeleportTo("Gridania", 132, 4) or AwaitAddonReady("ContentsFinderConfirm", 1)
    if AwaitAddonReady("ContentsFinderConfirm", 5) then
      Callback("ContentsFinderConfirm", true, 8)
      WaitForReadyInZone(1245)
      WaitUntil(function () return IsAddonVisible("_Image") end)

      FollowUntil(target, function ()
        local dist = GetDistanceToObject("Aetherial Flow")
        yield("/wait 0.2")
        return dist and dist > 0 and dist < 15
      end)
      enterAetherialFlow()

      FollowUntil(target, function () return IsAdderHuntLogComplete(1, 2, 3) or getPartyCount() < 2 end)
      LeaveDuty()
      WaitForReadyInZone(132)
    end
    yield("/pnotify r")
    yield("/at n")
  end
end

local function gcHuntCarryUnlockHalataliQuest()
  TeleportToZone(140)
  MountAndWaitPillion()
  NavToPoint(-471.1, 23.0, -355.4, 0.3, true, 300)
  Dismount()
end

local function gcHuntCarryUnlockHalataliDungeon()
  TeleportToZone(145)
  MountAndWaitPillion()
  NavToPoint(-331.5, -22.5, 434.1, 0.3, true, 120)
  Dismount()
end

local function gcHuntCarryEastThan(sender)
  TeleportToZone(145)
  MountAndWaitPillion()

  NavToPoint(-109.6, -29.4, 280.4, 1, true, 300)
  Dismount()
  fightUntilLogComplete(sender, "Amalj'aa Javelinier")
  MountAndWaitPillion()

  NavToPoint(152.2, 12.9, -52.7, 1, true, 300)
  Dismount()
  fightUntilLogComplete(sender, "Amalj'aa Bruiser", "Amalj'aa Ranger")
end

local function gcHuntCarryEastShroud(sender)
  TeleportToZone(152)
  MountAndWaitPillion()

  NavToPoint(-123.1, 15.7, 11.5, 1, true, 300)
  Dismount()
  fightUntilLogComplete(sender, "Sylvan Scream")
end

local function gcHuntCarryNorthShroudHighlands(sender)
  TeleportToGridania()
  yield("/li North Shroud")
  MountAndWaitPillion()

  NavToPoint(72.2, -32.4, 314.7, 1, true, 300)
  Dismount()
  fightUntilLogComplete(sender, "Ixali Deftalon")
  MountAndWaitPillion()

  repeat
    PathfindAndMoveTo(-372, 6.8, 185, true)
  until WaitForReadyInZone(155, 120)
  NavToPoint(509.8, 234.4, 317.6, 1, true, 300)
  Dismount()
  fightUntilLogComplete(sender, "Ixali Fearcaller")
end

local function gcHuntCarryLimsaUpper(sender)
  TeleportToAetheryte(14)
  MountAndWaitPillion()

  repeat
    PathfindAndMoveTo(409, 36, -16, true)
  until WaitForReadyInZone(139, 120)
  NavToPoint(-455.5, 32.3, 44.5, 1, true, 300)
  Dismount()
  fightUntilLogComplete(sender, "Kobold Pickman")
end

local function gcHuntCarryHalatali()
  if not IsInGridania() then TeleportToGridania() end
  EnterHalataliUnrestricted()
  yield("/ad start")
  yield("/wait 5")
  WaitUntil(function ()
    if getPartyCount() < 2 then
      yield("/ad stop")
      LeaveDuty()
    else
      TargetClosestEnemy()
    end
    return ADIsStopped()
  end)
  WaitForReadyInZone(132)
  yield("/wait 1")
end

function GCHuntingLog(target)
  if not Quests.IsQuestComplete(66219) then
    Logging.Notify(GetCharacterName(true).." has not completed MSQ")
    return
  end
  local world = gcHuntLogInit(target)
  if StringIsEmpty(world) then return end
  local fullname = target .. "@" .. world
  gcHuntLogUnlockHalatali(target, fullname)
  gcHuntLogEastThan(target, fullname)
  gcHuntLogEastShroud(target, fullname)
  gcHuntLogNorthShroudHighlands(target, fullname)
  gcHuntLogLimsaUpper(target, fullname)
  gcHuntLogHalatali(target, fullname)
  yield("/leave")
  WaitUntil(function () return getPartyCount() < 2 end)
end

function GCHuntMulti(chars, target, server)
  local function huntLoop()
    yield("/pnotify s 5")
    if TravelToWorld(server) then
      yield("/pnotify r")
      GCHuntingLog("Venom Tertia")
      yield("/pnotify s 5")
      ReturnToHomeWorld()
    end
    yield("/pnotify r")
  end
  local cids = ARFindCids(chars)
  ARApplyToAllCharacters(cids, huntLoop)
end

function GCHuntingLogCarryTrigger()
  local function trimWorld(name)
    for i = #name, 1, -1 do
      if string.match(name:sub(i, i), "%u") then
        return name:sub(1, i - 1)
      end
    end
  end

  if not TriggerData then return end
  if tostring(TriggerData.type) ~= "TellIncoming: 13" then return end
  local sender = trimWorld(TriggerData.sender)

  if not isInParty(sender) then
    if tostring(TriggerData.message) ~= "hunt-log" then return end
    Logging.Echo("hunting log carry request from "..tostring(TriggerData.sender))
    gcHuntCarryInit(trimWorld(TriggerData.sender))
    return
  end

  if tostring(TriggerData.message) == "unlock-halatali-quest" then
    gcHuntCarryUnlockHalataliQuest()
  end

  if tostring(TriggerData.message) == "unlock-halatali-dungeon" then
    gcHuntCarryUnlockHalataliDungeon()
  end

  if tostring(TriggerData.message) == "hunt-east-than" then
    gcHuntCarryEastThan(sender)
  end

  if tostring(TriggerData.message) == "hunt-east-shroud" then
    gcHuntCarryEastShroud(sender)
  end

  if tostring(TriggerData.message) == "hunt-north-shroud" then
    gcHuntCarryNorthShroudHighlands(sender)
  end

  if tostring(TriggerData.message) == "hunt-limsa-upper" then
    gcHuntCarryLimsaUpper(sender)
  end

  if tostring(TriggerData.message) == "hunt-halatali" then
    gcHuntCarryHalatali()
  end

  if getPartyCount() < 2 and not IsInGridania() then TeleportToGridania() end
end

function HuntingLogPrereqs()
  local function mountChocobo() while TerritorySupportsMounting() and not IsMounted() do yield("/mount \"Company Chocobo\"") WaitUntil(IsMounted, 3) end end
  local function waitZoneTransfer(zone) WaitUntil(function () return IsPlayerAvailable() and NavIsReady() and IsInZone(zone) end) end
  local function unlockAetheryte(zone, x, y, z)
    waitZoneTransfer(zone)
    mountChocobo()
    NavToPoint(x, y, z, 7, false, 120)
    Target("aetheryte")
    yield("/wait 0.2")
    yield("/interact")
    yield("/wait 5")
    if IsAddonVisible("SelectString") then
      Callback("SelectString", true, -1)
    end
    WaitUntil(IsPlayerAvailable)
  end

  -- Halatali
  yield("/at n")
  WaitUntil(IsPlayerAvailable)
  while not IsCasting() do
    yield("/item "..GetItemName(30362))
    yield("/wait 0.1")
  end
  waitZoneTransfer(140)
  mountChocobo()
  NavToPoint(-472.5, 23, -355, 3, false, 60)
  Dismount()
  yield("/wait 0.5")
  yield("/at y")
  InteractWith("Nedrick Ironheart", "SelectIconString", 5)
  if AwaitAddonReady("SelectIconString", 5) then
    Callback("SelectIconString", true, 0)
    yield("/wait 2")
  end
  if IsAddonVisible("JournalAccept") then
    Callback("JournalAccept", true, -1)
  end
  WaitUntil(IsPlayerAvailable)
  yield("/at n")
  yield("/wait 1")
  TeleportToAetheryte(18)
  waitZoneTransfer(145)
  mountChocobo()
  NavToPoint(-331, -22.5, 434.9, 3, false, 120)
  Dismount()
  yield("/wait 0.5")
  InteractWith("Fafajoni", "Talk", 5)
  yield("/at y")
  WaitUntil(IsPlayerAvailable)

  -- Fallgourd
  TeleportToGridania()
  yield("/li North Shroud")
  unlockAetheryte(154, -41.6, -38.6, 233.8)

  -- Wolves Den
  yield("/at n")
  TeleportToGridania()
  NavToPoint(-74.5, -0.5, -5.1, 3, false, 60)
  if InteractWith("Vorsaile Heuloix", "JournalAccept", 5) then
    yield("/at y")
    yield("/wait 2")
  end
  if IsAddonVisible("SelectIconString") then
    Callback("SelectIconString", true, -1)
  end
  WaitUntil(IsPlayerAvailable)
  TeleportToAetheryte(10)
  waitZoneTransfer(135)
  yield("/at y")
  NavToPoint(270.75, 4.4, 720.0, 3, false, 60)
  InteractWith("Ferry Skipper", "SelectYesno", 5)
  Callback("SelectYesno", true, 0)
  waitZoneTransfer(250)
  unlockAetheryte(250, 41, 5.5, -14.8)
  yield("/at n")
  NavToPoint(0, 3.6, -30.4, 3, false, 60)
  yield("/at y")
  yield("/wait 3")
  WaitForNavReady()

  -- Wineport
  TeleportToAetheryte(52)
  waitZoneTransfer(134)
  mountChocobo()
  NavToPoint(-164, 35, -725, 5, false, 120)
  PathfindAndMoveTo(-162, 36, -737, false)
  unlockAetheryte(137, -18.4, 72.7, 3.8)

  -- Bronze Lake
  mountChocobo()
  NavToPoint(79, 80, -114, 5, false, 120)
  PathfindAndMoveTo(77, 80, -121, false)
  unlockAetheryte(139, 437.4, 5.5, 94.6)
end

function MonitorGCSeals(count)
  while GetItemCount(21) < count do
    yield("/wait 5")
  end
  Logging.Notify("seal count met")
end

function HuntingLogMobs()
  -- Upper La'No
  GoToKillMobs(139, 15, -483, 27, 56, "Kobold Pickman", 2)
  GoToKillMobs(139, 15, -398, 36, 34, "Kobold Pickman", 1)

  -- East Than
  GoToKillMobs(145, 18, -49, -27, 330, "Amalj'aa Javelinier", 1)
  GoToKillMobs(145, 18, -91, -29, 285, "Amalj'aa Javelinier", 2)
  GoToKillMobsMulti(145, 18, 202, 13, -42, { ["Amalj'aa Ranger"] = 1, ["Amalj'aa Bruiser"] = 1 })
  GoToKillMobsMulti(145, 18, 172, 15, -76, { ["Amalj'aa Ranger"] = 1, ["Amalj'aa Bruiser"] = 1 })
  GoToKillMobsMulti(145, 18, 157, 12, -44, { ["Amalj'aa Ranger"] = 1, ["Amalj'aa Bruiser"] = 1 })

  -- East Shroud
  GoToKillMobs(152, 4, -138, 15, 3, "Sylvan Scream", 1)
  GoToKillMobs(152, 4, -96, 20, 8, "Sylvan Scream", 2)

  -- North Shroud
  GoToKillMobs(154, 7, 72.9, -39.1, 340.2, "Ixali Deftalon", 3)

  -- CCH
  ResPartyMembers()
  MountAndWaitPillion()
  PathfindAndMoveTo(-368, 10, 182, true)
  WaitUntil(function () return IsInZone(155) end)
  GoToKillMobs(155, nil, 480, 233, 318, "Ixali Fearcaller", 1)
  TeleportToGridania()
end

function EnterHalataliUnrestricted()
  yield("/pnotify s 1")
  OpenRegularDuty(7)
  AwaitAddonReady("ContentsFinder")
  SetDFUnrestricted(true)
  while not IsNodeVisible("ContentsFinder", 1, 62, 64, 65) do
    Callback("ContentsFinder", true, 3, 4)
    yield("/wait 1")
  end
  Callback("ContentsFinder", true, 12, 0)
  AwaitAddonReady("ContentsFinderConfirm")
  Callback("ContentsFinderConfirm", true, 8)
  WaitForReadyInZone(1245)
  WaitUntil(function () return IsAddonVisible("_Image") end)
  yield("/wait 1")
  yield("/pnotify r")
end

function HuntingLogHalatali()
  EnterHalataliUnrestricted()
  RebuildNavMesh()
  GoToKillMobs(1245, nil, 200, 6, -36, "Heckler Imp", 1)
  GoToKillMobs(1245, nil, 153, -2, -9, "Heckler Imp", 2)
  GoToKillMobs(1245, nil, 111, -4, 50, "Heckler Imp", 2)
  GoToKillMobs(1245, nil, 16.3, 0.9, 122.2, "Firemane", 1, 60)

  enterAetherialFlow()
  GoToKillMobs(1245, nil, 86, -9, -87, "Scythe Mantis", 2)
  GoToKillMobsMulti(1245, nil, 46, -11, -93, { ["Coliseum Python"] = 1, ["Scythe Mantis"] = 2 })
  GoToKillMobs(1245, nil, -2, -3, -115, "Scythe Mantis", 3)
  GoToKillMobsMulti(1245, nil, 4, -11, -188, { ["Coliseum Python"] = 1, ["Scythe Mantis"] = 2 })
  GoToKillMobsMulti(1245, nil, -8, -11, -156, { ["Coliseum Python"] = 1, ["Scythe Mantis"] = 2 })
  GoToKillMobsMulti(1245, nil, -83, -11, -100, { ["Coliseum Python"] = 1, ["Scythe Mantis"] = 2 })
  LeaveDuty()

  Logging.Notify("hunting log complete")
end

function DoHuntingLogCarried()
  HuntingLogPrereqs()
  FollowPartyLeader()
end

function DoHuntingLogCarry()
  HuntingLogMobs()
  HuntingLogHalatali()
end

function AttuneToShard()
  InteractWith("Aethernet shard")
  if AwaitAddonReady("TelepotTown", 3) then
    CloseAddonFast("TelepotTown")
  end
  WaitForPlayerReady()
end

function PartialGridaniaAethernet()
  yield("/at y")
  TeleportToGridania()
  InteractWithAetheryte()
  SelectStringOption("Aethernet")
  AwaitAddonReady("TelepotTown")
  local no_aethernet = StringIsEmpty(GetNewNodeText("TelepotTown", 1, 4, 9, 61007, 6))
  CloseAddonFast("TelepotTown")
  WaitForPlayerReady()
  if no_aethernet then
    yield("/li Leatherworker")
    yield("/wait 4")
    WaitForPlayerReady()
    -- Lancer's
    NavToPoint(121.2, 12.65, -229.6, 2, false, 100)
    AttuneToShard()
    -- Botanist
    yield("/li Mih Khetto")
    yield("/wait 4")
    WaitForPlayerReady()
    NavToPoint(-311.1, 7.95, -177.1, 2, false, 100)
    AttuneToShard()
  end
end

function PartialLimsaAethernet()
  yield("/at y")
  TeleportToLimsa()
  NavToAetheryte()
  InteractWithAetheryte()
  SelectStringOption("Aethernet")
  AwaitAddonReady("TelepotTown")
  local no_aethernet = StringIsEmpty(GetNewNodeText("TelepotTown", 1, 4, 9, 61007, 6))
  CloseAddonFast("TelepotTown")
  WaitForPlayerReady()
  if no_aethernet then
    -- Hawkers
    NavToPoint(-213.6, 16.7, 51.8, 2, false, 100)
    AttuneToShard()
    -- Arcanist
    NavToPoint(-335.2, 12.62, 56.4, 2, false, 100)
    AttuneToShard()
    -- Marauder
    yield("/li Culinarian")
    yield("/wait 4")
    WaitForPlayerReady()
    NavToPoint(-5.17, 44.6, -218.1, 2, false, 100)
    AttuneToShard()
  end
end

function UnlockUldahAetheryte()
  if TeleportToUldah() then return true end
  yield("/at y")
  if not TeleportToLimsa() then return false end
  NavToPoint(9.78, 21.0, 15.1, 2, false, 30)
  InteractWith("Grehfarr", "SelectIconString")
  SelectStringOption("Ride Lift to the Airship Landing")
  SelectYesno(0)
  WaitForReadyInZone(128)
  NavToPoint(-25.9, 92.0, -3.68, 3, false, 30)
  InteractWith("L'nophlo", "SelectIconString")
  SelectStringOption("Purchase Passage to Ul'dah")
  SelectYesno(0)
  WaitForReadyInZone(130)
  NavToPoint(-26.0, 81.8, -32.0, 3, false, 30)
  InteractWith("Nanahomi", "SelectIconString")
  SelectStringOption("Ride Lift to the Ruby Road Exchange")
  SelectYesno(0)
  yield("/wait 3")
  WaitForPlayerReady()
  NavToPoint(-140.7, -3.15, -165.7, 1, false, 100)
  InteractWith("aetheryte", nil, 11.165)
  yield("/wait 3")
  WaitForPlayerReady()
  return true
end

function PartialUldahAethernet()
  yield("/at y")
  if not UnlockUldahAetheryte() then return end
  InteractWithAetheryte()
  SelectStringOption("Aethernet")
  AwaitAddonReady("TelepotTown")
  local no_aethernet = StringIsEmpty(GetNewNodeText("TelepotTown", 1, 4, 9, 61010, 6))
  CloseAddonFast("TelepotTown")
  WaitForPlayerReady()
  if no_aethernet then
    -- Thaumaturge
    NavToPoint(-154.8, 14.6, 73.1, 2, false, 100)
    AttuneToShard()
    -- Miner
    yield("/li Goldsmith")
    yield("/wait 4")
    WaitForPlayerReady()
    NavToPoint(33.5, 13.2, 113.2, 2, false, 100)
    AttuneToShard()
    -- Alchemist
    yield("/li Chamber of Rule")
    yield("/wait 4")
    WaitForPlayerReady()
    NavToPoint(-98.3, 42.3, 88.5, 2, false, 100)
    AttuneToShard()
  end
end

function UnlockGridaniaAethernet()
  yield("/at y")
  TeleportToGridania()
  InteractWithAetheryte()
  SelectStringOption("Aethernet")
  AwaitAddonReady("TelepotTown")
  local no_aethernet = StringIsEmpty(GetNewNodeText("TelepotTown", 1, 4, 9, 61007, 6))
  CloseAddonFast("TelepotTown")
  WaitForPlayerReady()
  if no_aethernet then
    -- Archer's Guild
    NavToPoint(166.6, -1.72, 86.1, 2, false, 100)
    AttuneToShard()
    -- Old Gridania
    NavToPoint(101, 5, 14, 1, false, 100)
    WaitUntil(function () return GetZoneID() == 133 end)
    WaitForNavReady()
    -- Leatherworkers
    NavToPoint(101.2, 9.01, -111.3, 2, false, 100)
    AttuneToShard()
    -- Lancer's
    NavToPoint(121.2, 12.65, -229.6, 2, false, 100)
    AttuneToShard()
    -- Mih Khetto
    NavToPoint(-73.9, 7.98, -140.2, 2, false, 100)
    AttuneToShard()
    -- Botanist
    NavToPoint(-311.1, 7.95, -177.1, 2, false, 100)
    AttuneToShard()
  end
end

function UnlockArcanistShard()
  yield("/at y")
  TeleportToLimsa()
  NavToAetheryte()
  InteractWithAetheryte()
  SelectStringOption("Aethernet")
  AwaitAddonReady("TelepotTown")
  local no_aethernet = StringIsEmpty(GetNewNodeText("TelepotTown", 1, 4, 9, 61007, 6))
  CloseAddonFast("TelepotTown")
  WaitForPlayerReady()
  if no_aethernet then
    NavToPoint(-335.2, 12.62, 56.4, 2, false, 100)
    AttuneToShard()
  end
end

function GoCompleteClassQuests()
  local function classComplete() return Quests.IsQuestComplete(65603) or Quests.IsQuestComplete(65627) end
  if not classComplete() then
    yield("/xlenablecollection Questionable")
    yield("/wait 10")
    IPC.Questionable.ClearQuestPriority()
    IPC.Questionable.AddQuestPriority("21")
    IPC.Questionable.AddQuestPriority("22")
    IPC.Questionable.AddQuestPriority("46")
    IPC.Questionable.AddQuestPriority("48")
    IPC.Questionable.AddQuestPriority("67")
    IPC.Questionable.AddQuestPriority("91")
    yield("/qst start")
    WaitUntil(classComplete)
    yield("/qst stop")
    yield("/xldisablecollection Questionable")
    yield("/wait 2")
    repeat
      TryCallback("SelectString", true, -1)
    until IsPlayerAvailable()
  end
end

function GoUnlockOceanFishing()
  UnlockArcanistShard()
  yield("/at n")
  yield("/li Fishermen")
  yield("/wait 3")
  WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
  if not IsFisher() then
    if not NavToObject("N'nmulika", 3, false, 20) then return end
    InteractWith("N'nmulika", "Talk")
    yield("/at y")
    if AwaitAddonReady("SelectYesno", 5) then
      Callback("SelectYesno", true, 0)
    end
    WaitForPlayerReady()
    yield("/at n")
    InteractWith("N'nmulika", "Talk")
    yield("/at y")
    WaitForPlayerReady()
    yield("/at n")
  end
  if not NavToPoint(-174.7, 4.3, 165.9, 0.5, false, 20) then return end
  if not NavToPoint(-168, 4.4, 165.7, 0.5, false, 20) then return end
  if not IsFisher() then
    InteractWith("Sisipu", "Talk")
    yield("/at y")
    if AwaitAddonReady("SelectYesno", 5) then
      Callback("SelectYesno", true, 0)
    end
    WaitForPlayerReady()
    yield("/at n")
    repeat yield("/equip 2571") yield ("/wait 1") until IsFisher()
    EquipRecommendedGear()
  end
  if InteractWith("Sisipu", "SelectIconString") then
    Callback("SelectIconString", true, 0)
  else
    InteractWith("Sisipu", "Talk")
  end
  yield("/at y")
  WaitForPlayerReady()
  yield("/at n")
  if not NavToPoint(-194.8, 4, 174.5, 0.5, false, 20) then return end
  EquipBait(2585)
  SetAutoHookState(true)
  repeat yield("/ac cast") until WaitUntil(IsFishingWaiting, 0.5)
  WaitWhile(function () return GetLevel() < 10 or GetItemCount(4870) < 5 end, nil, 1)
  SetAutoHookState(false)
  repeat yield("/ac quit") until WaitForPlayerReady(1)
  if not NavToPoint(-174.7, 4.3, 165.9, 0.5, false, 20) then return end
  if not NavToPoint(-168, 4.4, 165.7, 0.5, false, 20) then return end
  InteractWith("Sisipu", "Talk")
  yield("/at y")
  repeat
    TryCallback("SelectIconString", true, -1)
    TryCallback("SelectString", true, -1)
    yield("/wait 1")
  until IsPlayerAvailable()
  yield("/at n")
  InteractWith("Fhilsnoe", "JournalAccept")
  yield("/at y")
  WaitForPlayerReady()
  yield("/at n")
  GoToOceanFishing()
  InteractWith("Foerzagyl", nil, 6)
  yield("/at y")
  yield("/wait 5")
  WaitForPlayerReady()
end

function DoOceanFishingUnlockQuest()
  if Quests.IsQuestComplete(69379) then return end
  yield("/at n")
  while not IsFisher() do yield("/equip 2571") yield ("/wait 1") end
  EquipRecommendedGear()
  yield("/li Fishermen")
  yield("/wait 3")
  WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
  NavToTarget("Fhilsnoe", 2, false, 20)
  InteractWith("Fhilsnoe", "JournalAccept")
  yield("/at y")
  WaitForPlayerReady()
  yield("/at n")
  GoToOceanFishing()
  InteractWith("Foerzagyl", nil, 6)
  yield("/at y")
  yield("/wait 5")
  WaitForPlayerReady()
end

function GoSetupRetainers(names, index)
  if TableIsEmpty(names) then return true end
  yield("/at y")
  local dist = GetDistanceToObject("Frydwyb")
  if (not IsInLimsa() or not dist or dist > 30) then
    TeleportToLimsa()
  end
  while not NavToObject("Frydwyb", 3, false, 30) do
    TeleportToLimsa()
  end
  for _, name in ipairs(names) do
    InteractWith("Frydwyb", "SelectString")
    Callback("SelectString", true, 0)
    Callback("SelectYesno", true, 0)
    yield("/wait 0.2")
    Callback("SelectYesno", true, 0)
    Callback("CharaMakeDataImport", true, 102, index or 0, 0)
    yield("/wait 0.2")
    Callback("_CharaMakeFeature", true, 100)
    Callback("SelectYesno", true, 1)
    yield("/wait 0.2")
    Callback("SelectYesno", true, 0)
    Callback("SelectString", true, 0)
    Callback("SelectYesno", true, 0)
    yield("/wait 1")
    Callback("InputString", true, 0, name, " ")
    yield("/wait 1")
    Callback("SelectYesno", true, 0)
    WaitForPlayerReady()
    yield("/wait 0.2")
  end
  return true
end

function GoUnlockRetainerVentures(archer)
  if Quests.IsQuestComplete(66968) then return end
  TeleportToGridania()
  yield("/at y")
  if archer then
    while GetClassJobId() ~= 5 do
      yield("/equip 1889")
      yield ("/wait 1")
    end
  end
  EquipRecommendedGear()
  NavToObject("Troubled Adventurer", 3, false, 20)
  InteractWith("Troubled Adventurer")
  yield("/wait 1")
  WaitForPlayerReady()
  if IsAetheryteUnlocked(4) then
    TeleportToZone(152)
  else
    NavToAetheryte()
    yield("/li Lancer")
    yield("/wait 3")
    WaitForPlayerReady()
    NavToPoint(181.4, -2.35, -240.4, 1, false, 100)
    InteractWith("Romarique", "SelectIconString", 3)
    SelectStringOption("Purchase Passge to Sweetbloom Pier")
    Callback("SelectYesno", true, 0)
    yield("/wait 1")
    WaitForPlayerReady()
  end
  yield("/at n")
  yield("/xlenablecollection Questionable")
  NavToPoint(-51.7, -9, 296.9, 1, false, 100)
  repeat
    yield("/rsr auto on")
    yield("/wrath auto on")
    --yield("/bmai on")
    yield("/bmrai on")
    WaitUntil(IsInCombat, 10)
    WaitWhile(IsInCombat)
    --yield("/bmai off")
    yield("/bmrai off")
    yield("/wrath auto off")
    yield("/rsr auto off")
    yield("/xldisablecollection Questionable")
    yield("/wait 2")
  until not IsInCombat() and (NavToTarget("Novice Retainer", 1, false, 20) or not Target("Novice Retainer"))
  InteractWith("Novice Retainer", "Talk", 3)
  yield("/at y")
  yield("/wait 1")
  WaitForPlayerReady()
  TeleportToGridania()
  yield("/at n")
  yield("/li leatherworker")
  yield("/wait 3")
  WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
  NavToObject("Parnell", 3, false, 20)
  yield("/at y")
  yield("/wait 2")
  WaitForPlayerReady()
end

function GoEquipPLDRetainers(count, skipBuy)
  if not skipBuy then
    yield("/at y")
    TeleportToLimsa()
    yield("/li hawkers")
    yield("/wait 3")
    WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
    NavToObject("Faezghim", 3, false, 20)
    InteractWith("Faezghim", "SelectIconString")
    Callback("SelectIconString", true, 0)
    Callback("SelectString", true, 0)
    local bought = 0
    while bought < count do
      local last_count = GetItemCount(1601)
      Callback("Shop", true, 0, 0, 1)
      Callback("Shop", true, 7, 0)
      Callback("SelectYesno", true, 0)
      AwaitAddonGone("SelectYesno", 1)
      WaitWhile(function () return GetItemCount(1601) == last_count end, 1)
      bought = bought + 1
    end
    Callback("Shop", true, -1)
    Callback("SelectString", true, -1)
    AwaitAddonGone("SelectString", 1)
    WaitForPlayerReady()
    yield("/wait 0.5")
  end

  NavToObject("Summoning Bell", 3, false, 20)
  OpenRetainerList()
  local rod_stacks = FindItemsInCharacterArmoury("Main")[1601]
  local armory = true
  if not rod_stacks then
    rod_stacks = FindItemsInCharacterInventory()[1601]
    armory = false
  end
  local rod_stacks_index = 1
  while count > 0 do
    OpenRetainer(count)
    SelectStringOption("Assign retainer class")
    yield("/wait 0.2")
    SelectStringOption("Gladiator")
    Callback("SelectYesno", true, 0)
    SelectStringOption("View retainer attributes")
    Callback("RetainerCharacter", true, 20, 0)
    if armory then
      Callback("ArmouryBoard", true, 8, rod_stacks[rod_stacks_index].visible.slot + rod_stacks[rod_stacks_index].visible.page * 35)
    else
      Callback("ArmouryBoard", true, 10, 0)
      Callback("InventoryExpansion", true, 16, 48 + rod_stacks[rod_stacks_index].visible.page, rod_stacks[rod_stacks_index].visible.slot)
    end
    yield("/wait 0.1")
    rod_stacks_index = rod_stacks_index + 1
    Callback("RetainerCharacter", true, -1)
    Callback("SelectString", true, -1)
    count = count - 1
  end
  AwaitAddonReady("RetainerList")
  CloseRetainerList()
end

function GoEquipFishingRetainers(count)
  yield("/at y")
  TeleportToLimsa()
  yield("/li hawkers")
  yield("/wait 3")
  WaitWhile(function () return LifestreamIsBusy() or not IsPlayerAvailable() end)
  NavToObject("Syneyhil", 3, false, 20)
  InteractWith("Syneyhil", "SelectIconString")
  Callback("SelectIconString", true, 1)
  Callback("SelectString", true, 0)
  local bought = 0
  while bought < count do
    local last_count = GetItemCount(2571)
    Callback("Shop", true, 0, 4, 1)
    Callback("Shop", true, 7, 4)
    Callback("SelectYesno", true, 0)
    AwaitAddonGone("SelectYesno", 1)
    WaitWhile(function () return GetItemCount(2571) == last_count end, 1)
    bought = bought + 1
  end
  Callback("Shop", true, -1)
  Callback("SelectString", true, -1)
  AwaitAddonGone("SelectString", 1)
  WaitForPlayerReady()
  yield("/wait 0.5")
  NavToObject("Summoning Bell", 3, false, 20)
  OpenRetainerList()
  local rod_stacks = FindItemsInCharacterArmoury("Main")[2571]
  local armory = true
  if not rod_stacks then
    rod_stacks = FindItemsInCharacterInventory()[2571]
    armory = false
  end
  local rod_stacks_index = 1
  while count > 0 do
    OpenRetainer(count)
    SelectStringOption("Assign retainer class")
    yield("/wait 0.2")
    SelectStringOption("Fisher")
    Callback("SelectYesno", true, 0)
    SelectStringOption("View retainer attributes")
    Callback("RetainerCharacter", true, 20, 0)
    local inv_count = GetItemCount(2571)
    repeat
      if armory then
        Callback("ArmouryBoard", true, 8, rod_stacks[rod_stacks_index].visible.slot + rod_stacks[rod_stacks_index].visible.page * 35)
      else
        Callback("ArmouryBoard", true, 10, 0)
        Callback("InventoryExpansion", true, 16, 48 + rod_stacks[rod_stacks_index].visible.page, rod_stacks[rod_stacks_index].visible.slot)
      end
      yield("/wait 0.2")
    until GetItemCount(2571) < inv_count
    rod_stacks_index = rod_stacks_index + 1
    Callback("RetainerCharacter", true, -1)
    Callback("SelectString", true, -1)
    count = count - 1
  end
  AwaitAddonReady("RetainerList")
  CloseRetainerList()
end

function GoPurchaseFishingItems()
  yield("/at y")
  TeleportToLimsa()
  NavToObject("Sorcha", 3, false, 20)
  InteractWith("Sorcha", "SelectIconString")
  Callback("SelectIconString", true, 1)
  for _, i in ipairs({ 5, 12, 16, 20, 20}) do
    Callback("Shop", true, 0, i, 1)
    Callback("Shop", true, 7, i)
    Callback("SelectYesno", true, 0)
    yield("/wait 1")
  end
  Callback("Shop", true, -1)
  AwaitAddonGone("Shop")
  WaitForNavReady()
  NavToObject("Gerulf", 3, false, 20)
  InteractWith("Gerulf", "Shop")
  local last_count = GetItemCount(4673)
  Callback("Shop", true, 0, 4, 99)
  Callback("Shop", true, 7, 4)
  Callback("SelectYesno", true, 0)
  WaitWhile(function () return GetItemCount(4673) == last_count end, 1)
  last_count = GetItemCount(4673)
  Callback("Shop", true, 0, 4, 99)
  Callback("Shop", true, 7, 4)
  Callback("SelectYesno", true, 0)
  WaitWhile(function () return GetItemCount(4673) == last_count end, 1)
  Callback("Shop", true, -1)
  AwaitAddonGone("Shop")
  WaitForNavReady()
  GoPurchaseItems({{ 6141, 900, 999 }}, 100000)
end

function InitOceanFishingRetainers(names, index, count)
  if not GoSetupRetainers(names, index) then
    Logging.Error("failed to setup retainers")
    return
  end
  UnlockGridaniaAethernet()
  GoCompleteClassQuests()
  GoUnlockRetainerVentures()
  GoUnlockOceanFishing()
  GoEquipFishingRetainers(count or TableSize(names))
  GoPurchaseFishingItems()
  ReturnToBell()
end

function InitOceanFishingRetainersMulti(chars, names, index)
  for _, char in ipairs(chars) do
    ARRelogTo(ARFindCid(char))
    InitOceanFishingRetainers(names, index)
  end
end

function BuyFishRetainerLevellingGear(vendor, market)
  local gear_buy_table = {
    { 15545, 1, 200000, true, true }, -- Luminous Fiber Fishing Rod
    { 17726, 1, 100000, true, nil  }, -- Spearfishing Gig
    { 19617, 1, 100000, true, true }, -- Gaganaskin Bush Hat
    { 19618, 1, 100000, true, true }, -- Gaganaskin Vest
    { 19619, 1, 100000, true, true }, -- Gaganaskin Gloves
    { 19620, 1, 100000, true, true }, -- Bloodhempen Trousers of Gathering
    { 19621, 1, 100000, true, true }, -- Gaganaskin Fringe Boots
    { 19733, 1, 100000, true, true }, -- Gyuki Leather Earrings
    { 19734, 1, 100000, true, true }, -- Gyuki Leather Choker
    { 19735, 1, 100000, true, true }, -- Gyuki Leather Wristband
    { 19736, 2, 100000, true, true }, -- Gyuki Leather Ring
  }
  local gear_vendor_table = {
    ["Syneyhil"] = {
      ["1,2"] = {
        { 2576, 9, 1 },
      },
    },
    ["Iron Thunder"] = {
      ["2,2"] = {
        { 2734, 4, 1 },
        { 3092, 8, 1 },
        { 3578, 13, 1 },
        { 3351, 17, 1 },
        { 3810, 22, 1 },
      },
    }
  }

  if vendor ~= false then BuyFromVendorMulti(gear_vendor_table, nil, true) end
  if market ~= false then GoPurchaseAllItems(gear_buy_table) end

  local gear_ids = TableMapValueTo(gear_buy_table, function (v) return v[1] end)
  for _, buy_table in ipairs(gear_vendor_table) do
    for _, items in ipairs(buy_table) do
      for _, item in ipairs(items) do
        table.insert(gear_ids, item[1])
      end
    end
  end
  MoveItemsToArmouryChest(gear_ids)
  EquipRecommendedGear()

  ReturnToBell()
end

function BuyFishRetainerLevellingGearMulti()
  ARApplyToAllCharacters(ARFindAllFishCharactersToLevel(nil, true), BuyFishRetainerLevellingGear)
end

function TopUpFishRetainer(junk_table, ventures, cordials, cordial_price, gil_floor, free_slots)
  ventures = ventures or 500
  cordials = cordials or 900
  cordial_price = cordial_price or 1000
  gil_floor = gil_floor or 100000
  junk_table = junk_table or {}

  GCTurnIn()
  ReturnToBell()
  ARItemSell()

  GoPurchaseItems({{ 6141, cordials, cordial_price }}, gil_floor)

  if GetItemCount(21072) < ventures and not TableIsEmpty(junk_table) then
    GoPurchaseItems(junk_table, gil_floor, free_slots)
    GCTurnIn()
    ReturnToBell()
  elseif not NavToTarget("Summoning Bell", 2, false, 20) then
    ReturnToBell()
  end
end

function TopUpFishRetainerMulti(junk_table, ventures, cordials, cordial_price, gil_floor, free_slots, level)
  level = level or GetMaxLevel()
  local function topUp(cid) TopUpFishRetainer(junk_table, ventures, cordials, cordial_price, gil_floor, free_slots) end
  ARApplyToAllCharacters(ARFindAllFishCharactersToLevel(level, true), topUp)
end
