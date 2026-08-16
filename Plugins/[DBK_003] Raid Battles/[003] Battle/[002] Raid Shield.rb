#===============================================================================
# Battle::Battler additions related to raid shields.
#===============================================================================
class Battle::Battler
  attr_accessor :shieldHP
  attr_accessor :selectedExtraAttack
  
  #-----------------------------------------------------------------------------
  # Aliased to initialize new raid battler properties.
  #-----------------------------------------------------------------------------
  alias raid_pbInitEffects pbInitEffects
  def pbInitEffects(batonPass)
    raid_pbInitEffects(batonPass)
    @shieldHP = 0
    @selectedExtraAttack = false
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to make status moves fail on a raid Pokemon behind a raid shield.
  #-----------------------------------------------------------------------------
  alias raid_pbSuccessCheckAgainstTarget pbSuccessCheckAgainstTarget
  def pbSuccessCheckAgainstTarget(move, user, target, targets)
    if target.hasRaidShield? && move.statusMove?
      @battle.pbDisplay(_INTL("The mysterious barrier protected {1}!", target.pbThis(true)))
      return false
    end
    return raid_pbSuccessCheckAgainstTarget(move, user, target, targets)
  end
  
  #-----------------------------------------------------------------------------
  # Returns true if the battler currently has a Raid shield.
  #-----------------------------------------------------------------------------
  def hasRaidShield?
    return false if !opposes? || fainted?
    return @shieldHP && @shieldHP > 0
  end
  
  #-----------------------------------------------------------------------------
  # Utility for starting a new raid shield.
  #-----------------------------------------------------------------------------
  def startRaidShield(shield_hp = 0)
    return if @battle.pbAllFainted? || @battle.decision > 0
    return if hasRaidShield?
    @battle.raidRules[:shield_hp] = shield_hp.clamp(0, 8) if !@battle.raidRules.has_key?(:shield_hp)
    return if !@battle.raidRules[:shield_hp] || @battle.raidRules[:shield_hp] <= 0
    @battle.scene.pbRefreshStyle(:Long) if !@battle.databoxStyle
    @battle.pbDisplay(_INTL("Energy has begun to gather around {1}!", pbThis(true)))
    @battle.pbAnimation(:REFLECT, self, self)
    @shieldHP = @battle.raidRules[:shield_hp]
    PBDebug.log("[Raid mechanics] #{pbThis(true)} (#{@index}) triggered its raid shield")
    @battle.scene.pbRefreshOne(@index)
    @battle.scene.pbAnimateRaidShield(self)
    @battle.pbDisplay(_INTL("A mysterious barrier appeared in front of {1}!", pbThis(true)))
    pbCureStatus
    @battle.pbDeluxeTriggers(@index, nil, "RaidShieldStart")
  end
  
  #-----------------------------------------------------------------------------
  # Utility for updating a raid shield's HP.
  #-----------------------------------------------------------------------------
  def setRaidShieldHP(amt, user = nil)
    return if !hasRaidShield?
    maxHP = @battle.raidRules[:shield_hp]
    oldShield = @shieldHP
    if $DEBUG && Input.press?(Input::CTRL)
      amt = (amt > 0) ? maxHP : -maxHP
    elsif user && amt < 0
      move = GameData::Move.try_get(user.lastMoveUsed)
      if move && move.damaging?
        amt -= 1 if user.effects[PBEffects::HelpingHand]
        amt -= 1 if user.pbOwnSide.effects[PBEffects::CheerOffense3] > 0
        case @battle.raidRules[:style]
        #-----------------------------------------------------------------------
        # Basic Raids
        #-----------------------------------------------------------------------
        # Super Effective moves remove 1 extra bar of shield HP.
        when :Basic
          amt -= 1 if Effectiveness.super_effective?(@damageState.typeMod)
        #-----------------------------------------------------------------------
        # Ultra Raids
        #-----------------------------------------------------------------------
        # Z-Moves remove 2 extra bars of shield HP. Doesn't stack with Ultra Burst.
        # Moves used by a Pokemon in Ultra Burst form remove an extra bar of shield HP.
        when :Ultra
          if !user.baseMoves.empty? && user.lastMoveUsedIsZMove && move.zMove?
            amt -= 2
          elsif user.ultra?
            amt -= 1
          end
        #-----------------------------------------------------------------------
        # Max Raids
        #-----------------------------------------------------------------------
        # Max Moves used by a Pokemon in Dynamax form remove an extra bar of shield HP.
        # G-Max moves used by a Gigantamax Pokemon remove an extra bar of shield HP.
        when :Max
          if !user.baseMoves.empty? && user.dynamax? && move.dynamaxMove?
            amt -= 1
            amt -= 1 if user.gmax? && move.gmaxMove?
          end
        #-----------------------------------------------------------------------
        # Tera Raids
        #-----------------------------------------------------------------------
        # Moves that match a Terastallized Pokemon's base typing remove an additional bar of shield HP.
        # Moves that match a Terastallized Pokemon's Tera Type remove an additional bar of shield HP.
        when :Tera
          if user.tera?
            amt -= 1 if user.types.include?(user.lastMoveUsedType)
            amt -= 1 if user.typeTeraBoosted?(user.lastMoveUsedType)
          end
        end
      end
    end
    @shieldHP += amt
    @shieldHP = maxHP if @shieldHP > maxHP
    @shieldHP = 0 if @shieldHP < 0
    return if @shieldHP == oldShield
    PBDebug.log("[Raid mechanics] #{pbThis(true)} (#{@index})'s raid shield HP changed (#{oldShield} => #{@shieldHP})")
    @battle.scene.pbRefreshOne(@index)
    @battle.scene.pbAnimateRaidShield(self, oldShield)
    @battle.pbDeluxeTriggers(@index, nil, "RaidShieldDamaged") if @shieldHP > 0 && @shieldHP < oldShield
    return if @shieldHP > 0
    return if @battle.pbAllFainted? || @battle.decision > 0
    @battle.pbDisplay(_INTL("The mysterious barrier disappeared!"))
    oldhp = @hp
    @hp -= @totalhp / 8
    @hp = 1 if @hp <= 1
    @battle.scene.pbHPChanged(self, oldhp)
    [:DEFENSE, :SPECIAL_DEFENSE].each do |stat|
      if pbCanLowerStatStage?(stat, self, nil, true)
        pbLowerStatStage(stat, 2, self, true, false, 0, true)
      end
    end
    @battle.raidRules.delete(:shield_hp)
    @battle.pbDeluxeTriggers(@index, nil, "RaidShieldBroken")
  end
end

#===============================================================================
# Raid shield damage calcs.
#===============================================================================
class Battle::Move
  alias raid_pbCalcDamageMults_Screens pbCalcDamageMults_Screens
  def pbCalcDamageMults_Screens(user, target, numTargets, type, baseDmg, multipliers)
    raid_pbCalcDamageMults_Screens(user, target, numTargets, type, baseDmg, multipliers)
    if target.hasRaidShield?
      multipliers[:final_damage_multiplier] *= 0.05
    end
  end
end

class Battle::AI::AIMove
  alias raid_calc_screen_mults calc_screen_mults
  def calc_screen_mults(user, target, base_dmg, calc_type, is_critical, multipliers)
    raid_calc_screen_mults(user, target, base_dmg, calc_type, is_critical, multipliers)
    if target.battler.hasRaidShield?
      multipliers[:final_damage_multiplier] *= 0.05
    end
  end
end

#===============================================================================
# General AI handler for scoring moves vs targets when a raid shield is active.
#===============================================================================
Battle::AI::Handlers::GeneralMoveAgainstTargetScore.add(:target_has_raid_shield,
  proc { |score, move, user, target, ai, battle|
    if target.battler.hasRaidShield?
      old_score = score
      if move.damagingMove?
        case battle.raidRules[:style]
        #-----------------------------------------------------------------------
        # Basic Raids
        # -Encourages use of Super Effective moves vs. raid shields.
        when :Basic
          type = move.rough_type
          eff = target.effectiveness_of_type_against_battler(type, user, move)
          score += 20 if Effectiveness.super_effective?(eff)
        #-----------------------------------------------------------------------
        # Ultra Raids
        # -Encourages use of Z-Moves moves vs. raid shields.
        when :Ultra
          if move.move.zMove?
            score += 20
          elsif user.battler.ultra?
            score += 5
          end
        #-----------------------------------------------------------------------
        # Max Raids
        # -Encourages use of G-Max moves vs. raid shields.
        when :Max
          if user.battler.dynamax?
            bonus = (move.move.gmaxMove?) ? 20 : 5
            score += bonus
          end
        #-----------------------------------------------------------------------
        # Tera Raids
        # -Encourages use of Tera-boosted moves vs. raid shields.
        when :Tera
          if user.battler.tera?
            type = move.rough_type
            score += 5 if user.types.include?(type)
            score += 20 if user.battler.typeTeraBoosted?(type)
          end
        end
        if score != old_score
          PBDebug.log_score_change(score - old_score, "prefer dealing more damage to raid shield")
        end
      else
        #-----------------------------------------------------------------------
        # Status moves discouraged vs. raid shields.
        score -= 50
        PBDebug.log_score_change(score - old_score, "avoid using status moves on raid shield")
      end
    elsif !target.battler.isRaidBoss?
      foe = battle.battlers[1]
      if foe && foe.hasRaidShield?
        #-----------------------------------------------------------------------
        # Encourages moves that help penetrate raid shields.
        case move.function_code
        when "PowerUpAllyMove" # Helping Hand
          score += 10
          PBDebug.log_score_change(score - old_score, "ally deals extra raid shield damage")
        end
      end
    end
    next score
  }
)