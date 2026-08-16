#===============================================================================
# New AI handlers for cheer usage.
#===============================================================================
module Battle::AI::Handlers
  GeneralCheerScore = HandlerHash.new
  CheerEffectScore  = CheerHandlerHash.new
  
  def self.apply_general_cheer_score_modifiers(score, *args)
    GeneralCheerScore.each do |id, score_proc|
      new_score = score_proc.call(score, *args)
      score = new_score if new_score
    end
    return score
  end
  
  def self.cheer_score(cheer, score, *args)
    ret = CheerEffectScore.trigger(cheer, score, *args)
    return (ret.nil?) ? score : ret
  end
end


################################################################################
#
# AI Cheer handlers.
#
################################################################################


#===============================================================================
# General AI handler.
#===============================================================================
Battle::AI::Handlers::GeneralCheerScore.add(:cheer_general,
  proc { |score, cheer, idxCheer, cheer_lvl, ai, battle|
    old_score = score
    if battle.pbCheerAlreadyInUse?(ai.user.index, idxCheer)
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because similar cheer is already in use")
      next score
    end
    next score if score <= Battle::AI::CHEER_USELESS_SCORE
    foe = battle.battlers[1]
    if battle.raidBattle? && foe && (foe.hp > (foe.totalhp * 0.75).floor)
      score -= 10
      PBDebug.log_score_change(score - old_score, "prefers conserving cheers until raid Pokémon is weakened")
    else
      score -= (3 - cheer_lvl) * 5
      PBDebug.log_score_change(score - old_score, "prefers conserving cheers for higher cheer levels") if score != old_score
    end
    next score
  }
)

#===============================================================================
# Offense Cheer - "Go all-out!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:Offense,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    cheer_effect = [
      PBEffects::CheerOffense1,
      PBEffects::CheerOffense2,
      PBEffects::CheerOffense3
    ][cheer_lvl - 1]
    if ai.user.pbOwnSide.effects[cheer_effect] > 0
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because cheer effect is still active")
      next score
    end
    if cheer_lvl == 2 && ai.user.pbOpposingSide.effects[PBEffects::CheerDefense2] > 0
      score = Battle::AI::CHEER_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because opposing team is protected from move effects")
      next score
    end
    if ai.trainer.has_skill_flag?("HPAware")
      ai.each_same_side_battler(ai.trainer.side) do |b|
        score -= 10 if b.hp < b.totalhp / 2
      end
      PBDebug.log_score_change(score - old_score, "considering team's HP")
      old_score = score
    end
    ai.each_same_side_battler(ai.trainer.side) do |b|
      score += 8 if b.check_for_move { |m| m.pp > 0 && m.power > 1 }
    end
    score += ai.pbAIRandom(10)
    PBDebug.log_score_change(score - old_score, "considering the team's offensive moves")
    old_score = score
    case cheer_lvl
    when 1  # Increases damage dealt by the team.
      score -= 20 if battle.raidBattle? && battle.battlers[1].shieldHP > 0
      score += 8 if ai.user.pbOpposingSide.effects[PBEffects::CheerDefense1] > 0
    when 2  # The team's moves always trigger critical hits and added effects.
      ai.each_same_side_battler(ai.trainer.side) do |b|
        score += 8 if b.check_for_move { |m| m.pp > 0 && (1..99).include?(m.addlEffect) }
      end
      PBDebug.log_score_change(score - old_score, "considering the team's move effects")
      old_score = score
      score -= 20 if battle.raidBattle? && battle.battlers[1].shieldHP > 0
    when 3  # The team's moves ignore Protect/Substitute/screens. Deals more damage to raid shields.
      functions = [
        "ProtectUser",                                    # Protect, Detect
        "ProtectUserFromTargetingMovesSpikyShield",       # Spiky Shield
        "ProtectUserBanefulBunker",                       # Baneful Bunker
        "ProtectUserBurningBulwark",                      # Burning Bulwark
        "ProtectUserFromDamagingMovesKingsShield",        # King's Shield
        "ProtectUserFromDamagingMovesObstruct",           # Obstruct
        "ProtectUserFromDamagingMovesSilkTrap",           # Silk Trap
        "ProtectUserSideFromDamagingMovesIfUserFirstTurn" # Mat Block
      ]
      ai.each_foe_battler(ai.trainer.side) do |b|
        score += 5 if b.check_for_move { |m| m.pp > 0 && functions.include?(m.function_code) }
        score += 5 if b.effects[PBEffects::Substitute] > 0
      end
      score += 20 if battle.raidBattle? && battle.battlers[1].shieldHP > 2
    end
    if cheer_lvl > 1
      score += 10 if ai.user.pbOpposingSide.effects[PBEffects::Reflect] > 0 ||
                     ai.user.pbOpposingSide.effects[PBEffects::LightScreen] > 0 ||
                     ai.user.pbOpposingSide.effects[PBEffects::AuroraVeil] > 0
    end
    PBDebug.log_score_change(score - old_score, "considering the opposing team's defenses") if score != old_score
    next score
  }
)

#===============================================================================
# Defense Cheer - "Hang tough!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:Defense,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    cheer_effect = [
      PBEffects::CheerDefense1,
      PBEffects::CheerDefense2,
      PBEffects::CheerDefense3
    ][cheer_lvl - 1]
    if ai.user.pbOwnSide.effects[cheer_effect] > 0
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because cheer effect is still active")
      next score
    end
    if ai.trainer.has_skill_flag?("HPAware")
      ai.each_same_side_battler(ai.trainer.side) do |b|
        if b.hp < b.totalhp / 2
          case cheer_lvl
          when 1, 2 then score -= 3
          when 3    then score += 8
          end
        end
      end
      PBDebug.log_score_change(score - old_score, "considering team's HP")
      old_score = score
    end
    ai.each_foe_battler(ai.trainer.side) do |b|
      score += 8 if b.check_for_move { |m| m.pp > 0 && m.power > 1 }
    end
    PBDebug.log_score_change(score - old_score, "considering the opposing team's offensive moves")
    old_score = score
    case cheer_lvl
    when 1  # Reduces damage taken by the team.
      ai.each_foe_battler(ai.trainer.side) do |b|
        has_super_effective_move = false
        b.battler.eachMove do |move|
          next if move.pp == 0 && move.total_pp > 0
          next if move.statusMove?
          move_type = move.type
          move_type = move.pbCalcType(b.battler) if ai.trainer.medium_skill?
          ai.each_same_side_battler(ai.trainer.side) do |ally|
            eff = b.effectiveness_of_type_against_battler(move_type, ally, move)
            has_super_effective_move = Effectiveness.super_effective?(eff)
            break if has_super_effective_move
          end
        end
        score += 8 if has_super_effective_move
      end
      score += 8 if ai.user.pbOpposingSide.effects[PBEffects::CheerOffense1] > 0
      score += 5 if ai.user.pbOpposingSide.effects[PBEffects::CheerOffense3] > 0
      score += 5 if ai.user.pbOwnSide.effects[PBEffects::Reflect] > 0 ||
                    ai.user.pbOwnSide.effects[PBEffects::LightScreen] > 0 ||
                    ai.user.pbOwnSide.effects[PBEffects::AuroraVeil] > 0
    when 2  # Makes the team immune to critical hits and added effects.
      ai.each_foe_battler(ai.trainer.side) do |b|
        score += 4 if b.check_for_move { |m| m.pp > 0 && (1..99).include?(m.addlEffect) }
      end
      PBDebug.log_score_change(score - old_score, "considering the opposing team's move effects")
      old_score = score
      score += 20 if ai.user.pbOpposingSide.effects[PBEffects::CheerOffense2] > 0
    when 3  # The team endures all attacks.
      score += 8 if ai.user.pbOpposingSide.effects[PBEffects::CheerOffense1] > 0
      score += 10 if ai.user.pbOpposingSide.effects[PBEffects::CheerOffense3] > 0
    end
    score += 5 if battle.battlers[1].isRaidBoss?
    score += ai.pbAIRandom(10)
    PBDebug.log_score_change(score - old_score, "considering the opposing team's offensive bonuses") if score != old_score
    next score
  }
)

#===============================================================================
# Healing Cheer - "Heal up!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:Healing,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    if cheer_lvl == 1
      heal_count = 0
      ai.each_same_side_battler(ai.trainer.side) do |b|
        next if !b.battler.canHeal?
        heal_count += 1
      end
      if heal_count == 0
        score = Battle::AI::CHEER_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because team can't be healed")
        next score
      end
    end
    # Restores the team's HP.
    if ai.trainer.has_skill_flag?("HPAware")
      ai.each_same_side_battler(ai.trainer.side) do |b|
        if !b.battler.canHeal?
          score -= 10
        elsif b.hp >= b.totalhp * 0.75
          score -= 3
        else
          score += (10 * cheer_lvl) * (b.totalhp - b.hp) / b.totalhp
        end
      end
      PBDebug.log_score_change(score - old_score, "healing the team's HP")
    end
    old_score = score
    # Cures the team's status afflictions.
    if cheer_lvl > 1
      ai.each_same_side_battler(ai.trainer.side) do |b|
        if b.status != :NONE
          score += (b.wants_status_problem?(b.status)) ? -10 : 10
        end
        score += 5 if b.effects[PBEffects::Confusion] > 0
        score += 5 if b.effects[PBEffects::Attract] >= 0
        score += 5 if b.effects[PBEffects::Curse]
      end
      if score != old_score
        PBDebug.log_score_change(score - old_score, "healing the team's condition")
      end
    end
    old_score = score
    # Restores the team's PP.
    if cheer_lvl == 3
      ai.each_same_side_battler(ai.trainer.side) do |b|
        b.battler.pokemon.moves.each do |m|
          next if m.pp > (m.total_pp / 2).floor
          mod = (m.pp == 0) ? 8 : 2
          score += mod
        end
      end
      if score != old_score
        PBDebug.log_score_change(score - old_score, "restoring the team's PP")
      end
    end
    next score
  }
)

#===============================================================================
# Counter Cheer - "Turn the tables!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:Counter,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    case cheer_lvl
    when 1  # Inverts the stat stages of all battlers on the field.
      modified_battlers = []
      ai.each_battler do |b|
        modified_battlers.push(b) if b.battler.hasAlteredStatStages?
      end
      if modified_battlers.length > 0
        modified_battlers.each do |b|
          raises = []
          drops = []
          GameData::Stat.each_battle do |s|
            if b.stages[s.id] > 0
              drops.push(s.id, b.stages[s.id] * 2)
            elsif b.stages[s.id] < 0
              raises.push(s.id, b.stages[s.id] * 2)
            end
          end
          PBDebug.log("     calculating stat inversions for #{b.name}")
          score = ai.get_score_for_stat_change(score, b, modified_battlers.length, raises, drops.length)
          PBDebug.log_score_change(score - old_score, "inverting stat drops")
          old_score = score
          score = ai.get_score_for_stat_change(score, b, modified_battlers.length, drops, raises.length, false)
          PBDebug.log_score_change(score - old_score, "inverting stat boosts")
          old_score = score
        end
      else
        score = Battle::AI::CHEER_FAIL_SCORE
        PBDebug.log_score_change(score - old_score, "fails because no battlers with modified stat stages")
        next score
      end
    when 2  # Swaps the effects in play on both sides of the field.
      good_effects = [
        :AuroraVeil,
        :CheerOffense1,
        :CheerOffense2,
        :CheerOffense3,
        :CheerDefense1,
        :CheerDefense2,
        :CheerDefense3,
        :LightScreen,
        :LuckyChant,
        :Mist,
        :Rainbow,
        :Reflect,
        :Safeguard,
        :Tailwind
      ].map! { |e| PBEffects.const_get(e) }
      bad_effects = [
        :Cannonade,
        :SeaOfFire,
        :Spikes,
        :StealthRock,
        :Steelsurge,
        :StickyWeb,
        :Swamp,
        :ToxicSpikes,
        :VineLash, 
        :Volcalith, 
        :Wildfire
      ].map! { |e| PBEffects.const_get(e) }
      bad_effects.each do |e|
        score += 10 if ![0, false, nil].include?(ai.user.pbOwnSide.effects[e])
        score -= 10 if ![0, false, nil].include?(ai.user.pbOpposingSide.effects[e])
      end
      PBDebug.log_score_change(score - old_score, "considering swapping bad effects") if score != old_score
      old_score = score
      if ai.trainer.high_skill?
        good_effects.each do |e|
          score += 10 if ![0, false, nil].include?(ai.user.pbOpposingSide.effects[e])
          score -= 10 if ![0, false, nil].include?(ai.user.pbOwnSide.effects[e])
        end
        PBDebug.log_score_change(score - old_score, "considering swapping good effects") if score != old_score
      end
    when 3  # Removes the Heal Block effect on the team, and places it on the opposing team.
      ai.each_same_side_battler(ai.trainer.side) do |b|
        next if b.effects[PBEffects::HealBlock] == 0
        score += b.effects[PBEffects::HealBlock] * 4
      end
      PBDebug.log_score_change(score - old_score, "removing Heal Block from allies") if score != old_score
      old_score = score
      ai.each_foe_battler(ai.trainer.side) do |b|
        next if b.effects[PBEffects::HealBlock] > 0
        score += 10
      end
      PBDebug.log_score_change(score - old_score, "applying Heal Block on foes") if score != old_score
    end
    next score
  }
)

#===============================================================================
# Basic Raid Cheer - "Keep it going!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:BasicRaid,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    if cheer_lvl < 2
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because cheer level is too low")
      next score
    end
    turnCount = battle.raidRules[:turn_count]
    # Increases the raid's Turn counter.
    if turnCount < 0
      score = Battle::AI::CHEER_USELESS_SCORE
      PBDebug.log_score_change(score - old_score, "useless because turn counter disabled")
    elsif turnCount < battle.raidRules[:max_turnCount]
      score += (battle.raidRules[:max_turnCount] - turnCount) * 2
      PBDebug.log_score_change(score - old_score, "increasing turn counter")
    end
    # Increases the raid's KO counter.
    if cheer_lvl == 3
      old_score = score
      koCount = battle.raidRules[:ko_count]
      if pbInRaidAdventure? && koCount >= 6
        score -= 10
        PBDebug.log_score_change(score - old_score, "useless because KO counter already at max value")
      elsif koCount < 0
        score -= 10
        PBDebug.log_score_change(score - old_score, "useless because KO counter disabled")
      else
        score += (8 - koCount) * 5
        PBDebug.log_score_change(score - old_score, "increasing KO counter")
      end
    end
    next score
  }
)

#===============================================================================
# Ultra Raid Cheer - "Let's use Z-Power!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:UltraRaid,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    if !battle.raidBattle?
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because this isn't a raid battle")
      next score
    end
    if cheer_lvl < 3
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because cheer level is too low")
      next score
    end
    if !battle.pbHasZRing?(ai.user.index)
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because trainer doesn't have a Z-Ring")
      next score
    end
    if battle.zMove[ai.trainer.side][ai.trainer.trainer_index] == -1
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because Z-Moves already usable")
      next score
    end
    # Enables the use of Z-Moves.
    if ai.user.battler.hasZMove?
      score += 100
      PBDebug.log_score_change(score - old_score, "can use a Z-Move")
    else
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{ai.user.name} can't use a Z-Move")
      next score
    end
    next score
  }
)

#===============================================================================
# Max Raid Cheer - "Let's Dynamax!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:MaxRaid,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    if !battle.raidBattle?
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because this isn't a raid battle")
      next score
    end
    if cheer_lvl < 3
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because cheer level is too low")
      next score
    end
    if !battle.pbHasDynamaxBand?(ai.user.index)
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because trainer doesn't have a Dynamax Band")
      next score
    end
    if battle.dynamax[ai.trainer.side].any? { |tr| tr == -1 }
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because Dynamax already usable by an ally")
      next score
    end
    if battle.allSameSideBattlers(ai.user.index).any? { |b| b.dynamax? }
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because an ally is already Dynamaxed")
      next score
    end
    # Enables the use of Dynamax.
    if !ai.user.battler.dynamax? && ai.user.battler.hasDynamax?(false)
      score += 100
      PBDebug.log_score_change(score - old_score, "can use Dynamax")
    else
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{ai.user.name} can't use Dynamax")
      next score
    end
    next score
  }
)

#===============================================================================
# Tera Raid Cheer - "Let's Terastallize!"
#===============================================================================
Battle::AI::Handlers::CheerEffectScore.add(:TeraRaid,
  proc { |cheer, score, cheer_lvl, ai, battle|
    old_score = score
    if !battle.raidBattle?
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because this isn't a raid battle")
      next score
    end
    if cheer_lvl < 3
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because cheer level is too low")
      next score
    end
    if !battle.pbHasTeraOrb?(ai.user.index)
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because trainer doesn't have a Tera Orb")
      next score
    end
    if battle.terastallize[ai.trainer.side].any? { |tr| tr == -1 }
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because Terastallization already usable by an ally")
      next score
    end
    if battle.allSameSideBattlers(ai.user.index).any? { |b| b.tera? }
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because an ally is already Terastallized")
      next score
    end
    # Enables the use of Terastallization.
    if !ai.user.battler.tera? && ai.user.battler.hasTera?(false)
      score += 100
      PBDebug.log_score_change(score - old_score, "can use Terastallization")
    else
      score = Battle::AI::CHEER_FAIL_SCORE
      PBDebug.log_score_change(score - old_score, "fails because #{ai.user.name} can't use Terastallization")
      next score
    end
    next score
  }
)