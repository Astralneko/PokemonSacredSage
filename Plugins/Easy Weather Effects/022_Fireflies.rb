
FIREFLY_SPRITE_COUNT = 60

class Spriteset_Map
  def firefly_make_bitmaps
    @firefly_bitmaps = []

    brightness_levels = [
      [240, 160,  80, 25],   # bright — fully lit
      [180, 100,  45, 15],   # mid — partially lit
      [ 80,  40,  15,  5],   # dim — nearly dark
    ]

    brightness_levels.each do |ca, ia, oa, ha|
      bm = Bitmap.new(11, 11)
      cx = 5
      cy = 5

      halo = Color.new(220, 240, 255, ha)
      (-5..5).each do |dy|
        w = (Math.sqrt([25 - dy*dy, 0].max)).floor
        x0 = [cx - w, 0].max
        rw = [cx + w, 10].min - x0 + 1
        bm.fill_rect(x0, cy + dy, rw, 1, halo) if rw > 0
      end

      outer = Color.new(230, 245, 255, oa)
      (-3..3).each do |dy|
        w = (Math.sqrt([9 - dy*dy, 0].max)).floor
        x0 = [cx - w, 0].max
        rw = [cx + w, 10].min - x0 + 1
        bm.fill_rect(x0, cy + dy, rw, 1, outer) if rw > 0
      end

      inner = Color.new(245, 252, 255, ia)
      (-2..2).each do |dy|
        w = (Math.sqrt([4 - dy*dy, 0].max)).floor
        x0 = [cx - w, 0].max
        rw = [cx + w, 10].min - x0 + 1
        bm.fill_rect(x0, cy + dy, rw, 1, inner) if rw > 0
      end

      core = Color.new(255, 255, 255, ca)
      bm.fill_rect(4, 5, 3, 1, core)
      bm.fill_rect(5, 4, 1, 3, core)
      bm.set_pixel(5, 5, core)

      @firefly_bitmaps.push(bm)
    end
  end

  def firefly_setup_layer
    @firefly_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @firefly_viewport.z = 200

    FIREFLY_SPRITE_COUNT.times do
      sprite         = Sprite.new(@firefly_viewport)
      sprite.z       = 1000
      blink_frame    = rand(3)
      sprite.bitmap  = @firefly_bitmaps[blink_frame]
      sprite.ox      = 5
      sprite.oy      = 5
      sprite.opacity = rand(180) + 50

      wx = cw_map_offset_x + rand(Graphics.width)
      wy = cw_map_offset_y + rand(Graphics.height)
      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      blink_speed = rand(20) + 15
      @firefly_sprites.push(sprite)
      @firefly_info.push([blink_frame, blink_speed, blink_speed, rand(120), rand(4) + 1, rand(80), wx, wy])
    end

    @firefly_active = true
  end

  def firefly_update_sprites
    @firefly_sprites.each_with_index do |sprite, i|
      blink_frame, blink_cd, blink_speed, drift, rise_delay, bob, wx, wy = @firefly_info[i]

      wy -= 1 if Graphics.frame_count % rise_delay == i % rise_delay

      drift = (drift + 1) % 120
      if    drift < 30  then wx -= 1
      elsif drift < 90  then wx += 0
      else                   wx += 1
      end

      bob = (bob + 1) % 80
      wy -= 1 if bob == 20
      wy += 1 if bob == 60

      blink_cd -= 1
      if blink_cd <= 0
        blink_frame = (blink_frame + 1) % 3
        sprite.bitmap = @firefly_bitmaps[blink_frame]
        blink_cd = blink_speed + rand(10) - 5
      end

      target_opacity = [200, 140, 60][blink_frame]
      sprite.opacity += (target_opacity - sprite.opacity) > 0 ? 4 : -4

      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @firefly_info[i] = [blink_frame, blink_cd, blink_speed, drift, rise_delay, bob, wx, wy]

      if sprite.y < -20
        wx = cw_map_offset_x + rand(Graphics.width)
        wy = cw_map_offset_y + Graphics.height + rand(40) + 20
        sprite.x        = cw_world_to_screen_x(wx)
        sprite.y        = cw_world_to_screen_y(wy)
        sprite.opacity  = 30
        new_blink_speed = rand(20) + 15
        @firefly_info[i] = [2, new_blink_speed, new_blink_speed, rand(120), rand(4) + 1, rand(80), wx, wy]
        sprite.bitmap   = @firefly_bitmaps[2]
      end
    end
  end

  def firefly_clear_layer
    @firefly_sprites.each { |s| s.dispose }
    @firefly_sprites.clear
    @firefly_info.clear
    @firefly_viewport.dispose if @firefly_viewport
    @firefly_viewport = nil
    @firefly_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:Fireflies) do |spriteset|
  spriteset.instance_eval do
    unless @firefly_bitmaps
      @firefly_bitmaps  = []
      @firefly_sprites  = []
      @firefly_info     = []
      @firefly_viewport = nil
      @firefly_active   = false
      firefly_make_bitmaps
    end
    if $game_screen.weather_type == :Fireflies
      firefly_setup_layer unless @firefly_active
      firefly_update_sprites
    elsif @firefly_active
      firefly_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:Fireflies) do |spriteset|
  spriteset.instance_eval do
    firefly_clear_layer if @firefly_active
    if @firefly_bitmaps
      @firefly_bitmaps.each { |bm| bm.dispose }
      @firefly_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :Fireflies, :id_number => 22, :category => :None, :graphics => [],
    :tone_proc => proc { |strength|
      Tone.new(-strength / 16, -strength / 12, strength / 10, 0)
    }
  },
  { :id => :Fireflies, :name => _INTL("Fireflies"), :animation => "Fireflies" }
)

CustomWeather::Handlers::StartMessage.add(:Fireflies,
  proc { |weather, battle| next _INTL("Fireflies began to drift across the battlefield!") })
CustomWeather::Handlers::ContinueMessage.add(:Fireflies,
  proc { |weather, battle| next _INTL("Fireflies continue to drift gently through the air.") })
CustomWeather::Handlers::EndMessage.add(:Fireflies,
  proc { |weather, battle| next _INTL("The fireflies drifted away into the night.") })
