#===============================================================================
# Determines the species of the raid Pokemon to be encountered in a raid battle.
#===============================================================================
def pbDefaultRaidSpecies(species, rules)
  species_data = GameData::Species.try_get(species)
  return :DITTO if !species_data
  if species_data.form > 0 && !species_data.raid_species?(rules[:style])
    species = species_data.species
    species_data = GameData::Species.get(species)
    rules[:rank] = species_data.raid_ranks.sample if !species_data.raid_ranks.include?(rules[:rank])
  end
  return (species_data.raid_species?(rules[:style])) ? species : :DITTO
end

#===============================================================================
# Determines the level of the raid Pokemon to be encountered in a raid battle.
#===============================================================================
def pbDefaultRaidPokemonLevel(pkmn, rules)
  rank = rules[:rank]
  if rank.nil?
    case pkmn
    when Integer then rank = pkmn
    when Pokemon then rank = pkmn.species_data.raid_ranks.sample
    when Symbol  then rank = GameData::Species.get(pkmn).raid_ranks.sample
    end
  end
  return 100 if rank == 7
  rank = 1 if rank <= 0
  level = (rank * 10) + rand(6)
  level += 15 if rank > 4
  return level
end

#===============================================================================
# Determines the rank for a raid battle.
#===============================================================================
def pbDefaultRaidRank(pkmn, rules)
  case pkmn
  when Pokemon
    case pkmn.level
    when 0..19  then return 1
    when 20..29 then return 2
    when 30..39 then return 3
    when 40..49 then return 4
    when 50..69 then return 5
    when 70..99 then return 6
    else             return 7
    end
  when Symbol
    pkmn = GameData::Species.try_get(pkmn)
    if pkmn && pkmn.raid_species?(rules[:style])
      rank = rules[:rank]
      raid_ranks = pkmn.raid_ranks
      return (rank && raid_ranks.include?(rank)) ? rank : raid_ranks.sample
    end
  end
  odds = rand(100)
  badges = $player.badge_count
  if badges >= 8
    return (odds < 40) ? 3 : [4, 5].sample
  elsif badges >= 6
    return (odds < 40) ? [1, 2].sample : [3, 4].sample
  elsif badges >= 3
    return (odds < 40) ? 2 : [1, 3].sample
  else
    return (odds < 80) ? 1 : 2
  end
end

#===============================================================================
# Returns whether the player has enough badges for a certain raid rank.
#===============================================================================
def pbHasBadgesForRank?(rank)
  badges = $player.badge_count
  return true if !rank || badges >= 8
  return true if rank == 4 && badges >= 6
  return true if rank == 3 && badges >= 3
  return true if rank <= 2
  return false
end

#===============================================================================
# General utility for setting default raid property values.
#===============================================================================
def pbDefaultRaidProperty(property, rules)
  case property
  when :ko_count      then pbDefaultRaidKOCount(rules)
  when :turn_count    then pbDefaultRaidTurnCount(rules)
  when :shield_hp     then pbDefaultRaidShield(rules)
  when :extra_actions then pbDefaultRaidActions(rules)
  end
end

#===============================================================================
# Determines the initial KO counter for a raid battle.
#===============================================================================
def pbDefaultRaidKOCount(rules)
  size = (rules[:partner]) ? 2 : rules[:size]
  return 1 if size == 1
  return rules[:ko_count] if rules.has_key?(:ko_count)
  rank = rules[:rank] || 1
  count = Settings::RAID_BASE_KNOCK_OUTS
  count += 1 if size == 2
  count += 1 if rank > 5
  return count
end

#===============================================================================
# Determines the initial turn counter for a raid battle.
#===============================================================================
def pbDefaultRaidTurnCount(rules)  
  return rules[:turn_count] if rules.has_key?(:turn_count)
  count = Settings::RAID_BASE_TURN_LIMIT
  size = ((rules[:partner]) ? 2 : rules[:size]) || Settings::RAID_BASE_PARTY_SIZE
  count += size if size < 3
  rank = rules[:rank] || 1
  count += (rank / 2).ceil
  return count
end

#===============================================================================
# Determines the amount of shield HP the raid Pokemon will have in a raid battle.
#===============================================================================
def pbDefaultRaidShield(rules)
  count = rules.has_key?(:shield_hp)
  return nil if count && !rules[:shield_hp]
  return rules[:shield_hp] if pbInRaidAdventure?
  rank = rules[:rank]
  count = rules[:shield_hp] || 0
  if rank
    count = rank + 2
    size = ((rules[:partner]) ? 2 : rules[:size]) || Settings::RAID_BASE_PARTY_SIZE
    count -= [2, 1, 0][size - 1]
  end
  return (count > 8) ? 8 : count
end

#===============================================================================
# Determines the kinds of extra actions the raid Pokemon may perform in a raid battle.
#===============================================================================
def pbDefaultRaidActions(rules)
  return rules[:extra_actions] if rules.has_key?(:extra_actions)
  rank = rules[:rank] || 1
  actions = []
  actions.push(:reset_drops)  if rank >= 3
  actions.push(:reset_boosts) if rank >= 4
  actions.push(:drain_cheer)  if rank >= 5
  return actions
end