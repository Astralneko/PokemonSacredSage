#===============================================================================
# Custom Weather Plugin - Battle Class Extensions
# Extends Battle class to handle custom weather effects
#===============================================================================
class Battle
  unless @__customweather_battle_patched
    @__customweather_battle_patched = true

    #===========================================================================
    # pbEORWeatherDamage — run custom weather EOR damage as an overlay.
    # Follows the standard EOR damage pattern used throughout the codebase:
    #   scene.pbDamageAnimation  (done inside each Handlers::EORDamage proc)
    #   pbReduceHP               (done inside each Handlers::EORDamage proc)
    #   pbItemHPHealCheck
    #   pbAbilitiesOnDamageTaken   ← was missing in original; required
    #   pbFaint
    # Falls through to the original for :None / built-in weather.
    #===========================================================================
    alias customweather_pbEORWeatherDamage pbEORWeatherDamage

    def pbEORWeatherDamage(battler)
      unless CustomWeather.custom_weather?(battler.effectiveWeather)
        return customweather_pbEORWeatherDamage(battler)
      end
      return if battler.fainted?
      CustomWeather::Handlers.triggerEORDamage(battler.effectiveWeather, battler, self)
      return if battler.fainted?
      battler.pbItemHPHealCheck
      battler.pbAbilitiesOnDamageTaken
      battler.pbFaint if battler.fainted?
    end

    #===========================================================================
    # pbEOREndWeather — drive the custom weather EOR loop (count-down, messages,
    # ability triggers, damage). Built-in weather falls through to original.
    #
    # The field-system alias (from 009_Field_Passive_Effects.rb) loads after
    # this file, so it sits outside in the chain and calls through first.
    # Field weather-duration extensions are therefore applied before this runs.
    #===========================================================================
    alias customweather_pbEOREndWeather pbEOREndWeather

    def pbEOREndWeather(priority)
      unless CustomWeather.custom_weather?(@field.weather)
        return customweather_pbEOREndWeather(priority)
      end

      # Count down duration (-1 means infinite)
      @field.weatherDuration -= 1 if @field.weatherDuration > 0

      if @field.weatherDuration == 0
        end_msg = CustomWeather::Handlers.triggerEndMessage(@field.weather, self)
        pbDisplay(end_msg) if end_msg
        @field.weather = :None
        allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
        pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
        return if @field.weather == :None
      end

      # Weather continues — animation, message, then per-battler effects
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if weather_data
      continue_msg = CustomWeather::Handlers.triggerContinueMessage(@field.weather, self)
      pbDisplay(continue_msg) if continue_msg

      priority.each do |battler|
        if battler.abilityActive?
          Battle::AbilityEffects.triggerEndOfRoundWeather(
            battler.ability, battler.effectiveWeather, battler, self
          )
          battler.pbFaint if battler.fainted?
        end
        pbEORWeatherDamage(battler)
      end
    end

    #===========================================================================
    # pbStartWeather — handle custom weather start.
    #
    # FIELD OVERLAY RULE: if the active field explicitly blocks this weather
    # (via field_blocks_weather? from the field system), the weather is rejected
    # and the appropriate block message is shown — exactly as built-in weather
    # is blocked by certain fields (e.g. Volcanic blocks Hail, Infernal blocks
    # Rain). Built-in weather falls through to the original method unchanged,
    # which already has the field-system's alias for pbStartWeather.
    #===========================================================================
    alias customweather_pbStartWeather pbStartWeather

    def pbStartWeather(user, newWeather, fixedDuration = false, showAnimation = true)
      unless CustomWeather.custom_weather?(newWeather)
        return customweather_pbStartWeather(user, newWeather, fixedDuration, showAnimation)
      end

      return if @field.weather == newWeather

      # Respect field weather-blocking rules (overlay rule)
      if respond_to?(:field_blocks_weather?) && field_blocks_weather?(newWeather)
        if respond_to?(:field_weather_block_message)
          msg = field_weather_block_message(newWeather)
          pbDisplay(msg) if msg
        end
        return
      end

      @field.weather = newWeather

      # Duration: -1 = infinite, 5 = default, 8 = with Weather Extender
      if fixedDuration
        @field.weatherDuration = 5
        @field.weatherDuration = 8 if user && user.hasActiveItem?(:WEATHEREXTENDER)
      else
        @field.weatherDuration = -1
      end

      # Apply field-specific weather duration extension (from fieldtxt :weatherDuration)
      # The field system sets this when pbStartWeather is called via its own alias;
      # since built-in weather falls through to that alias, custom weather must
      # replicate the extension check here.
      if fixedDuration && has_field? && respond_to?(:current_field)
        field_data = current_field
        if field_data.respond_to?(:weatherDuration)
          ext = field_data.weatherDuration[newWeather]
          @field.weatherDuration = ext if ext && ext > @field.weatherDuration
        end
      end

      if showAnimation
        weather_data = GameData::BattleWeather.try_get(@field.weather)
        pbCommonAnimation(weather_data.animation) if weather_data
      end

      start_msg = CustomWeather::Handlers.triggerStartMessage(newWeather, self)
      pbDisplay(start_msg) if start_msg

      allBattlers.each { |b| b.pbCheckFormOnWeatherChange }
      pbStartWeatherAbilities(newWeather)
    end

    #===========================================================================
    # Helper: trigger abilities that respond to a weather change
    #===========================================================================
    def pbStartWeatherAbilities(weather)
      pbPriority(true).each do |battler|
        battler.pbAbilityOnTerrainChange if battler.abilityActive?
      end
    end

  end # unless @__customweather_battle_patched
end
