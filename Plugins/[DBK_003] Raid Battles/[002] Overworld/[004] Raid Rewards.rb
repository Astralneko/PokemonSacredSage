#===============================================================================
# Generates a rewards list for this Raid Den.
#===============================================================================
def pbGenerateRaidRewards(pokemon, style = :Basic, rank = nil, loot = nil, weather = nil, terrain = nil, environ = nil)
  rewards = []
  rank = pbDefaultRaidRank(pokemon, {}) if rank.nil?
  qty = (rank * 1.5).round
  #-----------------------------------------------------------------------------
  # Adds each category of rewards.
  #-----------------------------------------------------------------------------
  pbRewardExpCandy(rewards, rank, qty)
  pbRewardExclusiveItems(rewards, pokemon, rank, style)
  pbRewardMachines(rewards, pokemon, rank, style)
  pbRewardVitamins(rewards, rank, qty)
  pbRewardBerries(rewards, qty)
  pbRewardMints(rewards, rank)
  pbRewardModifyingItems(rewards, rank)
  pbRewardTreasures(rewards, rank)
  pbRewardPokeBalls(rewards, rank)
  pbRewardWeatherItems(rewards, weather)
  pbRewardTerrainItems(rewards, terrain)
  pbRewardEnvironmentItems(rewards, environ)
  pbRewardLootItems(rewards, loot)
  #-----------------------------------------------------------------------------
  # Finalizes all rewards.
  #-----------------------------------------------------------------------------
  final_rewards = {}
  rewards.each do |reward|
    next if !GameData::Item.exists?(reward[0])
    if final_rewards.has_key?(reward[0])
      final_rewards[reward[0]] += reward[1]
    else
      final_rewards[reward[0]] = reward[1]
    end
  end
  return final_rewards
end

#-------------------------------------------------------------------------------
# Awards items that increase level or exp.
#-------------------------------------------------------------------------------
def pbRewardExpCandy(rewards, rank, qty)
  # Exp. Candy added in any raid rank.
  [:EXPCANDYXL, :EXPCANDYL, :EXPCANDYM, :EXPCANDYS, :EXPCANDYXS].each_with_index do |candy, i|
    case candy
    when :EXPCANDYXS then next if rank > 5 || rank == 5 && rand(10) < 4
    when :EXPCANDYS  then next if rank > 5 && rand(10) < 2
    when :EXPCANDYM  then next if rank < 3
    when :EXPCANDYL  then next if rank < 4 || rank == 4 && rand(10) > 2
    when :EXPCANDYXL then next if rank < 5 || rank == 5 && rand(10) > 2
    end
    candyQty = ((i == 0) ? (qty / 2).round : qty * i)
    rewards.push([candy, candyQty + rand(3)])
  end
  # Rare Candy only found in rank 3+ raids.
  return if rank < 3 
  rewards.push([:RARECANDY, qty + rand(-1..2)])
end

#-------------------------------------------------------------------------------
# Awards items exclusive to specific types of raids and opponents.
#-------------------------------------------------------------------------------
def pbRewardExclusiveItems(rewards, pkmn, rank, style)
  case style
  # Rewards found in Ultra Raids.
  when :Ultra
    rewards.push([:ZBOOSTER, 1]) if pkmn.isSpecies?(:NECROZMA)
  # Rewards found in Max Raids.
  when :Max
    rewards.push([:DYNAMAXCANDY, qty + rand(-1..2)]) if rank > 2
    rewards.push([:MAXSOUP, 1]) if pkmn.gmax_factor? && rand(2) == 0
    case pkmn.species
    when :VESPIQUEN
      rewards.push([:MAXHONEY, 1])
    when :PARASECT, :BRELOOM, :AMOONGUS, :SHIINOTIC, :TOEDSCRUEL
      rewards.push([:MAXMUSHROOMS, 1])
    when :ETERNATUS
      rewards.push([:WISHINGSTAR, 1])
    end
  # Rewards found in Tera Raids.
  when :Tera
    shard = GameData::Item.get_shard_from_type(pkmn.tera_type)
    return if !shard
    shardQty = qty + rand(-1..2)
    if $bag.has?(:GLIMMERINGCHARM)
      case rank
      when 3 then shardQty += 2
      when 4 then shardQty += 5
      when 5 then shardQty += 10
      when 6 then shardQty += 12
      when 7 then shardQty += 20
      end
    end
    rewards.push([shard, shardQty])
    rewards.push([:MYSTERYTERAJEWEL, 1]) if rand(10) < 2
    rewards.push([:RADIANTTERAJEWEL, 1]) if pkmn.isSpecies?(:TERAPAGOS)
  end
end

#-------------------------------------------------------------------------------
# Awards items that teach Pokemon a move (TM/TR).
#-------------------------------------------------------------------------------
def pbRewardMachines(rewards, pkmn, rank, style)
  return if rank < 3
  types = (style == :Tera) ? [pkmn.tera_type] : pkmn.types
  machine = GameData::Item.get_TR_from_type(types)
  rewards.push([machine, 1]) if machine
end

#-------------------------------------------------------------------------------
# Awards items that can be used to alter a Pokemon's attributes.
#-------------------------------------------------------------------------------
def pbRewardBerries(rewards, qty)
  itemQty = [1, ((qty / 2) + rand(-1..2)).round].max
  berries = [
    :POMEGBERRY, :KELPSYBERRY, :QUALOTBERRY,
    :HONDEWBERRY, :GREPABERRY, :TAMATOBERRY
  ]
  rewards.push([berries.sample, itemQty])
end

def pbRewardMints(rewards, rank)
  return if rank < 4 # Only found in rank 4+ raids.
  mints = [
    :SERIOUSMINT,                                          # - Neutral
    :LONELYMINT, :ADAMANTMINT, :NAUGHTYMINT, :BRAVEMINT,   # + Attack
    :BOLDMINT,   :IMPISHMINT,  :LAXMINT,     :RELAXEDMINT, # + Defense
    :MODESTMINT, :MILDMINT,    :RASHMINT,    :QUIETMINT,   # + Sp.Atk
    :CALMMINT,   :GENTLEMINT,  :CAREFULMINT, :SASSYMINT,   # + Sp.Def
    :TIMIDMINT,  :HASTYMINT,   :JOLLYMINT,   :NAIVEMINT    # + Speed
  ]
  rewards.push([mints.sample, 1])
end

def pbRewardVitamins(rewards, rank, qty)
  # Feather items added in any raid rank.
  itemQty = [1, ((qty / 2) + rand(-1..2)).round].max
  feathers = [
    :HEALTHFEATHER, :MUSCLEFEATHER, :RESISTFEATHER, 
    :GENIUSFEATHER, :CLEVERFEATHER, :SWIFTFEATHER
  ]
  rewards.push([feathers.sample, itemQty])
  # Vitamins only found in rank 3+ raids.
  return if rank < 3
  mod = (rank > 5) ? 2 : 4
  itemQty = [1, ((qty / mod) + rand(-1..2)).round].max
  vitamins = [:HPUP, :PROTEIN, :IRON, :CALCIUM, :ZINC, :CARBOS]
  rewards.push([vitamins.sample, itemQty])
end

def pbRewardModifyingItems(rewards, rank)
  return if rank < 3     # Only found in rank 3+ raids.
  return if rand(10) > 2 # 30% chance to add reward.
  modifiers = [
    :PPUP, :PPMAX,
    :ABILITYCAPSULE, :ABILITYPATCH, 
    :BOTTLECAP, :GOLDBOTTLECAP
  ]
  rewards.push([modifiers.sample, 1])
end

#-------------------------------------------------------------------------------
# Awards valuable items with a high sell price.
#-------------------------------------------------------------------------------
def pbRewardTreasures(rewards, rank)
  return if rank < 3     # Only found in rank 3+ raids.
  return if rand(10) > 1 # 20% chance to add reward.
  case rank
  when 3     # Rank 3 raids
    treasure = [:TINYMUSHROOM, :NUGGET, :PEARL, :RELICCOPPER, :RELICVASE]
  when 4, 5  # Rank 4 & 5 raids
    treasure = [:BIGMUSHROOM, :BIGNUGGET, :BIGPEARL, :RELICSILVER, :RELICBAND]
  when 6, 7  # Rank 6 & 7 raids
    treasure = [:BALMMUSHROOM, :PEARLSTRING, :RELICGOLD, :RELICSTATUE, :RELICCROWN]
  end
  rewards.push([treasure.sample, 1])
end

#-------------------------------------------------------------------------------
# Awards novelty Poke Ball items.
#-------------------------------------------------------------------------------
def pbRewardPokeBalls(rewards, rank)
  return if rand(6) >= rank # Odds increase with raid rank.
  balls = [
    :HEAVYBALL, :LUREBALL, :FRIENDBALL, :LOVEBALL, :LEVELBALL,
    :FASTBALL, :MOONBALL, :DREAMBALL, :BEASTBALL
  ]
	rewards.push([balls.sample, 1])
end

#-------------------------------------------------------------------------------
# Awards items related to the weather, terrain, or enviornment during the battle.
#-------------------------------------------------------------------------------
def pbRewardWeatherItems(rewards, value)
  return if rand(10) > 1 # 20% chance to add reward.
  case value
  when :Sun         then rewards.push([:HEATROCK,      1])
  when :Rain        then rewards.push([:DAMPROCK,      1])
  when :Sandstorm   then rewards.push([:SMOOTHROCK,    1])
  when :Hail, :Snow then rewards.push([:ICYROCK,       1])
  when :ShadowSky   then rewards.push([:LIFEORB,       1])
  when :Fog         then rewards.push([:SMOKEBALL,     1])
  end
end

def pbRewardTerrainItems(rewards, value)
  return if rand(10) > 1 # 20% chance to add reward.
  case value            
  when :Electric    then rewards.push([:ELECTRICSEED,  1])
  when :Grassy      then rewards.push([:GRASSYSEED,    1])
  when :Misty       then rewards.push([:MISTYSEED,     1])
  when :Psychic     then rewards.push([:PSYCHICSEED,   1])
  end
end

def pbRewardEnvironmentItems(rewards, value)
  return if rand(10) > 1 # 20% chance to add reward.
  case value
  when :None        then rewards.push([:CELLBATTERY,   1])    
  when :Grass       then rewards.push([:MIRACLESEED,   1])
  when :TallGrass   then rewards.push([:ABSORBBULB,    1])
  when :MovingWater then rewards.push([:MYSTICWATER,   1])
  when :StillWater  then rewards.push([:FRESHWATER,    1])
  when :Puddle      then rewards.push([:LIGHTCLAY,     1])
  when :Underwater  then rewards.push([:SHOALSHELL,    1])    
  when :Cave        then rewards.push([:LUMINOUSMOSS,  1])
  when :Rock        then rewards.push([:HARDSTONE,     1])
  when :Sand        then rewards.push([:SOFTSAND,      1])
  when :Forest      then rewards.push([:SHEDSHELL,     1])
  when :ForestGrass then rewards.push([:SILVERPOWDER,  1])
  when :Snow        then rewards.push([:SNOWBALL,      1])
  when :Ice         then rewards.push([:NEVERMELTICE,  1])
  when :Volcano     then rewards.push([:CHARCOAL,      1])
  when :Graveyard   then rewards.push([:RAREBONE,      1])
  when :Sky         then rewards.push([:PRETTYFEATHER, 1])
  when :Space       then rewards.push([:STARDUST,      1])
  when :UltraSpace  then rewards.push([:COMETSHARD,    1])
  end
end

#-------------------------------------------------------------------------------
# Awards special loot items set to appear in a particular den.
#-------------------------------------------------------------------------------
def pbRewardLootItems(reward, loot)
  return if loot.nil?
  case loot
  when Array
    loot.each do |itm|
      case itm
      when Array
        rewards.push(itm)
      when Symbol
        rewards.push([itm, 1])
      end
    end
  else
    rewards.push([loot, 1])
  end
end