################################################################################
# 
# Z-Moves are defined in Z-Move Effects.rb.
# 
################################################################################
#===============================================================================
# Add new move flags to Battle::Move
#===============================================================================
class Battle::Move
  def explosiveMove?;          return @flags.any? { |f| f[/^Explosive$/i] };                end
end

#===============================================================================
# Life Steal
#===============================================================================
# User gains all the HP it inflicts as damage.
#-------------------------------------------------------------------------------
class Battle::Move::HealUserByDamageDone < Battle::Move
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user, target)
    return if target.damageState.hpLost <= 0
    hpGain = (target.damageState.hpLost / 2.0).round
    user.pbRecoverHPFromDrain(hpGain, target)
    super
  end
end

#===============================================================================
# (old 781)
#===============================================================================
# Decreases the target's Special Attack by 2 stages.
#-------------------------------------------------------------------------------
class Battle::Move::LowerTargetSpAtk2 < Battle::Move::TargetStatDownMove
  def initialize(battle,move)
    super
    @statDown = [:SPECIAL_ATTACK,2]
  end
end

#===============================================================================
# Ground Zero
#===============================================================================
# For 5 rounds, creates irradiated terrain which boosts Poison-type moves and
# boosts poison damage. Affects non-airborne Pokémon only.
#-------------------------------------------------------------------------------
class Battle::Move::StartIrradiatedTerrain < Battle::Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :Poison
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Poison)
  end
end

#===============================================================================
# Spirit Realm
#===============================================================================
# For 5 rounds, creates spirit terrain which boosts Ghost-type moves and
# debuffs Normal-type moves. Affects non-airborne Pokémon only.
#-------------------------------------------------------------------------------
class Battle::Move::StartSpiritTerrain < Battle::Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :Spirit
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Spirit)
  end
end

#===============================================================================
# Star Mash
#===============================================================================
# Target's Special Defense is used instead of its Defense for this move's
# calculations.
#-------------------------------------------------------------------------------
class Battle::Move::UseTargetSpDefInsteadOfTargetDefense < Battle::Move
  def pbGetDefenseStats(user,target)
    return target.spdef, target.stages[:SPECIAL_DEFENSE] + Battle::Battler::STAT_STAGE_MAXIMUM
  end
end

#===============================================================================
# Overdose
#===============================================================================
# Heals the first time. Deals massive damage if used again directly after.
#-------------------------------------------------------------------------------
class Battle::Move::HealTargetApplyOverdoseCondition < Battle::Move
  def pbEffectAfterAllHits(user,target)
    if target.effects[PBEffects::Overdose]==0
      target.pbRecoverHP(((target.totalHP+1)/2.0).floor,true)
      target.effects[PBEffects::Overdose]=2
      return 0
    else
      target.effects[PBEffects::Overdose]=0
    end
    return super(user,target)
  end
end

#===============================================================================
# Event Horizon
#===============================================================================
# User is protected against moves that target it this round. Faints the user
# of a stopped contact move.
# When used, the user loses 1/4 of their maximum HP.
#-------------------------------------------------------------------------------
class Battle::Move::ProtectUserEventHorizon < Battle::Move::ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::EventHorizon
  end
  
  def pbInitialEffect(user,targets,hitnum)
    user.pbReduceHP(user.totalhp/4,false)
    user.pbItemHPHealCheck
  end
end

#===============================================================================
# (old 787)
#===============================================================================
# Hits 1-2 times.
#-------------------------------------------------------------------------------
class Battle::Move::HitOneToTwoTimes < Battle::Move
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets)
    hitChances = [
      1, 1, 1, 1, 1, 1,
      2, 2, 2
    ]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length-1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end
end

#===============================================================================
# (old 788)
#===============================================================================
# Hits 1-3 times.
#-------------------------------------------------------------------------------
class Battle::Move::HitOneToThreeTimes < Battle::Move
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets)
    hitChances = [
      1, 1, 1, 1, 1,
      2, 2, 2, 2,
      3, 3, 3
    ]
    r = @battle.pbRandom(hitChances.length)
    r = hitChances.length-1 if user.hasActiveAbility?(:SKILLLINK)
    return hitChances[r]
  end
end

#===============================================================================
# Magnadisk
#===============================================================================
# If the target is on the same side as the user, protects them. Renders user
# as not having Levitate.
#-------------------------------------------------------------------------------
class Battle::Move::ProtectUserMagnadisk < Battle::Move::ProtectMove
  def initialize(battle,move)
    super
    @effect = PBEffects::Magnadisk
  end
end

#===============================================================================
# Solar Wind
#===============================================================================
# 20% chance paralysis, can break through protecting moves except Event Horizon
# and Magnadisk.
#-------------------------------------------------------------------------------
class Battle::Move::ChanceParalysisBreaksProtect < Battle::Move
  def pbInitialEffect(user,target)
    ret=super(user,target)
    if ret>0 && !target.effects[PBEffects::Magnadisk] &&
       !target.effects[PBEffects::EventHorizon]
      target.effects[PBEffects::ProtectNegation]=true
      target.pbOwnSide.effects[PBEffects::CraftyShield]=false
    end
    return ret
  end
  
  def pbAdditionalEffect(user,target)
    return if target.damagestate.substitute
    if target.pbCanParalyze?(user,false,self)
      target.pbParalyze(user)
    end
  end
end

#===============================================================================
# Dark Matter
#===============================================================================
# Increases Defense and lowers Speed.
#-------------------------------------------------------------------------------
class Battle::Move::RaiseUserDefense1LowerUserSpeed1 < Battle::Move
  def pbEffectAfterAllHits(user, target)
    if !target.pbCanIncreaseStatStage?(PBStats::SPEED,user,self) 
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis))
      return -1
    end
    pbShowAnimation(@id,user,target,hitnum,showanimation)
    showanim=true
    if target.pbCanReduceStatStage?(PBStats::SPEED,user,self)
      target.pbReduceStatStage(PBStats::SPEED,1,user)
      showanim=false
    end
    showanim=true
    if target.pbCanIncreaseStatStage?(PBStats::DEFENSE,user,self)
      target.pbIncreaseStatStage(PBStats::DEFENSE,1,user)
      showanim=false
    end
    return 0
  end
end

#===============================================================================
# Dark Energy
#===============================================================================
# OHKO. Accuracy is not dependent on level.
# User faints (if successful). Considered an explosive move (handled in Damp).
# For non-Celestial-types, this move has half accuracy.
#-------------------------------------------------------------------------------
class Battle::Move::UserFaintsOHKOExplosive < Battle::Move::FixedDamageMove  
  def pbFailsAgainstTarget?(user,target)
    if target.level>user.level
      @battle.pbDisplay(_INTL("{1} is unaffected!",target.pbThis))
      return true
    end
    if target.hasActiveAbility?(:STURDY) && !@battle.moldBreaker
      @battle.pbShowAbilitySplash(target)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        @battle.pbDisplay(_INTL("But it failed to affect {1}!",target.pbThis(true)))
      else
        @battle.pbDisplay(_INTL("But it failed to affect {1} because of its {2}!",
           target.pbThis(true),target.abilityName))
      end
      @battle.pbHideAbilitySplash(target)
      return true
    end
    return false
  end
  
  def pbFixedDamage(user,target)
    return target.totalhp
  end
  
  def pbSelfKO(user)
    return if user.fainted?
    user.pbReduceHP(user.hp,false)
    user.pbItemHPHealCheck
  end
  
  def pbAccuracyCheck(user,target)
    acc = @accuracy
    acc /= 2 if !user.pbHasType?(:CELESTIAL)
    return @battle.pbRandom(100)<acc
  end

  def pbHitEffectivenessMessages(user,target,numTargets=1)
    super
    if target.fainted?
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
  end
end

#===============================================================================
# Planetary Alignment
#===============================================================================
# Changes Special Attack, Special Defense, and Accuracy a random amount.
# Can change a valid stat 0 stages, 1 stage, or 2 stages.
#-------------------------------------------------------------------------------
class Battle::Move::RaiseUserSpAtkSpDefAccRandomly < Battle::Move
  def pbEffectAfterAllHits(user,target)
    array=[]
    stats=[]
    for i in [PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY]
      array.push(@battle.pbRandom(2)) if target.pbCanIncreaseStatStage?(i,user,self)
      stats.push(i) if target.pbCanIncreaseStatStage?(i,user)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",target.pbThis))
      return -1
    end
    showanim=true
    for i in 0..array.length
      if target.pbCanIncreaseStatStage?(stats[i],user,self)
        target.pbIncreaseStatStage(stats[i],array[i],user)
        showanim=false
      end
    end
    return 0
  end
end

#===============================================================================
# Hits 1-3 times. User gains 2/3 the HP it inflicts as damage. (Draining Darts)
#===============================================================================
class Battle::Move::HitOneToThreeTimesHealUserByTwoThirdsDamageDone < Battle::Move::HitOneToThreeTimes
  def healingMove?; return Settings::MECHANICS_GENERATION >= 6; end

  def pbEffectAgainstTarget(user,target)
    return if target.damageState.hpLost<=0
    hpGain = (target.damageState.hpLost*2.0/3.0).round
    user.pbRecoverHPFromDrain(hpGain,target)
  end
end

#===============================================================================
# Hits twice. May burn the target on each hit. (Lashing Claws)
#===============================================================================
class Battle::Move::HitTwiceBurnTarget < Battle::Move::BurnTarget
  def multiHitMove?;           return true; end
  def pbNumHits(user,targets); return 2;    end
end
  
#===============================================================================
# Hits three times. Power doubles in rain. (Storming Pulses)
# An accuracy check is performed on each hit.
#===============================================================================
class Battle::Move::HitThreeTimesRainBoost < Battle::Move
  def multiHitMove?;           return true; end
  def pbNumHits(user, targets); return 3;    end
    
  def successCheckPerHit?
    return @accCheckPerHit
  end

  def pbOnStartUse(user,targets)
    @accCheckPerHit = !user.hasActiveAbility?(:SKILLLINK)
  end
  
  def pbBaseDamageMultiplier(damageMult,user,target)
    damageMult *= 2 if [:Rain, :HeavyRain].include?(@battle.pbWeather) && !user.hasUtilityUmbrella?
    return damageMult
  end
end

#===============================================================================
# Power is equal to that of the last used move.
# (Action Replay)
#===============================================================================
class Battle::Move::PowerOfLastUsedMove < Battle::Move
  def pbEffectAgainstTarget(user,target)
    target.effects[PBEffects::Disable]     = 5
    target.effects[PBEffects::DisableMove] = target.lastRegularMoveUsed
    @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",target.pbThis,
       GameData::Move.get(target.lastRegularMoveUsed).name))
    target.pbItemStatusCureCheck
  end
  
  def initialize(battle,move)
    super
    @noPowerDamagingMoves = [
       [["FixedDamage20"],20],
       [["FixedDamage40"],40],
       [["OHKO","OHKOIce","OHKOHitsUndergroundTarget"],150]
    ]
  end
  
  def pbBaseDamage(baseDmg,user,target)
    for i in @noPowerDamagingMoves
      if i[0].include?(@battle.lastMoveUsed.function_code)
        return i[1]
      end
    end
    if @battle.lastMoveUsed.statusMove?
      return 20
    end
    return @battle.lastMoveUsed.baseDamage.clamp(20, 150)
  end
end

#===============================================================================
# Causes Haywire.
#===============================================================================
#class PokeBattle_Move_792 < PokeBattle_HaywireMove
#end

#===============================================================================
# Frostbites the target. If used again, it freezes instead.
# (Superchill)
#===============================================================================
#class PokeBattle_Move_793 < PokeBattle_FreezeMove
#  def initialize(battle,move)
#    super
#    @stacking = true
#  end
#end

#===============================================================================
# Entry hazard. Lays ice spikes on the opposing side (max. 2 layers).
# (Ice Spikes)
#===============================================================================
class Battle::Move::AddIceSpikesToFoeSide < Battle::Move
  def pbMoveFailed?(user,targets)
    if user.pbOpposingSide.effects[PBEffects::IceSpikes]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    user.pbOpposingSide.effects[PBEffects::IceSpikes] += 1
    @battle.pbDisplay(_INTL("Ice spikes were scattered all around {1}'s feet!",
       user.pbOpposingTeam(true)))
  end
end

#===============================================================================
# This move's type is based on the move of the user. (Chroma Shine)
# The secondary type is used, and is typeless if there is none.
#===============================================================================
class Battle::Move::UsesUserSecondaryType < Battle::Move
  def pbBaseType(user)
    return nil if user.pbTypes(false).length < 2
    return user.pbTypes[1]
  end
end

#===============================================================================
# This move's type is based on the move of the user. (Chroma Blast)
# The secondary type is used. The user must have two different types to use it.
# Removes the user's secondary type after use.
#===============================================================================
class Battle::Move::UsesUserSecondaryTypeUserLosesSecondaryType < Battle::Move::UsesUserSecondaryType
  def pbMoveFailed?(user,targets)
    if !user.canChangeType? || user.pbTypes(false).length < 2
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end
  
  def pbEffectGeneral(user)
    if user.canChangeType?
      user.effects[PBEffects::ChromaBlast] = true
    end
  end
end

#===============================================================================
# Starts solar winds. (Starstorm)
#===============================================================================
class Battle::Move::StartStarstorm < Battle::Move::WeatherMove
  def initialize(battle,move)
    super
    @weatherType = :Starstorm
  end
end

#===============================================================================
# For 5 rounds, creates glitch terrain which boosts Glitch-type moves and
# prevents weather conditions. Affects non-airborne Pokémon only.
# (Glitch City)
#===============================================================================
class Battle::Move::StartGlitchCity < Battle::Move
  def pbMoveFailed?(user,targets)
    if @battle.field.terrain == :Glitch
      @battle.pbDisplay(_INTL("But it failed!"))
      return true
    end
    return false
  end

  def pbEffectGeneral(user)
    @battle.pbStartTerrain(user, :Glitch)
  end
end

#===============================================================================
# Debuffs the target if they are a foe, buffs them if they are not.
# (Cheat Code)
#===============================================================================
class Battle::Move::DebuffFoeOrBuffAllyRandomStat < Battle::Move
  def pbOnStartUse(user,targets)
    @raiseStat = false
    @raiseStat = !user.opposes?(targets[0]) if targets.length>0
    @stats = [:ATTACK,:DEFENSE,:SPECIAL_ATTACK,:SPECIAL_DEFENSE,:SPEED]
    @statToChange = @stats.sample
  end
  
  def pbFailsAgainstTarget?(user,target)
    return false if damagingMove? # Damage will always be applied
    @stats.length.times do
      if !target.pbCanRaiseStatStage?(@statToChange,user,self,true) && @raiseStat
        @stats.delete(@statToChange)
        @statToChange = @stats.sample
      elsif !target.pbCanLowerStatStage?(@statToChange,user,self,true) && !@raiseStat
        @stats.delete(@statToChange)
        @statToChange = @stats.sample
      else
        return false # The stat can be changed in the requisite way, so return
      end
    end
    return true # No stats can be changed
  end

  def pbEffectAgainstTarget(user,target)
    return if damagingMove?
    if @raiseStat
      target.pbRaiseStatStage(@statToChange,1,user)
    else
      target.pbLowerStatStage(@statToChange,1,user)
    end
  end

  def pbAdditionalEffect(user,target)
    return if target.damageState.substitute
    return if !target.pbCanRaiseStatStage?(@statToChange,user,self) && @raiseStat
    return if !target.pbCanLowerStatStage?(@statToChange,user,self) && !@raiseStat
    target.pbRaiseStatStage(@statToChange,1,user) if @raiseStat
    target.pbLowerStatStage(@statToChange,1,user) if @lowerStat
  end
end

#===============================================================================
# Type effectiveness, but not the type, of this move is replaced by the
# effectiveness of the bearer's Herald ability's aura.
# For non-Heralds, it's a basic damaging move. (Axial Tilt)
#===============================================================================
class Battle::Move::HeraldTypeEffectiveness < Battle::Move
  def hitsFlyingTargets?; return true; end
  
  def pbCalcTypeModSingle(moveType,defType,user,target)
    ret = super
    if user.hasActiveAbility?(:HERALDOFSPRING)    # Herald of Spring - Flying
      if GameData::Type.exists?(:FLYING)
        flyingEff = Effectiveness.calculate_one(:FLYING, defType)
        ret = flyingEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif user.hasActiveAbility?(:HERALDOFSUMMER) # Herald of Summer - Fire
      if GameData::Type.exists?(:FIRE)
        fireEff = Effectiveness.calculate_one(:FIRE, defType)
        ret = fireEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif user.hasActiveAbility?(:HERALDOFAUTUMN) # Herald of Autumn - Ground
      if GameData::Type.exists?(:GROUND)
        groundEff = Effectiveness.calculate_one(:GROUND, defType)
        ret = Effectiveness::NORMAL_EFFECTIVE_ONE if ret = Effectiveness::INEFFECTIVE # Ground on Flying
        ret = groundEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    elsif user.hasActiveAbility?(:HERALDOFWINTER) # Herald of Winter - Water
      if GameData::Type.exists?(:WATER)
        waterEff = Effectiveness.calculate_one(:WATER, defType)
        ret = waterEff.to_f / Effectiveness::NORMAL_EFFECTIVE_ONE
      end
    end
    return ret
  end
end

#===============================================================================
# Effectiveness against Electric is 2x. (Blackout)
#===============================================================================
class Battle::Move::SuperEffectiveAgainstElectric < Battle::Move
  def pbCalcTypeModSingle(moveType,defType,user,target)
    return Effectiveness::SUPER_EFFECTIVE_MULTIPLIER if defType == :ELECTRIC
    return super
  end
end