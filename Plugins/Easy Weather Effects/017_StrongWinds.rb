
WIND_SPRITE_COUNT = 120

class Spriteset_Map
  def wind_make_bitmaps
    @wind_bitmaps = []
    [
      [18, 1, Color.new(255, 255, 255,  50)],
      [24, 1, Color.new(235, 240, 255,  60)],
      [12, 1, Color.new(255, 255, 255,  40)],
      [40, 1, Color.new(255, 255, 255,  80)],
      [50, 1, Color.new(220, 230, 255,  70)],
      [35, 2, Color.new(255, 255, 255,  55)],
      [70, 1, Color.new(255, 255, 255, 110)],
      [90, 2, Color.new(255, 255, 255,  90)],
      [60, 2, Color.new(240, 245, 255, 100)],
    ].each do |w, h, color|
      bm = Bitmap.new(w, h)
      fade_w = [w / 4, 8].min
      (0...w).each do |x|
        a = if x < fade_w
              x.to_f / fade_w
            elsif x >= w - fade_w
              (w - 1 - x).to_f / fade_w
            else
              1.0
            end
        c = Color.new(color.red, color.green, color.blue, (color.alpha * a).round)
        h.times { |y| bm.set_pixel(x, y, c) }
      end
      @wind_bitmaps.push(bm)
    end
  end

  def wind_setup_layer
    @wind_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @wind_viewport.z = 200
    WIND_SPRITE_COUNT.times do
      bm             = @wind_bitmaps[rand(@wind_bitmaps.size)]
      sprite         = Sprite.new(@wind_viewport)
      sprite.z       = 1000
      sprite.bitmap  = bm
      sprite.opacity = rand(180) + 40

      wx = cw_map_offset_x + rand(Graphics.width + bm.width) - bm.width
      wy = cw_map_offset_y + rand(Graphics.height)
      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @wind_sprites.push(sprite)
      @wind_info.push([rand(12) + 8, rand(4), wx, wy])
    end
    @wind_active = true
  end

  def wind_update_sprites
    @wind_sprites.each_with_index do |sprite, i|
      speed, drift, wx, wy = @wind_info[i]

      wx += speed
      drift += 1
      if drift >= 6
        wy += rand(3) - 1
        drift = 0
      end

      @wind_info[i] = [speed, drift, wx, wy]

      sprite.opacity -= 1
      sprite.opacity += rand(4) if rand(20) == 0

      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      if sprite.x > Graphics.width || sprite.opacity <= 0
        bm             = @wind_bitmaps[rand(@wind_bitmaps.size)]
        sprite.bitmap  = bm
        wx = cw_map_offset_x + (-bm.width - rand(80))
        wy = cw_map_offset_y + rand(Graphics.height)
        sprite.x       = cw_world_to_screen_x(wx)
        sprite.y       = cw_world_to_screen_y(wy)
        sprite.opacity = rand(160) + 60
        @wind_info[i]  = [rand(12) + 8, rand(4), wx, wy]
      end
    end
  end

  def wind_clear_layer
    @wind_sprites.each { |s| s.dispose }
    @wind_sprites.clear
    @wind_info.clear
    @wind_viewport.dispose if @wind_viewport
    @wind_viewport = nil
    @wind_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:Windy) do |spriteset|
  spriteset.instance_eval do
    unless @wind_bitmaps
      @wind_sprites  = []
      @wind_info     = []
      @wind_viewport = nil
      @wind_active   = false
      wind_make_bitmaps
    end
    if $game_screen.weather_type == :Windy
      wind_setup_layer unless @wind_active
      wind_update_sprites
    elsif @wind_active
      wind_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:Windy) do |spriteset|
  spriteset.instance_eval do
    wind_clear_layer if @wind_active
    if @wind_bitmaps
      @wind_bitmaps.each { |bm| bm.dispose }
      @wind_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :Windy, :id_number => 17, :category => :None, :graphics => [],
    :tone_proc => proc { |strength| Tone.new(strength / 8, strength / 8, strength / 8, strength / 10) } },
  { :id => :Windy, :name => _INTL("Strong Winds"), :animation => "Windy" }
)

CustomWeather::Handlers::StartMessage.add(:Windy,
  proc { |weather, battle| next _INTL("A fierce wind began to blow across the battlefield!") })
CustomWeather::Handlers::ContinueMessage.add(:Windy,
  proc { |weather, battle| next _INTL("The fierce wind continues to blow!") })
CustomWeather::Handlers::EndMessage.add(:Windy,
  proc { |weather, battle| next _INTL("The wind died down.") })
CustomWeather::Handlers::TypeBoost.add(:Windy,
  proc { |weather, move_type, user, target|
    next 1.3 if move_type == :FLYING
    next 1.0
  })
