
PETAL_SPRITE_COUNT = 160

class Spriteset_Map
  def petal_make_bitmaps
    @petal_bitmaps = []

    palettes = {
      crimson: [
        Color.new(185,  45,  45, 225),   # core
        Color.new(230, 105,  90, 205),   # highlight
        Color.new(110,  10,  10, 215),   # shadow
        Color.new(210,  80,  70, 185),   # vein
      ],
      rose: [
        Color.new(215, 110, 130, 215),   # core
        Color.new(248, 178, 190, 205),   # highlight
        Color.new(155,  60,  80, 200),   # shadow
        Color.new(235, 145, 162, 185),   # vein
      ],
      blue: [
        Color.new(100, 140, 195, 215),   # core
        Color.new(160, 200, 238, 205),   # highlight
        Color.new( 50,  80, 140, 205),   # shadow
        Color.new(130, 168, 215, 185),   # vein
      ],
    }

    shapes = [
      { w: 10, h: 8, rows: [
        [0, 3, 4],
        [1, 2, 6],
        [2, 1, 8],
        [3, 1, 8],
        [4, 2, 6],
        [5, 3, 4],
        [6, 4, 2],
        [7, 4, 1],  # tip
      ]},
      { w: 6, h: 9, rows: [
        [0, 2, 2],
        [1, 1, 4],
        [2, 0, 6],
        [3, 0, 6],
        [4, 0, 6],
        [5, 1, 4],
        [6, 2, 2],
        [7, 2, 2],
        [8, 2, 1],  # tip
      ]},
      { w: 8, h: 9, rows: [
        [0, 2, 4],
        [1, 1, 6],
        [2, 0, 8],
        [3, 0, 8],
        [4, 1, 6],
        [5, 2, 4],
        [6, 3, 3],
        [7, 3, 2],
        [8, 3, 1],  # tip
      ]},
      { w: 7, h: 7, rows: [
        [0, 2, 3],
        [1, 1, 5],
        [2, 0, 7],
        [3, 0, 7],
        [4, 1, 5],
        [5, 3, 2],
        [6, 3, 1],  # tip
      ]},
      { w: 5, h: 10, rows: [
        [0, 1, 3],
        [1, 0, 5],
        [2, 0, 5],
        [3, 0, 5],
        [4, 0, 5],
        [5, 0, 5],
        [6, 1, 3],
        [7, 1, 3],
        [8, 1, 2],
        [9, 2, 1],  # tip
      ]},
    ]

    palettes.each do |_name, (core, highlight, shadow, vein)|
      shapes.each do |shape|
        bm    = Bitmap.new(shape[:w], shape[:h])
        mid_y = shape[:h] / 2

        shape[:rows].each do |ry, rx, rw|
          bm.fill_rect(rx, ry, rw, 1, core)

          if rw > 1
            bm.set_pixel(rx,          ry, shadow)
            bm.set_pixel(rx + rw - 1, ry, shadow)
          end

          if ry < mid_y
            bm.set_pixel(rx + 1,      ry, highlight) if rw > 3
            bm.set_pixel(rx + rw - 2, ry, highlight) if rw > 4
          end
        end

        shape[:rows].each do |ry, rx, rw|
          next if rw < 2
          bm.set_pixel(rx + rw / 2, ry, vein)
        end

        @petal_bitmaps.push(bm)
      end
    end
  end

  def petal_setup_layer
    @petal_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @petal_viewport.z = 200
    PETAL_SPRITE_COUNT.times do
      bm             = @petal_bitmaps[rand(@petal_bitmaps.size)]
      sprite         = Sprite.new(@petal_viewport)
      sprite.z       = 1000
      sprite.bitmap  = bm
      sprite.ox      = bm.width  / 2
      sprite.oy      = bm.height / 2
      sprite.angle   = rand(360)
      sprite.opacity = rand(170) + 50

      wx = cw_map_offset_x + rand(Graphics.width  + 40) - 20
      wy = cw_map_offset_y + rand(Graphics.height)
      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @petal_sprites.push(sprite)
      angle_speed = (rand(30) - 15) * 0.1
      @petal_info.push([rand(2) + 1, rand(140), rand(60), sprite.angle.to_f, angle_speed, wx, wy])
    end
    @petal_active = true
  end

  def petal_update_sprites
    @petal_sprites.each_with_index do |sprite, i|
      speed, sway, wobble, angle, angle_speed, wx, wy = @petal_info[i]

      wy += speed == 2 ? 1 : (Graphics.frame_count % 2 == i % 2 ? 1 : 0)

      sway = (sway + 1) % 140
      wx -= 1 if sway < 35
      wx += 1 if sway >= 105

      angle += angle_speed
      sprite.angle = angle.round % 360

      wobble = (wobble + 1) % 60
      sprite.opacity += wobble < 30 ? 1 : -1

      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @petal_info[i] = [speed, sway, wobble, angle, angle_speed, wx, wy]

      if sprite.y > Graphics.height + sprite.bitmap.height
        bm             = @petal_bitmaps[rand(@petal_bitmaps.size)]
        sprite.bitmap  = bm
        sprite.ox      = bm.width  / 2
        sprite.oy      = bm.height / 2
        sprite.angle   = rand(360)
        sprite.opacity = rand(170) + 50
        wx = cw_map_offset_x + rand(Graphics.width + 40) - 20
        wy = cw_map_offset_y + (-bm.height - rand(30))
        sprite.x = cw_world_to_screen_x(wx)
        sprite.y = cw_world_to_screen_y(wy)
        new_as = (rand(30) - 15) * 0.1
        @petal_info[i] = [rand(2) + 1, rand(140), rand(60), sprite.angle.to_f, new_as, wx, wy]
      end
    end
  end

  def petal_clear_layer
    @petal_sprites.each { |s| s.dispose }
    @petal_sprites.clear
    @petal_info.clear
    @petal_viewport.dispose if @petal_viewport
    @petal_viewport = nil
    @petal_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:FallingPetals) do |spriteset|
  spriteset.instance_eval do
    unless @petal_bitmaps
      @petal_bitmaps  = []
      @petal_sprites  = []
      @petal_info     = []
      @petal_viewport = nil
      @petal_active   = false
      petal_make_bitmaps
    end
    if $game_screen.weather_type == :FallingPetals
      petal_setup_layer unless @petal_active
      petal_update_sprites
    elsif @petal_active
      petal_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:FallingPetals) do |spriteset|
  spriteset.instance_eval do
    petal_clear_layer if @petal_active
    if @petal_bitmaps
      @petal_bitmaps.each { |bm| bm.dispose }
      @petal_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :FallingPetals, :id_number => 16, :category => :None, :graphics => [],
    :tone_proc => proc { |strength| Tone.new(strength / 6, -strength / 12, -strength / 8, 0) } },
  { :id => :FallingPetals, :name => _INTL("Falling Petals"), :animation => "FallingPetals" }
)

CustomWeather::Handlers::StartMessage.add(:FallingPetals,
  proc { |weather, battle| next _INTL("Colourful petals began to flutter down!") })
CustomWeather::Handlers::ContinueMessage.add(:FallingPetals,
  proc { |weather, battle| next _INTL("Petals continue to drift gently through the air.") })
CustomWeather::Handlers::EndMessage.add(:FallingPetals,
  proc { |weather, battle| next _INTL("The petals settled on the ground.") })
