#===============================================================================
# Custom Weather Plugin - Falling Ash Weather
# Fine grey ash flakes drifting slowly downward. No battle effects.
# Slightly larger flakes than original.
#===============================================================================

ASH_SPRITE_COUNT = 180

class Spriteset_Map
  def ash_make_bitmaps
    @ash_bitmaps = []
    [
      { w: 2, h: 2, color: Color.new(200, 200, 200, 160) },
      { w: 2, h: 2, color: Color.new(180, 180, 180, 140) },
      { w: 2, h: 2, color: Color.new(210, 205, 200, 130) },
      { w: 3, h: 2, color: Color.new(160, 160, 160, 170) },
      { w: 2, h: 3, color: Color.new(170, 165, 160, 160) },
      { w: 4, h: 3, color: Color.new(140, 140, 140, 175), irregular: true },
      { w: 3, h: 4, color: Color.new(130, 125, 120, 185), irregular: true },
      { w: 4, h: 4, color: Color.new(110, 110, 110, 145), irregular: true },
      { w: 5, h: 3, color: Color.new(150, 148, 145, 155), irregular: true },
      { w: 3, h: 5, color: Color.new(120, 118, 115, 165), irregular: true },
    ].each do |data|
      bm = Bitmap.new(data[:w], data[:h])
      if data[:irregular]
        (0...data[:w]).each do |x|
          (0...data[:h]).each do |y|
            # Skip corners to give irregular shape
            next if x == 0 && y == 0
            next if x == data[:w] - 1 && y == 0
            next if x == 0 && y == data[:h] - 1
            next if x == data[:w] - 1 && y == data[:h] - 1
            a = [[data[:color].alpha + rand(40) - 20, 0].max, 255].min
            bm.set_pixel(x, y, Color.new(data[:color].red, data[:color].green, data[:color].blue, a))
          end
        end
      else
        bm.fill_rect(0, 0, data[:w], data[:h], data[:color])
      end
      @ash_bitmaps.push(bm)
    end
  end

  def ash_setup_layer
    @ash_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @ash_viewport.z = 200
    ASH_SPRITE_COUNT.times do
      sprite         = Sprite.new(@ash_viewport)
      sprite.z       = 1000
      sprite.bitmap  = @ash_bitmaps[rand(@ash_bitmaps.size)]
      sprite.x       = rand(Graphics.width + 40) - 20
      sprite.y       = rand(Graphics.height)
      sprite.opacity = rand(160) + 40
      @ash_sprites.push(sprite)
      @ash_info.push([rand(2) + 1, rand(120)])
    end
    @ash_active = true
  end

  def ash_update_sprites
    @ash_sprites.each_with_index do |sprite, i|
      speed, phase = @ash_info[i]
      sprite.y += speed == 2 ? 1 : (Graphics.frame_count % 2 == i % 2 ? 1 : 0)
      phase = (phase + 1) % 120
      if    phase < 30  then sprite.x -= 1
      elsif phase < 90  then sprite.x += 0
      else                   sprite.x += 1
      end
      @ash_info[i] = [speed, phase]
      sprite.opacity += rand(3) - 1
      if sprite.y > Graphics.height + sprite.bitmap.height
        sprite.opacity = rand(160) + 40
        sprite.x       = rand(Graphics.width + 40) - 20
        sprite.y       = -sprite.bitmap.height - rand(20)
        sprite.bitmap  = @ash_bitmaps[rand(@ash_bitmaps.size)]
        @ash_info[i]   = [rand(2) + 1, rand(120)]
      end
    end
  end

  def ash_clear_layer
    @ash_sprites.each { |s| s.dispose }
    @ash_sprites.clear
    @ash_info.clear
    @ash_viewport.dispose if @ash_viewport
    @ash_viewport = nil
    @ash_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:FallingAsh) do |spriteset|
  spriteset.instance_eval do
    unless @ash_bitmaps
      @ash_sprites  = []
      @ash_info     = []
      @ash_viewport = nil
      @ash_active   = false
      ash_make_bitmaps
    end
    if $game_screen.weather_type == :FallingAsh
      ash_setup_layer unless @ash_active
      ash_update_sprites
    elsif @ash_active
      ash_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:FallingAsh) do |spriteset|
  spriteset.instance_eval do
    ash_clear_layer if @ash_active
    if @ash_bitmaps
      @ash_bitmaps.each { |bm| bm.dispose }
      @ash_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :FallingAsh, :id_number => 18, :category => :None, :graphics => [],
    :tone_proc => proc { |strength| Tone.new(-strength / 8, -strength / 10, -strength / 12, strength / 5) } },
  { :id => :FallingAsh, :name => _INTL("Falling Ash"), :animation => "FallingAsh" }
)

CustomWeather::Handlers::StartMessage.add(:FallingAsh,
  proc { |weather, battle| next _INTL("Ash began to fall from the sky.") })
CustomWeather::Handlers::ContinueMessage.add(:FallingAsh,
  proc { |weather, battle| next _INTL("Ash continues to drift down from above.") })
CustomWeather::Handlers::EndMessage.add(:FallingAsh,
  proc { |weather, battle| next _INTL("The ash stopped falling.") })
