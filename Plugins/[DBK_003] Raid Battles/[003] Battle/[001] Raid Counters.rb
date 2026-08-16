#===============================================================================
# General additions to the Battle class.
#===============================================================================
class Battle
  attr_accessor :raidRules
  
  #-----------------------------------------------------------------------------
  # Aliased to initialize new battle properties.
  #-----------------------------------------------------------------------------
  alias raid_initialize initialize
  def initialize(*args)
    raid_initialize(*args)
    @raidRules = {}
  end
  
  #-----------------------------------------------------------------------------
  # Utility for updating the raid turn counter.
  #-----------------------------------------------------------------------------
  def pbRaidChangeTurnCount(battler, amt)
    return if !battler || battler.fainted? || !battler.isRaidBoss?
    return if !@raidRules[:turn_count] || @raidRules[:turn_count] < 0
    oldCount = @raidRules[:turn_count]
    @raidRules[:turn_count] += amt if @raidRules[:turn_count] > 0
    @raidRules[:turn_count] = 0 if @raidRules[:turn_count] < 0
    @raidRules[:raid_turnCount] = @turnCount
    PBDebug.log("[Raid mechanics] Raid turn counter changed (#{oldCount} => #{@raidRules[:turn_count]})")
    @scene.pbRefreshOne(battler.index)
    return if @raidRules[:turn_count] > 0
    return if pbAllFainted? || @decision > 0
    pbDisplayPaused(_INTL("The energy around {1} grew out of control!", battler.pbThis(true)))
    pbDisplay(_INTL("You were blown out of the den!"))
    pbRaidAdventureState.hearts = 0 if pbInRaidAdventure?
    @scene.pbAnimateFleeFromRaid
    @decision = 3
  end
  
  #-----------------------------------------------------------------------------
  # Utility for updating the raid KO counter.
  #-----------------------------------------------------------------------------
  def pbRaidChangeKOCount(battler, amt, done_fainting)
    return if !battler || battler.fainted? || !battler.isRaidBoss?
    return if !@raidRules[:ko_count] || @raidRules[:ko_count] < 0
    oldCount = @raidRules[:ko_count]
    @raidRules[:ko_count] += amt if @raidRules[:ko_count] > 0
    @raidRules[:ko_count] = 0 if @raidRules[:ko_count] < 0
    if pbInRaidAdventure?
      pbRaidAdventureState.hearts = @raidRules[:ko_count]
      if pbRaidAdventureState.hearts > pbRaidAdventureState.max_hearts
        pbRaidAdventureState.max_hearts = @raidRules[:ko_count]
      end
    end
    PBDebug.log("[Raid mechanics] Raid KO counter changed (#{oldCount} => #{@raidRules[:ko_count]})")
    @scene.pbRefreshOne(battler.index)
    return if amt > 0 || !done_fainting
    case @raidRules[:ko_count]
    when 0 then pbDisplayPaused(_INTL("The energy around {1} grew out of control!", battler.pbThis(true)))
    when 1 then pbDisplay(_INTL("The energy around {1} is growing too strong to withstand!", battler.pbThis(true)))
    else        pbDisplay(_INTL("The energy around {1} is growing stronger!", battler.pbThis(true)))
    end
    return if @raidRules[:ko_count] > 0 || pbAllFainted? || @decision > 0
    pbDisplay(_INTL("You were blown out of the den!"))
    @scene.pbAnimateFleeFromRaid
    @decision = 3
  end
end