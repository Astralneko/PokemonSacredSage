#===============================================================================
# Gets all function codes for moves that should be banned for a raid battler.
#===============================================================================
def pbRaidBannedMoves(rental = false)
  funct_main = raid_blacklist_functions_main
  funct_other = (rental) ? raid_blacklist_functions_rental : raid_blacklist_functions_boss
  return funct_main.concat(funct_other)
end

#-------------------------------------------------------------------------------
# Damaging moves banned for all battlers during raid battles.
# Note: Most damaging moves below 55 Power or 60 Accuracy are automatically banned and don't need to be specified.
# Multi-hit, spread, and priority moves are counted as exceptions and filtered differently.
#-------------------------------------------------------------------------------
def raid_blacklist_functions_main
  return [
    "PursueSwitchingFoe",                             # Pursuit                          Reason: Neither side can switch.
    "SwitchOutUserDamagingMove",                      # U-Turn, Volt Switch, etc.        Reason: Neither side can switch.
    "UserTakesTargetItem",                            # Thief, Covet                     Reason: Bosses immune to item removal. Player's items are hard to earn.
    "FailsIfTargetHasNoItem",                         # Poltergeist                      Reason: Wasted moveslot in most cases.
    "FlinchTargetFailsIfNotUserFirstTurn",            # Fake Out                         Reason: Bosses immune to flinch. Wasted moveslot on bosses.
    "AttackAndSkipNextTurn",                          # Hyper Beam, Giga Impact, etc.    Reason: Bosses give free turn. Turn counter stalling.
    "SwitchOutTargetDamagingMove",                    # Circle Throw, Dragon Tail        Reason: Neither side can switch.
    "UserFaintsExplosive",                            # Self-Destruct, Explosion         Reason: Neither side can self-KO.
    "UserFaintsPowersUpInMistyTerrainExplosive",      # Misty Explosion                  Reason: Neither side can self-KO.
    "UserLosesHalfOfTotalHP",                         # Steel Beam                       Reason: Neither side can self-KO.
    "OHKO",                                           # Guillotine, Horn Drill           Reason: Neither side should be OHKO'd.
    "OHKOHitsUndergroundTarget",                      # Fissure                          Reason: Neither side should be OHKO'd.
    "OHKOIce",                                        # Sheer Cold                       Reason: Neither side should be OHKO'd.
    "LowerUserSpAtk2",                                # Overheat, Draco Meteor, etc.     Reason: Self-weaken too detrimental when neither side can switch.
    "TwoTurnAttack",                                  # Razor Wind                       Reason: Turn counter stalling.
    "TwoTurnAttackInvulnerableInSky",                 # Fly                              Reason: Turn counter stalling.
    "TwoTurnAttackInvulnerableUnderground",           # Dig                              Reason: Turn counter stalling.
    "TwoTurnAttackInvulnerableUnderwater",            # Dive                             Reason: Turn counter stalling.
    "HealUserByHalfOfDamageDoneIfTargetAsleep",       # Dream Eater                      Reason: Too specific to be useful.
    "TypeDependsOnUserIVs",                           # Hidden Power                     Reason: Too unpredictable.
    "FailsIfUserHasUnusedMove",                       # Last Resort                      Reason: Too specific to be useful.
    "TwoTurnAttackInvulnerableInSkyTargetCannotAct",  # Sky Drop                         Reason: Turn counter stalling.
    "FlinchTargetFailsIfTargetNotUsingPriorityMove",  # Upper Hand                       Reason: Too specific to be useful.
    "IncreasePowerEachFaintedAlly",                   # Last Respects                    Reason: Wasted moveslot on bosses. Limited use for player.
    "CategoryDependsOnHigherDamageTera"	              # Tera Blast                       Reason: Too spammable in Tera Raids. Irrelevant otherwise.
  ]
end

#-------------------------------------------------------------------------------
# Damaging moves banned for rental battlers during raid battles.
#-------------------------------------------------------------------------------
def raid_blacklist_functions_rental
  return [
    "TwoTurnAttackInvulnerableRemoveProtections",     # Shadow Force, Phantom Force      Reason: Turn counter stalling.
    "RemoveTargetItem",                               # Knock Off                        Reason: Bosses immune to item removal.
    "FailsIfUserNotConsumedBerry",                    # Belch                            Reason: Too specific to be useful.
    "LowerPPOfTargetLastMoveBy3"                      # Eerie Spell                      Reason: Raid bosses have infinite PP.
  ]
end

#-------------------------------------------------------------------------------
# Damaging moves banned for raid bosses during raid battles.
#-------------------------------------------------------------------------------
def raid_blacklist_functions_boss
  return [
    "FailsIfNotUserFirstTurn",                        # First Impression                 Reason: Wasted moveslot on bosses.
    "HitOncePerUserTeamMember",                       # Beat Up                          Reason: Boss's side only has 1 party member.
    "DoublePowerIfAllyFaintedLastTurn",               # Retaliate                        Reason: Boss's side only has 1 party member.
    "MultiTurnAttackConfuseUserAtEnd",                # Trash, Outrage, etc.             Reason: Bosses shouldn't be locked into a move.
    "FailsIfUserDamagedThisTurn",                     # Focus Punch                      Reason: Bosses will never pull this off.
    "UserLosesHalfOfTotalHPExplosive",                # Mind Blown                       Reason: Bosses cannot self-KO.
    "RemoveTerrain",                                  # Steel Roller                     Reason: Too specific to be useful.
    "RecoilHalfOfTotalHP"                             # Chloroblast                      Reason: Bosses cannot self-ko.
  ]
end

#===============================================================================
# Gets all function codes for approved status moves for raid battles.
# Any status moves that do not appear below are considered banned.
#===============================================================================
def pbRaidApprovedStatusMoves(category = nil, rental = false)
  funct_main = raid_whitelist_functions_main(category)
  funct_other = (rental) ? raid_whitelist_functions_rental(category) : raid_whitelist_functions_boss
  return funct_main.concat(funct_other)
end

#-------------------------------------------------------------------------------
# Status moves approved for all battlers during raid battles.
#-------------------------------------------------------------------------------
def raid_whitelist_functions_main(category)
  functions = [
    "RaiseUserAtkSpAtk1",                                # Work Up
    "RaiseUserAtkSpAtk1Or2InSun",                        # Growth
    "RaiseUserDefense2",                                 # Barrier, Iron Defense
    "RaiseUserDefense3",                                 # Cotton Guard
    "RaiseUserSpDef1PowerUpElectricMove",                # Charge
    "RaiseUserSpDef2",                                   # Amnesia
    "RaiseUserDefSpDef1",                                # Defend Order, Cosmic Power
    "UserAddStockpileRaiseDefSpDef1",                    # Stockpile
    "LowerTargetAtkDef1",                                # Tickle
    "LowerTargetAtkSpAtk1",                              # Noble Roar, Tearful Look
    "TrapTargetInBattleLowerTargetDefSpDef1EachTurn",    # Octolock
    "LowerTargetSpeed1MakeTargetWeakerToFire",           # Tar Shot
    "LowerTargetSpeed2",                                 # String Shot, Scary Face, etc.
    "ResetAllBattlersStatStages",                        # Haze
    "InvertTargetStatStages",                            # Topsy-Turvy
    "StartNegateTargetEvasionStatStageAndGhostImmunity", # Foresight, Odor Sleuth
    "StartNegateTargetEvasionStatStageAndDarkImmunity",  # Miracle Eye
    "SleepTarget",                                    	 # Sleep Powder, Spore
    "SleepTargetNextTurn",                               # Yawn
    "ParalyzeTarget",                                    # Glare, Stun Spore
    "ParalyzeTargetIfNotTypeImmune",                     # Thunder Wave
    "BurnTarget",                                        # Will-O-Wisp
    "RaiseTargetAttack2ConfuseTarget",                   # Swagger
    "RaiseTargetSpAtk1ConfuseTarget",                    # Flatter
    "DisableTargetStatusMoves",                          # Taunt
    "StartLeechSeedTarget",                              # Leech Seed
    "TargetNextFireMoveDamagesTarget"                    # Powder
    
  ]
  # Moves approved for battlers that prefer physical moves.
  functions.concat([
    "RaiseUserAtkDef1",                                  # Bulk Up
    "RaiseUserAtkSpd1",                                  # Dragon Dance
    "RaiseUserAtkSpd1RemoveHazardsSubstitutes",          # Tidy Up
    "RaiseUserAtk1Spd2",                                 # Shift Gear
    "RaiseUserAtkAcc1",                                  # Hone Claws
    "RaiseUserAtkDefAcc1",                               # Coil
    "RaiseUserAtkDefSpd1"                                # Victory Dance
  ]) if [nil, 0].include?(category)
  # Moves approved for battlers that prefer special moves.
  functions.concat([
    "RaiseUserSpAtkSpDef1",                              # Calm Mind
    "RaiseUserSpAtkSpDef1CureStatus",                    # Take Heart
    "RaiseUserSpAtkSpDefSpd1",                           # Quiver Dance
  ]) if [nil, 1].include?(category)
  return functions
end

#-------------------------------------------------------------------------------
# Status moves approved for rental battlers during raid battles.
#-------------------------------------------------------------------------------
def raid_whitelist_functions_rental(category)
  functions = [
    "RaiseUserSpeed2",                                   # Agility, Rock Polish
    "RaiseUserSpeed2LowerUserWeight",                    # Autotomize
    "RaiseUserEvasion1",                                 # Double Team
    "RaiseUserEvasion2MinimizeUser",                     # Minimize
    "LowerUserDefSpDef1RaiseUserAtkSpAtkSpd2",           # Shell Smash
    "RaiseUserAtkSpAtkSpeed2LoseHalfOfTotalHP",          # Fillet Away
    "RaiseUserMainStats1TrapUserInBattle",               # No Retreat
    "RaiseUserMainStats1LoseThirdOfTotalHP",             # Clangorous Soul
    "RaiseUserCriticalHitRate2",                         # Focus Energy
    "RaiseAlliesCriticalHitRate1DragonTypes2",           # Dragon Cheer
    "EnsureNextCriticalHit",                             # Laser Focus
    "RaiseGrassBattlersDef1",                            # Flower Shield
    "RaiseTargetSpDef1",                                 # Aromatic Mist
    "RaiseUserAndAlliesAtkDef1",                         # Coaching
    "RaiseGroundedGrassBattlersAtkSpAtk1",               # Rototiller
    "RaiseTargetAtkSpAtk2",                              # Decorate
    "RaiseTargetAtkLowerTargetDef2",                     # Spicy Extract
    "RaiseTargetRandomStat2",                            # Acupressure
    "LowerTargetAttack2",                                # Charm, Feather Dance
    "LowerTargetDefense2",                               # Screech
    "LowerTargetSpAtk2",                                 # Eerie Impulse
    "LowerTargetSpDef2",                                 # Metal Sound, Fake Tears
    "LowerTargetAccuracy1",                              # Flash, Smokescreen, etc.
    "LowerTargetEvasion1RemoveSideEffects",              # Defog
    "LowerTargetEvasion2",                               # Sweet Scent
    "UserTargetAverageBaseAtkSpAtk",                     # Power Split
    "UserTargetSwapAtkSpAtkStages",                      # Power Swap
    "UserSwapBaseAtkDef",                                # Power Trick, Power Shift
    "UserTargetAverageBaseDefSpDef",                     # Guard Split
    "UserTargetSwapDefSpDefStages",                      # Guard Swap
    "UserTargetSwapBaseSpeed",                           # Speed Swap
    "UserTargetSwapStatStages",                          # Heart Swap
    "UserCopyTargetStatStages",                          # Psych Up
    "PowerUpAllyMove",                                   # Helping Hand
    "StartUserAirborne",                                 # Magnet Rise
    "UserEnduresFaintingThisTurn",                       # Endure
    "UserMakeSubstitute",                                # Substitute
    "StartHealUserEachTurn",                             # Aqua Ring
    "StartHealUserEachTurnTrapUserInBattle",             # Ingrain
    "HealUserHalfOfTotalHP",                             # Recover, Milk Drink, etc.
    "HealUserHalfOfTotalHPLoseFlyingTypeThisTurn",       # Roost
    "CureTargetStatusHealUserHalfOfTotalHP",             # Purify
    "HealUserDependingOnWeather",                        # Morning Sun, Synthesis, etc.
    "HealUserDependingOnSandstorm",                      # Shore Up
    "HealTargetDependingOnGrassyTerrain",                # Floral Healing
    "HealUserPositionNextTurn",                          # Wish
    "HealUserByTargetAttackLowerTargetAttack1",          # Strength Sap
    "HealTargetHalfOfTotalHP",                           # Heal Pulse
    "HealUserAndAlliesQuarterOfTotalHP",                 # Life Dew
    "HealUserAndAlliesQuarterOfTotalHPCureStatus",       # Jungle Healing, Lunar Blessing
    "CureUserBurnPoisonParalysis",                       # Refresh
    "CureUserPartyStatus",                               # Heal Bell, Aromatherapy
    "GiveUserStatusToTarget",                            # Psycho Shift
    "StartUserSideImmunityToInflictedStatus",            # Safeguard
    "ProtectUser",                                       # Protect, Detect
    "ProtectUserBanefulBunker",                          # Baneful Bunker
    "ProtectUserBurningBulwark",                         # Burning Bulwark
    "ProtectUserFromTargetingMovesSpikyShield",          # Spiky Shield
    "ProtectUserFromDamagingMovesKingsShield",           # King's Shield
    "ProtectUserFromDamagingMovesObstruct",              # Obstruct
    "ProtectUserFromDamagingMovesSilkTrap",              # Silk Trap
    "ProtectUserSideFromDamagingMovesIfUserFirstTurn",   # Mat Block
    "ProtectUserSideFromMultiTargetDamagingMoves",       # Wide Guard
    "StartWeakenPhysicalDamageAgainstUserSide",          # Reflect
    "StartWeakenSpecialDamageAgainstUserSide",           # Light Screen
    "StartUserSideImmunityToStatStageLowering",          # Mist
    "StartPreventCriticalHitsAgainstUserSide",           # Lucky Chant
    "StartUserSideDoubleSpeed",                          # Tailwind
    "SwapSideEffects",                                   # Court Change
    "NegateTargetAbility",                               # Gastro Acid
    "SetTargetAbilityToSimple",                          # Simple Beam
    "SetTargetAbilityToInsomnia",                        # Worry Seed
    "SetTargetAbilityToUserAbility",                     # Entrainment
    "SetUserAbilityToTargetAbility",                     # Role Play
    "UserTargetSwapAbilities",                           # Skill Swap
    "SetUserAlliesAbilityToTargetAbility",               # Doodle
    "TargetMovesBecomeElectric",                         # Electrify
    "NormalMovesBecomeElectric",                         # Ion Deluge
    "TargetActsNext",                                    # After You
    "TargetActsLast",                                    # Quash
    "UseMoveTargetIsAboutToUse",                         # Me First
    "UseLastMoveUsed",                                   # Copycat
    "TargetUsesItsLastUsedMoveAgain",                    # Instruct
    "RedirectAllMovesToTarget",                          # Spotlight
    "RedirectAllMovesToUser"                             # Follow Me, Rage Powder
  ]
  # Moves approved only for rental battlers that prefer physical moves.
  functions.concat([
    "RaiseUserAttack2",                                  # Swords Dance
    "MaxUserAttackLoseHalfOfTotalHP"                     # Belly Drum
  ]) if [nil, 0].include?(category)
  # Moves approved only for rental battlers that prefer special moves.
  functions.concat([
    "RaiseUserSpAtk2",                                   # Nasty Plot
    "RaiseUserSpAtk3"                                    # Tail Glow
  ]) if [nil, 1].include?(category)
  return functions
end

#-------------------------------------------------------------------------------
# Status moves approved for raid bosses during raid battles.
#-------------------------------------------------------------------------------
def raid_whitelist_functions_boss
  return [
    "RaiseTargetAttack1",                                # Howl, Meditate, etc.
    "RaiseUserDefense1",                                 # Harden, Withdraw
    "RaiseUserDefense1CurlUpUser",                       # Defense Curl
    "LowerTargetAttack1",                                # Growl, Baby-Doll Eyes
    "LowerTargetAttack1BypassSubstitute",                # Play Nice
    "LowerTargetDefense1",                               # Leer, Tail Whip
    "LowerTargetSpAtk1",                                 # Confide
    "PoisonTarget",                                      # Poison Powder, Poison Gas
    "PoisonTargetLowerTargetSpeed1",                     # Toxic Thread
    "BadPoisonTarget",                                   # Toxic
    "ConfuseTarget",                                     # Confuse Ray, Teeter Dance
    "DisableTargetLastMoveUsed",                         # Disable
    "DisableTargetHealingMoves",                         # Heal Block
    "DisableTargetUsingDifferentMove",                   # Encore
    "DisableTargetUsingSameMoveConsecutively",           # Torment
    "CorrodeTargetItem"                                  # Corrosive Gas
  ]
end

#===============================================================================
# Gets all function codes for eligible status moves to be used as Support Moves.
# Raid bosses can only uses these moves as Support Moves.
#===============================================================================
def pbRaidSupportMoves
  return [
    "StartSunWeather",                                   # Sunny Day
    "StartRainWeather",                                  # Rain Dance
    "StartSandstormWeather",                             # Sandstorm
    "StartHailWeather",                                  # Hail, Snowscape
    "StartElectricTerrain",                              # Electric Terrain
    "StartGrassyTerrain",                                # Grassy Terrain
    "StartPsychicTerrain",                               # Psychic Terrain
    "StartMistyTerrain",                                 # Misty Terrain
    "StartWeakenFireMoves",                              # Water Sport
    "StartWeakenElectricMoves",                          # Mud Sport
    "StartNegateHeldItems",                              # Magic Room
    "StartSlowerBattlersActFirst",                       # Trick Room
    "StartSwapAllBattlersBaseDefensiveStats",            # Wonder Room
    "StartGravity",                                      # Gravity
    "StartWeakenPhysicalDamageAgainstUserSide",          # Reflect
    "StartWeakenSpecialDamageAgainstUserSide",           # Light Screen
    "StartWeakenDamageAgainstUserSideIfHail",            # Aurora Veil
    "StartUserSideImmunityToStatStageLowering",          # Mist
    "StartPreventCriticalHitsAgainstUserSide",           # Lucky Chant
    "StartUserSideDoubleSpeed",                          # Tailwind
    "AddStickyWebToFoeSide",                             # Sticky Web
    "AddStealthRocksToFoeSide",                          # Stealth Rock
    "AddSpikesToFoeSide",                                # Spikes
    "AddToxicSpikesToFoeSide",                           # Toxic Spikes
    "SwapSideEffects",                                   # Court Change
    "LowerTargetEvasion1RemoveSideEffects",              # Defog
    "StartHealUserEachTurn",                             # Aqua Ring
    "StartHealUserEachTurnTrapUserInBattle",             # Ingrain
    "HealUserDependingOnUserStockpile",                  # Swallow
    "PowerDependsOnUserStockpile",                       # Spit Up
    "StartUserAirborne",                                 # Magnet Rise
    "TwoTurnAttackRaiseUserSpAtkSpDefSpd2",              # Geomancy
    "RaiseUserMainStats1TrapUserInBattle",               # No Retreat
    "UserSwapBaseAtkDef",                                # Power Trick, Power Shift
    "RaiseUserCriticalHitRate2",                         # Focus Energy
    "EnsureNextCriticalHit",                             # Laser Focus
    "DisableTargetHealingMoves",                         # Heal Block
    "LowerPPOfTargetLastMoveBy4",                        # Spite
    "LowerPoisonedTargetAtkSpAtkSpd1",                   # Venom Drench
    "StartTargetAirborneAndAlwaysHitByMoves",            # Telekinesis
    "TargetActsLast",                                    # Quash
    "DisableTargetMovesKnownByUser",                     # Imprison
    "UseRandomMove"                                      # Metronome
  ]
end

#===============================================================================
# GameData::Species utilities for generating raid movesets.
#===============================================================================
module GameData
  class Species
    #---------------------------------------------------------------------------
    # Gets certain moves that should always be in a raid battler's move pool.
    # Overrides blacklist and all other raid move filters.
    #---------------------------------------------------------------------------
    # signature: This move will *always* be included in the battler's moveset.
    # primary:   Adds this move to the pool of randomly selected STAB options.
    # secondary: Adds this move to the pool of randomly selected secondary STAB options.
    # other:     Adds this move to the pool of randomly selected non-STAB options.
    # status:    Adds this move to the pool of randomly selected status moves.
    # spread:    Adds this move to the pool of potential spread moves to be used as an Extra Action.
    # support:   Adds this move to the pool of potential support moves to be used as an Extra Action.
    #---------------------------------------------------------------------------
    def getSignatureMoves
      case @species
      when :TAUROS      then return { signature: :RAGINGBULL }
      when :WOBBUFFET   then return { primary:   :COUNTER, 
                                      secondary: :MIRRORCOAT }
      when :SLAKING     then return { primary:   :GIGAIMPACT }
      when :CASTFORM    then return { signature: :WEATHERBALL }
      when :WYNAUT      then return { primary:   :COUNTER, 
                                      secondary: :MIRRORCOAT }
      when :DARKRAI     then return { support:   :DARKVOID }
      when :ARCEUS      then return { signature: :JUDGMENT }
      when :ACCELGOR    then return { other:     :WATERSHURIKEN }
      when :GENESECT    then return { other:     :TECHNOBLAST }
      when :GRENINJA    then return { secondary: :WATERSHURIKEN }
      when :AEGISLASH   then return { signature: :KINGSSHIELD }
      when :ORICORIO    then return { signature: :REVELATIONDANCE }
      when :SILVALLY    then return { signature: :MULTIATTACK }
      when :CRAMORANT   then return { signature: :DIVE,
                                      spread:    :SURF }
      when :MORPEKO     then return { signature: :AURAWHEEL }
      when :DRAGAPULT   then return { spread:    :DRAGONDARTS }
      when :ZACIAN      then return { signature: :IRONHEAD }
      when :ZAMAZENTA   then return { signature: :IRONHEAD }
      when :KLEAVOR     then return { secondary: :STONEAXE }
      when :OVERQWIL    then return { secondary: :BARBBARRAGE }
      when :MEOWSCARADA then return { secondary: :FLOWERTRICK }
      when :MAUSHOLD    then return { secondary: :POPULATIONBOMB }
      when :GARGANACL   then return { secondary: :SALTCURE }
      when :ANNIHILAPE  then return { secondary: :RAGEFIST }
      when :DIPPLIN     then return { secondary: :SYRUPBOMB }
      when :OGERPON     then return { signature: :IVYCUDGEL }
      when :HYDRAPPLE   then return { secondary: :SYRUPBOMB }
      when :RAGINGBOLT  then return { secondary: :RISINGVOLTAGE }
      when :TERAPAGOS   then return { signature: :TERASTARSTORM }
      end
      # Form-specific moves.
      case @id
      when :ROTOM_1     then return { signature: :OVERHEAT }
      when :ROTOM_2     then return { signature: :HYDROPUMP }
      when :ROTOM_3     then return { signature: :BLIZZARD }
      when :ROTOM_4     then return { signature: :AIRSLASH }
      when :ROTOM_5     then return { signature: :LEAFSTORM }
      when :SAMUROTT_1  then return { secondary: :CEASELESSEDGE }
      when :ZOROARK_1   then return { secondary: :BITTERMALICE }
      when :STUNFISK_1  then return { secondary: :SNAPTRAP }
      when :URSHIFU     then return { signature: :WICKEDBLOW }
      when :URSHIFU_1   then return { signature: :SURGINGSTRIKES }
      end
      return {}
    end
	
    #---------------------------------------------------------------------------
    # Compiles all eligible raid moves a species may have.
    #---------------------------------------------------------------------------
    def compileRaidMoves(style, rental = false, category = nil, style_criteria = nil)
      #-------------------------------------------------------------------------
      # Determines whether this species prefers physical or special moves.
      if !category
        if @base_stats[:ATTACK] > @base_stats[:SPECIAL_ATTACK] + 25
          category = 0
        elsif @base_stats[:SPECIAL_ATTACK] > @base_stats[:ATTACK] + 25
          category = 1
        end
      end
      #-------------------------------------------------------------------------
      # Compiles raid moves.
      blacklist = pbRaidBannedMoves(rental)
      whitelist = pbRaidApprovedStatusMoves(category, rental)
      raid_moves = Hash.new { |key, value| key[value] = [] }
      sig_moves = self.getSignatureMoves
      if style_criteria && style == :Ultra
        raid_moves[:primary] = [style_criteria]
      end
      get_family_moves.each do |m|
        next if sig_moves.values.include?(m)
        move = GameData::Move.get(m)
        next if blacklist.include?(move.function_code)
        next if (1..60).include?(move.accuracy)
        next if style == :Ultra && style_criteria == move.id
        #-----------------------------------------------------------------------
        # Compiles eligible status and support moves.
        if move.status?
          if !rental && pbRaidSupportMoves.include?(move.function_code)
            raid_moves[:support] << move.id
          elsif whitelist.include?(move.function_code)
            raid_moves[:status] << move.id
          end
          next
        end
        #-----------------------------------------------------------------------
        # Checks for eligible move category.
        if ![
            "UseUserDefenseInsteadOfUserAttack",               # Body Press
            "CategoryDependsOnHigherDamagePoisonTarget",       # Shell Side Arm
            "CategoryDependsOnHigherDamageIgnoreTargetAbility" # Photon Geyser
          ].include?(move.function_code)
          case category
          when 0 then next if move.special?
          when 1 then next if move.physical?
          end
        end
        #-----------------------------------------------------------------------
        # Compiles eligible spread moves.
        if [:AllNearFoes, :AllNearOthers].include?(move.target) && !rental
          raid_moves[:spread] << move.id if move.power >= 50
          next
        else
          next if move.target == :AllNearOthers
        end
        #-----------------------------------------------------------------------
        # Checks for eligible multi-hit moves.
        if [
            "HitTwoToFiveTimes",                               # Pin Missile, Arm Thrust, etc.
            "HitTwoToFiveTimesRaiseUserSpd1LowerUserDef1",     # Scale Shot
            "HitTwoToFiveTimesOrThreeForAshGreninja",          # Water Shuriken
            "HitThreeTimesPowersUpWithEachHit",                # Triple Kick, Triple Axel
            "HitTenTimes"                                      # Population Bomb
          ].include?(move.function_code)
          next if move.power < 25
        elsif [
            "HitTwoTimes",                                     # Dual Chop, Dual Wingbeat, etc.
            "HitTwoTimesFlinchTarget",                         # Double Iron Bash
            "HitTwoTimesTargetThenTargetAlly"                  # Dragon Darts
          ].include?(move.function_code)
          next if move.power < 35
        elsif [
            "HitThreeTimes",                                   # Triple Dive
            "HitThreeTimesAlwaysCriticalHit"                   # Surging Strikes
          ].include?(move.function_code)
          next if move.power < 25
        #-----------------------------------------------------------------------
        # Checks for moves with an eligible base power.
        elsif move.priority > 0
          next if move.power < 40  # Moves with increased priority must have at least 40 Power.
        else
          next if move.power < 55  # All other moves must have at least 55 Power.
        end
        #-----------------------------------------------------------------------
        # Compiles all eligible moves.
        if style == :Tera && style_criteria == move.type
          raid_moves[:primary] << move.id  # Moves that match the user's Tera type (Tera Raids only).
        elsif @types.include?(move.type)
          key = (move.power < 80) ? :secondary : :primary
          case style
          when :Ultra then key = :secondary if style_criteria
          when :Tera  then key = (key == :primary) ? :secondary : :other
          end
          raid_moves[key] << move.id       # Moves that match the user's base typing.
        elsif move.type != :NORMAL || move.priority > 0
          raid_moves[:other] << move.id    # All other moves (Normal-type moves excluded for more variety).
        end
      end
      #-------------------------------------------------------------------------
      # Applies species-specific signature moves, if any.
      sig_moves.each do |key, move|
        next if !GameData::Move.exists?(move)
        next if raid_moves[key].include?(move)
        raid_moves[key] << move
      end
      #-------------------------------------------------------------------------
      # Ensures raid bosses have support moves to select from.
      if !rental && !raid_moves.has_key?(:support) && raid_moves.has_key?(:status)
        raid_moves[:support] = raid_moves[:status].clone
      end
      return raid_moves
    end
  end
end