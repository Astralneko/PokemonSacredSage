#===============================================================================
# Main raid battle call.
#-------------------------------------------------------------------------------
# The "pkmn" hash accepts the following keys:
#-------------------------------------------------------------------------------
#	:type          => Filter by species type.
#	:habitat       => Filter by species habitat.
#	:generation    => Filter by species generation.
#	:encounter     => Filter by map encounter table.
#-------------------------------------------------------------------------------
# The "rules" hash accepts the following keys:
#-------------------------------------------------------------------------------
#	:rank          => Sets the raid rank.
#	:style         => Sets the raid type (Raid Dens ignore this).
#	:size          => Sets the battle size on the player's size.
#	:partner       => Sets a partner trainer.
#	:turn_count    => Sets the raid turn counter.
#	:ko_count      => Sets the raid KO counter.
#	:shield_hp     => Sets the raid shield HP.
#	:extra_actions => Sets extra raid actions.
#	:support_moves => Sets extra support moves.
#	:spread_moves  => Sets extra spread moves.
#	:loot          => Sets bonus loot (Raid Den only).
#	:online        => Sets the online status (Raid Den only).
#===============================================================================
class RaidBattle
  def self.start(pkmn = {}, rules = {})
    try_raid = GameData::RaidType.try_get(rules[:style])
    rules[:style] = :Basic if !try_raid || !try_raid.available
    #---------------------------------------------------------------------------
    # Checks for online Raid Den data.
    if rules[:raid_den] && !pkmn.is_a?(Pokemon)
      useOnlineData = (rules.has_key?(:online)) ? rules[:online] : rand(3) == 0
      rules[:online] = false
      if useOnlineData
        species, pkmn_data, raid_data = LiveRaidEvent.load
        if !species[0].nil? && rules[:style] == raid_data[:style] && pbHasBadgesForRank?(raid_data[:rank])
          setBattleRule("editWildPokemon", pkmn_data)
          pkmn = GameData::Species.get_species_form(*species).id
          rules = raid_data
        end
      end
    end
    #---------------------------------------------------------------------------
    # Sets up and validates general raid properties.
    rules[:rank] = pbDefaultRaidRank(pkmn, rules) if !rules[:rank]
    rules[:rank] = (rules[:rank] > 0) ? [rules[:rank], 7].min : 1
    if rules[:partner]
      rules[:size] = 1
      setBattleRule("2v1")
    else
      if rules[:size]
        rules[:size] = 1 if rules[:size] <= 0
        rules[:size] = 3 if rules[:size] > 3
      else
        rules[:size] = (Settings::RAID_BASE_PARTY_SIZE > 0) ? [Settings::RAID_BASE_PARTY_SIZE, 3].min : 1
      end
      rules[:size] = $player.able_pokemon_count if $player.able_pokemon_count < rules[:size]
      setBattleRule(sprintf("%dv1", rules[:size]))
    end
    rules[:pokemon] = self.generate_raid_foe(pkmn, rules)
    #---------------------------------------------------------------------------
    # Battle start.
    old_partner = $PokemonGlobal.partner
    pbDeregisterPartner
    if rules[:raid_den]
      decision = pbRaidDenEntry(rules)
    else
      pbSetRaidProperties(rules)
      pbFadeOutIn { decision = WildBattle.start_core(rules[:pokemon]) }
    end
    #---------------------------------------------------------------------------
    # Battle end.
    if rules[:pokemon]
      EventHandlers.trigger(:on_wild_battle_end, 
      rules[:pokemon].species_data.id, rules[:pokemon].level, decision)
      rules[:pokemon].heal
    end
    $PokemonGlobal.partner = old_partner
    $game_temp.transition_animation_data = nil
    return [1, 4].include?(decision)
  end
  
  #-----------------------------------------------------------------------------
  # Generates the raid Pokemon based on entered data.
  #-----------------------------------------------------------------------------
  def self.generate_raid_foe(pkmn, rules)
    if pkmn.is_a?(Pokemon)
      pkmn.heal
      return pkmn 
    end
    if pkmn.nil? || pkmn.is_a?(Hash)
      filter = []
      pkmn = {} if pkmn.nil?
      enc_list = $PokemonEncounters.get_encounter_list(pkmn[:encounter])
      raidRanks = GameData::Species.generate_raid_lists(rules[:style])
      raidRanks[rules[:rank]].each do |s|
        sp = GameData::Species.get(s)
        next if pkmn[:type]       && !sp.types.include?(pkmn[:type])
        next if pkmn[:habitat]    && sp.habitat != pkmn[:habitat]
        next if pkmn[:generation] && sp.generation != pkmn[:generation]
        next if pkmn[:encounter]  && !enc_list.include?(sp.id)
        filter.push(s)
      end
      pkmn = filter.sample
    end
    species = pbDefaultRaidSpecies(pkmn, rules)
    level = pbDefaultRaidPokemonLevel(species, rules)
    pkmn = Pokemon.new(species, level)
    pkmn.setRaidBossAttributes(rules)
    return pkmn
  end
end

#===============================================================================
# Generates a list of eligible raid species when :encounter is set in "pkmn" hash.
#===============================================================================
class PokemonEncounters
  def get_encounter_list(enc_type)
    enc_list = []
    return enc_list if !enc_type
    species = []
    enc_type = find_valid_encounter_type_for_time(enc_type, pbGetTimeNow)
    return enc_list if !@encounter_tables[enc_type]
    @encounter_tables[enc_type].each do |enc| 
      next if species.include?(enc[1])
      species.push(enc[1])
    end
    species.each do |sp|
      sp_data = GameData::Species.get(sp)
      if MultipleForms.hasFunction?(sp, "getForm")
        try_pkmn = Pokemon.new(sp, 1)
        check_form = try_pkmn.form
      else
        check_form = sp_data.form
      end
      sp_data.get_family_species.each do |fam|
        if fam == sp
          enc_list.push(fam)
        else
          id = GameData::Species.get_species_form(fam, check_form).id
          base_form = GameData::Species.get(id).base_form
          next if base_form > 0 && base_form != check_form
          enc_list.push(id)
        end
      end
    end
    return enc_list
  end
end

#===============================================================================
# Applies all relevant battle rules and properties for a raid battle.
#===============================================================================
def pbSetRaidProperties(rules)
  $game_temp.transition_animation_data = [rules[:pokemon], rules[:style]]
  [:ko_count, :turn_count, :shield_hp, :extra_actions].each do |r|
    rules[r] = pbDefaultRaidProperty(r, rules)
  end
  rules[:max_koCount] = rules[:ko_count]
  rules[:max_turnCount] = rules[:turn_count]
  raidType = GameData::RaidType.get(rules[:style])
  setBattleRule("raidBattle", rules)
  battleRules = $game_temp.battle_rules
  if !battleRules["backdrop"]
    bg = base = nil
    case battleRules["environment"]
    when raidType.battle_environ     then bg = raidType.battle_bg
    when :None                       then bg = "city"
    when :Grass, :TallGrass, :Puddle then bg = "field"
    when :MovingWater, :StillWater   then bg = "water"
    when :Underwater                 then bg = "underwater"
    when :Cave                       then bg = "cave3"
    when :Rock, :Volcano, :Sand      then bg = "rocky"
    when :Forest, :ForestGrass       then bg = "forest"
    when :Snow, :Ice                 then bg = "snow"
    when :Graveyard                  then bg = "distortion"
    end
    case battleRules["environment"]
    when raidType.battle_environ     then base = raidType.battle_base
    when :Grass, :TallGrass          then base = "grass"
    when :Sand                       then base = "sand"
    when :Ice                        then base = "ice"
    else                                  base = bg
    end
    setBattleRule("base", base) if base
    setBattleRule("backdrop", bg) if bg
  end
  if !battleRules["battleBGM"]
    bgm = raidType.battle_bgm
    if rules[:rank] == 7 || pbInRaidAdventure? && pbRaidAdventureState.boss_battled
      track = bgm[1]
    else
      track = bgm[0]
    end
    species = (rules[:pokemon]) ? rules[:pokemon].species_data.id : nil
    case rules[:style]
    when :Ultra then track = bgm[2] if [:NECROZMA_3, :NECROZMA_4].include?(species)
    when :Max   then track = bgm[2] if species == :ETERNATUS_1
    when :Tera  then track = bgm[2] if species == :TERAPAGOS_2
    end 
    if pbResolveAudioFile(track)
        setBattleRule("battleBGM", track)
      setBattleRule("lowHealthBGM", "")
    end
  end
  setBattleRule("canLose")
  setBattleRule("noBag") if pbInRaidAdventure?
  setBattleRule("setSlideSprite", "still") if !battleRules["slideSpriteStyle"]
  setBattleRule("databoxStyle", :Long) if !battleRules["databoxStyle"]
  pbRegisterPartner(*rules[:partner][0..2]) if rules[:partner]
  case rules[:style]
  when :Ultra then setBattleRule("noZMoves", :Player)
  when :Max   then setBattleRule("noDynamax", :Player)
  when :Tera  then setBattleRule("noTerastallize", :Player)
  end
end

#===============================================================================
# Handler for scaling a partner trainer's attributes to suit a particular raid.
#===============================================================================
EventHandlers.add(:on_trainer_load, :raid_partner,
  proc { |trainer|
    next if !trainer
    if pbInRaidAdventure?
      rules = {:rank  => 5,
               :style => pbRaidAdventureState.style}
    else
      rules = $game_temp.battle_rules["raidBattle"]
      next if !rules || rules[:partner][3]
    end
    items = {
      :Basic => [:MEGARING],
      :Ultra => [:ZRING], 
      :Max   => [:DYNAMAXBAND], 
      :Tera  => [:TERAORB]
    }
    trainer.items = items[rules[:style]]
    pkmn = trainer.party.last
    if pbInRaidAdventure?
      pkmn.level = [($player.badge_count + 1) * 10, 70].min
    else
      pkmn.level = pbDefaultRaidPokemonLevel(pkmn, rules)
    end
    if rules[:style] != :Basic
      pkmn.item = nil if pkmn.hasItem? && GameData::Item.get(pkmn.item_id).is_mega_stone?
    end
    case rules[:style]
    when :Max
      pkmn.dynamax_lvl = 5
      pkmn.dynamax_able = nil
    when :Tera
      pkmn.terastal_able = nil
    end
    pkmn.dynamax_able = false if defined?(pkmn.dynamax_able) && rules[:style] != :Max
    pkmn.terastal_able = false if defined?(pkmn.terastal_able) && rules[:style] != :Tera
    pkmn.set_raid_moves(rules, true)
    if !pkmn.hasItem? && GameData::Item.exists?(:SITRUSBERRY)
      pkmn.item = :SITRUSBERRY
    end
    pkmn.set_raid_evs
    pkmn.calc_stats
    trainer.party = [pkmn]
  }
)