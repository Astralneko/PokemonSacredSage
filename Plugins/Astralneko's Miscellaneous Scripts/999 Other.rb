#=====================================================================================
# NOTE FOR FUTURE ASTRALNEKO:
# These are not to be included in future versions of ANMS plugin.
# Exclude this file when creating them.
#=====================================================================================

# Deprecated: Will replace with a better version later.
# Set encounter table
#Events.onMapChange += proc { |_sender, e|
#  $PokemonGlobal.encounter_version = 0
#  $PokemonGlobal.encounter_version = pbGetSeason
#  $PokemonGlobal.encounter_version += $game_variables[27] * 4
#}

# Freeze becomes frostbite
EventHandlers.add(:on_end_battle, :revert_freeze,
  proc { |_decision, _canLose|
		$player.party.each do |pkmn|
			pkmn.status = :FROSTBITE if pkmn.status == :FREEZE
		end
  }
)

# When the player moves to a new map, step them forward if they're coming from Map Glitch maps. (Route 4 North, Alipigra City)
# Map Glitch: When moving onto certain maps, the map visually glitches and shows a different area for 1 frame for some bizarre reason. Can't figure out why, but this soft fix makes it not happen so
#EventHandlers.add(:on_enter_map, :map_glitch_hotfix,
# proc { |oldMapID|
#		newMapID = $game_map.map_id
#		# Map Glitch only occurs when walking through a map connection.
#		# On load, oldMapID and newMapID are the same.
#		next if oldMapID == newMapID
#		glitchedMaps = [14, # Route 4 North
#						        33  # Alipigra City
#		]
#		next if !glitchedMaps.include?(oldMapID)
#		$game_player.move_forward
#	}
#)
# Note: This soft fix is not perfect. The player will attempt to move forward again if they enter a door on a map glitch map, because this function is called when walking into a door. Map Glitch doesn't occur in that case.
# I might be able to use the transition flag to tell it not to run on doors. However, it's probably better to just actually find the root of the glitch and patch it.

# Remove overworld shadows from all events if applicable. @Maruno fix your gd "shaders" in PE22
def anToggleAllEventTransparency
	for event in $game_map.events.values
		event.transparent = !event.transparent if event != $game_player 
	end
end

def anHasDynamaxBand?
	if defined?(Settings::DMAX_BANDS)
		Settings::DMAX_BANDS.each { |item| return true if $bag.pbHasItem?(item) }
	end
	return false
end

# Decides a random nickname or the species name
def anDecideNickname(speciesDefaultName = "Magikarp", nickArray = ["Psycho"])
	nickNum = rand(10 + nickArray.size) # 10 + number of nicks in the array
	nick = speciesDefaultName
	nick = nickArray[nickNum-10] if nickNum > 10
	return nick
end

# Determines a Vivillon form based on the gamemap
# Vivillon form data is in the config
def anVivillonFormDeterminer
	if $game_map
		curform = 0
		for map_list in Astralneko_Config::VIVILLON_FORMS
			curform = map_list if !map_list.is_a?(Array) # if this isn't an array, this is a form ID
			next if !map_list.is_a?(Array) # the rest of this section assumes array
			for map in map_list
				return curform if $game_map.map_id == map
			end
		end
	end
	# If on an invalid map, use secret ID as a placeholder
	return $player.secret_ID % 18
end

#Events.onTrainerPartyLoad += proc { |_sender, trainer|
#  if trainer   # An NPCTrainer object containing party/items/lose text, etc.
#    if (trainer[0].trainer_type==:GHOST || $game_switches[63])  #the clone trainer type
#      partytoload=$Trainer.party
#      for i in 0...6
#        if i<$Trainer.party_count && !partytoload[i].egg?
#          trainer[0].party[i]=partytoload[i].clone
#          trainer[0].party[i].heal     #remove this comment to make a perfectly healed
#        else                            #copy of the party
#          trainer[0].party.pop()
#        end
#      end
#    end
#  end
#}

def anHasPokemonUprising
	return pbSaveTest("Pokemon Uprising","Exist",nil,18)
end