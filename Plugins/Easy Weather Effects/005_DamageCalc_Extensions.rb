#===============================================================================
# Custom Weather Plugin - Damage Calculation Extensions
# Extends move damage calculation to apply custom weather type boosts
#===============================================================================
class Battle::Move
  unless @__customweather_damagecalc_patched
    @__customweather_damagecalc_patched = true

    alias customweather_pbCalcDamageMultipliers pbCalcDamageMultipliers

    def pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)
      # Field system and base PE21.1 multipliers applied first
      customweather_pbCalcDamageMultipliers(user, target, numTargets, type, baseDmg, multipliers)

      # Apply custom weather type boost as an overlay on top of field effects
      weather = user.effectiveWeather
      return unless CustomWeather.custom_weather?(weather) && type

      boost = CustomWeather::Handlers.triggerTypeBoost(weather, type, user, target)
      multipliers[:final_damage_multiplier] *= boost if boost && boost != 1.0
    end

  end # unless @__customweather_damagecalc_patched
end
