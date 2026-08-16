#===============================================================================
# Battle class additions related to extra raid actions.
#===============================================================================
class Battle
  #-----------------------------------------------------------------------------
  # Utilities for triggering various extra raid actions.
  #-----------------------------------------------------------------------------
  def pbRaidExtraActions(battler)
    return if pbAllFainted? || @decision > 0
    return if !@raidRules[:extra_actions]
    @raidRules[:extra_actions].each do |action|
      if battler.inExtraActionPhase?(action)
        battler.pbRaidExtraActionPhase(action)
        @raidRules[:extra_actions].delete(action)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # The raid boss resets all stat boosts and negates all abilities on the player's side.
  #-----------------------------------------------------------------------------
  def pbRaidResetBoosts(battler)
    @scene.pbAnimateExtraAction(battler.index)
    pbDisplay(_INTL("{1} nullified the stat changes and Abilities affecting your side!", battler.pbThis))
    PBDebug.log("[Raid mechanics] #{battler.pbThis} (#{battler.index}) triggered an extra action (reset boosts)")
    battlers = []
    allOtherSideBattlers(battler).each do |b|
      if b.hasRaisedStatStages?
        b.statsLoweredThisRound = true
        b.statsDropped = true
      end
      GameData::Stat.each_battle { |s| b.stages[s.id] = 0 if b.stages[s.id] > 0 }
      b.effects[PBEffects::GastroAcid] = true if !b.hasActiveItem?(:ABILITYSHIELD)
      battlers.push(b.index)
    end
    pbCalculatePriority(false, battlers)
  end
  
  #-----------------------------------------------------------------------------
  # The raid boss resets its lowered stat stages and cures any status conditions.
  #-----------------------------------------------------------------------------
  def pbRaidResetDrops(battler)
    @scene.pbAnimateExtraAction(battler.index)
    pbDisplay(_INTL("{1} removed negative effects from itself!", battler.pbThis))
    PBDebug.log("[Raid mechanics] #{battler.pbThis} (#{battler.index}) triggered an extra action (reset drops)")
    battler.pbCureStatus
    if battler.hasLoweredStatStages?
      battler.statsRaisedThisRound = true
    end
    GameData::Stat.each_battle do |s|
      next if battler.stages[s.id] >= 0
      battler.stages[s.id] = 0
    end
    pbCalculatePriority(false, [battler.index])
  end
  
  #-----------------------------------------------------------------------------
  # The raid boss decreases the cheer level for all trainers on the player's side.
  #-----------------------------------------------------------------------------
  def pbRaidDrainCheer(battler)
    @scene.pbAnimateExtraAction(battler.index)
    pbDisplay(_INTL("{1} reduced the effectiveness of cheering!", battler.pbThis))
    PBDebug.log("[Raid mechanics] #{battler.pbThis} (#{battler.index}) triggered an extra action (drain cheer)")
    @cheerLevel[0].length.times do |i|
      oldLvl = @cheerLevel[0][i]
      next if oldLvl <= 0
      @cheerLevel[0][i] -= 1
      PBDebug.log("[Cheer level] #{@player[i].name}'s Cheer level changed (#{oldLvl} => #{@cheerLevel[0][i]})")
    end
  end
  
  #-----------------------------------------------------------------------------
  # Utility for allowing the AI to choose an Extra Attack.
  #-----------------------------------------------------------------------------
  def pbChooseRaidExtraAttack(idxBattler, extra_attacks, group_id)
    return @battleAI.pbRaidChooseExtraAttack(idxBattler, extra_attacks, group_id)
  end
end

#===============================================================================
# Battle::Battler class additions related to processing moves.
#===============================================================================
class Battle::Battler
  #-----------------------------------------------------------------------------
  # Utilities for checking for and performing a raid boss's Extra Action phases.
  #-----------------------------------------------------------------------------
   def inExtraActionPhase?(action)
     return false if !isRaidBoss? || fainted?
     case action
     when :reset_boosts then mod = 0.4 # 40% of max HP or of max turn count.
     when :reset_drops  then mod = 0.6 # 60% of max HP or of max turn count.
     when :drain_cheer  then mod = 0.5 # 50% of max HP or of max turn count.
     end
     return true if @hp <= (@totalhp * mod).round
     turnCount = @battle.raidRules[:turn_count]
     maxCount = @battle.raidRules[:max_turnCount] || 0
     return true if (maxCount > 0 && turnCount <= (maxCount * mod).round)
     return false
   end
   
   def pbRaidExtraActionPhase(action)
    case action
    when :reset_boosts then @battle.pbRaidResetDrops(self)
    when :reset_drops  then @battle.pbRaidResetBoosts(self)
    when :drain_cheer  then @battle.pbRaidDrainCheer(self)
    end
  end

  #-----------------------------------------------------------------------------
  # Utilities for checking for and performing a raid boss's Extra Attack phases.
  #-----------------------------------------------------------------------------
   def inExtraAttackPhase?(moves)
     return false if !isRaidBoss? || fainted?
     case moves
     # Triggers on the first turn, and then every 5th turn.
     when :support_moves
       return true if @battle.turnCount == 0
       return true if @battle.turnCount % 5 == 0
     # Triggers if at max shield HP, likelihood reduces as shield weakens. 
     when :spread_moves
       return false if !hasRaidShield?
       maxHP = @battle.raidRules[:shield_hp]
       return true if @battle.pbRandom(maxHP) < @shieldHP
     end
     return false
   end
   
  def pbRaidExtraAttackPhase(choice)
    return if choice[0] != :UseMove || @battle.pbAllFainted?
    return if @battle.decision > 0 || @battle.raidRules[:ko_count] == 0
    [:support_moves, :spread_moves].each do |moves|
      raid_moves = @battle.raidRules[moves]
      next if !raid_moves || raid_moves.empty?
      next if !inExtraAttackPhase?(moves)
      @selectedExtraAttack = true
      move = @battle.pbChooseRaidExtraAttack(@index, raid_moves, move)
      next if move.nil?
	  type = (moves == :support_moves) ? "support move" : "spread move"
      PBDebug.log("[Raid mechanics] #{pbThis} (#{@index}) triggered an extra move (#{type})")
      @battle.scene.pbAnimateExtraAction(@index)
      PBDebug.logonerr{ pbUseMoveSimple(move, -1, -1, false) }
      @battle.pbJudge
    end
    @selectedExtraAttack = false
  end
   
  #-----------------------------------------------------------------------------
  # Utilities for checking for and performing a raid boss's Double Attack phase.
  #-----------------------------------------------------------------------------
   def inDoubleAttackPhase?
     return false if !isRaidBoss? || fainted?
     return true if @hp <= (@totalhp * 0.4).round
     turnCount = @battle.raidRules[:turn_count]
     maxCount = @battle.raidRules[:max_turnCount] || 0
     return true if (maxCount > 0 && turnCount <= (maxCount * 0.4).round)
     return false
   end
  
  def pbRaidDoubleAttackPhase(choice)
    return if choice[0] != :UseMove || @battle.pbAllFainted?
    return if @battle.decision > 0 || @battle.raidRules[:ko_count] == 0
    if inDoubleAttackPhase?
      moves = (@baseMoves.empty?) ? @moves.clone : @baseMoves.clone
      if moves.length > 1
        moves.length.times { |i| moves[i] = nil if moves[i].id == @lastMoveUsed }
        moves.compact!
      end
      idxRand = rand(moves.length)
      choice[1] = idxRand
      choice[2] = moves[idxRand]
      choice[3] = -1
      PBDebug.log("[Raid mechanics] #{pbThis} (#{@index}) triggered an extra move (double attack)")
      PBDebug.log("[Use move] #{pbThis} (#{@index}) used #{choice[2].name}")
      PBDebug.logonerr { pbUseMove(choice) }
      @battle.pbJudge
    end
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to process all additional attacks a raid Pokemon can use in a turn.
  #-----------------------------------------------------------------------------
  alias raid_pbProcessTurn pbProcessTurn
  def pbProcessTurn(choice, tryFlee = true)
    pbRaidExtraAttackPhase(choice)
    return false if isRaidBoss? && @battle.raidRules[:ko_count] == 0
    ret = raid_pbProcessTurn(choice, tryFlee)
    pbRaidDoubleAttackPhase(choice)
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to allow raid Pokemon to use Belch without consuming a berry.
  #-----------------------------------------------------------------------------
  alias raid_belched? belched?
  def belched?
    return true if self.isRaidBoss?
    return raid_belched?
  end
end

#===============================================================================
# Battle::AI class additions related to selecting an Extra Attack.
#===============================================================================
class Battle::AI
  #-----------------------------------------------------------------------------
  # Scores all possible Extra Attacks a raid Pokemon can use.
  #-----------------------------------------------------------------------------
  def pbRaidExtraMoveScores(moves)
    idxMove = -1
    choices = []
    PBDebug.log("[Raid mechanics] #{@user.name} is considering extra move choices...")
    moves.each do |m|
      next if @user.battler.pbHasMove?(m)
      move = Battle::Move.from_pokemon_move(@battle, Pokemon::Move.new(m))
      set_up_move_check(move)
      if @trainer.has_skill_flag?("PredictMoveFailure") && pbPredictMoveFailure
        PBDebug.log_ai("#{@user.name} is considering using #{move.name}...")
        PBDebug.log_score_change(MOVE_FAIL_SCORE - MOVE_BASE_SCORE, "move will fail")
        choices.push([move, MOVE_FAIL_SCORE, -1])
        next
      end
      target_data = @move.pbTarget(@user.battler)
      if @move.function_code == "CurseTargetOrLowerUserSpd1RaiseUserAtkDef1" &&
         @move.rough_type == :GHOST && @user.has_active_ability?([:LIBERO, :PROTEAN])
        target_data = GameData::Target.get((Settings::MECHANICS_GENERATION >= 8) ? :RandomNearFoe : :NearFoe)
      end
      case target_data.num_targets
      when 0
        PBDebug.log_ai("#{@user.name} is considering using #{move.name}...")
        score = MOVE_BASE_SCORE
        PBDebug.logonerr { score = pbGetMoveScore }
        choices.push([move, score, -1])
      when 1
        redirected_target = get_redirected_target(target_data)
        num_targets = 0
        @battle.allBattlers.each do |b|
          next if redirected_target && b.index != redirected_target
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          next if target_data.targets_foe && !@user.battler.opposes?(b)
          PBDebug.log_ai("#{@user.name} is considering using #{move.name} against #{b.name} (#{b.index})...")
          score = MOVE_BASE_SCORE
          PBDebug.logonerr { score = pbGetMoveScore([b]) }
          choices.push([move, score, b.index])
          num_targets += 1
        end
        PBDebug.log("     no valid targets") if num_targets == 0
      else
        targets = []
        @battle.allBattlers.each do |b|
          next if !@battle.pbMoveCanTarget?(@user.battler.index, b.index, target_data)
          targets.push(b)
        end
        PBDebug.log_ai("#{@user.name} is considering using #{move.name}...")
        score = MOVE_BASE_SCORE
        PBDebug.logonerr { score = pbGetMoveScore(targets) }
        choices.push([move, score, -1])
      end
    end
    @battle.moldBreaker = false
    return choices
  end
  
  #-----------------------------------------------------------------------------
  # Returns the Extra Attack the raid Pokemon should use after tallying scores.
  #-----------------------------------------------------------------------------
  def pbRaidChooseExtraAttack(idxBattler, moves, group_id)
    set_up(idxBattler)
    choice = nil
    choices = pbRaidExtraMoveScores(moves)
    user_battler = @user.battler
	type = (group_id == :support_moves) ? "support move" : "spread move"
    if choices.length == 0
      PBDebug.log_ai("#{@user.name} will not use an extra move (#{type})")
      return nil
    end
    max_score = 0
    choices.each { |c| max_score = c[1] if max_score < c[1] }
    if max_score < MOVE_BASE_SCORE
      PBDebug.log_ai("#{@user.name} will not use an extra move (#{type})")
      return nil
    end
    threshold = (max_score * move_score_threshold.to_f).floor
    choices.each { |c| c[3] = [c[1] - threshold, 0].max }
    total_score = choices.sum { |c| c[3] }
    if $INTERNAL
      PBDebug.log_ai("Extra move choices for #{@user.name}:")
      choices.each_with_index do |c, i|
        chance = sprintf("%5.1f", (c[3] > 0) ? 100.0 * c[3] / total_score : 0)
        log_msg = "   * #{chance}% to use #{c[0].name}"
        log_msg += " (target #{c[2]})" if c[2] >= 0
        log_msg += ": score #{c[1]}"
        PBDebug.log(log_msg)
      end
    end
    randNum = pbAIRandom(total_score)
    choices.each_with_index do |c, i|
      randNum -= c[3]
      next if randNum >= 0
      choice = i
      break
    end
    if choice
      move_name = choices[choice][0].name
      if choices[choice][2] >= 0
        PBDebug.log("   => will use #{move_name} (target #{choices[choice][2]})")
      else
        PBDebug.log("   => will use #{move_name}")
      end
      PBDebug.log("")
      return choices[choice][0].id
    else
      return nil
    end
  end
end

#===============================================================================
# General AI handler for scoring moves during certain raid boss phases.
#===============================================================================
Battle::AI::Handlers::GeneralMoveScore.add(:preferences_vs_raid_boss,
  proc { |score, move, user, ai, battle|
    if battle.raidBattle?
      old_score = score
      foe = battle.battlers[1]
      if foe && foe.isRaidBoss?
        #-----------------------------------------------------------------------
        # Considers the raid boss's support move phases.
        if foe.inExtraAttackPhase?(:support_moves)
          case move.function_code
          when "DisableTargetStatusMoves" # Taunt
            score += 10
            PBDebug.log_score_change(score - old_score, "prefers move while raid boss may use support moves")
            old_score = score
          end
        end
        #-----------------------------------------------------------------------
        # Considers the raid boss's spread move phase.
        if foe.inExtraAttackPhase?(:spread_moves)
          case move.function_code
          when "ProtectUserSideFromMultiTargetDamagingMoves" # Wide Guard
            score += 10
            PBDebug.log_score_change(score - old_score, "prefers move while raid boss may use spread moves")
            old_score = score
          end
        end
      end
    end
    next score
  }
)