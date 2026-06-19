#===============================================================================
# Save Data
#===============================================================================

SaveData.register(:Materials) do
  ensure_class :Array
  save_value { $materialList }
  load_value { |value| $materialList = value }
  new_game_value { [] }
end

class Battle::Scene
  alias_method :orig_pbWildBattleSuccess, :pbWildBattleSuccess

  def pbWildBattleSuccess
    orig_pbWildBattleSuccess
    cntr = 0
    @battle.battlers.each do |b|
      pbWait(0.1)
      pbDrops(b) if cntr % 2 == 1
      cntr += 1
    end
  end
end

def pbDrops(pkmn)
  amnt = 0
  return if !pkmn
  evos = pkmn.pokemon.species_data.get_family_species
  pkmnIndex = evos.index(pkmn.species)
  while amnt <= pkmnIndex
    amnt += 1
  end
  amnt += 1 if pkmnIndex == evos.length-1
  baby = pkmn.pokemon.species_data.get_baby_species
  return if !GameData::Item.exists?(baby)
  item = GameData::Item.get(baby)
  return if !item
  if baby == item.id
    $bag.add(item.id,amnt)
    if amnt == 1
      @battle.pbDisplay(_INTL("The {1} dropped a {2}!",pkmn.name,item.name))
    else
      @battle.pbDisplay(_INTL("The {1} dropped {2} {3}!",pkmn.name,amnt,item.name_plural))
    end
  end
end