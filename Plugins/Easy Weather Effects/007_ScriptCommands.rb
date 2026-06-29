#===============================================================================
# Custom Weather Plugin - Script Commands API
# Provides easy-to-use commands for setting custom weather in events
#===============================================================================

#===============================================================================
# Set custom weather on the overworld map
# @param weather_id [Symbol] The weather ID (e.g., :PoisonFog)
# @param strength [Integer] Weather intensity (0-9, default 9)
# @param duration [Integer] Duration in frames (default 0 = permanent until changed)
#===============================================================================
def pbSetCustomWeather(weather_id, strength = 9, duration = 0)
  $game_screen.weather(weather_id, strength, duration)
end

#===============================================================================
# Set weather for the next battle
# @param weather_id [Symbol] The battle weather ID (e.g., :PoisonFog)
#===============================================================================
def pbSetBattleWeather(weather_id)
  setBattleRule("weather", weather_id)
end

#===============================================================================
# Clear all weather from the overworld
# @param duration [Integer] Fade duration in frames (default 20)
#===============================================================================
def pbClearWeather(duration = 20)
  $game_screen.weather(:None, 0, duration)
end

#===============================================================================
# Module methods for map weather control
#===============================================================================
module CustomWeather
  #-----------------------------------------------------------------------------
  # Set weather on map entry with optional probability
  # Useful for parallel process events at map start
  # @param weather_id [Symbol] The weather ID (e.g., :PoisonFog)
  # @param probability [Integer] Chance (0-100) for weather to appear (default 100)
  # @param strength [Integer] Weather intensity (0-9, default 9)
  #-----------------------------------------------------------------------------
  def self.setMapWeather(weather_id, probability = 100, strength = 9)
    return if probability < 100 && rand(100) >= probability
    $game_screen.weather(weather_id, strength, 0)
  end

  #-----------------------------------------------------------------------------
  # Check if a specific weather is currently active on the overworld
  # @param weather_id [Symbol] The weather ID to check
  # @return [Boolean] True if the weather is active
  #-----------------------------------------------------------------------------
  def self.weatherActive?(weather_id)
    return $game_screen.weather_type == weather_id
  end

  #-----------------------------------------------------------------------------
  # Get the current overworld weather
  # @return [Symbol] The current weather ID
  #-----------------------------------------------------------------------------
  def self.currentWeather
    return $game_screen.weather_type
  end

  #-----------------------------------------------------------------------------
  # Set weather for specific maps (use with :on_enter_map event)
  # @param map_weather [Hash] Map ID to weather ID mapping
  #   { 1 => :PoisonFog, 5 => :PoisonFog }
  # @param strength [Integer] Weather intensity (default 9)
  #-----------------------------------------------------------------------------
  def self.setupMapWeatherTable(map_weather, strength = 9)
    @map_weather_table = map_weather
    @map_weather_strength = strength
  end

  #-----------------------------------------------------------------------------
  # Check and apply weather based on map weather table
  # Call this from an :on_enter_map event handler
  #-----------------------------------------------------------------------------
  def self.applyMapWeatherFromTable
    return unless @map_weather_table
    weather = @map_weather_table[$game_map.map_id]
    if weather
      strength = @map_weather_strength || 9
      $game_screen.weather(weather, strength, 0)
    end
  end

  # Storage for map weather table
  @map_weather_table = nil
  @map_weather_strength = 9
end

#===============================================================================
# Example event handler for automatic map weather (commented out)
# Add this to your game if you want maps to automatically have weather
#===============================================================================
# EventHandlers.add(:on_enter_map, :custom_weather_map_check,
#   proc { |old_map_id|
#     CustomWeather.applyMapWeatherFromTable
#   }
# )
