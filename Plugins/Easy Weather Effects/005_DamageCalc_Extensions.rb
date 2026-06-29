#===============================================================================
# Custom Weather Plugin - Damage Calculation Extensions
# Extends move damage calculation to apply custom weather type boosts
#===============================================================================
class Battle::Move
  #=============================================================================
  # Extend pbCalcDamageMultipliers to handle custom weather type boosts
  #=============================================================================
  alias_method :customweather_pbCalcDamageMultipliers, :pbCalcDamageMultipliers

  def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
    # Call original method first
    customweather_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)

    # Apply custom weather type boosts
    weather = user.effectiveWeather
    if CustomWeather.custom_weather?(weather) && type
      boost = CustomWeather::Handlers.triggerTypeBoost(weather, type, user, target)
      if boost && boost != 1.0
        multipliers[:final_damage_multiplier] *= boost
      end
    end
  end
end
