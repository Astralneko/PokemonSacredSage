#===============================================================================
# Custom Weather Plugin - Battle Starting Extensions
# Extends battle preparation to convert overworld custom weather to battle weather
#===============================================================================
module BattleCreationHelperMethods
  class << self
    alias_method :customweather_prepare_battle, :prepare_battle
  end

  def self.prepare_battle(battle)
    # Call original method first
    customweather_prepare_battle(battle)

    # Check for custom weather conversion
    battleRules = $game_temp.battle_rules
    if battleRules["defaultWeather"].nil?
      overworld_weather = $game_screen.weather_type
      battle_weather = CustomWeather.get_battle_weather(overworld_weather)
      if battle_weather
        battle.defaultWeather = battle_weather
      end
    end
  end
end
