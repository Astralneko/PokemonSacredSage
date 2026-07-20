#===============================================================================
# Astaryuu's Midbattle Scripts
#===============================================================================
# This module stores all custom battle scripts that can be called upon with the
# battle rule "midbattleScript" if you don't want to input the entire script in
# the event script itself, due to it being too long or if you just find it neater
# this way.
#
# Note that when calling one of the scripts here, you do so in the event by
# setting the constant you defined here as a battle rule.
#
# 	For example:  
#   setBattleRule("midbattleScript", :DEMO_SPEECH)
#
#   *Note that a semi-colon is required in front of the constant when called, 
#    but not when defined below.
#-------------------------------------------------------------------------------
module MidbattleScripts
	#-----------------------------------------------------------------------------
	# Natsuki's first battle script
	#-----------------------------------------------------------------------------
	Natsuki_1 = {
		#---------------------------------------------------------------------------
		# Turn 1
		"RoundStartCommand_1_foe" => "It's our first battle, \\PN...Let's do this! Go, {1}!",
		#---------------------------------------------------------------------------
		# Opponent low on HP and has no remaining ally Pokémon
		"LastTargetHPHalf_foe" => ["This is bad...",
				"{1}, hang in there!"],
		#---------------------------------------------------------------------------
		# Player low on HP and has no remaining ally Pokémon
		"LastTargetHPHalf_player" => [:Opposing, "{1}, we're almost there! Just gotta finish it strong!"]
	}
	
	#-----------------------------------------------------------------------------
	# Mona's first battle script
	#-----------------------------------------------------------------------------
	Mona_1 = {
		#---------------------------------------------------------------------------
		# Turn 1
		"RoundStartCommand_1_foe" => {
			"speech" => "Gotta think of a good battle opener if I'm gonna make it big doing this...",
			"setVariable" => 0,
		},
		#---------------------------------------------------------------------------
		# Activated if the player has less than 2 able Pokémon
		"VariableUnder_2" => ["Wait, \\PN, you're supposed to bring 2 Pokémon to a double battle!",
				"This doesn't feel like those televised battles at all..."],
		#---------------------------------------------------------------------------
		# Opponent low on HP and has no remaining ally Pokémon
		"LastTargetHPHalf_foe" => "It's down to the wire... C'mon! {1}!",
		#---------------------------------------------------------------------------
		# Player uses an item
		"BeforeItemUse_player" => "Hey! I forgot to pack my bag... Come on, \\PN...",
		#---------------------------------------------------------------------------
		# Player loses the battle - according to the other example events, this does not need setBattler
		"BattleEndLoss" => "I won? ...I won! Yes!"
	}
	
	#-----------------------------------------------------------------------------
	# Gym Leader Aria
	#-----------------------------------------------------------------------------
	GYMLEADER_Aria = {
		#---------------------------------------------------------------------------
		# Turn 1
		"RoundStartCommand_1_foe" => {
			"speech_A" => ["The first thing you need to know... is how to move quickly!",
					"You know, something like this!"],
			"useItem" => :XSPEED2,
			"speech_B" => "Alright, let's do this!",
		},
		#---------------------------------------------------------------------------
		# Opponent just sent out their last Pokémon
		"AfterLastSendOut_foe" => {
			"setSpeaker" => :Self,
			"changeBGM"  => "ARS_Battle_Gym Leader 2",
			"speech" => "Crap... \\PN might win this..."
		},
		#---------------------------------------------------------------------------
		# Player just sent out their last Pokémon
		"AfterLastSendOut_player" => [:Opposing, "{1}, you've got this! Finish it strong!"]
	}
	
	#-----------------------------------------------------------------------------
	# Sorrel's first battle script
	#-----------------------------------------------------------------------------
	Sorrel_1 = {
		#---------------------------------------------------------------------------
		# Before using a Z-Move
		"BeforeZMove_foe" => ["\\PN, is it...?",
				"Well, regardless, prepare to feel my Pokémon's innate power!"],
		#---------------------------------------------------------------------------
		# Opponent takes their first attack
		"TargetDealtDamage_foe" => "{1}! Shake it off!"
	}
	
	#-----------------------------------------------------------------------------
	# Gym Leader Desiree
	#-----------------------------------------------------------------------------
	GYMLEADER_Desiree = {
		#---------------------------------------------------------------------------
		# Turn 1
		"RoundStartCommand_1_foe" => {
			"speech_A" => "The most important thing is to be patient!",
			"useItem" => :XDEFENSE2,
			"speech_B" => "Slow and steady!",
		},
		#---------------------------------------------------------------------------
		# Opponent just sent out their last Pokémon
		"AfterLastSendOut_foe" => {
			"setSpeaker" => :Self,
			"changeBGM"  => "ARS_Battle_Gym Leader 2",
			"speech" => "\\PN, you're doing good! But I'm not done yet!"
		},
		#---------------------------------------------------------------------------
		# Player just sent out their last Pokémon
		"AfterLastSendOut_player" => [:Opposing, "Alright {1}... Finish them!"],
		#---------------------------------------------------------------------------
		# Opponent about to Terastallize
		"BeforeTerastallize_foe" => ["Wahaha! Time for a surprise...",
				"{1}, let's show this Trainer our power! Terastalize!"]
	}
	
	#-----------------------------------------------------------------------------
	# Mona's second battle script
	#-----------------------------------------------------------------------------
	Mona_2 = {
		#---------------------------------------------------------------------------
		# Turn 1 - Used entirely to check for able_pokemon_count again
		"RoundStartCommand_1_foe" => {
			"setVariable" => 0,
		},
		#---------------------------------------------------------------------------
		# Activated if the player has less than 2 able Pokémon
		"VariableUnder_2" => "Man, \\PN, going solo? You trying to challenge yourself?",
		#---------------------------------------------------------------------------
		# Opponent low on HP and has no remaining ally Pokémon
		"LastTargetHPHalf" => "It's down to the wire... C'mon! {1}!",
		#---------------------------------------------------------------------------
		# Player about to Terastallize
		"BeforeTerastallize_player" => [:Opposing, "H-huh?! What's that do, \\PN?!"],
		#---------------------------------------------------------------------------
		# User loses the battle - according to the other example events, this does not need setBattler
		"BattleEndLoss" => "...huh. Better hope they aren't too tough, then."
	}
	
	#-----------------------------------------------------------------------------
	# Natsuki's second battle script
	#-----------------------------------------------------------------------------
	Natsuki_2 = {
		#---------------------------------------------------------------------------
		# Turn 1
		"RoundStartCommand_1_foe" => ["Whew... I know you're strong from our battles together, \PN...",
				"Let's go, {1}!"],
		#---------------------------------------------------------------------------
		# Opponent low on HP and has no remaining ally Pokémon
		"LastTargetHPHalf_foe" => ["This is bad...",
				"{1}, hang in there!"],
		#---------------------------------------------------------------------------
		# Player low on HP and has no remaining ally Pokémon
		"LastTargetHPHalf_player" => [:Opposing, "Time to finish this, {1}!"],
		#---------------------------------------------------------------------------
		# Opponent about to Terastallize
		"BeforeTerastallize_foe" => "Well... Time to try this! {1}! Terastalize!",
		#---------------------------------------------------------------------------
		# Player about to Terastallize
		"BeforeTerastallize_player" => "Nice, \PN! Looks like I'll have to step it up..."
	}
	
	#-----------------------------------------------------------------------------
	# Professor Turo examples
	#-----------------------------------------------------------------------------
	PROFESSOR_Turo_1 = {
		"RoundStartCommand_1_foe" => "I dɵn’t know whɵ you thιnk you ɑrə, but |’m not about tɵ let ɑnyonɜ get ιn the way of мy goɑls.",
		"AfterDamagingMove_foe" => ["Thιs is thɜ poweɹ thə dis7ɑnt futurɜ hɵ|ds.",
				"5plendιd, isn’t ιt?"],
		"TargetWeakToMove_player" => [:Opposing,"Dɵ you imɑgine you cɑn best thɜ wealth ɵf dɑta at my dιsposɑl with your huмan braιnʡ"],
		"TargetWeakToMove_foe" => ["N0w, thιs is ιntere5ting...",
				"Chiլd, dɵ you aɔtually undeɹstɑnd futurɜ Pokéмon’s weaknɜsses?"],
		"UserDealtCriticalHit_player" => [:Opposing,"Whɑt?! Some sort of ərror has occurred here...",
				:Opposing,"Recɑլculatıng for crıticɑl δamagə..."],
		"UserDealtCriticalHit_foe" => ["Just ɑs calculatəd: a criticaլ hit tɵ your Pokémoդ.",
				"|t’s tıme you simply gɑve up, chiլd."],
		"AfterLastSendOut_foe" => ["Єveɹything is proceədin6 wιthin my expectatiɵns.",
				"I’m afraid thɜ probabιlity ɵf you wιnning is zero."]
	}
	# Note: the transfer from Turo to the Miraidon boss battle would have to occur in eventing
	# The eventing requirement also applies the special effects (namely, battle rules cannotSwitch, setStyle)
	PROFESSOR_Turo_2 = {
		"RoundStartCommand_1_foe" => {
			"speech" => "You wιll falլ herɜ, withιn this gɑrden paradisɜ—and aɔhiɜve n█thıng in the ɜnd.",
			"endSpeech" => true,
			"text_A" => "The Paradise Protection Protocol ran a program...",
			"changeWeather" => "Glitch",
			"text_B" => "All Poké Balls except those containing a Pokémon caught in the Zero Lab were disabled!",
			"disableBalls" => true
		},
		"RoundStartCommand_2_foe" => "Yoʊ wιll not be ɑlloweδ to dɜstroy мy parɑdise. Өbstaclɜs t█ my goɑls WILL be elιminatɜd.",
		"RoundStartCommand_3_foe" => "The dɑta say | am the suƿerior. Fɑlլ, and beɔome a fouդdɑtιon upon щhιch my δreɑm may be bμilt."
	}
end