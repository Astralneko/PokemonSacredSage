#===============================================================================
# Custom Weather Plugin - Battle Starting Extensions
# Extends battle preparation to convert overworld custom weather to battle weather
#===============================================================================
module BattleCreationHelperMethods
  unless singleton_class.instance_variable_get(:@__customweather_battlestart_patched)
    singleton_class.instance_variable_set(:@__customweather_battlestart_patched, true)

    class << self
      alias customweather_prepare_battle prepare_battle
    end

    def self.prepare_battle(battle)
      # Run the original (which includes any field-system prepare_battle hooks)
      customweather_prepare_battle(battle)

      # If no explicit weather rule was set, check whether the overworld weather
      # maps to a custom battle weather and apply it as the default
      battleRules = $game_temp.battle_rules
      if battleRules["defaultWeather"].nil?
        overworld_weather = $game_screen.weather_type
        battle_weather = CustomWeather.get_battle_weather(overworld_weather)
        battle.defaultWeather = battle_weather if battle_weather
      end
    end

  end # unless singleton patched
end
