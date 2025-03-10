require "Logging"
require "Navigation"
require "Utils"

function GetGridaniaQuests()
  Logging.Echo("qst:v1:Mzk7MTIzOzIx") -- starter
  Logging.Echo("qst:v1:Mzk7MTIzOzIxOzY4MDs1MTM7NzEwOzcyNTszODYw") -- full
end

local function buyChocoboIssuanceAdder()
  InteractWith("Serpent Quartermaster", "GrandCompanyExchange")
  Callback("GrandCompanyExchange", true, 2, 1)
  yield("/wait 1")
  Callback("GrandCompanyExchange", true, 0, 6, 1, 0, true, false)
  AwaitAddonReady("SelectYesno")
  Callback("SelectYesno", true, 0)
  AwaitAddonGone("SelectYesno")
  CloseAddon("GrandCompanyExchange")
  yield("/wait 1")
end

local function nameChocoboAdder()
  yield("/at n")
  NavToPoint(32.3, -0.05, 70.3, 3, false, 60)
  yield("/at y")
  if not AwaitAddonReady("InputString", 5) then
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
  local function resetCounts(isFail)
    stuck_count = 0
    stop_count = 0
    dead_count = 0
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

    if IsInCombat() or IsPlayerDead() or IsPlayerOccupied() or not ADIsStopped() or not NavIsReady() or not IsPlayerAvailable() or NavBuildProgress() > 0 then
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
      returnOrGridania()
      return
    end

    yield("/wait 1")
  end

  yield("/qst stop")
  if not silent then Logging.Notify("questing complete") end
end

function QuestMulti(chars, level)
  for _, character in pairs(chars) do
    if GetCharacterName(true) ~= character then
      yield("/ays relog "..character)
      yield("/wait 10")
      WaitForNavReady()
    end
    if GetCharacterName(true) == character then
      QuestWatch(level, true)
      yield("/wait 5")
      returnOrGridania()
      Logging.Info("levelling complete for "..character)
      yield("/wait 1")
    else
      Logging.Error("failed to find character "..character)
    end
  end
  Logging.Notify("multi questing complete")
end
