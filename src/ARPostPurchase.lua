require "Navigation"
require "Logging"

function ARPostPurchase()
  if GoToMarketBoard() then
    LogTrace("topping up repair materials")
  end
  ReturnToBell()
end
