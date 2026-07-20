
GLITCH_SPRITE_COUNT = 55

GLITCH_FADE_IN   = 30
GLITCH_ACTIVE    = 150
GLITCH_FADE_OUT  = 30
GLITCH_SILENT    = 90
GLITCH_CYCLE     = GLITCH_FADE_IN + GLITCH_ACTIVE + GLITCH_FADE_OUT + GLITCH_SILENT

class Spriteset_Map
  def glitch_make_bitmaps
    @glitch_bitmaps = []

    palettes = [
      Color.new(  0, 230, 255, 255),  # cyan
      Color.new(  0, 200, 255, 255),  # cyan-blue
      Color.new( 20,  80, 255, 255),  # electric blue
      Color.new(  0,  40, 220, 255),  # deep blue
      Color.new(230,   0,  60, 255),  # red
      Color.new(200,  10,  30, 255),  # dark red
      Color.new(255,  20, 180, 255),  # magenta
      Color.new(220,   0, 200, 255),  # purple-magenta
    ]

    widths  = [18, 28, 40, 55, 75, 100, 130, 160, 200, 240, 280, 320]
    heights = [1, 1, 1, 2, 2, 3, 4]   # weighted toward thin

    palettes.each do |col|
      widths.each do |w|
        heights.each do |h|
          bm = Bitmap.new(w, h)
          fade = [w / 6, 12].min
          bm.fill_rect(fade, 0, w - fade * 2, h, col)
          fade.times do |fx|
            a = ((fx.to_f / fade) * col.alpha).round
            cap = Color.new(col.red, col.green, col.blue, a)
            bm.fill_rect(fx,             0, 1, h, cap)
            bm.fill_rect(w - 1 - fx,     0, 1, h, cap)
          end
          @glitch_bitmaps.push(bm)
        end
      end
    end
  end

  def glitch_setup_layer
    @glitch_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @glitch_viewport.z = 210
    @glitch_viewport.ox = 0

    GLITCH_SPRITE_COUNT.times do
      sprite        = Sprite.new(@glitch_viewport)
      sprite.z      = 1000
      sprite.bitmap = @glitch_bitmaps[rand(@glitch_bitmaps.size)]
      sprite.x      = rand(Graphics.width)
      sprite.y      = rand(Graphics.height)
      sprite.opacity = 0
      @glitch_sprites.push(sprite)
      @glitch_info.push([rand(20) + 5, rand(180) + 60])
    end

    @glitch_phase     = 0
    @glitch_master_op = 0
    @glitch_active    = true
  end

  def glitch_update_sprites
    @glitch_phase = (@glitch_phase + 1) % GLITCH_CYCLE

    if @glitch_phase < GLITCH_FADE_IN
      @glitch_master_op = ((@glitch_phase.to_f / GLITCH_FADE_IN) * 255).round
    elsif @glitch_phase < GLITCH_FADE_IN + GLITCH_ACTIVE
      @glitch_master_op = 220 + rand(35)
    elsif @glitch_phase < GLITCH_FADE_IN + GLITCH_ACTIVE + GLITCH_FADE_OUT
      elapsed = @glitch_phase - GLITCH_FADE_IN - GLITCH_ACTIVE
      @glitch_master_op = ((1.0 - elapsed.to_f / GLITCH_FADE_OUT) * 255).round
    else
      @glitch_master_op = 0
    end
    @glitch_master_op = @glitch_master_op.clamp(0, 255)

    in_active = (@glitch_phase >= GLITCH_FADE_IN &&
                 @glitch_phase < GLITCH_FADE_IN + GLITCH_ACTIVE)

    @glitch_sprites.each_with_index do |sprite, i|
      jump_cd, base_op = @glitch_info[i]

      if @glitch_master_op == 0
        sprite.opacity = 0
        next
      end

      if in_active
        jump_cd -= 1
        if jump_cd <= 0
          sprite.bitmap = @glitch_bitmaps[rand(@glitch_bitmaps.size)]
          sprite.x      = rand(Graphics.width + 40) - 20
          sprite.y      = rand(Graphics.height)
          base_op       = rand(180) + 60
          jump_cd       = rand(25) + 4

          sprite.x += rand(30) - 5 if rand(8) == 0
        end
        @glitch_info[i] = [jump_cd, base_op]
      end

      sprite.opacity = ((base_op / 255.0) * @glitch_master_op).round.clamp(0, 255)
    end
  end

  def glitch_clear_layer
    @glitch_sprites.each { |s| s.dispose }
    @glitch_sprites.clear
    @glitch_info.clear
    @glitch_viewport.dispose if @glitch_viewport
    @glitch_viewport  = nil
    @glitch_phase     = 0
    @glitch_master_op = 0
    @glitch_active    = false
  end
end

CustomWeather::SpritesetHandlers.register(:Glitch) do |spriteset|
  spriteset.instance_eval do
    unless @glitch_bitmaps
      @glitch_bitmaps   = []
      @glitch_sprites   = []
      @glitch_info      = []
      @glitch_viewport  = nil
      @glitch_phase     = 0
      @glitch_master_op = 0
      @glitch_active    = false
      glitch_make_bitmaps
    end
    if $game_screen.weather_type == :Glitch
      glitch_setup_layer unless @glitch_active
      glitch_update_sprites
    elsif @glitch_active
      glitch_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:Glitch) do |spriteset|
  spriteset.instance_eval do
    glitch_clear_layer if @glitch_active
    if @glitch_bitmaps
      @glitch_bitmaps.each { |bm| bm.dispose }
      @glitch_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :Glitch, :id_number => 21, :category => :None, :graphics => [],
    :tone_proc => proc { |strength|
      Tone.new(-strength / 14, -strength / 10, strength / 8, strength / 12)
    }
  },
  { :id => :Glitch, :name => _INTL("Glitch"), :animation => "Glitch" }
)

CustomWeather::Handlers::StartMessage.add(:Glitch,
  proc { |weather, battle| next _INTL("The air began to distort strangely!") })
CustomWeather::Handlers::ContinueMessage.add(:Glitch,
  proc { |weather, battle| next _INTL("Reality flickers and glitches around you.") })
CustomWeather::Handlers::EndMessage.add(:Glitch,
  proc { |weather, battle| next _INTL("The distortions faded away.") })
  
# Glitch deals extra damage.
CustomWeather::Handlers::TypeBoost.add(:Glitch,
	proc { |weather, move_type, user, target|
		next 1.3 if move_type == :GLITCH
		next 1.0
	})
