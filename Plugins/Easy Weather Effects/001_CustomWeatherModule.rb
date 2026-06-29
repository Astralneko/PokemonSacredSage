#===============================================================================
# Custom Weather Plugin - Core Module
# Provides handler registries and configuration for custom weather effects
#===============================================================================
module CustomWeather
  # Mapping of overworld weather IDs to battle weather IDs
  # Custom weathers should add their mapping here
  OVERWORLD_TO_BATTLE = {}

  # Registry of custom weather IDs that this plugin manages
  CUSTOM_WEATHER_IDS = []

  #-----------------------------------------------------------------------------
  # Check if a weather ID is a custom weather managed by this plugin
  #-----------------------------------------------------------------------------
  def self.custom_weather?(weather_id)
    return CUSTOM_WEATHER_IDS.include?(weather_id)
  end

  #-----------------------------------------------------------------------------
  # Register a custom weather (called from weather definition files)
  #-----------------------------------------------------------------------------
  def self.register(overworld_id, battle_id = nil)
    CUSTOM_WEATHER_IDS.push(overworld_id) if !CUSTOM_WEATHER_IDS.include?(overworld_id)
    OVERWORLD_TO_BATTLE[overworld_id] = battle_id if battle_id
  end

  #-----------------------------------------------------------------------------
  # Get the battle weather for an overworld weather
  #-----------------------------------------------------------------------------
  def self.get_battle_weather(overworld_weather)
    return OVERWORLD_TO_BATTLE[overworld_weather]
  end

  #=============================================================================
  # Handler Module - Contains all handler registries
  #=============================================================================
  module Handlers
    #---------------------------------------------------------------------------
    # End-of-round damage handler
    # proc { |weather, battler, battle| ... }
    #---------------------------------------------------------------------------
    EORDamage = HandlerHash.new

    #---------------------------------------------------------------------------
    # Damage immunity check handler
    # proc { |weather, battler| next true/false }
    #---------------------------------------------------------------------------
    DamageImmunity = HandlerHash.new

    #---------------------------------------------------------------------------
    # Type boost multiplier handler
    # proc { |weather, move_type, user, target| next multiplier }
    #---------------------------------------------------------------------------
    TypeBoost = HandlerHash.new

    #---------------------------------------------------------------------------
    # Weather start message handler
    # proc { |weather, battle| next "message" }
    #---------------------------------------------------------------------------
    StartMessage = HandlerHash.new

    #---------------------------------------------------------------------------
    # Weather continue message handler
    # proc { |weather, battle| next "message" }
    #---------------------------------------------------------------------------
    ContinueMessage = HandlerHash.new

    #---------------------------------------------------------------------------
    # Weather end message handler
    # proc { |weather, battle| next "message" }
    #---------------------------------------------------------------------------
    EndMessage = HandlerHash.new

    #---------------------------------------------------------------------------
    # Trigger helpers
    #---------------------------------------------------------------------------
    def self.triggerEORDamage(weather, battler, battle)
      EORDamage.trigger(weather, weather, battler, battle)
    end

    def self.triggerDamageImmunity(weather, battler)
      ret = DamageImmunity.trigger(weather, weather, battler)
      return ret == true
    end

    def self.triggerTypeBoost(weather, move_type, user, target)
      ret = TypeBoost.trigger(weather, weather, move_type, user, target)
      return ret || 1.0
    end

    def self.triggerStartMessage(weather, battle)
      return StartMessage.trigger(weather, weather, battle)
    end

    def self.triggerContinueMessage(weather, battle)
      return ContinueMessage.trigger(weather, weather, battle)
    end

    def self.triggerEndMessage(weather, battle)
      return EndMessage.trigger(weather, weather, battle)
    end
  end
end
