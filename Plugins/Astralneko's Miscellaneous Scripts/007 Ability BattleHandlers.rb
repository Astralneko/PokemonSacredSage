################################################################################
# 
# New Battle AbilityEffects.
# 
################################################################################

#===============================================================================
# StatusCheckNonIgnorable handlers
#===============================================================================
Battle::AbilityEffects::StatusCheckNonIgnorable.add(:PERMAFROST,
  proc { |ability, battler, status|
    next false if !battler.isSpecies?(:KOMBLANCHE)
    next true if status.nil? || status == :FROSTBITE || status == :FREEZE
  }
)

#===============================================================================
# StatusImmunityNonIgnorable handlers
#===============================================================================
Battle::AbilityEffects::StatusImmunityNonIgnorable.add(:PERMAFROST,
  proc { |ability, battler, status|
    next true if battler.isSpecies?(:KOMBLANCHE)
  }
)

#===============================================================================
# StatLossImmunity handlers
#===============================================================================
Battle::AbilityEffects::StatLossImmunity.add(:ARTISTSBLOCK,
  proc { |ability,battler,stat,battle,showMessages|
    next false if stat != :SPECIAL_ATTACK && stat != :SPECIAL_DEFENSE
    if showMessages
      battle.pbShowAbilitySplash(battler)
      if PokeBattle_SceneConstants::USE_ABILITY_SPLASH
        battle.pbDisplay(_INTL("{1}'s {2} cannot be lowered!",battler.pbThis,GameData::Stat.get(stat).name))
      else
        battle.pbDisplay(_INTL("{1}'s {2} prevents {3} loss!",battler.pbThis,
           battler.abilityName,GameData::Stat.get(stat).name))
      end
      battle.pbHideAbilitySplash(battler)
    end
    next true
  }
)

#===============================================================================
# MoveBlocking handlers
#===============================================================================

Battle::AbilityEffects::MoveBlocking.add(:DAMP,
  proc { |ability, bearer, user, targets, move, battle|
    next false if !move.explosiveMove?
    next false if !bearer.opposes?(user)
    ret = false
    targets.each { |b| ret = true if b.opposes?(user) }
    next ret
  }
)

#===============================================================================
# ModifyMoveBaseType handlers
#===============================================================================
Battle::AbilityEffects::ModifyMoveBaseType.add(:ASTRALIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:CELESTIAL)
    move.powerBoost = true
    next :CELESTIAL
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:INCENDIATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:FIRE)
    move.powerBoost = true
    next :FIRE
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:AQUILATE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:WATER)
    move.powerBoost = true
    next :WATER
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:VERDARIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:GRASS)
    move.powerBoost = true
    next :GRASS
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:VILLAINIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:DARK)
    move.powerBoost = true
    next :DARK
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:ARCANIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:DRAGON)
    move.powerBoost = true
    next :DRAGON
  }
)

Battle::AbilityEffects::ModifyMoveBaseType.add(:SPECTRALIZE,
  proc { |ability,user,move,type|
    next if type != :NORMAL || !GameData::Type.exists?(:GHOST)
    move.powerBoost = true
    next :GHOST
  }
)

#===============================================================================
# DamageCalcFromUser handlers
#===============================================================================
Battle::AbilityEffects::DamageCalcFromUser.add(:PACKMENTALITY,
  proc { |ability,user,target,move,mults,power,type|
    # The search will always find at least 1,
    # so this needs to be 1 minus the boost amount
    boost = 0.6 
    for i in user.battle.pbParty(user.index)
      if GameData::Species.get(user.species).get_related_species.include?(i.species)
        boost += 0.4
      end
    end
    mults[:base_damage_multiplier] *= boost
  }
)

#===============================================================================
# DamageCalcFromAlly handlers
#===============================================================================
Battle::AbilityEffects::DamageCalcFromAlly.add(:PACKMENTALITY,
  proc { |ability,user,target,move,mults,power,type|
    # The search will always find at least 1,
    # so this needs to be 1 minus the boost amount
    boost = 0.6 
    for i in user.battle.pbParty(user.index)
      if GameData::Species.get(user.species).get_related_species.include?(i.species)
        boost += 0.4
      end
    end
    mults[:base_damage_multiplier] *= boost
  }
)
#===============================================================================
# DamageCalcFromTarget handlers
#===============================================================================
Battle::AbilityEffects::DamageCalcFromTarget.add(:PERMAFROST,
  proc { |ability,user,target,move,mults,baseDmg,type|
    mults[:base_damage_multiplier] /= 2 if type == :ICE
    mults[:base_damage_multiplier] *= 1.5 if type == :FIRE
  }
)

#===============================================================================
# OnBeingHit handlers
#===============================================================================
Battle::AbilityEffects::OnBeingHit.add(:RESILIENCE,
  proc { |ability,user,target,move,battle|
    # Moves that deal with the user's defense despite being Special
    physical_function_codes = [
            # no 121 because Foul Play is physical
            "UseTargetDefenseInsteadOfTargetSpDef",
            "CategoryDependsOnHigherDamageIgnoreTargetAbility"
    ]
    # Moves that deal with the user's special defense despite being Physical
    special_function_codes = [
            "UseTargetSpDefInsteadOfDefense"
    ]
    next if target.fainted?
    # Fails if it's a Z-Move or Max Move
    next if move.powerMove?
    # Photon Geyser/Light That Burns The Sky/Tera Blast
    next if ["CategoryDependsOnHigherDamageIgnoreTargetAbility"].include?(move.function) && user.spdef > user.defense
    next if !physical_function_codes.include?(move.function) && move.category != 0 && Settings::MOVE_CATEGORY_PER_MOVE
    next if !physical_function_codes.include?(move.function) && !GameData::Type.get(move.type).physical?
    next if special_function_codes.include?(move.function)
    target.effects[PBEffects::ResilienceDamage] += (0.75 * target.damageState.calcDamage).floor
  }
)

#===============================================================================
# OnEndOfUsingMove handlers
#===============================================================================
Battle::AbilityEffects::OnEndOfUsingMove.add(:QUICKPLAY,
  proc { |ability,user,targets,move,battle|
    next if battle.pbAllFainted?(user.idxOpposingSide)
    numFainted = 0
    targets.each { |b| numFainted += 1 if b.damageState.fainted }
    next if numFainted==0
    next if !user.pbCanLowerStatStage?(:DEFENSE,user) && 
            !user.pbCanLowerStatStage?(:ATTACK,user)
    battle.pbShowAbilitySplash(user)
    user.pbLowerStatStageByAbility(:ATTACK,numFainted,user,false)
    user.pbLowerStatStageByAbility(:DEFENSE,numFainted,user,false)
    battle.pbHideAbilitySplash(user)
  }
)

#===============================================================================
# EndOfRoundHealing handlers
#===============================================================================
Battle::AbilityEffects::EndOfRoundHealing.add(:RESILIENCE,
  proc { |ability,battler,battle|
    battle.pbShowAbilitySplash(battler)
    if battler.effects[PBEffects::ResilienceDamage] > 0
      battler.pbRecoverHP(battler.effects[PBEffects::ResilienceDamage])
      battler.effects[PBEffects::ResilienceDamage] = 0
    end
    battle.pbHideAbilitySplash(battler)
  }
)

#===============================================================================
# OnSwitchIn handlers
#===============================================================================
Battle::AbilityEffects::OnSwitchIn.add(:QUICKPLAY,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battler.pbRaiseStatStageByAbility(:ATTACK,1,battler,false)
    battler.pbRaiseStatStageByAbility(:DEFENSE,1,battler,false)
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:STARRYSURGE,
  proc { |ability, battler, battle, switch_in|
    pbBattleWeatherAbility(:Starstorm, battler, battle)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HERALDOFSPRING,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating an airy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HERALDOFSUMMER,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a fiery aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HERALDOFAUTUMN,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating an earthy aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:HERALDOFWINTER,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is radiating a watery aura!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)

Battle::AbilityEffects::OnSwitchIn.add(:PERMAFROST,
  proc { |ability, battler, battle, switch_in|
    battle.pbShowAbilitySplash(battler)
    battle.pbDisplay(_INTL("{1} is covered in frost!",battler.pbThis))
    battle.pbHideAbilitySplash(battler)
  }
)