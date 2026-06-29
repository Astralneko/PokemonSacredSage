#===============================================================================
# Custom Weather Plugin - Sparkling Ice Weather
# Tiny glittering ice crystals hang nearly static in the air. No battle effects.
#===============================================================================

SPARKLE_SPRITE_COUNT = 200

class Spriteset_Map
  def sparkle_make_bitmaps
    @sparkle_bitmaps = []
    [
      { w: 1, h: 1, color: Color.new(255, 255, 255, 230) },
      { w: 1, h: 1, color: Color.new(200, 235, 255, 200) },
      { w: 3, h: 3, color: Color.new(255, 255, 255, 220), cross: true },
      { w: 3, h: 3, color: Color.new(180, 220, 255, 190), cross: true },
      { w: 2, h: 2, color: Color.new(220, 245, 255, 210) },
    ].each do |data|
      bm = Bitmap.new([data[:w], 1].max, [data[:h], 1].max)
      if data[:cross] && data[:w] == 3
        bm.set_pixel(1, 0, data[:color])
        bm.fill_rect(0, 1, 3, 1, data[:color])
        bm.set_pixel(1, 2, data[:color])
      else
        bm.fill_rect(0, 0, data[:w], data[:h], data[:color])
      end
      @sparkle_bitmaps.push(bm)
    end
  end

  def sparkle_setup_layer
    @sparkle_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @sparkle_viewport.z = 200
    SPARKLE_SPRITE_COUNT.times do
      sprite         = Sprite.new(@sparkle_viewport)
      sprite.z       = 1000
      sprite.bitmap  = @sparkle_bitmaps[rand(@sparkle_bitmaps.size)]
      sprite.x       = rand(Graphics.width)
      sprite.y       = rand(Graphics.height)
      sprite.opacity = rand(200) + 30
      @sparkle_sprites.push(sprite)
      @sparkle_info.push(rand(120))
    end
    @sparkle_active = true
  end

  def sparkle_update_sprites
    frame = Graphics.frame_count
    @sparkle_sprites.each_with_index do |sprite, i|
      @sparkle_info[i] = (@sparkle_info[i] + 1) % 120
      phase = @sparkle_info[i]
      if    phase < 30  then sprite.opacity += 3
      elsif phase < 60  then sprite.opacity -= 1
      elsif phase < 90  then sprite.opacity -= 3
      else                   sprite.opacity += 1
      end
      sprite.y += 1 if (frame + @sparkle_info[i]) % 4 == 0
      sprite.x += (rand(3) - 1) if frame % 30 == @sparkle_info[i] % 30
      if sprite.opacity <= 0 || sprite.y > Graphics.height
        sprite.opacity   = rand(60) + 10
        sprite.x         = rand(Graphics.width)
        sprite.y         = -sprite.bitmap.height
        sprite.bitmap    = @sparkle_bitmaps[rand(@sparkle_bitmaps.size)]
        @sparkle_info[i] = 0
      end
    end
  end

  def sparkle_clear_layer
    @sparkle_sprites.each { |s| s.dispose }
    @sparkle_sprites.clear
    @sparkle_info.clear
    @sparkle_viewport.dispose if @sparkle_viewport
    @sparkle_viewport = nil
    @sparkle_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:SparklingIce) do |spriteset|
  spriteset.instance_eval do
    unless @sparkle_bitmaps
      @sparkle_sprites  = []
      @sparkle_info     = []
      @sparkle_viewport = nil
      @sparkle_active   = false
      sparkle_make_bitmaps
    end
    if $game_screen.weather_type == :SparklingIce
      sparkle_setup_layer unless @sparkle_active
      sparkle_update_sprites
    elsif @sparkle_active
      sparkle_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:SparklingIce) do |spriteset|
  spriteset.instance_eval do
    sparkle_clear_layer if @sparkle_active
    if @sparkle_bitmaps
      @sparkle_bitmaps.each { |bm| bm.dispose }
      @sparkle_bitmaps.clear
    end
  end
end

#===============================================================================
# Register Overworld & Battle Weather
#===============================================================================
CustomWeather.register_weather(
  { :id => :SparklingIce, :id_number => 15, :category => :None, :graphics => [],
    :tone_proc => proc { |strength| Tone.new(strength / 5, strength / 5, strength / 3, strength / 6) } },
  { :id => :SparklingIce, :name => _INTL("Sparkling Ice"), :animation => "SparklingIce" }
)

CustomWeather::Handlers::StartMessage.add(:SparklingIce,
  proc { |weather, battle| next _INTL("Ice crystals began glittering in the air!") })
CustomWeather::Handlers::ContinueMessage.add(:SparklingIce,
  proc { |weather, battle| next _INTL("Tiny ice crystals glitter in the cold air.") })
CustomWeather::Handlers::EndMessage.add(:SparklingIce,
  proc { |weather, battle| next _INTL("The glittering crystals melted away.") })
