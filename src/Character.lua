require "Callback"
require "Logging"
require "UINav"
require "Utils"

function OpenCharacterWindow() return OpenCommandWindow("character", "Character") end

function EquipRecommendedGear()
  if OpenCharacterWindow() then
    Callback("Character", true, 12)
    if AwaitAddonReady("RecommendEquip", 3) then
      repeat
        Callback("RecommendEquip", true, 0)
      until AwaitAddonGone("RecommendEquip", 1)
      repeat
        Callback("Character", true, -1)
      until AwaitAddonGone("Character", 1)
      return true
    end
  end
  return false
end
