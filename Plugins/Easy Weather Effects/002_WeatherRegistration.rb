#===============================================================================
# Custom Weather Plugin - Weather Registration
# Template and helpers for registering custom weather types
#===============================================================================

#===============================================================================
# Helper module for registering custom weather
#===============================================================================
module CustomWeather
  #-----------------------------------------------------------------------------
  # Register both overworld and battle weather for a custom weather type
  # @param overworld_data [Hash] Data for GameData::Weather.register
  # @param battle_data [Hash] Data for GameData::BattleWeather.register
  #-----------------------------------------------------------------------------
  def self.register_weather(overworld_data, battle_data)
    # Register overworld weather
    GameData::Weather.register(overworld_data) if overworld_data

    # Register battle weather
    GameData::BattleWeather.register(battle_data) if battle_data

    # Register in our custom weather tracking
    overworld_id = overworld_data ? overworld_data[:id] : nil
    battle_id = battle_data ? battle_data[:id] : nil

    if overworld_id && battle_id
      register(overworld_id, battle_id)
    elsif battle_id
      CUSTOM_WEATHER_IDS.push(battle_id) if !CUSTOM_WEATHER_IDS.include?(battle_id)
    end
  end
end

#===============================================================================
# EXAMPLE: How to register a custom weather (commented out)
# Copy this template to your own weather file (e.g., 010_PoisonFog.rb)
#===============================================================================
# CustomWeather.register_weather(
#   # Overworld Weather Registration
#   {
#     :id               => :PoisonFog,
#     :id_number        => 12,  # Use 12+ for custom weather
#     :category         => :Fog,
#     :graphics         => [["poisonfog_1", "poisonfog_2"], ["poisonfog_tile"]],
#     :particle_delta_x => -40,
#     :particle_delta_y => 15,
#     :tone_proc        => proc { |strength|
#       Tone.new(-strength / 3, -strength / 2, strength / 3, 0)
#     }
#   },
#   # Battle Weather Registration
#   {
#     :id        => :PoisonFog,
#     :name      => _INTL("Poison Fog"),
#     :animation => "PoisonFog"
#   }
# )
