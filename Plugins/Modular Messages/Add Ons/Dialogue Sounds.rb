# Sets the dialogue sound effect sound to the one for the given character (or the dummy one if none is mapped)
def anSetDialogueSound(name)
	echoln name
	for entry in Astralneko_Config::DIALOGUE_SFX
		if entry[0] == name
			DialogueSound.set_sound_effect(entry[1])
			return
		end
	end
	DialogueSound.set_sound_effect("Dialogue/boopSINE2")
end

# Used when there is no xn control in the message
def anDefaultDialogueSound
	DialogueSound.set_sound_effect("Dialogue/boopSINE2")
end

#=============================================================================
# For Dialogue Sounds
#-------------------------------
# Control Handlers: Dialogue Sounds
Modular_Messages::Controls.add("ds", {
  "before_appears" => proc { |hash, param|
	anSetDialogueSound(param)
  }
})
# Note: ds is unnecessary if xn is in the message and the param for ds were to match it, as xn itself has been modified to run anSetDialogueSound.
# This also means ds needs to be placed after xn.