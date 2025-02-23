require "Navigation"
require "Logging"

function ARPostPurchase()
  if NavToMarketBoard() then
    Logging.Trace("topping up repair materials")
  end
  ReturnToBell()
end
