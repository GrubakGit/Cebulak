-- ====================================================================
-- Cebulak - Waylaid Crate Optimizer (WoW Forever)
-- Baza danych skrzyń Waylaid oraz ich surowców napełnienia
-- ====================================================================
local _, Cebulak = ...

Cebulak.REWARDS = {
  ["Apprentice"] = {
    ["Biała"] = { favor = 5, refund = 0 },
    ["Zielona"] = { favor = 10, refund = 500 },
  },
  ["Journeyman"] = {
    ["Biała"] = { favor = 10, refund = 500 },
    ["Zielona"] = { favor = 20, refund = 1000 },
  },
  ["Expert"] = {
    ["Biała"] = { favor = 15, refund = 750 },
    ["Zielona"] = { favor = 30, refund = 1500 },
  },
  ["Artisan"] = {
    ["Biała"] = { favor = 20, refund = 1000 },
    ["Zielona"] = { favor = 40, refund = 2000 },
  },
}

Cebulak.CRATES = {
  {
    name = "Waylaid Crate: Apprentice Herbs",
    itemID = 248682,
    category = "Herbs",
    tier = "Apprentice",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 2447, name = "Peacebloom", count = 20 },
      },
      {
        { itemID = 765, name = "Silverleaf", count = 20 },
      },
      {
        { itemID = 2449, name = "Earthroot", count = 10 },
      },
      {
        { itemID = 785, name = "Mageroyal", count = 10 },
      },
      {
        { itemID = 2450, name = "Briarthorn", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Herbs",
    itemID = 248686,
    category = "Herbs",
    tier = "Journeyman",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 3820, name = "Stranglekelp", count = 10 },
      },
      {
        { itemID = 2453, name = "Bruiseweed", count = 10 },
      },
      {
        { itemID = 3355, name = "Wild Steelbloom", count = 10 },
      },
      {
        { itemID = 3369, name = "Grave Moss", count = 10 },
      },
      {
        { itemID = 3356, name = "Kingsblood", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Earthly Expert Herbs",
    itemID = 248690,
    category = "Herbs",
    tier = "Expert",
    quality = "Biała",
    reqLevel = 20,
    options = {
      {
        { itemID = 3357, name = "Liferoot", count = 20 },
      },
      {
        { itemID = 3818, name = "Fadeleaf", count = 10 },
      },
      {
        { itemID = 3821, name = "Goldthorn", count = 10 },
      },
      {
        { itemID = 3358, name = "Khadgar's Whisker", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Flowering Expert Herbs",
    itemID = 248691,
    category = "Herbs",
    tier = "Expert",
    quality = "Biała",
    reqLevel = 20,
    options = {
      {
        { itemID = 3819, name = "Wintersbite", count = 10 },
      },
      {
        { itemID = 4625, name = "Firebloom", count = 10 },
      },
      {
        { itemID = 8831, name = "Purple Lotus", count = 20 },
      },
      {
        { itemID = 8836, name = "Arthas' Tears", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Earthly Artisan Herbs",
    itemID = 248695,
    category = "Herbs",
    tier = "Artisan",
    quality = "Biała",
    reqLevel = 35,
    options = {
      {
        { itemID = 13464, name = "Golden Sansam", count = 10 },
      },
      {
        { itemID = 8838, name = "Sungrass", count = 20 },
      },
      {
        { itemID = 8839, name = "Blindweed", count = 10 },
      },
      {
        { itemID = 8845, name = "Ghost Mushroom", count = 10 },
      },
      {
        { itemID = 8846, name = "Gromsblood", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Flowering Artisan Herbs",
    itemID = 248696,
    category = "Herbs",
    tier = "Artisan",
    quality = "Biała",
    reqLevel = 35,
    options = {
      {
        { itemID = 13463, name = "Dreamfoil", count = 20 },
      },
      {
        { itemID = 13465, name = "Mountain Silversage", count = 20 },
      },
      {
        { itemID = 13466, name = "Plaguebloom", count = 20 },
      },
      {
        { itemID = 13467, name = "Icecap", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Apprentice Ore",
    itemID = 248683,
    category = "Ore",
    tier = "Apprentice",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 2770, name = "Copper Ore", count = 20 },
      },
      {
        { itemID = 2771, name = "Tin Ore", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Ore",
    itemID = 248687,
    category = "Ore",
    tier = "Journeyman",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 2775, name = "Silver Ore", count = 10 },
      },
      {
        { itemID = 2772, name = "Iron Ore", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Expert Ore",
    itemID = 248692,
    category = "Ore",
    tier = "Expert",
    quality = "Biała",
    reqLevel = 20,
    options = {
      {
        { itemID = 2776, name = "Gold Ore", count = 10 },
      },
      {
        { itemID = 3858, name = "Mithril Ore", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Artisan Ore",
    itemID = 248697,
    category = "Ore",
    tier = "Artisan",
    quality = "Biała",
    reqLevel = 35,
    options = {
      {
        { itemID = 7911, name = "Truesilver Ore", count = 10 },
      },
      {
        { itemID = 10620, name = "Thorium Ore", count = 20 },
      },
      {
        { itemID = 11370, name = "Dark Iron Ore", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Apprentice Textiles",
    itemID = 248684,
    category = "Textiles",
    tier = "Apprentice",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 2589, name = "Linen Cloth", count = 40 },
      },
      {
        { itemID = 2318, name = "Light Leather", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Textiles",
    itemID = 248688,
    category = "Textiles",
    tier = "Journeyman",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 2592, name = "Wool Cloth", count = 20 },
      },
      {
        { itemID = 4306, name = "Silk Cloth", count = 40 },
      },
      {
        { itemID = 2319, name = "Medium Leather", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Expert Textiles",
    itemID = 248693,
    category = "Textiles",
    tier = "Expert",
    quality = "Biała",
    reqLevel = 20,
    options = {
      {
        { itemID = 4338, name = "Mageweave Cloth", count = 40 },
      },
      {
        { itemID = 4234, name = "Heavy Leather", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Artisan Textiles",
    itemID = 248698,
    category = "Textiles",
    tier = "Artisan",
    quality = "Biała",
    reqLevel = 35,
    options = {
      {
        { itemID = 14047, name = "Runecloth", count = 40 },
      },
      {
        { itemID = 4304, name = "Thick Leather", count = 20 },
      },
      {
        { itemID = 8170, name = "Rugged Leather", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Apprentice Curiosities",
    itemID = 248685,
    category = "Curiosities",
    tier = "Apprentice",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 10940, name = "Strange Dust", count = 20 },
      },
      {
        { itemID = 10939, name = "Greater Magic Essence", count = 4 },
      },
      {
        { itemID = 10978, name = "Small Glimmering Shard", count = 6 },
      },
      {
        { itemID = 11084, name = "Large Glimmering Shard", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Curiosities",
    itemID = 248689,
    category = "Curiosities",
    tier = "Journeyman",
    quality = "Biała",
    reqLevel = 10,
    options = {
      {
        { itemID = 11083, name = "Soul Dust", count = 20 },
      },
      {
        { itemID = 11082, name = "Greater Astral Essence", count = 4 },
      },
      {
        { itemID = 11138, name = "Small Glowing Shard", count = 6 },
      },
      {
        { itemID = 11139, name = "Large Glowing Shard", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Expert Curiosities",
    itemID = 248694,
    category = "Curiosities",
    tier = "Expert",
    quality = "Biała",
    reqLevel = 20,
    options = {
      {
        { itemID = 11137, name = "Vision Dust", count = 20 },
      },
      {
        { itemID = 11135, name = "Greater Mystic Essence", count = 4 },
      },
      {
        { itemID = 11177, name = "Small Radiant Shard", count = 6 },
      },
      {
        { itemID = 11178, name = "Large Radiant Shard", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Artisan Curiosities",
    itemID = 248699,
    category = "Curiosities",
    tier = "Artisan",
    quality = "Biała",
    reqLevel = 35,
    options = {
      {
        { itemID = 11176, name = "Dream Dust", count = 20 },
      },
      {
        { itemID = 11175, name = "Greater Nether Essence", count = 4 },
      },
      {
        { itemID = 14343, name = "Small Brilliant Shard", count = 6 },
      },
      {
        { itemID = 14344, name = "Large Brilliant Shard", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Apprentice Fabrics",
    itemID = 248702,
    category = "Fabrics",
    tier = "Apprentice",
    quality = "Zielona",
    reqLevel = 10,
    options = {
      {
        { itemID = 4231, name = "Cured Light Hide", count = 2 },
      },
      {
        { itemID = 2996, name = "Bolt of Linen Cloth", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Fabrics",
    itemID = 248705,
    category = "Fabrics",
    tier = "Journeyman",
    quality = "Zielona",
    reqLevel = 10,
    options = {
      {
        { itemID = 2997, name = "Bolt of Woolen Cloth", count = 6 },
      },
      {
        { itemID = 4305, name = "Bolt of Silk Cloth", count = 10 },
      },
      {
        { itemID = 4233, name = "Cured Medium Hide", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Expert Fabrics",
    itemID = 248708,
    category = "Fabrics",
    tier = "Expert",
    quality = "Zielona",
    reqLevel = 20,
    options = {
      {
        { itemID = 4339, name = "Bolt of Mageweave", count = 8 },
      },
      {
        { itemID = 4236, name = "Cured Heavy Hide", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Artisan Fabrics",
    itemID = 248711,
    category = "Fabrics",
    tier = "Artisan",
    quality = "Zielona",
    reqLevel = 35,
    options = {
      {
        { itemID = 14048, name = "Bolt of Runecloth", count = 8 },
      },
      {
        { itemID = 8172, name = "Cured Thick Hide", count = 2 },
      },
    },
  },
  {
    name = "Waylaid Crate: Apprentice Ingots",
    itemID = 248703,
    category = "Ingots",
    tier = "Apprentice",
    quality = "Zielona",
    reqLevel = 10,
    options = {
      {
        { itemID = 2840, name = "Copper Bar", count = 20 },
      },
      {
        { itemID = 3576, name = "Tin Bar", count = 20 },
      },
      {
        { itemID = 2841, name = "Bronze Bar", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Ingots",
    itemID = 248706,
    category = "Ingots",
    tier = "Journeyman",
    quality = "Zielona",
    reqLevel = 10,
    options = {
      {
        { itemID = 2842, name = "Silver Bar", count = 10 },
      },
      {
        { itemID = 3575, name = "Iron Bar", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Expert Ingots",
    itemID = 248709,
    category = "Ingots",
    tier = "Expert",
    quality = "Zielona",
    reqLevel = 20,
    options = {
      {
        { itemID = 3860, name = "Mithril Bar", count = 20 },
      },
      {
        { itemID = 3859, name = "Steel Bar", count = 15 },
      },
      {
        { itemID = 3577, name = "Gold Bar", count = 10 },
      },
    },
  },
  {
    name = "Waylaid Crate: Artisan Ingots",
    itemID = 248712,
    category = "Ingots",
    tier = "Artisan",
    quality = "Zielona",
    reqLevel = 35,
    options = {
      {
        { itemID = 11371, name = "Dark Iron Bar", count = 2 },
      },
      {
        { itemID = 6037, name = "Truesilver Bar", count = 10 },
      },
      {
        { itemID = 12359, name = "Thorium Bar", count = 20 },
      },
    },
  },
  {
    name = "Waylaid Crate: Apprentice Parts",
    itemID = 248704,
    category = "Parts",
    tier = "Apprentice",
    quality = "Zielona",
    reqLevel = 10,
    options = {
      {
        { itemID = 4359, name = "Handful of Copper Bolts", count = 16 },
      },
      {
        { itemID = 4361, name = "Copper Tube", count = 16 },
      },
      {
        { itemID = 4363, name = "Copper Modulator", count = 4 },
      },
    },
  },
  {
    name = "Waylaid Crate: Journeyman Parts",
    itemID = 248707,
    category = "Parts",
    tier = "Journeyman",
    quality = "Zielona",
    reqLevel = 10,
    options = {
      {
        { itemID = 4371, name = "Bronze Tube", count = 8 },
      },
      {
        { itemID = 4375, name = "Whirring Bronze Gizmo", count = 7 },
      },
      {
        { itemID = 4382, name = "Bronze Framework", count = 4 },
      },
      {
        { itemID = 10558, name = "Gold Power Core", count = 45 },
      },
    },
  },
  {
    name = "Waylaid Crate: Expert Parts",
    itemID = 248710,
    category = "Parts",
    tier = "Expert",
    quality = "Zielona",
    reqLevel = 20,
    options = {
      {
        { itemID = 4387, name = "Iron Strut", count = 8 },
      },
      {
        { itemID = 10559, name = "Mithril Tube", count = 5 },
      },
      {
        { itemID = 10560, name = "Unstable Trigger", count = 12 },
      },
      {
        { itemID = 10561, name = "Mithril Casing", count = 5 },
      },
    },
  },
  {
    name = "Waylaid Crate: Artisan Parts",
    itemID = 248713,
    category = "Parts",
    tier = "Artisan",
    quality = "Zielona",
    reqLevel = 35,
    options = {
      {
        { itemID = 15994, name = "Thorium Widget", count = 5 },
      },
      {
        { itemID = 18631, name = "Truesilver Transformer", count = 5 },
      },
      {
        { itemID = 16000, name = "Thorium Tube", count = 2 },
      },
    },
  },
}

-- Łatwy lookup po itemID skrzynki
Cebulak.CRATES_BY_ID = {}
for _, crate in ipairs(Cebulak.CRATES) do
  if crate.itemID and crate.itemID > 0 then
    Cebulak.CRATES_BY_ID[crate.itemID] = crate
  end
end