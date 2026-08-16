#===============================================================================
# Applies all raid attributes to Pokemon in a raid setting.
#===============================================================================
class Pokemon
  #-----------------------------------------------------------------------------
  # Applies raid attributes to a Pokemon, converting it into a raid boss.
  #-----------------------------------------------------------------------------
  def setRaidBossAttributes(rules)
    boss_edit = $game_temp.battle_rules["editWildPokemon"].clone || {}
    EventHandlers.trigger(:on_wild_pokemon_created, self)
    self.shadow = nil
    calc_form = MultipleForms.call("getForm", self)
    @form = calc_form if ![nil, @form].include?(calc_form)
    # Pokemon caught in Raid Adventures are never shiny until the rewards screen.
    if pbInRaidAdventure?
      self.shiny = false
      self.super_shiny = false
    end
    # Sets style-specific forms and properties.
    case rules[:style]
    #---------------------------------------------------------------------------
    # Sets Pokemon into its Ultra Burst form. Sets Ultra Burst item.
    when :Ultra
      if MultipleForms.hasFunction?(self, "getUltraItem")
        self.form_simple = 1 if isSpecies?(:NECROZMA)
        self.item = MultipleForms.call("getUltraItem", self)
        self.makeUltra
      end
    #---------------------------------------------------------------------------
    # Sets Pokemon into its Dynamax form. Sets Dynamax Level.
    when :Max
      self.gmax_factor = true if species_data.gmax_move
      self.dynamax_lvl = 10
      self.dynamax = true
    #---------------------------------------------------------------------------
    # Sets Pokemon into its Terastallized form. Sets Tera type.
    when :Tera
      self.tera_type = :Random if !boss_edit[:tera_type]
      self.terastallized = true
      self.forced_form = @form + 4 if isSpecies?(:OGERPON)
    end
    # Sets all other properties.
    self.dynamax_able = false if defined?(dynamax_able) && rules[:style] != :Max
    self.terastal_able = false if defined?(terastal_able) && rules[:style] != :Tera
    self.set_raid_boss_properties(rules, boss_edit)
    self.set_raid_moves(rules, false, boss_edit[:moves])
    self.set_raid_ability(rules[:rank], boss_edit[:ability_index])
    self.set_raid_ivs(rules[:rank], boss_edit[:iv])
    self.calc_stats
    self.heal
  end
  
  #-----------------------------------------------------------------------------
  # Applies raid attributes to a Pokemon, converting it into a raid rental.
  #-----------------------------------------------------------------------------
  def setRaidRentalAttributes(style = :Basic, rank = 4)
    return if !species_data.raid_species?(style)
    self.shadow = nil
    # Sets style-specific forms and properties.
    case style
    #---------------------------------------------------------------------------
    # Returns Ultra Burst Pokemon to their base form.
    when :Ultra
      self.makeUnUltra
    #---------------------------------------------------------------------------
    # Returns G-Max Pokemon to their base form. Sets Dynamax Level.
    when :Max
      self.dynamax_lvl = 5
      if species_data.gmax_move
        self.gmax_factor = true
        self.form = species_data.ungmax_form
      end
    #---------------------------------------------------------------------------
    # Returns Terastal form Pokemon to their base form. Sets Tera type.
    when :Tera
      self.makeUnterastal
      self.tera_type = :Random if rank > 2
    end
    # Sets all other properties.
    calc_form = MultipleForms.call("getForm", self)
    @form = calc_form if ![nil, @form].include?(calc_form)
    self.dynamax_able = false if defined?(dynamax_able) && style != :Max
    self.terastal_able = false if defined?(terastal_able) && style != :Tera
    self.set_raid_moves(style, true)
    self.set_raid_ability(rank)
    self.set_raid_ivs(rank)
    self.set_raid_evs
    self.calc_stats
    self.heal
  end
  
  #-----------------------------------------------------------------------------
  # Resets a Pokemon's raid attributes.
  #-----------------------------------------------------------------------------
  def resetRaidAttributes(style, rank)
    self.shadow = nil
    self.forced_form = nil
    self.makeUnmega
    self.makeUnprimal
    # Resets style-specific forms and properties.
    case style
    #---------------------------------------------------------------------------
    # Returns Ultra Burst Pokemon to their base form. Removes held Z-Crystal.
    when :Ultra
      self.item = nil if ultra?
      self.makeUnUltra
      self.form_simple = 0 if isSpecies?(:NECROZMA)
      pkmn.item = nil if !pbInRaidAdventure?
    #---------------------------------------------------------------------------
    # Returns Dynamax Pokemon to their base form. Sets Dynamax Level.
    when :Max
      self.dynamax = false
      self.dynamax_lvl = rank + rand(3)
    #---------------------------------------------------------------------------
    # Returns Terastallized Pokemon to their base form.
    when :Tera
      self.terastallized = false
    end
    calc_form = MultipleForms.call("getForm", self)
    @form = calc_form if ![nil, @form].include?(calc_form)
    # Sets properties specific to Raid Dens or Raid Adventures.
    if pbInRaidAdventure?
      self.level = [($player.badge_count + 1) * 10, 70].min
      self.obtain_level = self.level
      self.set_raid_evs if !pbRaidAdventureState.endAdventure?
    else
      self.dynamax_able = nil if defined?(dynamax_able) && style != :Max
      self.terastal_able = nil if defined?(terastal_able) && style != :Tera
      self.reset_moves
    end
    # Resets all other properties.
    self.hp_level   = 0
    self.level      = 75 if self.level > 75
    self.immunities = nil
    self.name       = nil
    self.ability    = nil
    self.resetLegacyData if defined?(self.legacy_data)
    self.calc_stats
    self.heal
  end
  
  #-----------------------------------------------------------------------------
  # Utility for getting all eligible raid moves for a Pokemon.
  #-----------------------------------------------------------------------------
  def get_raid_moves(style, rental = false)
    category = ([:HUGEPOWER, :PUREPOWER].include?(self.ability_id)) ? 0 : nil
    style_criteria = nil
    case style
    when :Ultra
      GameData::Item.each do |item|
        next if !item.is_zcrystal?
        next if !item.has_zmove_combo?
        species = (item.has_flag?("UsableByAllForms")) ? @species : species_data.id
        next if !item.zmove_species.include?(species)
        style_criteria = item.zmove_base_move
        break
      end
    when :Tera
      style_criteria = self.tera_type
    end
    return species_data.compileRaidMoves(style, rental, category, style_criteria)
  end
  
  #-----------------------------------------------------------------------------
  # Applies a raid moveset to a Pokemon.
  #-----------------------------------------------------------------------------
  def set_raid_moves(rules, rental = false, boss_edit = nil)
    style = (rules.is_a?(Hash)) ? rules[:style] : rules
    raid_moves = self.get_raid_moves(style, rental).clone
    if boss_edit.nil?
      @moves.clear
      moves_to_learn = []
      move_categories = raid_moves.keys
      move_categories.delete(:spread)
      move_categories.delete(:support)
      if move_categories.include?(:signature)
        moves_to_learn.push(raid_moves[:signature][0])
        move_categories.delete(:signature)
      end
      move_categories.shuffle!
      until moves_to_learn.length >= MAX_MOVES
        move_categories.length.times do |i|
          category = move_categories[i]
          if !raid_moves.has_key?(category) || raid_moves[category].empty?
            move_categories[i] = nil
          else
            m = raid_moves[category].sample
            moves_to_learn.push(m) if !moves_to_learn.include?(m)
            break if moves_to_learn.length >= MAX_MOVES
            raid_moves[category].delete(m)
            move_categories[i] = nil if raid_moves[category].empty?
          end
        end
        move_categories.compact!
        break if move_categories.empty?
      end
      moves_to_learn.each { |m| self.learn_move(m) }
    end
    self.reset_moves if @moves.empty?
    if style == :Ultra && !hasZCrystal? && !ultra?
      self.item = GameData::Item.get_compatible_crystal(self)
    end
    if !rental
      if raid_moves.has_key?(:support) && !rules.has_key?(:support_moves)
        rules[:support_moves] = raid_moves[:support]
      end
      if raid_moves.has_key?(:spread) && !rules.has_key?(:spread_moves)
        rules[:spread_moves] = raid_moves[:spread]
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Applies a Hidden Ability to a Pokemon, based on raid rank.
  #-----------------------------------------------------------------------------
  def set_raid_ability(rank, boss_edit = nil)
    return if rank < 3
    return if boss_edit
    return if species_data.hidden_abilities.empty?
    @ability_index = 2 if rand(10) < rank
  end
  
  #-----------------------------------------------------------------------------
  # Applies flawless IV's to a Pokemon, based on raid rank.
  #-----------------------------------------------------------------------------
  def set_raid_ivs(rank, boss_edit = nil)
    return if boss_edit
    stats = []
    maxIVs = [1, rank - 1].max
    GameData::Stat.each_main do |s|
      next if @iv[s.id] == IV_STAT_LIMIT
      stats.push(s.id)
    end
    tries = 0
    stats.shuffle.each do |stat|
      break if tries >= maxIVs
      @iv[stat] = IV_STAT_LIMIT
      tries += 1
    end
  end
  
  #-----------------------------------------------------------------------------
  # Applies an EV spread to a raid rental Pokemon.
  #-----------------------------------------------------------------------------
  def set_raid_evs
    stats = []
    GameData::Stat.each_main do |s|
      case s.id
      when :ATTACK
        stats.push(s.id) if @moves.any? { |m| m.physical_move? }
      when :SPECIAL_ATTACK
        stats.push(s.id) if @moves.any? { |m| m.special_move? }
      when :SPEED
        stats.push(s.id) if self.baseStats[:SPEED] > 60
      else
        stats.push(s.id)
      end
    end
    @ev.each_value { |val| val = 0 }
    stat = stats.sample
    case stat
    when :HP
      GameData::Stat.each_main_battle do |s|
        @ev[s.id] = (EV_STAT_LIMIT / 5).floor
      end
    else
      @ev[stat] = EV_STAT_LIMIT
    end
    @ev[:HP] = EV_STAT_LIMIT
  end
  
  #-----------------------------------------------------------------------------
  # Applies various boss-exclusive properties to a raid Pokemon.
  #-----------------------------------------------------------------------------
  def set_raid_boss_properties(rules, boss_edit)
    # Applies boss HP, based on rank.
    if boss_edit[:hp_level].nil?
      case rules[:rank]
      when 1 then hpBoost = 4
      when 2 then hpBoost = 6
      when 3 then hpBoost = 8
      when 4 then hpBoost = 12
      when 5 then hpBoost = 20
      when 6 then hpBoost = 24
      when 7 then hpBoost = 30
      end
      hpBoost -= ((GameData::GrowthRate.max_level - self.level) / 10).floor - 1
      hpBoost = (hpBoost / 2).floor if rules[:style] == :Max
      hpBoost = 2 if hpBoost <= 1
      self.hp_level = hpBoost
    end
    # Applies boss immunities.
    boss_immunities = [:RAIDBOSS, :FLINCH, :PPLOSS, :ITEMREMOVAL, :OHKO, :SELFKO, :ESCAPE]
    if boss_edit[:immunities]
      self.immunities.concat(boss_immunities)
      self.immunities.uniq!
    else
      self.immunities = boss_immunities
    end
    # Applies Mightiest Mark.
    if boss_edit[:memento].nil? && rules[:rank] == 7
      self.memento = :MIGHTIESTMARK if defined?(self.memento)
    end
  end
end