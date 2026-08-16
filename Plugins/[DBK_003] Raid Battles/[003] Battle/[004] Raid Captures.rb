#===============================================================================
# Aliases how Raid Pokemon are captured and stored.
#===============================================================================
module Battle::CatchAndStoreMixin
  alias raid_pbStorePokemon pbStorePokemon
  def pbStorePokemon(pkmn)
    if pkmn.immunities.include?(:RAIDBOSS) && @raidStyleCapture && !@caughtPokemon.empty?
      pkmn.resetRaidAttributes(@raidRules[:style], @raidRules[:rank])
      if pbInRaidAdventure?
        pbRaidAdventureState.captures.push(pkmn)
        pbDisplay(_INTL("Caught {1}!", pkmn.name))
      else
        stored_box = $PokemonStorage.pbStoreCaught(pkmn)
        box_name = @peer.pbBoxName(stored_box)
        pbDisplayPaused(_INTL("{1} has been sent to Box \"{2}\"!", pkmn.name, box_name))
      end
    else
      raid_pbStorePokemon(pkmn)
    end
  end
  
  alias raid_pbRecordAndStoreCaughtPokemon pbRecordAndStoreCaughtPokemon
  def pbRecordAndStoreCaughtPokemon
    if pbInRaidAdventure?
      @caughtPokemon.each { |pkmn| pbStorePokemon(pkmn) }
      @caughtPokemon.clear
    else
      raid_pbRecordAndStoreCaughtPokemon
    end
  end
end