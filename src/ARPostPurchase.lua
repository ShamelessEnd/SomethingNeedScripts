require "Navigation"
require "Logging"

function ARPostPurchase()
  if GoToMarketBoard() then
    Logging.Trace("topping up repair materials")
  end
  ReturnToBell()
end
