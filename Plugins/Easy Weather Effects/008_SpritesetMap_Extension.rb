#===============================================================================
# Custom Weather Plugin - Spriteset_Map Extension
# Provides a single, safe patch point for all custom weather particle effects.
#
# WHY A SINGLE PATCH?
#   Every weather file previously aliased Spriteset_Map#update independently.
#   When Essentials reloads the scene (e.g. loading a save file), all plugin
#   files are re-evaluated. If alias is called again on an already-patched
#   method, the new alias captures the patched version rather than the original,
#   collapsing the chain into infinite recursion.
#
#   The solution: alias update/dispose EXACTLY ONCE here, using a check that
#   works in this Ruby/RGSS environment (an instance variable on the class
#   itself rather than method_defined?, which proved unreliable).
#   Weather files never alias anything — they register handlers instead.
#
# USAGE (in a weather file):
#   CustomWeather::SpritesetHandlers.register(:MyWeather) do |spriteset|
#     spriteset.instance_eval do
#       # code here runs with self = the Spriteset_Map instance
#       # so @my_bitmaps, my_helper_method, etc. all work normally
#     end
#   end
#   CustomWeather::SpritesetHandlers.register_dispose(:MyWeather) do |spriteset|
#     spriteset.instance_eval { my_clear_layer if @my_active }
#   end
#===============================================================================
module CustomWeather
  module SpritesetHandlers
    @update_handlers  = {}
    @dispose_handlers = {}

    #---------------------------------------------------------------------------
    # Register an update handler for a weather type.
    # Called every frame from Spriteset_Map#update.
    # The block receives the Spriteset_Map instance as its argument.
    # Use spriteset.instance_eval { ... } to access instance variables and
    # helper methods defined on Spriteset_Map directly.
    #---------------------------------------------------------------------------
    def self.register(key, &block)
      @update_handlers[key] = block
    end

    #---------------------------------------------------------------------------
    # Register a dispose handler for a weather type.
    # Called from Spriteset_Map#dispose when the scene is torn down.
    #---------------------------------------------------------------------------
    def self.register_dispose(key, &block)
      @dispose_handlers[key] = block
    end

    def self.run_update(spriteset)
      @update_handlers.each_value { |handler| handler.call(spriteset) }
    end

    def self.run_dispose(spriteset)
      @dispose_handlers.each_value { |handler| handler.call(spriteset) }
    end
  end
end

#===============================================================================
# Single Spriteset_Map patch — protected by a class-level flag so it runs
# exactly once no matter how many times the plugin files are evaluated.
#===============================================================================
class Spriteset_Map
  unless @custom_weather_patched
    @custom_weather_patched = true

    alias custom_weather_update_original update
    def update
      custom_weather_update_original
      CustomWeather::SpritesetHandlers.run_update(self)
    end

    alias custom_weather_dispose_original dispose
    def dispose
      CustomWeather::SpritesetHandlers.run_dispose(self)
      custom_weather_dispose_original
    end
  end
end
