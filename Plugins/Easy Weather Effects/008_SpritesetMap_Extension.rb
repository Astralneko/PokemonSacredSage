module CustomWeather
  module SpritesetHandlers
    @update_handlers  = {}
    @dispose_handlers = {}

    def self.register(key, &block)
      @update_handlers[key] = block
    end

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

  def cw_map_offset_x(parallax: 1.0)
    ($game_map.display_x / 4.0) * parallax
  end

  def cw_map_offset_y(parallax: 1.0)
    ($game_map.display_y / 4.0) * parallax
  end

  def cw_world_to_screen_x(world_x, parallax: 1.0)
    world_x - cw_map_offset_x(parallax: parallax)
  end

  def cw_world_to_screen_y(world_y, parallax: 1.0)
    world_y - cw_map_offset_y(parallax: parallax)
  end
end
