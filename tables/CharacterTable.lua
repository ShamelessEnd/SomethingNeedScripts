CharacterTable = {
  -- 3
  { id = 18014498540029699, duty = 1266, cap = 0   },
  { id = 18014398543277161, duty = 1266, cap = nil },
  { id = 18014498543912195, duty = 1266, cap = nil },
  { id = 18014498570859517, duty = 1242, cap = 0   },
  { id = 18014498570872383, duty = 1242, cap = 0   },
  { id = 18014498545460076, duty = 1242, cap = 0   },

  -- 2
  { id = 18014498548750340, duty = 1266, cap = nil },
  { id = 18014498552814954, duty = 1266, cap = nil },
  { id = 18014498552814974, duty = 1266, cap = 0   },
  { id = 18014498558583161, duty = 1266, cap = 0   },
  { id = 18014439509482497, duty = 1266, cap = 0   },
  { id = 18014498570872882, duty = 1266, cap = 0   },
}

function CharacterIdTable()
  local ids = {}
  for _, char in pairs(CharacterTable) do
    if GetARCharacterData(char.id) then
      table.insert(ids, char.id)
    end
  end
  return ids
end
