require "Logging"
require "Navigation"
require "UINav"
require "Utils"

function GetFCCredits()
  if not OpenCommandWindow("freecompanycmd", "FreeCompany") then return 0 end
  local credits = nil
  local timeout = 2
  repeat
    credits = ParseInt(GetNewNodeText("FreeCompany", 1, 4, 16, 17))
    Logging.Echo(credits)
    yield("/wait 0.1")
    timeout = timeout - 0.1
  until credits or timeout <= 0
  CloseAddonFast("FreeCompany")
  if not credits then
    Logging.Error("could not get FC credits")
  end
  return credits or 0
end

function BuyCeruleumTanks(stacks)
  if not AwaitAddonReady("FreeCompanyCreditShop", 2) then
    Logging.Error("FreeCompanyCreditShop not open")
    return false
  end
  repeat yield("/wait 0.1") until not StringIsEmpty(GetNewNodeText("FreeCompanyCreditShop", 1, 2, 9, 10))
  local tanks_to_buy = stacks * 999
  local target_tanks = GetItemCount(10155) + tanks_to_buy
  while tanks_to_buy > 0 do
    if GetInventoryFreeSlotCount() <= 0 then
      Logging.Error("not enough inventory space to buy tanks")
      break
    end
    local purchase_count = math.min(tanks_to_buy, 99)
    local credits = ParseInt(GetNewNodeText("FreeCompanyCreditShop", 1, 2, 9, 10))
    if credits < purchase_count * 100 then
      Logging.Error("insufficient credits to buy tanks")
      break
    end
    local last_tanks = GetItemCount(10155)
    Callback("FreeCompanyCreditShop", true, 0, 0, purchase_count)
    SelectYesno(true)
    local function purchaseComplete()
      local next_credits = ParseInt(GetNewNodeText("FreeCompanyCreditShop", 1, 2, 9, 10))
      return GetItemCount(10155) > last_tanks and next_credits ~= credits
    end
    if WaitUntil(purchaseComplete, 5) then
      tanks_to_buy = tanks_to_buy - purchase_count
    end
  end
  CloseAddonFast("FreeCompanyCreditShop")
  WaitForPlayerReady(1)
  return GetItemCount(10155) >= target_tanks
end

function NavToCompanyCreditShop()
  local exit_dist = GetDistanceToObject("Exit")
  local rooms_dist = GetDistanceToObject("Entrance to Additional Chambers")

  if not IsInCompanyWorkshop() then
    if not (exit_dist and rooms_dist and (exit_dist < 3 or rooms_dist < 3)) then
      local house_dist = GetDistanceToObject("Entrance")
      if not house_dist or house_dist > 10 then
        ReturnToFC()
      end
      if not WalkToTarget("Entrance") then return false end
      if not InteractWith("Entrance", "SelectYesno") then return false end
      if not SelectYesno(true) then return false end
      if not WaitUntil(function() return not IsInHousingDistrict() and IsPlayerAvailable() and NavIsReady() end, 10, 1) then return false end
    end
    if not WalkToTarget("Entrance to Additional Chambers") then return false end
    if not InteractWith("Entrance to Additional Chambers", "SelectString") then return false end
    if not SelectStringOption("Move to the company workshop") then CloseAddonFast("SelectString") return false end
    if not WaitUntil(function() return IsInCompanyWorkshop() and IsPlayerAvailable() and NavIsReady() end, 10, 1) then return false end
  end
  if not WalkToTarget("Mammet Voyager #004A") then return false end
  if not InteractWith("Mammet Voyager #004A", "SelectIconString") then return false end
  if not SelectIconStringOption("Company Credit Exchange") then CloseAddonFast("SelectIconString") return false end
  return AwaitAddonReady("FreeCompanyCreditShop", 5)
end

function GoBuyCeruleumTanks(stacks)
    local credits = GetFCCredits()
    local tank_stacks_can_buy = math.floor(credits / (100 * 999))
    local stacks_to_buy = math.min(tank_stacks_can_buy, stacks, GetInventoryFreeSlotCount() - 1)
    if stacks_to_buy <= 0 then
      Logging.Error("no stacks to buy, insufficient credits or inventory spaces")
      return 0
    end
    if not NavToCompanyCreditShop() then
      Logging.Error("could not navigate to company credit shop")
      return nil
    end
    if not BuyCeruleumTanks(stacks_to_buy) then
      Logging.Error("failed to buy ceruleum tanks")
      return nil
    end
    return stacks_to_buy
end
