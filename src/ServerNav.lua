
ServerNavTable = {
  JP = {
    Elemental = {
      [90]  = "Aegis",
      [68]  = "Atomos",
      [45]  = "Carbuncle",
      [58]  = "Garuda",
      [94]  = "Gungnir",
      [49]  = "Kujata",
      [72]  = "Tonberry",
      [50]  = "Typhon",
    },
    Gaia = {
      [43]  = "Alexander",
      [69]  = "Bahamut",
      [92]  = "Durandal",
      [46]  = "Fenrir",
      [59]  = "Ifrit",
      [98]  = "Ridill",
      [76]  = "Tiamat",
      [51]  = "Ultima",
    },
    Mana = {
      [44]  = "Anima",
      [23]  = "Asura",
      [70]  = "Chocobo",
      [47]  = "Hades",
      [48]  = "Ixion",
      [96]  = "Masamune",
      [28]  = "Pandaemonium",
      [61]  = "Titan",
    },
    Meteor = {
      [24]  = "Belias",
      [82]  = "Mandragora",
      [60]  = "Ramuh",
      [29]  = "Shinryu",
      [30]  = "Unicorn",
      [52]  = "Valefor",
      [31]  = "Yojimbo",
      [32]  = "Zeromus",
    },
  },
  NA = {
    Aether = {
      [73]  = "Adamantoise",
      [79]  = "Cactuar",
      [54]  = "Faerie",
      [63]  = "Gilgamesh",
      [40]  = "Jenova",
      [65]  = "Midgardsormr",
      [99]  = "Sargatanas",
      [57]  = "Siren",
    },
    Crystal = {
      [91]  = "Balmung",
      [34]  = "Brynhildr",
      [74]  = "Coeurl",
      [62]  = "Diabolos",
      [81]  = "Goblin",
      [75]  = "Malboro",
      [37]  = "Mateus",
      [41]  = "Zalera",
    },
    Dynamis = {
      [408] = "Cuchulainn",
      [411] = "Golem",
      [406] = "Halicarnassus",
      [409] = "Kraken",
      [407] = "Maduin",
      [404] = "Marilith",
      [410] = "Rafflesia",
      [405] = "Seraph",
    },
    Primal = {
      [78]  = "Behemoth",
      [93]  = "Excalibur",
      [53]  = "Exodus",
      [35]  = "Famfrit",
      [95]  = "Hyperion",
      [55]  = "Lamia",
      [64]  = "Leviathan",
      [77]  = "Ultros",
    },
  },
  EU = {
    Chaos = {
      [80]  = "Cerberus",
      [83]  = "Louisoix",
      [71]  = "Moogle",
      [39]  = "Omega",
      [401] = "Phantom",
      [97]  = "Ragnarok",
      [400] = "Sagittarius",
      [85]  = "Spriggan",
    },
    Light = {
      [402] = "Alpha",
      [36]  = "Lich",
      [66]  = "Odin",
      [56]  = "Phoenix",
      [403] = "Raiden",
      [67]  = "Shiva",
      [33]  = "Twintania",
      [42]  = "Zodiark",
    },
  },
  OCE = {
    Materia = {
      [22]  = "Bismarck",
      [21]  = "Ravana",
      [86]  = "Sephirot",
      [87]  = "Sophia",
      [88]  = "Zurvan",
    },
  },
}

function GetServerData(server_index)
  if not server_index then
    server_index = GetCurrentWorld()
  end

  for region, region_table in pairs(ServerNavTable) do
    for data_center, data_center_table in pairs(region_table) do
      local server_name = data_center_table[server_index]
      if server_name then
        return {
          id = server_index,
          region = region,
          dc = data_center,
          name = server_name,
        }
      end
    end
  end
end
