#===============================================================================
# A script that plays an SE for each letter in a message
#
# Usage:
# DialogueSound.enable_sound  - Use this to enable the sound.
# DialogueSound.disable_sound   - Use this to disable the sound. You will need to re-enable
#                                 it again to continue use.
# DialogueSound.set_sound_effect("SE_NAME")  -  You can use this to change the sound used.
#
#
#===============================================================================
module DialogueSound
  @sound_effect_name = "Dialogue/boopSINE"    # This is the default SE for the text.
  @sound_enabled = true              # If it's enabled by default.
  @sound_interval = 2                # This is the number of letters to be 
#                                      displayed before the sound is played.
#                                      This makes it sound more natural.
                                      
  @letter_count = 0                  

  # Adjust sound interval based on player's text speed
  def self.set_sound_interval
    case $PokemonSystem.textspeed
    when 0 # Slow
      @sound_interval = 2
    when 1 # Normal
      @sound_interval = 3
    when 2 # Fast
      @sound_interval = 5
    else
      # Instant  - This one makes no difference. It will play 1 sound for the whole message
      @sound_interval = 2 # Default
    end
  end

  # Reset letter count for a new message
  def self.reset
    @letter_count = 0
    @previous_position = 0
    set_sound_interval
  end

  # Play sound effect at intervals if enabled, and ignore spaces
  def self.play_sound_effect(current_position, char)
    return unless @sound_enabled          # Check if sound is enabled or not
    return if char.strip.empty?           # Ignore spaces and blank characters

    if current_position > @previous_position
      if @letter_count % @sound_interval == 0
        pbSEPlay(@sound_effect_name)
      end
      @letter_count += 1
      @previous_position = current_position
    end
  end

  # Script commands to control sound effect and toggle
  def self.set_sound_effect(name)
    @sound_effect_name = name
  end

  def self.enable_sound
    @sound_enabled = true
  end

  def self.disable_sound
    @sound_enabled = false
  end
end

#===============================================================================
# Override pbMessageDisplay to play sound while message is being written
#===============================================================================
alias original_pbMessageDisplay pbMessageDisplay
def pbMessageDisplay(msgwindow, message, letterbyletter = true, commandProc = nil)
  # Reset letter count for each new message so that the sound is played at the correct time, may not be necessary.
  DialogueSound.reset

  # Call the original pbMessageDisplay but modify its behavior
  original_pbMessageDisplay(msgwindow, message, letterbyletter, commandProc) do
    # Only play sound if letterbyletter display is enabled, advancing to the next letter
    if letterbyletter && msgwindow && msgwindow.waitcount == 0 && msgwindow.text
      current_position = msgwindow.position
      current_char = msgwindow.text[current_position] || ""
      DialogueSound.play_sound_effect(current_position, current_char)
    end

    # Yield to the original block behavior
    yield if block_given?
  end
end

