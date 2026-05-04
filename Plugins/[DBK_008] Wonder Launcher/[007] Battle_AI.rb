################################################################################
#
# General item AI handler.
#
################################################################################

#===============================================================================
# Discourages use of items based on available Wonder Launcher points.
#===============================================================================
Battle::AI::Handlers::GeneralItemScore.add(:wonder_launcher,
  proc { |score, item, idxPkmn, idxMove, ai, battle|
    if battle.launcherBattle?
      old_score = score
      max_points = Settings::WONDER_LAUNCHER_MAX_POINTS
      item_points = GameData::Item.get(item).launcher_points
      owner_points = battle.launcherPoints[ai.trainer.side][ai.trainer.trainer_index]
      score -= 10 if owner_points <= 2
      score -= 5 if item_points >= owner_points - 1
      score -= 5 if item_points >= max_points - 1
      PBDebug.log_score_change(score - old_score, "considering Wonder Launcher points")
    end
    next score
  }
)

################################################################################
#
# Launcher item AI handlers.
#
################################################################################

#===============================================================================
# Reset Urge
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:RESETURGE,
  proc { |item, score, battler, ai, battle|
    old_score = score
    stats_to_change = 0
    opposes = battler.opposes?(ai.trainer)
    if battler.battler.hasAlteredStatStages?
      if ai.trainer.medium_skill? && battler.battler.hasRaisedStatStages?
        if battler.has_move_with_function?("PowerHigherWithUserPositiveStatStages")            # Stored Power
          (opposes) ? score += 8 : score -= 8
        end
        if battler.opponent_side_has_function?("InvertTargetStatStages",                       # Topsy-Turvy
                                               "UserTargetSwapStatStages",                     # Heart Swap
                                               "UserCopyTargetStatStages",                     # Psych Up
                                               "UserStealTargetPositiveStatStages",            # Spectral Thief
                                               "PowerHigherWithTargetPositiveStatStages")      # Punishment
          (opposes) ? score -= 8 : score += 8
        end
      end
      GameData::Stat.each_battle do |s|
        stages = battler.stages[s.id]
        next if stages == 0
        amt = (5 * stages).abs
        if stages < 0 && ai.stat_raise_worthwhile?(battler, s.id)
          stats_to_change += stages.abs
          (opposes) ? score -= amt : score += amt
          case s.id
          when :ATTACK
            if battler.opponent_side_has_function?("UseTargetAttackInsteadOfUserAttack",       # Foul Play
                                                   "HealUserByTargetAttackLowerTargetAttack1") # Strength Sap
              (opposes) ? score += 8 : score -= 8
            end
          when :SPEED
            if battle.field.effects[PBEffects::TrickRoom] > 0
              (opposes) ? score += 10 : score -= 10
            end
          end
        elsif stages > 0 && ai.stat_drop_worthwhile?(battler, s.id)
          stats_to_change += stages.abs
          (opposes) ? score += amt : score -= amt
          case s.id
          when :ATTACK, :SPECIAL_ATTACK
            if battler.opponent_side_has_function?("UserTargetSwapAtkSpAtkStages")             # Power Swap
              (opposes) ? score -= 8 : score += 8
            end
          when :DEFENSE, :SPECIAL_DEFENSE
            if battler.opponent_side_has_function?("UserTargetSwapDefSpDefStages")             # Guard Swap
              (opposes) ? score -= 8 : score += 8
            end
          when :SPEED
            if battle.field.effects[PBEffects::TrickRoom] > 0
              (opposes) ? score -= 10 : score += 10
            end
          end
        end
        PBDebug.log_score_change(score - old_score, "resetting #{battler.name}'s #{s.name} stat")
        old_score = score
      end
    end
    if battler.effects[PBEffects::FocusEnergy] > 0 && 
       battler.pbOpposingSide.effects[PBEffects::LuckyChant] == 0 &&
       battler.check_for_move { |m| m.damagingMove? && m.pp > 0 }
      amt = 5 * battler.effects[PBEffects::FocusEnergy]
      stats_to_change += battler.effects[PBEffects::FocusEnergy]
      (opposes) ? score += amt : score -= amt
      if ai.trainer.medium_skill? && battler.has_active_ability?(:SNIPER)
        (opposes) ? score += 5 : score -= 5
      end
      PBDebug.log_score_change(score - old_score, "resetting #{battler.name}'s critical hit ratio")
      old_score = score
    end
    if stats_to_change <= 2
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{battler.name} doesn't have enough stats worth resetting")
    end
    next score
  }
)

#===============================================================================
# Item Drop
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:ITEMDROP,
  proc { |item, score, battler, ai, battle|
    old_score = score
    if battler.item && battler.item_active?
      itemName = battler.battler.itemName
      if battler.has_active_ability?(:STICKYHOLD) || battler.battler.unlosableItem?(battler.item_id)
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s held item #{itemName} can't be removed")
      else
        value = 3 * battler.wants_item?(battler.item_id)
        if battler.opposes?(ai.trainer)
          if value > 0
            score += value
            PBDebug.log_score_change(score - old_score, "removing #{battler.name}'s held item #{itemName}")
          else
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because #{battler.name}'s held item #{itemName} isn't worth removing")
          end
        else
          if value > 0
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because #{battler.name}'s held item #{itemName} isn't worth removing")
          else
            score += value.abs
            PBDebug.log_score_change(score - old_score, "removing #{battler.name}'s held item #{itemName}")
          end
        end
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{battler.name} isn't holding an active held item")
    end
    next score
  }
)

#===============================================================================
# Item Urge
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:ITEMURGE,
  proc { |item, score, battler, ai, battle|
    old_score = score
    if battler.item && battler.item_active?
      item_id = battler.item_id
      itemName = battler.battler.itemName
      opposes = battler.opposes?(ai.trainer)
      case item_id
      when :CHESTOBERRY then usableItem = [:SLEEP, :DROWSY].include?(battler.status)
      when :ASPEARBERRY then usableItem = [:FROZEN, :FROSTBITE].include?(battler.status)
      when :LIECHIBERRY then usableItem = battler.battler.pbCanRaiseStatStage?(:ATTACK, battler)
      when :PETAYABERRY then usableItem = battler.battler.pbCanRaiseStatStage?(:SPECIAL_ATTACK, battler)
      when :SALACBERRY  then usableItem = battler.battler.pbCanRaiseStatStage?(:SPEED, battler)
      when :MICLEBERRY  then usableItem = !battler.effects[PBEffects::MicleBerry]
      when :STARFBERRY  then usableItem = battler.stages.values.any? { |s| s < Battle::Battler::STAT_STAGE_MAXIMUM }
      when :GANLONBERRY, :KEEBERRY
        usableItem = battler.battler.pbCanRaiseStatStage?(:DEFENSE, battler)
      when :APICOTBERRY, :MARANGABERRY
        usableItem = battler.battler.pbCanRaiseStatStage?(:SPECIAL_DEFENSE, battler)
      when :LEPPABERRY, :HOPOBERRY
        usableItem = battler.check_for_move { |m| m.pp < m.total_pp }
      when :ORANBERRY, :SITRUSBERRY, :ENIGMABERRY, :BERRYJUICE, 
           :FIGYBERRY, :IAPAPABERRY, :WIKIBERRY, :AGUAVBERRY, :MAGOBERRY
        usableItem = battler.battler.canHeal?
      else
        usableItem = battler.get_score_change_for_consuming_item(item_id, !opposes) > 0
      end
      if usableItem
        PBDebug.log("     triggering #{battler.name}'s held item #{itemName}...")
        case item_id
        when :MICLEBERRY
          if opposes
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because raising #{battler.name}'s Accuracy isn't worthwhile")
          else
            wants_accuracy = ai.stat_raise_worthwhile?(battler, :ACCURACY, true)
            (wants_accuracy) ? score += 5 : score -= 5
            PBDebug.log_score_change(score - old_score, "raising #{battler.name}'s Accuracy")
          end
        when :STARFBERRY
          if opposes
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because raising #{battler.name}'s stats isn't worthwhile")
          else
            GameData::Stat.each_battle do |s|
              next if !ai.stat_raise_worthwhile?(battler, s.id)
              stages = battler.stages[s.id]
              mult = (stages == Battle::Battler::STAT_STAGE_MAXIMUM - 1) ? 1 : 2
              score += ai.pbAIRandom(5) * mult
            end
            PBDebug.log_score_change(score - old_score, "raising a random stat on #{battler.name}")
          end
        when :WHITEHERB
          GameData::Stat.each_battle do |s|
            stage = battler.stages[s.id]
            next if stage >= 0
            value = stage.abs * 5
            if ai.stat_raise_worthwhile?(battler, s.id)
              (opposes) ? score -= value : score += value
            else
              (opposes) ? score += value : score -= value
            end
            PBDebug.log_score_change(score - old_score, "resetting #{battler.name}'s lowered #{s.name} stat")
            old_score = score
          end
        when :MENTALHERB
          if opposes
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because clearing #{battler.name}'s condition isn't worthwhile")
          else
            score += 10
            PBDebug.log_score_change(score - old_score, "clearing #{battler.name}'s condition")
          end
        when :LEPPABERRY, :HOPOBERRY
          if opposes
            score = Battle::AI::ITEM_USELESS_SCORE
            PBDebug.log_score_change(score - old_score, "useless because restoring #{battler.name}'s PP isn't worthwhile")
          else
            found_empty_moves = []
            found_partial_moves = []
            battler.pokemon.moves.each_with_index do |move, i|
              next if move.total_pp <= 0 || move.pp == move.total_pp
              (move.pp == 0) ? found_empty_moves.push(i) : found_partial_moves.push(i)
            end
            idxMove = found_empty_moves.first || found_partial_moves.first
            score = Battle::AI::Handlers.pokemon_item_score(item_id, score, battler.pokemon, battler, idxMove, ai, battle)
          end
        else
          if Battle::AI::Handlers::BattlerItemEffectScore[item_id]
            score = Battle::AI::Handlers.battler_item_score(item_id, score, battler, ai, battle)
          elsif Battle::AI::Handlers::PokemonItemEffectScore[item_id]
            score = Battle::AI::Handlers.pokemon_item_score(item_id, score, battler.pokemon, battler, nil, ai, battle)
          end
        end
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s held item #{itemName} can't be triggered")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{battler.name} isn't holding an active held item")
    end
    next score
  }
)

#===============================================================================
# Ability Urge
#===============================================================================
Battle::AI::Handlers::BattlerItemEffectScore.add(:ABILITYURGE,
  proc { |item, score, battler, ai, battle|
	old_score = score
    if battler.ability_active?
      original_score = score
      abilName = battler.battler.abilityName
      if !Battle::AbilityEffects::OnSwitchIn[battler.ability_id]
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s #{abilName} ability is ineligible")
        next score
      end
      opposes = battler.opposes?(ai.trainer)
      PBDebug.log("     triggering #{battler.name}'s #{abilName} ability...")
      if !opposes && battler.battler.isSpecies?(:OGERPON)
        aspect_abils = {
          :EMBODYASPECT   => :SPEED, 
          :EMBODYASPECT_1 => :SPECIAL_DEFENSE, 
          :EMBODYASPECT_2 => :ATTACK, 
          :EMBODYASPECT_3 => :DEFENSE
        }
        if aspect_abils.keys.include?(battler.ability_id) && 
           battler.effects[PBEffects::OneUseAbility] != battler.ability_id
          stat = aspect_abils[battler.ability_id]
          score = ai.get_item_score_for_target_stat_change(score, battler, stat, 1)
          next score
        end
      end
      terrain_abils = {
        :ELECTRICSURGE   => :Electric,
        :HADRONENGINE    => :Electric,
        :GRASSYSURGE     => :Grassy,
        :MISTYSURGE      => :Misty,
        :PSYCHICSURGE    => :Psychic
      }
      if terrain_abils.keys.include?(battler.ability_id)
        terrain = terrain_abils[battler.ability_id]
        terrainName = GameData::BattleTerrain.get(terrain).name
        if terrain == battle.field.terrain
          score = Battle::AI::ITEM_FAIL_SCORE
          PBDebug.log_score_change(score - old_score, "fails because #{terrainName} Terrain is already active")
          next score
        else
          value = ai.get_score_for_terrain(terrain, battler, true)
          (opposes) ? score -= value : score += value
          PBDebug.log_score_change(score - old_score, "starting #{terrainName} Terrain")
          next score if score - old_score > 10
          score = Battle::AI::ITEM_FAIL_SCORE
          PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s #{abilName} ability isn't worth triggering")
          next score
        end
      end
      weather_abils = {
        :DROUGHT         => :Sun,
        :ORICHALCUMPULSE => :Sun,
        :DRIZZLE         => :Rain,
        :SNOWWARNING     => :Hail,
        :SANDSTREAM      => :Sandstream,
        :DESOLATELAND    => :HarshSun,
        :PRIMORDIALSEA   => :HeavyRain,
        :DELTASTREAM     => :StrongWinds
      }
      if weather_abils.keys.include?(battler.ability_id)
        weather = weather_abils[battler.ability_id]
        weatherName = GameData::BattleWeather.get(weather).name
        if weather == battle.field.weather
          score = Battle::AI::ITEM_FAIL_SCORE
          PBDebug.log_score_change(score - old_score, "fails because #{weatherName} weather is already active")
          next score
        elsif battle.pbCheckGlobalAbility(:AIRLOCK) || battle.pbCheckGlobalAbility(:CLOUDNINE)
          score = Battle::AI::ITEM_USELESS_SCORE
          PBDebug.log_score_change(score - old_score, "useless because weather is being suppressed")
          next score
        else
          value = ai.get_score_for_weather(weather, battler, true)
          (opposes) ? score -= value : score += value
          PBDebug.log_score_change(score - old_score, "starting #{weatherName} weather")
          next score if score - old_score > 10
          score = Battle::AI::ITEM_FAIL_SCORE
          PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s #{abilName} ability isn't worth triggering")
          next score
        end
      end
      case battler.ability_id
      when :INTIMIDATE
        if !(Settings::MECHANICS_GENERATION >= 9 && 
           battler.effects[PBEffects::OneUseAbility] == battler.ability_id)
          ai.each_foe_battler(battler.side) do |b, i|
            score = ai.get_item_score_for_target_stat_change(score, b, :ATTACK, 1, false)
          end
        end
      when :SUPERSWEETSYRUP
        if !(Settings::MECHANICS_GENERATION >= 9 && battler.battler.ability_triggered?)
          ai.each_foe_battler(battler.side) do |b, i|
            score = ai.get_item_score_for_target_stat_change(score, b, :EVASION, 1, false)
          end
        end
      when :DOWNLOAD
        if !opposes
          oDef = oSpDef = 0
          ai.each_foe_battler(battler.side) do |b, i|
            oDef   += b.battler.defense
            oSpDef += b.battler.spdef
          end
          stat = (oDef < oSpDef) ? :ATTACK : :SPECIAL_ATTACK
          score = ai.get_item_score_for_target_stat_change(score, battler, stat, 1)
        end
      when :DAUNTLESSSHIELD, :INTREPIDSWORD
        if !opposes && !(Settings::MECHANICS_GENERATION >= 9 && battler.battler.ability_triggered?)
          abils = { :INTREPIDSWORD => :ATTACK, :DAUNTLESSSHIELD => :DEFENSE }
          stat = abils[battler.ability_id]
          score = ai.get_item_score_for_target_stat_change(score, battler, stat, 1)
        end
      when :WINDRIDER
        if !opposes && battler.pbOwnSide.effects[PBEffects::Tailwind] > 0
          score = ai.get_item_score_for_target_stat_change(score, battler, :ATTACK, 1)
        end
      when :COSTAR
        ai.each_ally(battler.index) do |b, i|
          next if !b.battler.near?(battler.index)
          next if !b.battler.hasAlteredStatStages?
          GameData::Stat.each_battle do |s|
            stages = b.stages[s.id] - battler.stages[s.id]
            if stages > 0
              score = ai.get_item_score_for_target_stat_change(score, battler, s.id, stages)
            elsif stages < 0
              score = ai.get_item_score_for_target_stat_change(score, battler, s.id, stages.abs, false)
            end
          end
          break
        end
      when :CURIOUSMEDICINE
        ai.each_ally(battler.index) do |b, i|
          next if !b.battler.hasAlteredStatStages?
          GameData::Stat.each_battle do |s|
            stages = b.stages[s.id]
            if stages > 0
              score = ai.get_item_score_for_target_stat_change(score, b, s.id, stages, false)
            elsif stages < 0
              score = ai.get_item_score_for_target_stat_change(score, b, s.id, stages.abs)
            end
          end
        end
      when :HOSPITALITY
        ai.each_ally(battler.index) do |b, i|
          next if !b.battler.canHeal?
          score = Battle::AI::Handlers.pokemon_item_score(:SITRUSBERRY, score, b.pokemon, b, nil, ai, battle)
        end
      when :PASTELVEIL
        ai.each_ally(battler.index) do |b, i|
          next if b.status != :POISON
          score = Battle::AI::Handlers.pokemon_item_score(:ANTIDOTE, score, b.pokemon, b, nil, ai, battle)
        end
      when :SCREENCLEANER
        [PBEffects::Reflect, PBEffects::LightScreen].each_with_index do |screen, i|
          category = (i == 0) ? "physical" : "special"
          if battler.pbOwnSide.effects[screen] > 0 ||
             battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
            old_score = score
            ai.each_foe_battler(battler.side) do |b, i|
              score -= 10 if b.check_for_move { |m| screen == PBEffects::Reflect && m.physicalMove?(m.type) ||
                                                    screen == PBEffects::LightScreen && m.specialMove?(m.type) }
            end
            PBDebug.log_score_change(score - old_score, "removing screens on #{battler.name}'s side (#{category})")
          end
          if battler.pbOpposingSide.effects[screen] > 0 ||
             battler.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
            old_score = score
            ai.each_same_side_battler(battler.side) do |b, i|
              score += 10 if b.check_for_move { |m| screen == PBEffects::Reflect && m.physicalMove?(m.type) ||
                                                    screen == PBEffects::LightScreen && m.specialMove?(m.type) }
            end
            PBDebug.log_score_change(score - old_score, "removing screens on #{battler.name}'s opponent's side (#{category})")
          end
        end
      when :TERAFORMZERO
        if !battler.battler.ability_triggered?
          if battle.field.weather != :None
            value = ai.get_score_for_weather(battle.field.weather, battler)
            (opposes) ? score += value : score -= value
            weatherName = GameData::BattleWeather.get(battle.field.weather).name
            PBDebug.log_score_change(score - old_score, "clearing #{weatherName} weather")
            old_score = score
          end
          if battle.field.terrain != :None
            value = ai.get_score_for_terrain(battle.field.terrain, battler)
            (opposes) ? score += value : score -= value
            weatherName = GameData::BattleTerrain.get(battle.field.terrain).name
            PBDebug.log_score_change(score - old_score, "clearing #{terrainName} Terrain")
          end
        end
      else
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s #{abilName} ability is ineligible")
        next score
      end
      if score == original_score
        score = Battle::AI::ITEM_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because #{battler.name}'s #{abilName} ability isn't worth triggering")
      end
    else
      score = Battle::AI::ITEM_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{battler.name} doesn't have an active ability")
    end
    next score
  }
)