#===============================================================================
# Custom Weather Plugin - Battle Class Extensions
# Extends Battle class to handle custom weather effects
#===============================================================================
class Battle
  #=============================================================================
  # Extend pbStartBattleCore to show custom weather announcement at battle start
  #=============================================================================
  alias_method :customweather_pbStartBattleCore, :pbStartBattleCore

  def pbStartBattleCore
    # Check if we have custom weather that needs announcement
    if CustomWeather.custom_weather?(@field.weather)
      # Set up the battlers on each side
      sendOuts = pbSetUpSides
      @battleAI.create_ai_objects
      # Create all the sprites and play the battle intro animation
      @scene.pbStartBattle(self)
      # Show trainers on both sides sending out Pokémon
      pbStartBattleSendOut(sendOuts)
      # Custom weather announcement
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if weather_data
      # Get custom start message for battle start
      start_msg = CustomWeather::Handlers.triggerStartMessage(@field.weather, self)
      pbDisplay(start_msg) if start_msg
      # Terrain announcement (keep original behavior)
      terrain_data = GameData::BattleTerrain.try_get(@field.terrain)
      pbCommonAnimation(terrain_data.animation) if terrain_data
      case @field.terrain
      when :Electric
        pbDisplay(_INTL("An electric current runs across the battlefield!"))
      when :Grassy
        pbDisplay(_INTL("Grass is covering the battlefield!"))
      when :Misty
        pbDisplay(_INTL("Mist swirls about the battlefield!"))
      when :Psychic
        pbDisplay(_INTL("The battlefield is weird!"))
      end
      # Abilities upon entering battle
      pbOnAllBattlersEnteringBattle
      # Main battle loop
      pbBattleLoop
      return
    end
    # Fall back to original method for built-in weather
    customweather_pbStartBattleCore
  end

  #=============================================================================
  # Extend pbEORWeatherDamage to handle custom weather damage
  #=============================================================================
  alias_method :customweather_pbEORWeatherDamage, :pbEORWeatherDamage

  def pbEORWeatherDamage(battler)
    # First try custom weather handling
    if CustomWeather.custom_weather?(battler.effectiveWeather)
      return if battler.fainted?
      CustomWeather::Handlers.triggerEORDamage(battler.effectiveWeather, battler, self)
      battler.pbItemHPHealCheck
      battler.pbFaint if battler.fainted?
      return
    end
    # Fall back to original method for built-in weather
    customweather_pbEORWeatherDamage(battler)
  end

  #=============================================================================
  # Extend pbEOREndWeather to handle custom weather messages
  #=============================================================================
  alias_method :customweather_pbEOREndWeather, :pbEOREndWeather

  def pbEOREndWeather(priority)
    # Check if this is a custom weather
    if CustomWeather.custom_weather?(@field.weather)
      # Count down weather duration
      @field.weatherDuration -= 1 if @field.weatherDuration > 0
      # Weather wears off
      if @field.weatherDuration == 0
        # Get custom end message
        end_msg = CustomWeather::Handlers.triggerEndMessage(@field.weather, self)
        pbDisplay(end_msg) if end_msg
        @field.weather = :None
        # Check for form changes caused by the weather changing
        allBattlers.each { |battler| battler.pbCheckFormOnWeatherChange }
        # Start up the default weather
        pbStartWeather(nil, @field.defaultWeather) if @field.defaultWeather != :None
        return if @field.weather == :None
      end
      # Weather continues
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if weather_data
      # Get custom continue message
      continue_msg = CustomWeather::Handlers.triggerContinueMessage(@field.weather, self)
      pbDisplay(continue_msg) if continue_msg
      # Effects due to weather
      priority.each do |battler|
        # Weather-related abilities
        if battler.abilityActive?
          Battle::AbilityEffects.triggerEndOfRoundWeather(battler.ability, battler.effectiveWeather, battler, self)
          battler.pbFaint if battler.fainted?
        end
        # Weather damage
        pbEORWeatherDamage(battler)
      end
      return
    end
    # Fall back to original method for built-in weather
    customweather_pbEOREndWeather(priority)
  end

  #=============================================================================
  # Extend pbStartWeather to handle custom weather start messages
  #=============================================================================
  alias_method :customweather_pbStartWeather, :pbStartWeather

  def pbStartWeather(user, newWeather, fixedDuration = false, showAnimation = true)
    return if @field.weather == newWeather
    # Check if new weather is custom
    if CustomWeather.custom_weather?(newWeather)
      @field.weather = newWeather
      @field.weatherDuration = fixedDuration ? 5 : -1
      if user
        @field.weatherDuration = 8 if fixedDuration && user.hasActiveItem?(:WEATHEREXTENDER)
      end
      weather_data = GameData::BattleWeather.try_get(@field.weather)
      pbCommonAnimation(weather_data.animation) if showAnimation && weather_data
      # Get custom start message
      start_msg = CustomWeather::Handlers.triggerStartMessage(newWeather, self)
      pbDisplay(start_msg) if start_msg
      # Check for form changes caused by the weather changing
      allBattlers.each { |battler| battler.pbCheckFormOnWeatherChange }
      # Trigger abilities that activate upon weather changing
      pbStartWeatherAbilities(newWeather)
      return
    end
    # Fall back to original method for built-in weather
    customweather_pbStartWeather(user, newWeather, fixedDuration, showAnimation)
  end

  #=============================================================================
  # Helper: Trigger abilities that activate when weather changes
  #=============================================================================
  def pbStartWeatherAbilities(weather)
    pbPriority(true).each do |battler|
      battler.pbAbilityOnTerrainChange if battler.abilityActive?
    end
  end
end
