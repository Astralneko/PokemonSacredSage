#===============================================================================
# Adds Raid-related tools to debug options.
#===============================================================================

#-------------------------------------------------------------------------------
# Battle rule options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_rules_menu, :cheerBattle, {
  "name"        => "Cheer battle: [{1}]",
  "rule"        => "cheerBattle",
  "order"       => 314,
  "parent"      => :set_battle_rules,
  "description" => _INTL("Enables all trainers to use the Cheer command."),
  "effect"      => proc { |menu|
    next pbApplyBattleRule("cheerBattle", :Toggle, true)
  }
})

MenuHandlers.add(:battle_rules_menu, :cheerMode, {
  "name"        => "Cheer mode: [{1}]",
  "rule"        => "cheerMode",
  "order"       => 315,
  "parent"      => :set_battle_rules,
  "description" => _INTL("Determines the specific cheer commands displayed."),
  "effect"      => proc { |menu|
    next pbApplyBattleRule("cheerMode", :Integer, 0, 
      _INTL("Set a cheer mode to determine the cheer commands displayed."))
  }
})

#-------------------------------------------------------------------------------
# General Debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :deluxe_raid_settings, {
  "name"        => _INTL("Raid settings..."),
  "parent"      => :deluxe_plugins_menu,
  "description" => _INTL("Edit and test features related to Raid Battles."),
  "effect"      => proc {
    styles = []
    style_choices = []
    GameData::RaidType.each_available do |raid|
      styles.push(raid.id)
      style_choices.push(raid.name)
    end
    val = $PokemonGlobal.raid_adventure_endless_unlocked
    command  = 0
    commands = [
      _INTL("Empty all Raid Dens"),
      _INTL("Reset all Raid Dens"),
      _INTL("Endless Adventure Mode unlocked [{1}]", (val ? "YES" : "NO")),
      _INTL("Edit saved Adventure routes"),
      _INTL("Edit Adventure maps"),
      _INTL("Playtest a Raid battle"),
      _INTL("Playtest a Raid Adventure")
    ]
    loop do
      command = pbShowCommands(nil, commands, -1, command)
      break if command < 0
      case command
      when 0 # Empty All Dens
        pbClearAllRaids(false)
        pbMessage(_INTL("Raid events on all maps were emptied of all Pokémon."))
      when 1 # Reset All Dens
        pbClearAllRaids(true)
        pbMessage(_INTL("Raid events on all maps were reset with new Pokémon."))
      when 2 # Unlock Endless Mode
        pbPlayDecisionSE
        $PokemonGlobal.raid_adventure_endless_unlocked = !val
        val = $PokemonGlobal.raid_adventure_endless_unlocked
        commands[2] = _INTL("Endless Adventure Mode unlocked [{1}]", (val ? "YES" : "NO"))
      when 3 # Edit saved Adventure routes
        cmd = pbMessage(_INTL("Select a type of Adventure to edit routes for."), style_choices, -1)
        pbPlayCancelSE if cmd < 0
        if cmd >= 0
          pbPlayDecisionSE
          style = styles[cmd]
          name = GameData::RaidType.get(style).lair_name
          species_list = GameData::Species.generate_raid_lists(style, true)[6]
          choices = [
            _INTL("Add a new {1} route", name),
            _INTL("Clear an existing {1} route", name),
            _INTL("Clear all {1} routes", name)
          ]
          loop do
            cmd = pbShowCommands(nil, choices, -1, 0)
            pbPlayCancelSE if cmd < 0
            break if cmd < 0
            routes = $PokemonGlobal.raid_adventure_routes(style)
            case cmd
            when 0 # Add a new route
              if routes.keys.length >= 3
                pbMessage(_INTL("The max number of saved {1} routes has already been met.", name))
              elsif species_list.empty?
                pbMessage(_INTL("There aren't any eligible {1} boss species found.", name))
              else
                pbMessage(_INTL("Choose a boss species for this {1} route.", name))
                species = pbChooseFromGameDataList(:Species) do |data|
                  next nil if !species_list.include?(data.id)
                  next (data.form > 0) ? sprintf("%s_%d", data.real_name, data.form) : data.real_name
                end
                if species
                  sp_name = GameData::Species.get(species).name
                  if routes.keys.include?(species)
                    pbMessage(_INTL("There is already an existing {1} route leading to {2}.", name, sp_name))
                  else
                    pbMessage(_INTL("Choose an Adventure map to encounter {1} on.", sp_name))
                    mapID = pbChooseFromGameDataList(:AdventureMap) do |data|
                      next data.real_name
                    end
                    if mapID
                      map_name = GameData::AdventureMap.get(mapID).name
                      pbMessage(_INTL("A new {1} route to {2} was found within {3}.", name, sp_name, map_name))
                      routes[species] = mapID
                    end
                  end
                end
              end
            when 1 # Clear an existing route
              if routes.empty?
                pbMessage(_INTL("No saved {1} routes exist.", name))
              else
                route_choices = []
                routes.each do |sp, map|
                  sp_name = GameData::Species.get(sp).name
                  map_name = GameData::AdventureMap.get(map).name
                  route_choices.push(_INTL("{1} in {2}", sp_name, map_name))
                end
                new_cmd = pbMessage(_INTL("Select a saved {1} route to remove.", name), route_choices, -1)
                if new_cmd >= 0
                  species = routes.keys[new_cmd]
                  sp_name = GameData::Species.get(species).name
                  pbMessage(_INTL("The {1} route to {2} was cleared.", name, sp_name))
                  routes.delete(species)
                end
              end
            when 2 # Clear all routes
              pbMessage(_INTL("All saved {1} routes were cleared.", name))
              routes.clear
            end
          end
        end
      when 4 # Edit Adventure maps
        pbFadeOutIn do
          scene = AdventureMapEditor.new
          screen = AdventureMapEditorScreen.new(scene)
          screen.pbStart
        end
      when 5 # Playtest a Raid battle
        cmd = pbMessage(_INTL("Select a type of raid to test."), style_choices, -1)
        pbPlayCancelSE if cmd < 0
        if cmd >= 0
          pbPlayDecisionSE
          style = styles[cmd]
          raidType = GameData::RaidType.get(style).name
          pbMessage(_INTL("Choose a species to challenge in the {1} Raid.", raidType))
          species = pbChooseFromGameDataList(:Species) do |data|
            next nil if !data.raid_species?(style)
            next (data.form > 0) ? sprintf("%s_%d", data.real_name, data.form) : data.real_name
          end
          pbDebugRaidBattle(species, style)
          break
        end
      when 6 # Begin a Raid Adventure
        cmd = pbMessage(_INTL("Select a type of lair to explore."), style_choices, -1)
        pbPlayCancelSE if cmd < 0
        if cmd >= 0
          pbPlayDecisionSE
          data = {}
          data[:style] = styles[cmd]
          name = GameData::RaidType.get(data[:style]).lair_name
          data[:darkness] = pbConfirmMessageSerious(_INTL("Apply Darkness Mode to this {1}?", name))
          RaidAdventure.start(data)
          break
        end
      end
    end
  }
})

#-------------------------------------------------------------------------------
# Utility for initiating a debug raid battle.
#-------------------------------------------------------------------------------
def pbDebugRaidBattle(species, style)
  return if !GameData::Species.exists?(species)
  raid_party = []
  $player.party.each do |p|
    next if !p.able?
    raid_party.push(p)
    break if raid_party.length >= Settings::RAID_BASE_PARTY_SIZE
  end
  if raid_party.empty?
    pbMessage(_INTL("You don't have any Pokémon in your party to enter a Raid battle."))
    return
  end
  max_size = raid_party.length
  ruleset = PokemonRuleSet.new
  ruleset.setNumber(max_size)
  ruleset.addPokemonRule(AblePokemonRestriction.new)
  rules = { 
    :style => style,
    :size  => max_size,
    :rank  => GameData::Species.get(species).raid_ranks.first
  }
  [:ko_count, :turn_count, :shield_hp, :extra_actions].each do |r|
    rules[r] = pbDefaultRaidProperty(r, rules)
  end
  raidType = GameData::RaidType.get(style)
  speciesName = GameData::Species.get(species).name
  loop do
    options = [
      _INTL("[Battle {1}]",              speciesName),
      _INTL("Set raid rank [{1}]",       rules[:rank]),
      _INTL("Set raid party [{1} PkMn]", rules[:size]),
      _INTL("Set raid partner [{1}]",    (rules[:partner] ? rules[:partner][1] : "None"))
    ]
    case pbMessage(_INTL("Set {1} Raid battle properties.", raidType.name), options, -1)
    when 0 # Start battle
      raid_party.each { |pkmn| pkmn.heal }
      setBattleRule("tempParty", raid_party)
      setBattleRule("raidStyleCapture", {
        :capture_chance => 100,
        :capture_bgm    => raidType.capture_bgm
      })
      RaidBattle.start(species, rules)
      break
    when 1 # Set raid rank
      ranks = GameData::Species.get(species).raid_ranks.clone
      ranks.push(7)
      if ranks.length > 1
        pbPlayDecisionSE
        choices = []
        ranks.each { |r| choices.push(r.to_s) }
        choice = pbMessage(_INTL("Choose a raid rank."), choices, -1)
        if choice >= 0
          pbPlayDecisionSE
          rules[:rank] = ranks[choice]
        end
      else
        pbPlayBuzzerSE
      end
    when 2 # Set raid party
      pbPlayDecisionSE
      ruleset.setNumber(max_size) if !rules[:partner] && max_size > rules[:size]
      pbFadeOutIn {
        scene = PokemonParty_Scene.new
        screen = PokemonPartyScreen.new(scene, $player.party)
        ret = screen.pbPokemonMultipleEntryScreenEx(ruleset)
        if ret
          raid_party = ret 
          rules[:size] = raid_party.length
        end
      }
    when 3 # Set raid partner
      pbPlayDecisionSE
      choice = 1
      if rules[:partner]
        choices = [_INTL("Remove"), _INTL("Replace"), _INTL("Cancel")]
        choice = pbMessage(
          _INTL("Do what with the existing raid partner? ({1})", rules[:partner][1]), choices, -1)
        rules.delete(:partner) if choice == 0
      end
      next if choice != 1
      trdata = pbListScreen(_INTL("PARTNER TRAINER"), TrainerBattleLister.new(0, false))
      if trdata
        backSprite = false
        if trdata[2] > 0 && pbResolveBitmap(sprintf("Graphics/Trainers/%s_%s_back", trdata[0], trdata[2]))
          backSprite = true
        end
        if !backSprite && pbResolveBitmap(sprintf("Graphics/Trainers/%s_back", trdata[0]))
          backSprite = true
        end
        if backSprite
          rules[:size] = 1
          ruleset.setNumber(1)
          raid_party = [raid_party.first]
          rules[:partner] = trdata
          pbMessage(_INTL("Set {1} as raid partner.", trdata[1]))
        else
          pbMessage(_INTL("Trainer is missing a back sprite.\nUnable to set as partner."))
        end
      end
    else
      break if pbConfirmMessage(_INTL("Are you sure you want to abandon this raid battle?"))
    end
  end
end

#-------------------------------------------------------------------------------
# Battle Debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :deluxe_battle_cheer_level, {
  "name"        => _INTL("Cheer Levels"),
  "parent"      => :trainers,
  "description" => _INTL("Current Cheer level of each trainer."),
  "effect"      => proc { |battle|
    cmd = 0
    loop do
      commands = []
      cmds = []
      battle.cheerLevel.each_with_index do |side_values, side|
        trainers = (side == 0) ? battle.player : battle.opponent
        next if !trainers
        side_values.each_with_index do |value, i|
          next if !trainers[i]
          text = (side == 0) ? "Your side:" : "Foe side:"
          text += sprintf(" %d: %s", i, trainers[i].name)
          text += sprintf(" (%d)", value)
          commands.push(text)
          cmds.push([side, i])
        end
      end
      if battle.cheerMode
        cmd = pbMessage("\\ts[]" + _INTL("Choose a trainer's Cheer level to edit."),
                        commands, -1, nil, cmd)
        break if cmd < 0
        real_cmd = cmds[cmd]
        maxLvl = 3
        level = battle.cheerLevel[real_cmd[0]][real_cmd[1]]
        params = ChooseNumberParams.new
        params.setRange(0, maxLvl)
        params.setInitialValue(level)
        params.setCancelValue(level)
        newLvl = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Set Cheer level (max={1}).", maxLvl), params
        )
        battle.cheerLevel[real_cmd[0]][real_cmd[1]] = newLvl if newLvl != level
      else
        pbMessage(_INTL("Cheer commands are not available in this battle."))
        break
      end
    end
  }
})

#===============================================================================
# Adds new raid battle-specific debug tools.
#===============================================================================
MenuHandlers.add(:battle_debug_menu, :raid_conditions, {
  "name"        => _INTL("Raid conditions..."),
  "parent"      => :main,
  "description" => _INTL("Look at and edit various raid battle properties.")
})

#-------------------------------------------------------------------------------
# Edits the turn count of the raid battle.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :raid_turn_count, {
  "name"        => _INTL("Turn count"),
  "parent"      => :raid_conditions,
  "description" => _INTL("Edits how many turns are left before losing."),
  "effect"      => proc { |battle|
    if battle.raidBattle?
      foe = battle.battlers[1]
      if foe.isRaidBoss?
        count = battle.raidRules[:turn_count] || 0
        params = ChooseNumberParams.new
        params.setRange(0, 99)
        params.setInitialValue(count)
        params.setCancelValue(count)
        new_count = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Set remaining turns."), params
        )
        new_count = -1 if new_count <= 0
        if new_count && new_count != count
          battle.raidRules[:turn_count] = new_count
          if !battle.raidRules[:max_turnCount] || new_count > battle.raidRules[:max_turnCount]
            battle.raidRules[:max_turnCount] = new_count
          end
        end
      else
        pbMessage(_INTL("This can only be edited when there is a raid boss."))
      end
    else
      pbMessage(_INTL("This can only be edited during raid battles."))
    end
  }
})

#-------------------------------------------------------------------------------
# Edits the KO count of the raid battle.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :raid_ko_count, {
  "name"        => _INTL("KO count"),
  "parent"      => :raid_conditions,
  "description" => _INTL("Edits how many knock outs are allowed before losing."),
  "effect"      => proc { |battle|
    if battle.raidBattle?
      foe = battle.battlers[1]
      if foe.isRaidBoss?
        count = battle.raidRules[:ko_count] || 0
        params = ChooseNumberParams.new
        params.setRange(0, 9)
        params.setInitialValue(count)
        params.setCancelValue(count)
        new_count = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Set remaining knock outs."), params
        )
        new_count = -1 if new_count <= 0
        if new_count && new_count != count
          if new_count > 1 && battle.pbParty(0).length == 1
            pbMessage(_INTL("Cannot increase the remaining KO's with only one Pokemon in the party."))
          else
            battle.raidRules[:ko_count] = new_count
            if pbInRaidAdventure?
              pbRaidAdventureState.hearts = new_count
              if pbRaidAdventureState.hearts > pbRaidAdventureState.max_hearts
                pbRaidAdventureState.max_hearts = new_count
              end
            end
          end
        end
      else
        pbMessage(_INTL("This can only be edited when there is a raid boss."))
      end
    else
      pbMessage(_INTL("This can only be edited during raid battles."))
    end
  }
})

#-------------------------------------------------------------------------------
# Edits the raid shield of the raid boss.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :raid_shield_hp, {
  "name"        => _INTL("Raid shield"),
  "parent"      => :raid_conditions,
  "description" => _INTL("Edits the state of the raid boss's shield."),
  "effect"      => proc { |battle|
    if battle.raidBattle?
      foe = battle.battlers[1]
      if foe.isRaidBoss?
        count = foe.shieldHP || 0
        params = ChooseNumberParams.new
        params.setRange(0, 8)
        params.setInitialValue(count)
        params.setCancelValue(count)
        new_count = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Set raid boss's shield HP."), params
        )
        if new_count && new_count != count
          if foe.hasRaidShield?
            battle.raidRules[:shield_hp] = new_count if battle.raidRules[:shield_hp] < new_count
          battle.raidRules.delete(:shield_hp) if new_count == 0
          elsif new_count > 0
            battle.raidRules[:shield_hp] = new_count 
          end
          foe.shieldHP = new_count
          battle.scene.pbRefreshStyle(:Long) if !battle.databoxStyle
        end
      else
        pbMessage(_INTL("This can only be edited when there is a raid boss."))
      end
    else
      pbMessage(_INTL("This can only be edited during raid battles."))
    end
  }
})

#-------------------------------------------------------------------------------
# Edits the extra actions that may be performed by the raid boss.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :raid_extra_actions, {
  "name"        => _INTL("Extra actions"),
  "parent"      => :raid_conditions,
  "description" => _INTL("Edits extra actions the raid boss may perform."),
  "effect"      => proc { |battle|
    if battle.raidBattle?
      foe = battle.battlers[1]
      if foe.isRaidBoss?
        cmd = 0
        actions = {
          :reset_boosts => _INTL("Reset boosts/negate Abilities"),
          :reset_drops  => _INTL("Reset drops/cure status"),
          :drain_cheer  => _INTL("Drain cheer level")
        }
        loop do
          commands = []
          cmds = []
          actions.each do |action, text|
            has_action = battle.raidRules[:extra_actions].include?(action)
            annot = (has_action) ? " [ABLE]" : " [UNABLE]"
            commands.push(text + annot)
            cmds.push(action)
          end
          cmd = pbMessage("\\ts[]" + _INTL("Toggle which actions the raid boss can perform."),
                          commands, -1, nil, cmd)
          break if cmd < 0
          real_cmd = cmds[cmd]
          if battle.raidRules[:extra_actions].include?(real_cmd)
            battle.raidRules[:extra_actions].delete(real_cmd)
          else
            battle.raidRules[:extra_actions].push(real_cmd)
          end
        end
      else
        pbMessage(_INTL("This can only be edited when there is a raid boss."))
      end
    else
      pbMessage(_INTL("This can only be edited during raid battles."))
    end
  }
})

#-------------------------------------------------------------------------------
# Edits the extra moves that may be performed by the raid boss.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :raid_extra_moves, {
  "name"        => _INTL("Extra moves"),
  "parent"      => :raid_conditions,
  "description" => _INTL("Edits extra moves the raid boss may perform."),
  "effect"      => proc { |battle|
    if battle.raidBattle?
      foe = battle.battlers[1]
      if foe.isRaidBoss?
        cmd = 0
        raid_moves = {
          :support_moves => [],
          :spread_moves  => []
        }
        GameData::Move.each do |move|
          next if move.powerMove?
          next if pbRaidBannedMoves.include?(move.function_code)
          if pbRaidSupportMoves.include?(move.function_code)
            raid_moves[:support_moves].push(move.id)
          end
          if [:AllNearFoes, :AllNearOthers].include?(move.target)
            raid_moves[:spread_moves].push(move.id)
          end
        end
        loop do
          cmd_ids = [:support_moves, :spread_moves]
          commands = [_INTL("Support moves"), _INTL("Spread moves")]
          cmd = pbMessage("\\ts[]" + _INTL("Choose a move list."), commands, -1, nil, cmd)
          break if cmd < 0
          list_id = cmd_ids[cmd]
          moves = battle.raidRules[list_id] || []
          new_moves = RaidMovesProperty.set(moves, raid_moves[list_id])
          battle.raidRules[list_id] = new_moves
        end
      else
        pbMessage(_INTL("This can only be edited when there is a raid boss."))
      end
    else
      pbMessage(_INTL("This can only be edited during raid battles."))
    end
  }
})


#===============================================================================
# Used for editing Support and Spread moves in the raid battle debug menu.
#===============================================================================
class RaidMovesProperty
  def self.set(old_setting, moves)
    ret = old_setting
    values = []
    values.push([nil, _INTL("[ADD MOVE]")])
    old_setting.each do |value|
      values.push([value, GameData::Move.get(value).real_name])
    end
    command_window = pbListWindow([], 200)
    cmd = 0
    commands = []
    need_refresh = true
    loop do
      if need_refresh
        values.sort! { |a, b| (a[0].nil?) ? -1 : b[0].nil? ? 1 : a[1] <=> b[1] }
        commands = values.map { |entry| entry[1] }
        need_refresh = false
      end
      cmd = pbCommands2(command_window, commands, -1, cmd, true)
      if cmd >= 0
        entry = values[cmd]
        if entry[0].nil?
          new_value = pbChooseMoveListExclusive(nil, moves)
          if new_value
            if values.any? { |val| val[0] == new_value }
              cmd = values.index { |val| val[0] == new_value }
              next
            end
            values.push([new_value, GameData::Move.get(new_value).real_name])
            need_refresh = true
          end
        else
          case pbMessage("\\ts[]" + _INTL("Do what with this move?"),
                         [_INTL("Change move"), _INTL("Delete"), _INTL("Cancel")], 3)
          when 0
            new_value = pbChooseMoveListExclusive(entry[0], moves)
            if new_value && new_value != entry[0]
              if values.any? { |val| val[0] == new_value }
                values.delete_at(cmd)
                cmd = values.index { |val| val[0] == new_value }
                need_refresh = true
                next
              end
              entry[0] = new_value
              entry[1] = GameData::Move.get(new_value).real_name
              values.sort! { |a, b| a[1] <=> b[1] }
              cmd = values.index { |val| val[0] == new_value }
              need_refresh = true
            end
          when 1
            values.delete_at(cmd)
            cmd = [cmd, values.length - 1].min
            need_refresh = true
          end
        end
      else
        case pbMessage(_INTL("Apply changes?"),
                       [_INTL("Yes"), _INTL("No"), _INTL("Cancel")], 3)
        when 0
          values.shift
          values.length.times do |i|
            values[i] = values[i][0]
          end
          values.compact!
          ret = values
          break
        when 1
          break
        end
      end
    end
    command_window.dispose
    return ret
  end
end

def pbChooseMoveListExclusive(default = nil, moves = [])
  return pbChooseFromGameDataList(:Move, default) do |data|
    next (moves.include?(data.id)) ? data.real_name : nil
  end
end