#===============================================================================
# Custom Weather Plugin - Weather Effect Handlers
# Add methods to register handlers for custom weather effects
#===============================================================================
module CustomWeather
  module Handlers
    #===========================================================================
    # Handler registration helpers - syntactic sugar for adding handlers
    #===========================================================================

    #---------------------------------------------------------------------------
    # Add an end-of-round damage handler for a weather
    # @param weather_id [Symbol] The weather ID (e.g., :PoisonFog)
    # @param handler [Proc] The handler proc
    #   proc { |weather, battler, battle|
    #     # Apply damage to battler
    #   }
    #---------------------------------------------------------------------------
    def self.add_eor_damage(weather_id, &handler)
      EORDamage.add(weather_id, handler)
    end

    #---------------------------------------------------------------------------
    # Add a damage immunity handler for a weather
    # @param weather_id [Symbol] The weather ID
    # @param handler [Proc] The handler proc
    #   proc { |weather, battler|
    #     next true   # if immune
    #     next false  # if not immune
    #   }
    #---------------------------------------------------------------------------
    def self.add_damage_immunity(weather_id, &handler)
      DamageImmunity.add(weather_id, handler)
    end

    #---------------------------------------------------------------------------
    # Add a type boost handler for a weather
    # @param weather_id [Symbol] The weather ID
    # @param handler [Proc] The handler proc
    #   proc { |weather, move_type, user, target|
    #     next 1.5 if move_type == :POISON  # 50% boost
    #     next 1.0  # No boost
    #   }
    #---------------------------------------------------------------------------
    def self.add_type_boost(weather_id, &handler)
      TypeBoost.add(weather_id, handler)
    end

    #---------------------------------------------------------------------------
    # Add a start message handler for a weather
    # @param weather_id [Symbol] The weather ID
    # @param handler [Proc] The handler proc
    #   proc { |weather, battle|
    #     next _INTL("A toxic fog rolled in!")
    #   }
    #---------------------------------------------------------------------------
    def self.add_start_message(weather_id, &handler)
      StartMessage.add(weather_id, handler)
    end

    #---------------------------------------------------------------------------
    # Add a continue message handler for a weather
    # @param weather_id [Symbol] The weather ID
    # @param handler [Proc] The handler proc
    #   proc { |weather, battle|
    #     next _INTL("The toxic fog continues...")
    #   }
    #---------------------------------------------------------------------------
    def self.add_continue_message(weather_id, &handler)
      ContinueMessage.add(weather_id, handler)
    end

    #---------------------------------------------------------------------------
    # Add an end message handler for a weather
    # @param weather_id [Symbol] The weather ID
    # @param handler [Proc] The handler proc
    #   proc { |weather, battle|
    #     next _INTL("The toxic fog cleared.")
    #   }
    #---------------------------------------------------------------------------
    def self.add_end_message(weather_id, &handler)
      EndMessage.add(weather_id, handler)
    end

    #---------------------------------------------------------------------------
    # Register all handlers for a weather at once
    # @param weather_id [Symbol] The weather ID
    # @param handlers [Hash] Hash of handler types to procs
    #   {
    #     :eor_damage => proc { ... },
    #     :damage_immunity => proc { ... },
    #     :type_boost => proc { ... },
    #     :start_message => proc { ... },
    #     :continue_message => proc { ... },
    #     :end_message => proc { ... }
    #   }
    #---------------------------------------------------------------------------
    def self.register_all(weather_id, handlers = {})
      EORDamage.add(weather_id, handlers[:eor_damage]) if handlers[:eor_damage]
      DamageImmunity.add(weather_id, handlers[:damage_immunity]) if handlers[:damage_immunity]
      TypeBoost.add(weather_id, handlers[:type_boost]) if handlers[:type_boost]
      StartMessage.add(weather_id, handlers[:start_message]) if handlers[:start_message]
      ContinueMessage.add(weather_id, handlers[:continue_message]) if handlers[:continue_message]
      EndMessage.add(weather_id, handlers[:end_message]) if handlers[:end_message]
    end
  end
end
