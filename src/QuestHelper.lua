require "Logging"
require "Navigation"
require "Utils"

function GetGridaniaQuests()
  Logging.Echo("qst:v1:Mzk7MTIzOzIx") -- starter
  Logging.Echo("qst:v1:Mzk7MTIzOzIxOzY4MDs1MTM7NzEwOzcyNTszODYw") -- full
end

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
  Callback("InputString", true, 0, "Choco", "")
  AwaitAddonReady("SelectYesno")
  Callback("SelectYesno", true, 0)
  AwaitAddonGone("SelectYesno")
  yield("/wait 5")
end

local function returnOrGridania() if not DoReturn() then TeleportToGridania() end end

function QuestWatch(target_level, silent)
  yield("/at y")
  yield("/wait 0.1")
  yield("/qst start")
  yield("/wait 1")

  local function returnToZone(zone)
    if not TeleportToZone(zone) then
      Logging.Warning("no available teleport to original zone, trying aethernet")
      yield("/li "..GetZoneName(zone))
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
  local coffer_opened = false
  while not target_level or GetLevel() < target_level do
    if IsPlayerDead() and IsAddonVisible("SelectYesno") and StringStartsWith(GetNodeText("SelectYesno", 15), "Return to ") then
      Logging.Info("player dead, attempting to recover")
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

    if not coffer_opened and GetItemCount(31329) > 0 then
      yield("/qst stop")
      yield("/wait 5")
      WaitUntil(IsPlayerAvailable)
      yield("/item "..GetItemName(31329))
      coffer_opened = true
      yield("/wait 5")
      yield("/qst start")
    end

    if IsInCombat() or IsPlayerDead() or IsPlayerOccupied() or not NavIsReady() or not IsPlayerAvailable() or NavBuildProgress() > 0 then
      last_x = 0
      last_y = 0
      last_z = 0
      resetCounts()
    elseif GetDistanceToPoint(last_x, last_y, last_z) < 1 then
      if PathIsRunning() then
        stuck_count = stuck_count + 1
        if stuck_count > 20 then
          Logging.Info("nav stuck, rebuilding")
          yield("/qst stop")
          RebuildNavMesh()
          yield("/qst start")
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
          Logging.Info("questing stopped, restarting")
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
          Logging.Info("questing dead, reloading")
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
      last_x = GetPlayerRawXPos()
      last_y = GetPlayerRawYPos()
      last_z = GetPlayerRawZPos()
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
  if not silent then Logging.Notify("questing complete") end
  return true
end

function QuestMulti(chars, level)
  for _, character in pairs(chars) do
    if GetCharacterName(true) ~= character then
      yield("/ays relog "..character)
      yield("/wait 10")
      WaitForNavReady()
    end
    if GetCharacterName(true) == character then
      if QuestWatch(level, true) then
        Logging.Info("levelling complete for "..character)
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
  Logging.Notify("multi questing complete")
end

function UnlockTeleport()
  if IsInZone(132) then
    PathfindAndMoveTo(155, -13, 159, false)
  end
  WaitUntil(function () return IsPlayerAvailable() and NavIsReady() and GetZoneID() == 148 end)
  NavToPoint(13.08, 0.56, 35.90, 7, false, 300)
  yield("/target aetheryte")
  yield("/wait 0.2")
  yield("/interact")
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

    if IsPlayerDead() and IsAddonVisible("SelectYesno") and StringStartsWith(GetNodeText("SelectYesno", 15), "Return to ") then
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
      if GetFateMaxLevel(GetNearestFate()) < GetLevel() then
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
    if IsAddonReady("SelectYesno") and StringStartsWith(GetNodeText("SelectYesno", 15), "Accept Teleport") then
      Callback("SelectYesno", true, 0)
    elseif IsAddonReady("SelectYesno") and StringStartsWith(GetNodeText("SelectYesno", 15), "Accept Raise") then
      Callback("SelectYesno", true, 0)
    elseif IsAddonReady("ContentsFinderConfirm") then
      Callback("ContentsFinderConfirm", true, 8)
    elseif not HasTarget() then
      local lead_name = GetPartyMemberName(GetPartyLeadIndex())
      if not TerritorySupportsMounting() and StringIsEmpty(lead_name) then
        yield("/autofollow")
        LeaveDuty()
      else
        yield("/target "..GetPartyMemberName(GetPartyLeadIndex()))
      end
    elseif IsTargetMounted() and GetDistanceToTarget() < 5 then
      if not GetCharacterCondition(10) then yield("/ridepillion <t>") end
    elseif not TerritorySupportsMounting() then
      if GetDistanceToObject("Aetherial Flow") < 30 then
        enterAetherialFlow()
      else
        NavToTarget(GetTargetName(), 1, false, 10)
      end
    elseif GetDistanceToTarget() > 5 then
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
      yield("/target "..name)
      local inCombat = GetTargetName() == name and IsTargetInCombat()
      if StringIsEmpty(old_target) then ClearTarget() else yield("/target "..old_target) end
      if inCombat then return true end
    end
  end
  return false
end

function KillMobs(targets)
  local function needKill()
    for _, count in pairs(targets) do
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
          yield("/target "..name)
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
        yield("/target <me>")
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
    TeleportToAetheryte(aetheryte)
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
      yield("/target "..name)
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

function HuntingLogPrereqs()
  local function mountChocobo() while TerritorySupportsMounting() and not IsMounted() do yield("/mount \"Company Chocobo\"") WaitUntil(IsMounted, 3) end end
  local function waitZoneTransfer(zone) WaitUntil(function () return IsPlayerAvailable() and NavIsReady() and IsInZone(zone) end) end
  local function unlockAetheryte(zone, x, y, z)
    waitZoneTransfer(zone)
    mountChocobo()
    NavToPoint(x, y, z, 7, false, 120)
    yield("/target aetheryte")
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

function DoHuntingLogCarried()
  HuntingLogPrereqs()
  FollowPartyLeader()
end

function DoHuntingLogCarry()
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

  -- Halatali
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
  WaitUntil(function () return IsPlayerAvailable() and NavIsReady() and IsInZone(1245) end)
  WaitUntil(function () return IsAddonVisible("_Image") end)
  yield("/wait 1")
  RebuildNavMesh()
  GoToKillMobs(1245, nil, 200, 6, -36, "Heckler Imp", 1)
  GoToKillMobs(1245, nil, 153, -2, -9, "Heckler Imp", 2)
  GoToKillMobs(1245, nil, 111, -4, 50, "Heckler Imp", 2)
  GoToKillMobs(1245, nil, 29, 1, 125, "Firemane", 1, 60)

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
