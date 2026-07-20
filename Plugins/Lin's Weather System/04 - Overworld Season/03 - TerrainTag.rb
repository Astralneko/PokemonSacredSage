#===============================================================================
# * Weather System - Season Change
#===============================================================================

GameData::TerrainTag.register({
  :id                     => :SummerGrass,
  :id_number              => 51,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :SummerGrass
})

GameData::TerrainTag.register({
  :id                     => :SummerTallGrass,
  :id_number              => 52,
  :deep_bush              => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => true,
  :battle_environment     => :SummerTallGrass,
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :AutumnGrass,
  :id_number              => 53,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :AutumnGrass
})

GameData::TerrainTag.register({
  :id                     => :AutumnTallGrass,
  :id_number              => 54,
  :deep_bush              => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => true,
  :battle_environment     => :AutumnTallGrass,
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :WinterGrass,
  :id_number              => 55,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :WinterGrass
})

GameData::TerrainTag.register({
  :id                     => :WinterTallGrass,
  :id_number              => 56,
  :deep_bush              => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => true,
  :battle_environment     => :WinterTallGrass,
  :must_walk              => true
})

GameData::TerrainTag.register({
  :id                     => :SpringGrass,
  :id_number              => 57,
  :shows_grass_rustle     => true,
  :land_wild_encounters   => true,
  :battle_environment     => :SpringGrass
})

GameData::TerrainTag.register({
  :id                     => :SpringTallGrass,
  :id_number              => 58,
  :deep_bush              => true,
  :land_wild_encounters   => true,
  :double_wild_encounters => true,
  :battle_environment     => :SpringTallGrass,
  :must_walk              => true
})