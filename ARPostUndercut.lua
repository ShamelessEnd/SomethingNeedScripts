
local log_level = 0
local retainer_count = 9
local game_folder =  "D:\\Documents\\My Games\\FINAL FANTASY XIV - A Realm Reborn"
local default_undercut_floor = 14500
local retainer_sell_tables = {
  [2] = {
    -- config
    [0] = { exclude=false, unlist=false, entrust=true },
    --   id, price floor, force list, stack size, max listings, min keep, name
    { 13115,      399900,       true,          1,           20,        0, "Jet Black"                  },
    { 13114,      299900,       true,          1,           20,        0, "Pure White"                 },
    { 13708,       49500,      false,          2,            3,        0, "Pastel Pink"                },
    { 13116,       14500,      false,          2,            3,        0, "Metallic Silver"            },
    { 13117,       14500,      false,          2,            3,        0, "Metallic Gold"              },
    { 13723,       11500,      false,          2,            3,        0, "Metallic Purple"            },
    { 13716,       11500,      false,          2,            3,        0, "Dark Purple"                },
    { 13721,        9500,      false,          2,            3,        0, "Sky Blue"                   },
    { 13709,        3500,      false,          2,            3,        0, "Dark Red"                   },
    { 13714,        3500,      false,          2,            3,        0, "Dark Blue"                  },
    { 13717,        4500,      false,          2,            0,        0, "Metallic Red"               },
    { 13720,        4500,      false,          2,            0,        0, "Metallic Green"             },
    { 13722,        4500,      false,          2,            0,        0, "Metallic Blue"              },
    { 13719,        4500,      false,          2,            0,        0, "Metallic Yellow"            },
    { 13713,        1500,      false,          2,            0,        0, "Pastel Blue"                },
    { 13715,        1500,      false,          2,            0,        0, "Pastel Purple"              },
    { 13711,        1500,      false,          2,            0,        0, "Pastel Green"               },
    { 13718,        1500,      false,          2,            0,        0, "Metallic Orange"            },
    { 13710,        1500,      false,          2,            0,        0, "Dark Brown"                 },
    { 13712,        1500,      false,          2,            0,        0, "Dark Green"                 },
    {  5728,        1500,      false,          1,            0,        0, "Terebinth"                  },
    {  8841,        1500,      false,          1,            0,        0, "Retainer Fantasia"          },
  },
  [9] = {
    [0] = { exclude=false, unlist=false, entrust=true },
    --   id, price floor, force list, stack size, max listings, min keep, name
    { 32799,      249500,      false,          1,            1,        0, "Calfskin Rider's Jacket"    },
    { 32798,      249500,      false,          1,            1,        0, "Calfskin Rider's Cap"       },
    { 32801,      249500,      false,          1,            1,        0, "Calfskin Rider's Bottoms"   },
    { 32802,      249500,      false,          1,            1,        0, "Calfskin Rider's Shoes"     },
    { 32800,      249500,      false,          1,            1,        0, "Calfskin Rider's Gloves"    },
    { 28590,      249500,      false,          1,            1,        0, "Rebel Coat"                 },
    { 28591,      249500,      false,          1,            1,        0, "Rebel Boots"                },
    { 28588,      249500,      false,          1,            1,        0, "Urban Coat"                 },
    { 28589,      249500,      false,          1,            1,        0, "Urban Boots"                },
    {  7542,       49500,      false,          1,            1,        0, "Spring Dress Shoes"         },
    {  7540,      249500,      false,          1,            1,        0, "Spring Dress"               },
    { 16600,      249500,      false,          1,            1,        0, "Cashmere Poncho"            },
    { 20477,      249500,      false,          1,            1,        0, "Quan"                       },
    { 20476,      249500,      false,          1,            1,        0, "Ao Dai"                     },
    {  8559,      249500,      false,          1,            1,        0, "Crescent Moon Nightgown"    },
    {  8557,      249500,      false,          1,            1,        0, "Crescent Moon Cone"         },
    {  8561,      249500,      false,          1,            1,        0, "Crescent Moon Slippers"     },
    { 33027,       99500,      false,          1,            1,        0, "Calf Leather"               },
    {  7032,       99500,      false,          1,            1,        0, "Lotus Leaf"                 },
    {  8026,       99500,      false,          1,            1,        0, "Mist Silk"                  },
    { 28905,       99500,      false,          1,            1,        0, "Shell Leather"              },
    { 27977,       99500,      false,          1,            1,        0, "Enchanted Elm Lumber"       },
    { 36629,       99500,      false,          1,            1,        0, "Phonograph Plate"           },
    { 40700,       49500,      false,          1,            1,        0, "Malake Karpasos"            },
    { 20270,       49500,      false,          1,            1,        0, "Nagxian Silk"               },
    {  7772,       49500,      false,          1,            1,        0, "Mariner Cotton Cloth"       },
    { 41653,       49500,      false,          1,            1,        0, "Athletikos Cloth"           },
    {  8560,       49500,      false,          1,            1,        0, "Crescent Moon Bottoms"      },
    {  8558,       49500,      false,          1,            1,        0, "Crescent Moon Nightcap"     },
    { 41592,       49500,      false,          1,            1,        0, "Martial Artist's Vest"      },
    { 41595,       49500,      false,          1,            1,        0, "Martial Artist's Sleeveles" },
    { 41593,       49500,      false,          1,            1,        0, "Martial Artist's Slops"     },
    { 41594,       49500,      false,          1,            1,        0, "Martial Artist's Pumps"     },
    { 24006,       49500,      false,          1,            1,        0, "Whisperfine Woolen Boots"   },
    { 24004,       49500,      false,          1,            1,        0, "Whisperfine Woolen Coat"    },
    { 24005,       49500,      false,          1,            1,        0, "Whisperfine Woolen Shorts"  },
    { 30056,       49500,      false,          1,            1,        0, "Dalmascan Draped Bottoms"   },
    { 30057,       49500,      false,          1,            1,        0, "Dalmascan Leather Shoes"    },
    { 15926,       49500,      false,          1,            1,        0, "Moonfire Tanga"             },
    { 15927,       49500,      false,          1,            1,        0, "Moonfire Sandals"           },
    { 15925,       49500,      false,          1,            1,        0, "Moonfire Halter"            },
    { 27941,       49500,      false,          1,            1,        0, "Summer Indigo Shirt"        },
    { 40405,       49500,      false,          1,            1,        0, "Plain Pajama Shirt"         },
    { 40407,       49500,      false,          1,            1,        0, "Plain Pajama Slippers"      },
    { 40406,       49500,      false,          1,            1,        0, "Plain Pajama Bottoms"       },
    { 40413,       49500,      false,          1,            1,        0, "Chocobo Pajama Shirt"       },
    { 40414,       49500,      false,          1,            1,        0, "Chocobo Pajama Bottoms"     },
    { 40415,       49500,      false,          1,            1,        0, "Chocobo Pajama Slippers"    },
    { 40412,       49500,      false,          1,            1,        0, "Chocobo Pajama Eye Mask"    },
    { 33656,       49500,      false,          1,            1,        0, "Frontier Jacket"            },
    { 33661,       49500,      false,          1,            1,        0, "Frontier Dress Gloves"      },
    { 33660,       49500,      false,          1,            1,        0, "Frontier Dress"             },
    { 33662,       49500,      false,          1,            1,        0, "Frontier Pumps"             },
    { 33657,       49500,      false,          1,            1,        0, "Frontier Trousers"          },
    {  7541,       49500,      false,          1,            1,        0, "Spring Skirt"               },
    { 27939,       49500,      false,          1,            1,        0, "pped Fireglass Leather Slo" },
    { 27938,       49500,      false,          1,            1,        0, "oded Fireglass Leather Ves" },
    { 36837,       49500,      false,          1,            1,        0, "Varsity Flat Cap"           },
    { 36839,       49500,      false,          1,            1,        0, "Varsity Bottoms"            },
    { 36842,       49500,      false,          1,            1,        0, "Varsity Skirt"              },
    { 36838,       49500,      false,          1,            1,        0, "Varsity Jacket"             },
    { 36840,       49500,      false,          1,            1,        0, "Varsity Shoes"              },
    { 36841,       49500,      false,          1,            1,        0, "Buttoned Varsity Jacket"    },
    { 21204,       49500,      false,          1,            1,        0, "Hannish Wool Autumn Shirt"  },
    { 23002,       49500,      false,          1,            1,        0, "Quaintrelle's Ruffled Skir" },
    { 23001,       49500,      false,          1,            1,        0, "Quaintrelle's Ruffled Dres" },
    { 23373,       49500,      false,          1,            1,        0, "Quaintrelle's Hat"          },
    { 23374,       49500,      false,          1,            1,        0, "Quaintrelle's Dress Shoes"  },
    { 10393,       49500,      false,          1,            1,        0, "Thavnairian Bustier"        },
    { 10395,       49500,      false,          1,            1,        0, "Thavnairian Tights"         },
    { 10392,       49500,      false,          1,            1,        0, "Thavnairian Headdress"      },
    { 10396,       49500,      false,          1,            1,        0, "Thavnairian Sandals"        },
    { 10394,       49500,      false,          1,            1,        0, "Thavnairian Armlets"        },
    { 10390,       49500,      false,          1,            1,        0, "Thavnairian Sarouel"        },
    {  8553,       49500,      false,          1,            1,        0, "Coeurl Beach Halter"        },
    {  8555,       49500,      false,          1,            1,        0, "Coeurl Beach Tanga"         },
    {  7535,       49500,      false,          1,            1,        0, "Sailor Shirt"               },
    {  7537,       49500,      false,          1,            1,        0, "Sailor Brais"               },
    { 33869,       49500,      false,          1,            1,        0, "Frontier Cloth"             },
    { 33659,       49500,      false,          1,            1,        0, "Frontier Ribbon"            },
    { 20471,       49500,      false,          1,            1,        0, "Taoist's Shirt"             },
    { 20473,       49500,      false,          1,            1,        0, "Taoist's Slops"             },
    { 14869,       49500,      false,          1,            1,        0, "Uraeus Coat"                },
    {  7771,       29500,      false,          1,            1,        0, "Dress Material"             },
    { 30135,       29500,      false,          1,            1,        0, "Cloth-softening Powder"     },
    { 12646,       29500,      false,          1,            1,        0, "Thavnairian Silk"           },
    { 12645,       29500,      false,          1,            1,        0, "Thavnairian Leather"        },
    { 40404,       29500,      false,          1,            1,        0, "Plain Pajama Eye Mask"      },
    { 40409,       29500,      false,          1,            1,        0, "Cactuar Pajama Shirt"       },
    { 40410,       29500,      false,          1,            1,        0, "Cactuar Pajama Bottoms"     },
    { 40411,       29500,      false,          1,            1,        0, "Cactuar Pajama Slippers"    },
    { 30055,       29500,      false,          1,            1,        0, "Dalmascan Draped Top"       },
    {  6980,       29500,      false,          1,            1,        0, "Highland Mitts"             },
    {  6979,       29500,      false,          1,            1,        0, "Highland Smock"             },
    {  6981,       29500,      false,          1,            1,        0, "Highland Boots"             },
    { 15921,       29500,      false,          1,            1,        0, "Moonfire Hat"               },
    { 30755,       29500,      false,          1,            1,        0, "Southern Seas Shirt"        },
    { 30757,       29500,      false,          1,            1,        0, "Southern Seas Skirt"        },
    { 30756,       29500,      false,          1,            1,        0, "Southern Seas Trousers"     },
    { 30758,       29500,      false,          1,            1,        0, "Southern Seas Shoes"        },
    { 16601,       29500,      false,          1,            1,        0, "Fur-lined Saurian Boots"    },
    { 14940,       29500,      false,          1,            1,        0, "Wind Silk Coatee"           },
    {  7549,       29500,      false,          1,            1,        0, "Taffeta Loincloth"          },
    { 20475,       29500,      false,          1,            1,        0, "Non La"                     },
    { 20478,       29500,      false,          1,            1,        0, "Guoc"                       },
    { 37299,       29500,      false,          1,            1,        0, "White Byregotia Choker"     },
    {  6475,       29500,      false,          1,            1,        0, "Moogle Letter Box"          },
    {  6586,       29500,      false,          1,            1,        0, "Manor Candelabra"           },
    { 14835,       29500,      false,          1,            1,        0, "Expeditioner's Pantalettes" },
    { 14836,       29500,      false,          1,            1,        0, "Expeditioner's Thighboots"  },
    { 22569,       29500,      false,          1,            1,        0, "Southern Kitchen"           },
    {  8796,       29500,      false,          1,            1,        0, "Shipping Crate"             },
    { 38243,       19500,      false,          1,            1,        0, "Lawless Enforcer's Hat"     },
    { 38244,       19500,      false,          1,            1,        0, "Lawless Enforcer's Jacket"  },
    { 38245,       19500,      false,          1,            1,        0, "Lawless Enforcer's Gloves"  },
    {  9289,       19500,      false,          1,            1,        0, "Plain Long Skirt"           },
    { 13272,       19500,      false,          1,            1,        0, "Falconer's Shirt"           },
    { 13769,       19500,      false,          1,            1,        0, "Falconer's Bottoms"         },
    { 13770,       19500,      false,          1,            1,        0, "Falconer's Boots"           },
    { 17467,       19500,      false,          1,            1,        0, "Flannel Suspenders"         },
    { 17466,       19500,      false,          1,            1,        0, "Flannel Knit Cap"           },
    { 21937,       19500,      false,          1,            1,        0, "Adventuring Sweater"        },
    { 35869,       19500,      false,          1,            1,        0, "Wristlet of Happiness"      },
    { 35868,       19500,      false,          1,            1,        0, "Cape of Happiness"          },
    { 35870,       19500,      false,          1,            1,        0, "Hose of Happiness"          },
    { 35871,       19500,      false,          1,            1,        0, "Boots of Happiness"         },
    { 15922,       19500,      false,          1,            1,        0, "Moonfire Vest"              },
    { 24592,       19500,      false,          1,            1,        0, "Raincoat"                   },
    { 21202,       19500,      false,          1,            1,        0, "Thavnairian Wool Autumn S"  },
    { 21203,       19500,      false,          1,            1,        0, "Thavnairian Wool Autumn D"  },
    { 10388,       19500,      false,          1,            1,        0, "Thavnairian Bolero"         },
    { 10389,       19500,      false,          1,            1,        0, "Thavnairian Gloves"         },
    { 10391,       19500,      false,          1,            1,        0, "Thavnairian Babouches"      },
    { 39308,       19500,      false,          1,            1,        0, "Salon Server's Hat"         },
    { 39315,       19500,      false,          1,            1,        0, "Salon Server's Skirt"       },
    { 39309,       19500,      false,          1,            1,        0, "Salon Server's Vest"        },
    { 39312,       19500,      false,          1,            1,        0, "Salon Server's Shoes"       },
    { 39313,       19500,      false,          1,            1,        0, "Salon Server's Dress Vest"  },
    { 39314,       19500,      false,          1,            1,        0, "Salon Server's Dress Glove" },
    { 13266,       19500,      false,          1,            1,        0, "High House Justaucorps"     },
    { 40408,       19500,      false,          1,            1,        0, "Cactuar Pajama Eye Mask"    },
    {  7547,       19500,      false,          1,            1,        0, "Light Steel Subligar"       },
    {  7546,       19500,      false,          1,            1,        0, "Light Steel Galerus"        },
    { 14868,       19500,      false,          1,            1,        0, "Uraeus Skirt"               },
    { 35862,       19500,      false,          1,            1,        0, "Red Ribbon"                 },
    { 35575,       19500,      false,          1,            1,        0, "Imitation Wooden Skylight"  },
    {  9734,       19500,      false,          1,            1,        0, "Oak Low Barrel Planter"     },
    { 23884,       19500,      false,          1,            1,        0, "Mahogany Bunk Bed"          },
    {  7976,       19500,      false,          1,            1,        0, "Model Star Globe"           },
    {  9719,       19500,      false,          1,            1,        0, "Oriental Bathtub"           },
    {  8778,       19500,      false,          1,            1,        0, "South Seas Couch"           },
    { 23893,       19500,      false,          1,            1,        0, "Bathroom Floor Tiles"       },
    { 36888,       19500,      false,          1,            1,        0, "Highland Flooring"          },
    { 15924,       14500,      false,          1,            1,        0, "Moonfire Caligae"           },
    {  8554,       14500,      false,          1,            1,        0, "Coeurl Beach Pareo"         },
    {  8547,       14500,      false,          1,            1,        0, "Coeurl Beach Maro"          },
    {  8548,       14500,      false,          1,            1,        0, "Coeurl Beach Briefs"        },
    {  8546,       14500,      false,          1,            1,        0, "Coeurl Talisman"            },
    { 15472,       14500,      false,          1,            1,        0, "Survival Hat"               },
    { 15476,       14500,      false,          1,            1,        0, "Extreme Survival Shirt"     },
    { 15473,       14500,      false,          1,            1,        0, "Survival Shirt"             },
    { 15475,       14500,      false,          1,            1,        0, "Survival Boots"             },
    {  7539,       14500,      false,          1,            1,        0, "Spring Straw Hat"           },
    { 21205,       14500,      false,          1,            1,        0, "Hannish Wool"               },
    { 16625,       14500,      false,          1,            1,        0, "Astral Silk Robe"           },
    { 16626,       14500,      false,          1,            1,        0, "Griffin Leather Cuffs"      },
    { 33655,       14500,      false,          1,            1,        0, "Frontier Hat"               },
    { 33658,       14500,      false,          1,            1,        0, "Frontier Shoes"             },
    { 17469,       14500,      false,          1,            1,        0, "Pteroskin Shoes"            },
    {  6982,       14500,      false,          1,            1,        0, "Glacial Coat"               },
    {  6983,       14500,      false,          1,            1,        0, "Glacial Boots"              },
    { 15463,       14500,      false,          1,            1,        0, "New World Jacket"           },
    { 15464,       14500,      false,          1,            1,        0, "New World Armlets"          },
    { 14850,       14500,      false,          1,            1,        0, "Uraeis Body Armor"          },
    { 21936,       14500,      false,          1,            1,        0, "Winter Sweater"             },
    { 24593,       14500,      false,          1,            1,        0, "Rain Boots"                 },
    { 13269,       14500,      false,          1,            1,        0, "High House Cloche"          },
    { 13270,       14500,      false,          1,            1,        0, "High House Bustle"          },
    { 13268,       14500,      false,          1,            1,        0, "High House Boots"           },
    { 13271,       14500,      false,          1,            1,        0, "High House Halfboots"       },
    { 14830,       14500,      false,          1,            1,        0, "Expeditioner's Coat"        },
    { 14833,       14500,      false,          1,            1,        0, "Expeditioner's Tabard"      },
    { 14832,       14500,      false,          1,            1,        0, "Expeditioner's Moccasins"   },
    { 14834,       14500,      false,          1,            1,        0, "Expeditioner's Gloves"      },
    { 39310,       14500,      false,          1,            1,        0, "Salon Server's Gloves"      },
    { 14930,       14500,      false,          1,            1,        0, "Dhalmelskin Thighboots"     },
    { 13259,       14500,      false,          1,            1,        0, "White Beret"                },
    {  8564,       14500,      false,          1,            1,        0, "Shaded Spectacles"          },
    {  9298,       14500,      false,          1,            1,        0, "Classic Spectacles"         },
    {  7548,       14500,      false,          1,            1,        0, "Taffeta Shawl"              },
    { 14852,       14500,      false,          1,            1,        0, "Gryphonskin Breastguard"    },
    {  8541,       14500,      false,          1,            1,        0, "Straw Capeline"             },
    { 13273,       14500,      false,          1,            1,        0, "Punching Gloves"            },
    { 13687,       14500,      false,          1,            1,        0, "Archaeoskin Halfboots"      },
    { 20470,       14500,      false,          1,            1,        0, "Taoist's Cap"               },
    { 20472,       14500,      false,          1,            1,        0, "Taoist's Gloves"            },
    { 20474,       14500,      false,          1,            1,        0, "Taoist's Shoes"             },
    { 16597,       14500,      false,          1,            1,        0, "Ramie Poncho"               },
    { 14929,       14500,      false,          1,            1,        0, "Ramie Pantalettes"          },
    { 38247,       14500,      false,          1,            1,        0, "Lawless Enforcer's Shoes"   },
    {  7538,       14500,      false,          1,            1,        0, "Sailor Deck Shoes"          },
    { 13682,       14500,      false,          1,            1,        0, "Rainbow Justaucorps"        },
    { 27991,       14500,      false,          1,            1,        0, "Adventurer's Hooded Vest"   },
    {  9291,       14500,      false,          1,            1,        0, "Gryphonskin Eyepatch"       },
    { 37359,       14500,      false,          1,            1,        0, "Ivy Curtain"                },
    { 13069,       14500,      false,          1,            1,        0, "The Unending Journey"       },
    { 22440,       14500,      false,          1,            1,        0, "Hedge Partition"            },
    { 40630,       14500,      false,          1,            1,        0, "Imitation Moonlit Window"   },
    { 17025,       14500,      false,          1,            1,        0, "Ivy Pillar"                 },
    {  7970,       14500,      false,          1,            1,        0, "Wall Planter"               },
    {  6573,       14500,      false,          1,            1,        0, "Riviera Pillar"             },
    {  6574,       14500,      false,          1,            1,        0, "Glade Pillar"               },
    {  8004,       14500,      false,          1,            1,        0, "Glade Hedgewall"            },
    { 22558,       14500,      false,          1,            1,        0, "Bar Counter"                },
    { 38592,       14500,      false,          1,            1,        0, "Tatami Loft"                },
    { 37360,       14500,      false,          1,            1,        0, "Luminous Wooden Loft"       },
    {  8797,       14500,      false,          1,            1,        0, "Wine Barrel"                },
    {  6670,       14500,      false,          1,            1,        0, "Belah'dian Crystal Lantern" },
    { 30385,       14500,      false,          1,            1,        0, "Wooden Staircase Bookshelf" },
    { 15974,       14500,      false,          1,            1,        0, "Mounted Bookshelf"          },
    { 20734,       14500,      false,          1,            1,        0, "Hingan Bookshelf"           },
    {  6559,       14500,      false,          1,            1,        0, "Company Chest"              },
    { 28639,       14500,      false,          1,            1,        0, "Leather Sofa"               },
    {  6590,       14500,      false,          1,            1,        0, "Deluxe Manor Fireplace"     },
    {  6535,       14500,      false,          1,            1,        0, "Manor Couch"                },
    {  8806,       14500,      false,          1,            1,        0, "Manor Sofa"                 },
    {  6519,       14500,      false,          1,            1,        0, "Manor Stool"                },
    {  7109,       14500,      false,          1,            1,        0, "Manor Music Stool"          },
    {  7114,       14500,      false,          1,            1,        0, "Manor Music Stand"          },
    {  6569,       14500,      false,          1,            1,        0, "Manor Bookshelf"            },
    { 20735,       14500,      false,          1,            1,        0, "Hingan Cupboard"            },
    { 16781,       14500,      false,          1,            1,        0, "Troupe Stage"               },
    { 32224,       14500,      false,          1,            1,        0, "Swag Valance"               },
    { 24525,       14500,      false,          1,            1,        0, "Red Carpet"                 },
    {  7979,       14500,      false,          1,            1,        0, "Planter Partition"          },
    { 24536,       14500,      false,          1,            1,        0, "Botanist's Garden"          },
    { 24511,       14500,      false,          1,            1,        0, "Wooden Loft"                },
    { 24513,       14500,      false,          1,            1,        0, "Wooden Beam"                },
    {  8816,       14500,      false,          1,            1,        0, "Large Planter Box"          },
    {  6487,       14500,      false,          1,            1,        0, "Oaken Bench"                },
    {  8002,       14500,      false,          1,            1,        0, "Planter Box"                },
    { 24526,       14500,      false,          1,            1,        0, "Hanging Planter Shelf"      },
    { 28975,       14500,      false,          1,            1,        0, "Oldrose Wall Planter"       },
    { 22554,       14500,      false,          1,            1,        0, "Portable Stepladder"        },
    {  6668,       14500,      false,          1,            1,        0, "Nymian Wall Lantern"        },
    { 17954,       14500,      false,          1,            1,        0, "Table Orchestrion"          },
    { 13075,       14500,      false,          1,            1,        0, "Oriental Round Table"       },
    { 35561,       14500,      false,          1,            1,        0, "Indoor Oriental Waterfall"  },
    { 14068,       14500,      false,          1,            1,        0, "Alpine Chandelier"          },
    { 32226,       14500,      false,          1,            1,        0, "Wood Slat Partition"        },
    {  6595,       14500,      false,          1,            1,        0, "Potted Maguey"              },
    {  6646,       14500,      false,          1,            1,        0, "Potted Spider Plant"        },
    {  7975,       14500,      false,          1,            1,        0, "Potted Dragon Tree"         },
    {  6645,       14500,      false,          1,            1,        0, "Potted Azalea"              },
    { 41111,       14500,      false,          1,            1,        0, "Field of Hope Rug"          },
    { 24506,       14500,      false,          1,            1,        0, "Fat Cat Bank"               },
    {  8814,       14500,      false,          1,            1,        0, "Oasis Doormat"              },
    {  6549,       14500,      false,          1,            1,        0, "Riviera Wardrobe"           },
    { 24508,       14500,      false,          1,            1,        0, "Botanist's Dried Herbs"     },
    { 27296,       14500,      false,          1,            1,        0, "Wooden Handrail"            },
    { 38606,       14500,      false,          1,            1,        0, "Natural Wooden Beam"        },
    { 30405,       14500,      false,          1,            1,        0, "Factory Partition"          },
    {  7958,       14500,      false,          1,            1,        0, "Riviera Wall Shelf"         },
    {  8790,       14500,      false,          1,            1,        0, "Masonwork Stove"            },
    {  8831,       14500,      false,          1,            1,        0, "Masonwork Interior Wall"    },
    {  6596,       14500,      false,          1,            1,        0, "Astroscope"                 },
    { 17971,       14500,      false,          1,            1,        0, "Easel"                      },
    {  6663,       14500,      false,          1,            1,        0, "Galleass Wheel"             },
    {  6480,       14500,      false,          1,            1,        0, "Mossy Rock"                 },
    {  7064,       14500,      false,          1,            1,        0, "Summoning Bell"             },
    { 21864,       14500,      false,          1,            1,        0, "Corner Hedge Partition"     },
    {  7978,       14500,      false,          1,            1,        0, "Corner Counter"             },
    { 17545,       14500,      false,          1,            1,        0, "Pink Cherry Blossom Corsag" },
    { 38566,       14500,      false,          1,            1,        0, "White Sweet Pea Necklace"   },
    { 38567,       14500,      false,          1,            1,        0, "Black Sweet Pea Necklace"   },
    { 28809,        9500,      false,          1,            1,        0, " Sky Pirate's Coat of Fend" },
    { 28834,        9500,      false,          1,            1,        0, " Sky Pirate's Coat of Heal" },
    { 28839,        9500,      false,          1,            1,        0, " Sky Pirate's Coat of Cast" },
    { 28814,        9500,      false,          1,            1,        0, " Sky Pirate's Coat of Maim" },
    { 28812,        9500,      false,          1,            1,        0, " Sky Pirate's Boots of Fen" },
    { 28822,        9500,      false,          1,            1,        0, " Sky Pirate's Boots of Str" },
    { 28827,        9500,      false,          1,            1,        0, " Sky Pirate's Boots of Aim" },
    { 28832,        9500,      false,          1,            1,        0, " Sky Pirate's Boots of Sco" },
    { 28817,        9500,      false,          1,            1,        0, " Sky Pirate's Boots of Mai" },
    { 28837,        9500,      false,          1,            1,        0, " Sky Pirate's Shoes of Hea" },
    { 28842,        9500,      false,          1,            1,        0, " Sky Pirate's Shoes of Cas" },
    { 28841,        9500,      false,          1,            1,        0, " Sky Pirate's Bottoms of C" },
    { 28823,        9500,      false,          1,            1,        0, " Sky Pirate's Beret of Aim" },
    { 28818,        9500,      false,          1,            1,        0, " Sky Pirate's Mask of Stri" },
    { 28828,        9500,      false,          1,            1,        0, " Sky Pirate's Mask of Scou" },
    { 28819,        9500,      false,          1,            1,        0, " Sky Pirate's Jacket of St" },
    { 28829,        9500,      false,          1,            1,        0, " Sky Pirate's Jacket of Sc" },
    { 28824,        9500,      false,          1,            1,        0, " Sky Pirate's Vest of Aimi" },
    { 28813,        9500,      false,          1,            1,        0, " Sky Pirate's Helm of Maim" },
    { 28830,        9500,      false,          1,            1,        0, " Sky Pirate's Gloves of Sc" },
    { 28825,        9500,      false,          1,            1,        0, " Sky Pirate's Gloves of Ai" },
    { 28835,        9500,      false,          1,            1,        0, " Sky Pirate's Gloves of He" },
    { 28840,        9500,      false,          1,            1,        0, " Sky Pirate's Gloves of Ca" },
    { 28820,        9500,      false,          1,            1,        0, " Sky Pirate's Gloves of St" },
    { 28815,        9500,      false,          1,            1,        0, "ky Pirate's Gauntlets of M" },
    { 28810,        9500,      false,          1,            1,        0, "ky Pirate's Gauntlets of F" },
    {  8155,        4500,      false,          0,            1,        0, "Mastercraft Demimateria"    },
    { 16908,        4500,      false,          0,            1,        0, "Tempered Glass"             },
    {  7047,        4500,      false,          0,            1,        0, "Frosted Glass Lens"         },
    { 12913,        4500,      false,          0,            1,        0, "Garlond Steel"              },
    {  7775,        4500,      false,          0,            1,        0, "Glazenut"                   },
    {  2820,        4500,      false,          1,            1,        0, "Red Onion Helm"             },
  }
}

-- Logging

function LogMessage(message) yield(""..message) end
function LogTrace(message) if log_level <= -1 then LogMessage("-- "..message) end end
function LogDebug(message) if log_level <= 0 then LogMessage(message) end end
function LogInfo(message) if log_level <= 1 then LogMessage(message) end end
function LogWarning(message) if log_level <= 2 then LogMessage("WARNING: "..message) end end
function LogError(message) if log_level <= 3 then LogMessage("ERROR: "..message) end end

-- Utils

function StringIsEmpty(s) return s == nil or s == "" end
function RoundUpToNext(x, increment) return math.floor(((x + increment - 1) // increment) * increment + 0.5) end

function GetSellEntryByName(sell_table, item_name)
  if sell_table ~= nil then
    for i, sell_entry in pairs(sell_table) do
      if sell_entry[7] ~= nil and string.find(item_name, sell_entry[7]) then
        return sell_entry
      end
    end
  end
  return nil
end

function ReadXORData(file, key, bytes)
  local x = 0
  for i = 0, bytes - 1 do
    local data = file:read(1)
    if data == nil then LogDebug("read nil data") return nil end
    x = x + ((string.byte(data) ~ key) << (8 * i))
  end
  return x
end

function GetARCharacterData()
  LogDebug("fetching AR character data")
  local char = GetCharacterName(true)
  local cids = ARGetCharacterCIDs()
  for i = 0, cids.Count - 1 do
    local data = ARGetCharacterData(cids[i])
    if data ~= nil and type(data) == "userdata" and data.Name.."@"..data.World == char then
      return data
    end
  end
  return nil
end

-- Callback

function CallbackCommand(target, update, ...)
  -- even with all these checks, /callback will randomly crash, so fallback to /pcall
  local command = "/pcall "..target.." "..tostring(update)
  for _, arg in pairs({...}) do
    command = command.." "..tostring(arg)
  end
  LogTrace(command)
  return command
end

function Callback(target, update, ...)
  local command = CallbackCommand(target, update, ...)
  while not IsAddonReady(target) do
    yield("/wait 0.1")
  end
  yield(command)
end

function CallbackTimeout(timeout, target, update, ...)
  local command = CallbackCommand(target, update, ...)
  local timeout_count = 0
  while timeout_count < timeout do
    if IsAddonReady(target) then
      yield(command)
      return true
    end
    yield("/wait 0.1")
    timeout_count = timeout_count + 0.1
  end
  LogError("callback command timed out: "..command)
  return false
end

-- UI Navigation

function AwaitAddonReady(addon_name, timeout)
  if timeout == nil or timeout <= 0 then
    -- /waitaddon slows things down a lot, but might be more reliable
    -- yield("/waitaddon "..addon_name)
    while not IsAddonReady(addon_name) do
      yield("/wait 0.1")
    end
  else
    local timeout_count = 0
    while not IsAddonReady(addon_name) do
      yield("/wait 0.1")
      timeout_count = timeout_count + 0.1
      if timeout_count >= timeout then
        return false
      end
    end
  end
  return true
end

function AwaitAddonGone(addon_name, timeout)
  if timeout == nil or timeout <= 0 then
    while IsAddonVisible(addon_name) do
      yield("/wait 0.1")
    end
  else
    local timeout_count = 0
    while IsAddonVisible(addon_name) do
      yield("/wait 0.1")
      timeout_count = timeout_count + 0.1
      if timeout_count >= timeout then
        return false
      end
    end
  end
  return true
end

function CloseAndAwaitOther(addon_name, other_addon_name)
  repeat
    Callback(addon_name, true, -1)
  until AwaitAddonGone(addon_name, 2)
  AwaitAddonReady(other_addon_name)
end

function ClearTalkAndAwait(addon_name)
  while not IsAddonReady(addon_name) do
    if IsAddonReady("Talk") then
      Callback("Talk", true, 1)
    end
    yield("/wait 0.1")
  end
  AwaitAddonReady(addon_name)
end

function OpenRetainerList()
  LogDebug("opening RetainerList")
  if IsAddonVisible("RetainerList") then
    return AwaitAddonReady("RetainerList", 5)
  end

  -- yield("/runmacro WalkToBell")
  yield("/target Summoning Bell")
  if GetTargetName() ~= "Summoning Bell" or GetDistanceToTarget() > 4.6 then
    LogError("not in range of Summoning Bell")
    return false
  end
  
  local attempt_count = 0
  repeat
    attempt_count = attempt_count + 1
    if attempt_count > 3 then
      LogError("could not open Summoning Bell")
      return false
    end
    yield("/interact")
  until AwaitAddonReady("RetainerList", 3)
  return true
end

function CloseRetainerList()
  LogDebug("closing RetainerList")
  Callback("RetainerList", true, -1)
  yield("/wait 1")
end

function OpenRetainer(retainer_index)
  LogDebug("opening retainer "..retainer_index)
  Callback("RetainerList", true, 2, retainer_index - 1)
  ClearTalkAndAwait("SelectString")
end

function CloseRetainer()
  LogDebug("closing retainer")
  Callback("SelectString", true, -1)
  ClearTalkAndAwait("RetainerList")
end

function OpenSellListRetainer()
  LogDebug("opening retainer inventory sell list")
  Callback("SelectString", true, 3)
  AwaitAddonReady("RetainerSellList")
end

function OpenSellListInventory()
  LogDebug("opening player inventory sell list")
  Callback("SelectString", true, 2)
  AwaitAddonReady("RetainerSellList")
end

function CloseSellList()
  LogDebug("closing retainer sell list")
  Callback("RetainerSellList", true, -1)
  while IsAddonReady("RetainerSellList") do
    if IsAddonReady("SelectYesno") then
      Callback("SelectYesno", true, 0)
      break
    end
    yield("/wait 0.1")
  end
  AwaitAddonReady("SelectString")
end

function OpenRetainerInventory()
  LogDebug("opening retainer inventory")
  Callback("SelectString", true, 0)
  AwaitAddonReady("InventoryRetainerLarge")
end

function CloseRetainerInventory()
  LogDebug("closing retainer inventory")
  CloseAndAwaitOther("InventoryRetainerLarge", "SelectString")
end

function OpenSellListItemContext(item_index, timeout)
  -- this is flaky if you're moving/clicking the mouse at the same time
  -- hence the timeout/retry logic
  LogDebug("opening item "..item_index.." context menu")
  Callback("RetainerSellList", true, 0, item_index - 1, 1)
  return AwaitAddonReady("ContextMenu", timeout)
end

function OpenItemSell(item_index, attempts)
  for i = 1, attempts do
    if OpenSellListItemContext(item_index, 1) then
      LogDebug("opening item "..item_index.." sell menu")
      if CallbackTimeout(1, "ContextMenu", true, 0, 0) then
        if AwaitAddonReady("RetainerSell", 1) then
          return true
        end
      end
    end
  end
  return false
end

function CloseItemSell()
  LogDebug("closing item sell menu")
  CloseAndAwaitOther("RetainerSell", "RetainerSellList")
end

function CloseItemListings()
  LogDebug("closing item listings")
  CloseAndAwaitOther("ItemSearchResult", "RetainerSell")
end

function OpenItemListings(attempts)
  LogDebug("opening item listings")

  for i = 1, attempts do
    Callback("RetainerSell", true, 4)
    if AwaitAddonReady("ItemSearchResult", 2) then
      for wait_time = 1, 100 do
        if string.find(GetNodeText("ItemSearchResult", 26), "Please wait") then
          break
        end
        if string.find(GetNodeText("ItemSearchResult", 2), "hit") then
          return true
        end
        yield("/wait 0.1")
      end
      CloseItemListings()
    end
    yield("/wait 0.5")
  end

  return false
end

function OpenItemRetainerSell(item_page, page_slot)
  LogDebug("opening item from page "..item_page.." slot "..page_slot.." of retainer inventory")
  AwaitAddonReady("RetainerSellList")
  Callback("RetainerSellList", true, 2, 52 + item_page, page_slot)
  AwaitAddonReady("RetainerSell")
end

function ConfirmItemSellAndClose()
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 0)
  AwaitAddonGone("RetainerSell")
  AwaitAddonReady("RetainerSellList")
end

-- Read UI

function GetSellListCount()
  local item_full_text = GetNodeText("RetainerSellList", 3)
  local count_start, count_end
  while count_start == nil or count_end == nil do
    count_start, count_end = string.find(item_full_text, "%d+")
  end
  local item_count = string.sub(item_full_text, count_start, count_end - count_start + 1)
  LogDebug("found "..item_count.." items for sale on retainer ("..item_full_text..")")
  return tonumber(item_count)
end

function GetItemListingPrice(listing_index)
  local price_text = string.gsub(GetNodeText("ItemSearchResult", 5, listing_index, 10), "%D", "")
  if StringIsEmpty(price_text) then
    return 0
  else
    return tonumber(price_text)
  end
end

function GetItemHistoryPrice(history_index)
  local hist_price_text = string.gsub(GetNodeText("ItemHistory", 3, history_index + 1, 6), "%D", "")
  if StringIsEmpty(hist_price_text) then
    return 0
  else
    return tonumber(hist_price_text)
  end
end

function GetCurrentItemSellPrice()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNodeText("RetainerSell", 15, 4))
end

function GetCurrentItemSellCount()
  AwaitAddonReady("RetainerSell")
  return tonumber(GetNodeText("RetainerSell", 11, 4))
end

function GetRetainerName(retainer_index)
  local name = nil
  local retry_count = 3
  for i = 1, retry_count do
    name = GetNodeText("RetainerList", 2, retainer_index, 13)
    if not StringIsEmpty(name) then
      break
    end
    yield("/wait 0.5")
  end
  return name
end

-- Calcs

function GetItemHistoryTrimmedMean()
  LogDebug("fetching item history")
  Callback("ItemSearchResult", true, 0)
  if not AwaitAddonReady("ItemHistory", 5) then
    LogDebug("failed to open item history")
    return 0
  end

  local history_list = { GetItemHistoryPrice(1) }
  while history_list[1] == 0 do
    if IsNodeVisible("ItemHistory", 1, 11) and string.find(GetNodeText("ItemHistory", 2), "No items found") then
      LogDebug("no history")
      return 0
    end
    yield("/wait 0.1")
    history_list[1] = GetItemHistoryPrice(1)
  end

  local history_count = 1
  for i = 2, 10 do
    history_list[i] = GetItemHistoryPrice(i)
    if (history_list[i] <= 0) then
      break
    else
      history_count = history_count + 1
    end
  end

  table.sort(history_list)
  for i = 1, 2 do
    if (history_count > 2) then
      table.remove(history_list, 1)
      table.remove(history_list)
      history_count = history_count - 2
    else
      break
    end
  end

  local history_total = 0
  for _, history_price in pairs(history_list) do
    history_total = history_total + history_price
  end

  local history_trimmed_mean = history_total / history_count
  LogDebug("history_trimmed_mean: "..history_trimmed_mean)

  CloseAndAwaitOther("ItemHistory", "ItemSearchResult")
  return history_trimmed_mean
end

function CalculateUndercutPrice(p1, p2, p3, h)
  if h <= 0 then
    return 0
  elseif p1 <= 0 then
    return RoundUpToNext(h * 1.25, 10000) - 10
  end

  local hh = 0.4 * h
  local h2 = 2 * h
  local hr = RoundUpToNext(h, 10000)
  local h3r = RoundUpToNext(3 * h, 10000)
  if p2 <= 0 then p2 = hr end
  if p3 <= 0 then p3 = hr end

  if p3 < hh then
    return hr - 10
  elseif p2 < hh or (p2 < (0.5 * p3) and p3 < h2) then
    return RoundUpToNext(p3, 10) - 10
  elseif p1 < hh or (p1 < (0.5 * p2) and p2 < h2) then
    return RoundUpToNext(p2, 10) - 10
  elseif p1 > h3r and h3r > 50000 then
    return h3r - 10
  else
    return RoundUpToNext(p1, 10) - 10
  end
end

function GetUndercutPrice()
  LogDebug("calculating suggested price")
  if not OpenItemListings(10) then
    LogError("failed to open item listings")
    return 0
  end

  local p1 = GetItemListingPrice(1)
  local timeout_count = 0
  while p1 == 0 do
    if timeout_count > 10 then
      CloseItemListings()
      LogError("failed to get item list price")
      return 0
    end
    if string.find(GetNodeText("ItemSearchResult", 26), "Please wait") then
      CloseItemListings()
      LogWarning("failed to load item listings")
      if not OpenItemListings(1) then
        LogError("failed to reopen item listings")
        return 0
      end
      timeout_count = 0
    end
    if string.find(GetNodeText("ItemSearchResult", 26), "No items found") then
      LogDebug("no listings")
      break
    end
    yield("/wait 0.1")
    timeout_count = timeout_count + 0.1
    p1 = GetItemListingPrice(1)
  end

  local p2 = GetItemListingPrice(2)
  local p3 = GetItemListingPrice(3)
  LogDebug("list prices: "..p1..", "..p2..", "..p3)

  local hist = GetItemHistoryTrimmedMean()

  CloseItemListings()
  return CalculateUndercutPrice(p1, p2, p3, hist)
end

-- ItemODR
--   ID | Name      | DL | Variable       | Note
-- -----------------------------------------------------
-- 0x56 | Unknown   | ?? | ???            | ??
-- 0x4E | Retainers | 04 | Retainer Count | followed by [Retainer Count] 'Retainer' sections
-- 0x52 | Retainer  | 08 | Retainer ID    | followed by an 'Inventory' section
-- 0x6E | Inventory | 04 | Slot Count     | followed by [Slot Count] 'Slot' sections
-- 0x69 | Slot      | 04 | Slot|Container | 2 shorts: Slot Index, Container Index

function ReadItemODRData(file, bytes)
  local xor_key = 0x73 -- xor encryption byte for ITEMODR.DAT
  return ReadXORData(file, xor_key, bytes)
end

function ReadItemODRSectionHeader(file)
  return ReadItemODRData(file, 1), ReadItemODRData(file, 1) -- id, length
end

function ReadItemODRExpectedBlock(file, expected_id, expected_length)
  local id, length = ReadItemODRSectionHeader(file)
  if id ~= expected_id or length ~= expected_length then LogDebug("expected block not found") return nil end
  return ReadItemODRData(file, length)
end

function ParseItemODRInventory(file, page_offset, count)
  if count == nil then LogError("nil inventory count") return nil end
  local inventory = {}
  for i = 0, count - 1 do
    local id, length = ReadItemODRSectionHeader(file)
    if id ~= 0x69 or length ~= 4 then LogError("expected slot not found") return nil end
    slot = ReadItemODRData(file, 2)
    page = ReadItemODRData(file, 2)
    if slot == nil or page == nil then LogError("could not read slot data") return nil end
    inventory[i] = {
      internal = { slot = slot, page = page_offset + page },
      visible = { slot = i % 35, page = i // 35 }
    }
  end
  return inventory
end

function ParseItemODRRetainers(file, count)
  local retainers = {}
  for _ = 1, count do
    local rid = ReadItemODRExpectedBlock(file, 0x52, 8)
    if rid == nil then LogError("could not read retainer id") return nil end
    retainers[rid] = ParseItemODRInventory(file, 10000, ReadItemODRExpectedBlock(file, 0x6E, 4))
    if retainers[rid] == nil then LogError("could not fetch inventory for retainer "..rid) return nil end
  end
  return retainers
end

function ParseItemODR(cid)
  local filepath = game_folder.."\\FFXIV_CHR"..string.format("%016X", cid).."\\".."ITEMODR.DAT"
  LogDebug("parsing item ODR from ".. filepath)
  local file = assert(io.open(filepath, 'rb'))
  file:read(17) -- skip first 17 bytes

  local data = {}
  while data.inventory == nil or data.retainers == nil do
    local id, length = ReadItemODRSectionHeader(file)
    if id == nil or length == nil then
      break
    elseif id == 0x6E and data.inventory == nil then
      if length ~= 4 then LogDebug("bad inventory length") break end
      data.inventory = ParseItemODRInventory(file, 0, ReadItemODRData(file, length))
      if data.inventory == nil then LogDebug("bad inventory data") break end
    elseif id == 0x4E and data.retainers == nil then
      if length ~= 4 then LogDebug("bad retainers length") break end
      data.retainers = ParseItemODRRetainers(file, ReadItemODRData(file, length))
      if data.retainers == nil then LogDebug("bad retainers data") break end
    else
      file:read(length) -- skip
    end
  end

  file:close()

  if data.inventory == nil then LogError("failed to find character inventory data") return nil end
  if data.retainers == nil then LogError("failed to find retainers inventory data") return nil end
  return data
end

-- Inventory

local lazy_inventory_data = {}
local loaded_inventory_data = false
function GetLazyInventoryData()
  local retry_count = 3
  while not loaded_inventory_data and retry_count > 0 do
    LoadLazyInventoryData()
    retry_count = retry_count - 1
  end

  return lazy_inventory_data
end

function LoadLazyInventoryData()
  LogDebug("attempting to load inventory data")
  local char_data = GetARCharacterData()
  if char_data == nil or char_data.RetainerData.Count <= 0 then
    LogError("failed to load character data")
    return
  end
  local inv_data = ParseItemODR(char_data.CID)
  if inv_data == nil then
    LogError("failed to load inventory data")
    return
  end

  lazy_inventory_data.inventory = inv_data.inventory
  lazy_inventory_data.retainers = {}
  for i = 0, char_data.RetainerData.Count - 1 do
    local retainer_data = char_data.RetainerData[i]
    lazy_inventory_data.retainers[retainer_data.Name] = inv_data.retainers[retainer_data.RetainerID]
  end

  LogDebug("inventory data loaded")
  loaded_inventory_data = true
end

function FindItemsInInventory(inventory_map)
  LogDebug("searching for items in inventory")
  local items = {}
  if inventory_map == nil then
    return items
  end
  for _, mapping in pairs(inventory_map) do
    local item_id = GetItemIdInSlot(mapping.internal.page, mapping.internal.slot)
    local item_stack = {
      page = mapping.visible.page,
      slot = mapping.visible.slot,
      count = GetItemCountInSlot(mapping.internal.page, mapping.internal.slot),
    }
    if items[item_id] == nil then
      items[item_id] = { item_stack }
    else
      table.insert(items[item_id], item_stack)
    end
  end
  return items
end

function FindItemsInRetainerInventory(name) return FindItemsInInventory(GetLazyInventoryData().retainers[name]) end
function FindItemsInCharacterInventory() return FindItemsInInventory(GetLazyInventoryData().inventory) end

-- Actions (Manage Items)

function ReturnItemToTarget(item_index, target_id, attempts)
  for i = 1, attempts do
    if OpenSellListItemContext(item_index, 1) then
      local sell_count = GetSellListCount()
      if CallbackTimeout(1, "ContextMenu", true, 0, target_id) then
        local timeout_count = 0
        while sell_count == GetSellListCount() do
          yield("/wait 0.1")
          timeout_count = timeout_count + 0.1
          if timeout_count >= 5 then
            return false
          end
        end
        return true
      end
    end
  end
  return false
end

function ReturnItemToInventory(item_index, attempts)
  LogDebug("returning item "..item_index.." to inventory")
  return ReturnItemToTarget(item_index, 2, attempts)
end

function ReturnItemToRetainer(item_index, attempts)
  LogDebug("returning item"..item_index.." to retainer")
  return ReturnItemToTarget(item_index, 1, attempts)
end

function ReturnAllItemsToRetainer()
  while GetSellListCount() > 0 do
    ReturnItemToRetainer(1, 1)
  end
end

function EntrustSingleItem(item_id, item_stack)
  LogDebug("entrusting item "..item_id.." at "..item_stack.page.."."..item_stack.slot.." to retainer")
  local retry_timeout = 1
  local fail_timeout = 0
  while GetItemIdInSlot(item_stack.page, item_stack.slot) == item_id do
    if fail_timeout >= 5 then
      LogWarning("failed to entrust item, skipping")
      break
    elseif retry_timeout >= 1 then
      Callback("InventoryExpansion", true, 14, 48 + item_stack.page, item_stack.slot)
      retry_timeout = 0
    end
    yield("/wait 0.1")
    retry_timeout = retry_timeout + 0.1
    fail_timeout = fail_timeout + 0.1
  end
end

function EntrustInventoryItems(sell_table)
  OpenRetainerInventory()
  local inventory = FindItemsInCharacterInventory()
  for _, sell_entry in pairs(sell_table) do
    local item_id = sell_entry[1]
    local item_stacks = inventory[item_id] or {}
    for _, stack in pairs(item_stacks) do EntrustSingleItem(item_id, stack) end
  end
  CloseRetainerInventory()
end

-- Actions (Sell)

function ApplyItemSellCount(new_count)
  LogDebug("applying item sell count "..new_count)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 3, new_count)
end

function ApplyPriceUpdateAndClose(new_price)
  LogDebug("applying new price "..new_price)
  AwaitAddonReady("RetainerSell")
  Callback("RetainerSell", true, 2, string.format("%.0f", new_price))
  ConfirmItemSellAndClose()
end

function UndercutItems(return_function, sell_table)
  LogDebug("undercutting all items")
  local item_count = GetSellListCount()
  local last_item_name = ""
  local last_item_price = 0
  local last_sell_entry = nil
  local returned_count = 0
  local listed_items = {}

  LogInfo("  Found "..item_count.." items listed")
  if item_count > 0 then
    for item_number = 1, item_count do
      local item_index = item_number - returned_count
      if not OpenItemSell(item_index, 5) then
        LogError("failed to open ItemSell, aborting")
        break
      end

      local item_name = GetNodeText("RetainerSell", 18)
      local current_price = GetCurrentItemSellPrice()
      LogInfo("  Undercutting item "..item_number.." "..item_name)
      LogDebug("    current_price: "..current_price)

      local undercut_price = 0
      local sell_entry = nil
      if last_item_name == item_name then
        undercut_price = last_item_price
        sell_entry = last_sell_entry
      else
        undercut_price = GetUndercutPrice()
        sell_entry = GetSellEntryByName(sell_table, item_name)
      end

      if sell_entry ~= nil then
        local item_id = sell_entry[1]
        if listed_items[item_id] == nil then
          listed_items[item_id] = { count=1, price=undercut_price }
        else
          listed_items[item_id].count = listed_items[item_id].count + 1
        end
      end

      local floor_price = default_undercut_floor
      if sell_entry ~= nil then
        floor_price = sell_entry[2]
      end

      if undercut_price <= 0 then
        LogInfo("    failed to calculate price, skipping item")
        CloseItemSell()
      elseif undercut_price == current_price then
        LogInfo("    price target unchanged, skipping item")
        CloseItemSell()
      elseif undercut_price < floor_price then
        LogInfo("    new price too low ("..undercut_price.." < "..floor_price..")")
        if sell_entry ~= nil and sell_entry[3] == true then
          LogInfo("      using floor price")
          ApplyPriceUpdateAndClose(floor_price)
        else
          LogInfo("      removing listing")
          CloseItemSell()
          if return_function(item_index, 5) then
            returned_count = returned_count + 1
          end
          if sell_entry ~= nil then
            listed_items[sell_entry[1]].count = sell_entry[5]
          end
        end
      else
        ApplyPriceUpdateAndClose(undercut_price)
        LogInfo("    price updated: "..current_price.." -> "..undercut_price)
      end

      last_item_name = item_name
      last_item_price = undercut_price
      last_sell_entry = sell_entry
    end
  end
  return listed_items
end

function UndercutRetainerItems(retainer_index)
  if GetNodeText("RetainerList", 2, retainer_index, 5) == "None" then
    LogDebug("skipping retainer "..retainer_index.." - no items listed")
    return
  end

  OpenRetainer(retainer_index)
  OpenSellListInventory()
  UndercutItems(ReturnItemToInventory)
  CloseSellList()
  CloseRetainer()
end

function ListItemForSaleFromStack(item_stack, stack_size, max_slots, price_floor, force_list, list_price)
  local num_listings = 1
  if stack_size > 0 then
    num_listings = item_stack.count // stack_size
  else
    stack_size = item_stack.count
  end
  if num_listings > max_slots then
    num_listings = max_slots
  end
  if num_listings <= 0 then
    LogDebug("cannot fill stack_size "..stack_size.." with available items ("..item_stack.count.."), skipping")
    return 0, list_price
  end

  OpenItemRetainerSell(item_stack.page, item_stack.slot)

  if list_price <= 0 then
    list_price = GetUndercutPrice()
    if list_price <= 0 then
      list_price = RoundUpToNext(price_floor * 2, 10000) - 10
    elseif list_price < price_floor then
      if force_list then
        list_price = RoundUpToNext(price_floor, 10) - 10
      else
        list_price = 0
      end
    end
    if list_price <= 0 then
      CloseItemSell()
      LogDebug("item price is too low, bailing")
      return 0, 0
    end
  end

  LogDebug("listing item "..num_listings.." times")
  for i = 1, num_listings do
    if i > 1 then
      OpenItemRetainerSell(item_stack.page, item_stack.slot)
    end

    if stack_size > 0 and stack_size ~= GetCurrentItemSellCount() then
      ApplyItemSellCount(stack_size)
    end

    local current_price = GetCurrentItemSellPrice()
    if list_price ~= current_price then
      ApplyPriceUpdateAndClose(list_price)
    else
      ConfirmItemSellAndClose()
    end
  end

  LogDebug("listed "..stack_size.." item(s) x"..num_listings.." at price "..list_price)
  return num_listings, list_price
end

function ListItemForSale(sell_entry, max_slots, item_stacks, listed_item)
  local item_id = sell_entry[1]
  local price_floor = sell_entry[2]
  local force_list = sell_entry[3]
  local stack_size = sell_entry[4]
  local max_listings = sell_entry[5]
  local save_count = sell_entry[6]
  -- LogDebug("listing item "..item_id)

  if max_slots <= 0 then
    LogDebug("no slots available, skipping item")
    return 0
  end
  
  if max_listings <= 0 then
    LogDebug("no listings desired, skipping item")
    return 0
  end

  local list_price = -1
  if listed_item ~= nil then
    list_price = listed_item.price
    max_listings = max_listings - listed_item.count
    if max_listings <= 0 then
      LogDebug("max listings already fulfilled, skipping item")
      return 0
    end
  end

  if max_listings < max_slots then
    max_slots = max_listings
  end

  local num_listings = 0
  for _, item_stack in pairs(item_stacks) do
    LogDebug("processing stack "..item_stack.count.." at "..item_stack.page.."."..item_stack.slot)
    local original_count = item_stack.count
    if item_stack.count <= 0 then
      LogDebug("cannot process stack, failed to fetch item count")
    elseif save_count > 0 then
      if item_stack.count < save_count then
        save_count = save_count - item_stack.count
        item_stack.count = 0
      else
        item_stack.count = item_stack.count - save_count
        save_count = 0
      end
      LogDebug("reducing count to save min_keep items. new count "..item_stack.count.." (save_count="..save_count..")")
    end
 
    if item_stack.count > 0 then
      local listings_added = 0
      listings_added, list_price = ListItemForSaleFromStack(item_stack, stack_size, max_slots, price_floor, force_list, list_price)
      item_stack.count = original_count - (listings_added * stack_size)
      num_listings = num_listings + listings_added
      max_slots = max_slots - listings_added
      if list_price == 0 then
        LogDebug("failed to fetch item price, bailing")
        break
      end
      if max_slots <= 0 then
        LogDebug("max slots reached, bailing")
        break
      end
    end
  end

  if num_listings > 0 then
    LogInfo("    Listed item "..item_id.." "..num_listings.." times, at "..list_price)
  end
  return num_listings
end

function SellRetainerItems(retainer_index, retainer_name, sell_table, unlist)
  OpenSellListRetainer()

  local sale_slots = 0
  local listed_items = {}
  if unlist then
    LogInfo("  Returning all listed items to retainer "..retainer_index.." inventory")
    ReturnAllItemsToRetainer()
    sale_slots = 20
  else
    LogInfo("  Undercutting existing items for retainer "..retainer_index)
    listed_items = UndercutItems(ReturnItemToRetainer, sell_table)
    sale_slots = 20 - GetSellListCount()
  end

  local inventory = FindItemsInRetainerInventory(retainer_name)

  LogInfo("  Listing sale items for retainer "..retainer_index)
  for i, sell_entry in pairs(sell_table) do
    if i ~= 0 then
      local item_id = sell_entry[1]
      local item_stacks = inventory[item_id]
      if item_stacks ~= nil then
        sale_slots = sale_slots - ListItemForSale(sell_entry, sale_slots, item_stacks, listed_items[item_id])
        if sale_slots <= 0 then
          LogDebug("no open slots remaining")
          break
        end
      end
    end
  end

  CloseSellList()
end

-- Actions (Core)

function ARPostUndercutRetainer(retainer_index, sell_table)
  if sell_table == nil then
    LogInfo("  Only undercutting items for retainer "..retainer_index)
    UndercutRetainerItems(retainer_index)
    return
  end

  local retainer_config = sell_table[0]
  if retainer_config.exclude == true then
    LogInfo("  Skipping excluded retainer  "..retainer_index)
    return
  end

  local retainer_name = GetRetainerName(retainer_index)
  if StringIsEmpty(retainer_name) then
    LogError("  Failed to fetch name for retainer "..retainer_index)
    return
  end
  LogInfo("Processing retainer "..retainer_index.." "..retainer_name)

  OpenRetainer(retainer_index)
  if retainer_config.entrust == true then
    LogInfo("  Entrusting items to retainer "..retainer_index.." from inventory")
    EntrustInventoryItems(sell_table)
  end
  SellRetainerItems(retainer_index, retainer_name, sell_table, retainer_config.unlist == true)
  CloseRetainer()
end

function ARPostUndercut()
  LogInfo("ARPostUndercut")
  ARSetSuppressed(true)
  yield("/xldisablecollection ARPostUndercutSuppress")
  if OpenRetainerList() then
    for i = 1, retainer_count do
      ARPostUndercutRetainer(i, retainer_sell_tables[i])
    end
    CloseRetainerList()
  end
  yield("/xlenablecollection ARPostUndercutSuppress")
  yield("/wait 2")
  ARSetSuppressed(false)
end


ARPostUndercut()
