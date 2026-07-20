#==================================================================================================#
#                                        SOUNDS--ON--STEP
#                                          By Astralneko
#==================================================================================================#
# This simply allows for the capability to have sounds on step.
# 
# To actually use, you'll need to define the step sound effect for the tile in
#   the TerrainTag script section, adding the following line to each terraintag:
# :sound_effect           => ["(filename)",(volume),(pitch)]
#   Replace (filename) with a sound file within the SE folder. For example,
# :sound_effect           => ["Step/Grass",100,100]
#   will set the sound effect to Step/Grass, which is recommended for tall grass.
# Replace (volume) with the volume as a percent. 100 is full blast.
# Replace (pitch) with the pitch modifier. 100 is the default.
# These terrain tags *can* be defined here, but this will not work for the default terrain tags.
#
# If the sound effect doesn't need its volume or pitch modified, you can simply
#   remove the array brackets (the []) and define it as:
# :sound_effect           => "Step/Grass"
#
# You will need to place the sound effect for those tiles in the SE folder,
# and set the tiles that should play that sound to the proper TerrainTag.
# 
# By default, the step sound effect will be the provided sound files:
# - Step/Wood if indoors
# - Step/Default if outdoors and the map is not a cave (as defined in map environment metadata)
# - Step/Rock if outdoors and the map is a cave
# Therefore, tiles that should use this sound effect do not need a sound_effect item in TerrainTag.
#
# The sound files do not *need* to be in a Step folder, but they will need to be for the default sounds.
#==================================================================================================#

# Game Variable number that stores what event is treated as the "listener" for Sounds On Step/Default
# This should be whatever event the player is focusing on at this point, or 0 if the player is focusing on the player's event
LISTENING_EVENT_ID_VARIABLE = 28

# Commented out due to needing to include in terraintag script section
#====================================
# Add attr_reader for terrain tag
#====================================
#module GameData
#	class TerrainTag
#		attr_reader :sound_effect
#		
#		alias initialize_old initialize
#		def initialize(hash)
#			initialize_old(hash)
#			@sound_effect = hash[:sound_effect] || false
#		end
#	end
#end

#===================================
# Play defined sound effect
#===================================
EventHandlers.add(:on_step_taken, :play_step_sound, proc { |event|
	# Get the event affected by field movement
	if $game_variables[LISTENING_EVENT_ID_VARIABLE] == 0
		if event == $game_player
			pbPlaySoundEffectEvent($game_player)
		else
			pbPlaySoundEffectEvent(event)
		end
	else
		if event == $game_player
			pbPlaySoundEffectEvent($game_player,get_event_from_id($game_variables[LISTENING_EVENT_ID_VARIABLE]))
		else
			pbPlaySoundEffectEvent(event,get_event_from_id($game_variables[LISTENING_EVENT_ID_VARIABLE]))
		end
	end
})

def pbPlaySoundEffectEvent(event_walking,event_hearing = $game_player)
	event = event_walking   # Get the event affected by field movement
	rel_x = event_hearing.x
	rel_y = event_hearing.y
	pbPlaySoundEffectToLocation(event,rel_x,rel_y)
end

def pbPlaySoundEffectToLocation(event_walking,relative_x,relative_y)
	event = event_walking   # Get the event affected by field movement
	if $scene.is_a?(Scene_Map)
		event.each_occupied_tile do |x, y|
			# Get this tile's sound_effect flag
			sound_effect = $map_factory.getTerrainTag(event.map.map_id, x, y, $PokemonGlobal.bridge > 0).sound_effect
			
			sound_effect_period = 1
			# Convert the flag into the actual values needed
			if sound_effect && sound_effect.is_a?(Array)
				sound_file = sound_effect[0]
				sound_base_volume = sound_effect[1] ? sound_effect[1] : 80
				sound_base_pitch = sound_effect[2] ? sound_effect[2] : 100
				sound_effect_period = sound_effect[3] ? sound_effect[3] : 0
			elsif sound_effect
				sound_file = sound_effect
				sound_base_volume = 80
				sound_base_pitch = 100
			else
				if GameData::MapMetadata.get($game_map.map_id).outdoor_map
					sound_file = "Step/Default"
					sound_base_volume = 80
					sound_base_pitch = 100
				elsif GameData::MapMetadata.get($game_map.map_id).battle_environment == "Cave"
					sound_file = "Step/Rock"
					sound_base_volume = 80
					sound_base_pitch = 100
				else
					sound_file = "Step/Wood"
					sound_base_volume = 45
					sound_base_pitch = 100
				end
			end
			
			# Randomize pitch
			sound_pitch = sound_base_pitch + rand(12) - 6
			
			# Set volume based on absolute distance between source and listener
			distance_x = event_walking.x - relative_x
			distance_y = event_walking.y - relative_y
			absolute_distance = Math.sqrt(distance_x ** 2 + distance_y ** 2)
			if absolute_distance != 0 # Dividing by zero is bad, this only occurs if the step is occuring on the listener's position
				# Volume is logarithmic, but the slider is not
				sound_volume = sound_base_volume / Math.sqrt(absolute_distance)
			else
				sound_volume = sound_base_volume
			end
			
			# If distance > 20/3 blocks, the sound will be basically nonexistent, so don't bother playing it
			if absolute_distance <= 20/3
				if sound_effect_period == 0 || rand(sound_effect_period) == 0
					pbSEPlay(sound_file,sound_volume,sound_pitch)
				end
			end
		end
	end
end