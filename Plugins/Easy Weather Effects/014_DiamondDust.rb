
DIAMOND_DUST_SPRITE_COUNT = 180

class Spriteset_Map
  def diamond_dust_make_bitmaps
    @diamond_dust_bitmaps = []

    colours = [
      [Color.new(200, 230, 255,  80), Color.new(230, 245, 255, 160), Color.new(255, 255, 255, 220)],  # cool white
      [Color.new(180, 215, 255,  70), Color.new(210, 235, 255, 150), Color.new(245, 252, 255, 210)],  # icy blue
      [Color.new(220, 240, 255,  90), Color.new(240, 250, 255, 170), Color.new(255, 255, 255, 240)],  # pure white
    ]

    colours.each do |dim, bright, core|
      bm = Bitmap.new(3, 3)
      bm.set_pixel(1, 1, dim)
      @diamond_dust_bitmaps.push(bm)

      bm = Bitmap.new(3, 3)
      bm.set_pixel(1, 1, bright)
      @diamond_dust_bitmaps.push(bm)

      bm = Bitmap.new(5, 5)
      bm.fill_rect(2, 1, 1, 3, bright)
      bm.fill_rect(1, 2, 3, 1, bright)
      bm.set_pixel(2, 2, core)
      @diamond_dust_bitmaps.push(bm)

      bm = Bitmap.new(9, 9)
      bm.fill_rect(4, 0, 1, 9, dim)     # vertical arm (full length, dim)
      bm.fill_rect(0, 4, 9, 1, dim)     # horizontal arm (full length, dim)
      bm.fill_rect(4, 1, 1, 7, bright)  # vertical bright inner
      bm.fill_rect(1, 4, 7, 1, bright)  # horizontal bright inner
      bm.fill_rect(4, 2, 1, 5, core)    # core strip vertical
      bm.fill_rect(2, 4, 5, 1, core)    # core strip horizontal
      bm.set_pixel(4, 4, core)          # centre
      bm.set_pixel(2, 2, dim)
      bm.set_pixel(6, 2, dim)
      bm.set_pixel(2, 6, dim)
      bm.set_pixel(6, 6, dim)
      @diamond_dust_bitmaps.push(bm)

      bm = Bitmap.new(5, 5)
      bm.fill_rect(2, 1, 1, 3, dim)
      bm.fill_rect(1, 2, 3, 1, dim)
      bm.set_pixel(2, 2, bright)
      @diamond_dust_bitmaps.push(bm)
    end

    @diamond_dust_frames = 5          # frames per colour
    @diamond_dust_colours = colours.size
  end

  def diamond_dust_setup_layer
    @diamond_dust_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @diamond_dust_viewport.z = 200

    DIAMOND_DUST_SPRITE_COUNT.times do
      colour  = rand(@diamond_dust_colours)
      frame   = rand(@diamond_dust_frames)
      bm_idx  = colour * @diamond_dust_frames + frame
      sprite         = Sprite.new(@diamond_dust_viewport)
      sprite.z       = 1000
      sprite.bitmap  = @diamond_dust_bitmaps[bm_idx]
      sprite.opacity = rand(180) + 40

      wx = cw_map_offset_x + rand(Graphics.width)
      wy = cw_map_offset_y + rand(Graphics.height)
      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      fall_delay = rand(4) + 1
      countdown  = rand(20) + 8
      @diamond_dust_info.push([colour, frame, countdown, rand(20) + 8, fall_delay, wx, wy])
      @diamond_dust_sprites.push(sprite)
    end

    @diamond_dust_active = true
  end

  def diamond_dust_update_sprites
    @diamond_dust_sprites.each_with_index do |sprite, i|
      colour, frame, countdown, cycle_len, fall_delay, wx, wy = @diamond_dust_info[i]

      wy += 1 if Graphics.frame_count % fall_delay == i % fall_delay
      wx += 1 if Graphics.frame_count % (fall_delay * 3) == i % (fall_delay * 3)
      wx -= 1 if Graphics.frame_count % (fall_delay * 5) == i % (fall_delay * 5)

      countdown -= 1
      if countdown <= 0
        frame    = (frame + 1) % @diamond_dust_frames
        bm_idx   = colour * @diamond_dust_frames + frame
        sprite.bitmap = @diamond_dust_bitmaps[bm_idx]
        countdown = cycle_len
        case frame
        when 3 then sprite.opacity = rand(80) + 160
        when 0 then sprite.opacity = rand(60) + 20
        else        sprite.opacity = rand(100) + 80
        end
      end

      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @diamond_dust_info[i] = [colour, frame, countdown, cycle_len, fall_delay, wx, wy]

      if sprite.y > Graphics.height + 10
        colour     = rand(@diamond_dust_colours)
        sprite.bitmap = @diamond_dust_bitmaps[colour * @diamond_dust_frames]
        wx = cw_map_offset_x + rand(Graphics.width)
        wy = cw_map_offset_y + (-10 - rand(20))
        sprite.x   = cw_world_to_screen_x(wx)
        sprite.y   = cw_world_to_screen_y(wy)
        sprite.opacity = rand(60) + 20
        @diamond_dust_info[i] = [colour, 0, rand(20) + 8, rand(20) + 8, rand(4) + 1, wx, wy]
      end
    end
  end

  def diamond_dust_clear_layer
    @diamond_dust_sprites.each { |s| s.dispose }
    @diamond_dust_sprites.clear
    @diamond_dust_info.clear
    @diamond_dust_viewport.dispose if @diamond_dust_viewport
    @diamond_dust_viewport = nil
    @diamond_dust_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:DiamondDust) do |spriteset|
  spriteset.instance_eval do
    unless @diamond_dust_bitmaps
      @diamond_dust_bitmaps  = []
      @diamond_dust_sprites  = []
      @diamond_dust_info     = []
      @diamond_dust_frames   = 5
      @diamond_dust_colours  = 3
      @diamond_dust_viewport = nil
      @diamond_dust_active   = false
      diamond_dust_make_bitmaps
    end
    if $game_screen.weather_type == :DiamondDust
      diamond_dust_setup_layer unless @diamond_dust_active
      diamond_dust_update_sprites
    elsif @diamond_dust_active
      diamond_dust_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:DiamondDust) do |spriteset|
  spriteset.instance_eval do
    diamond_dust_clear_layer if @diamond_dust_active
    if @diamond_dust_bitmaps
      @diamond_dust_bitmaps.each { |bm| bm.dispose }
      @diamond_dust_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :DiamondDust, :id_number => 13, :category => :Hail, :graphics => [],
    :tone_proc => proc { |strength|
      Tone.new(strength / 5, strength / 5, strength / 3, strength / 5)
    }
  },
  { :id => :DiamondDust, :name => _INTL("Diamond Dust"), :animation => "DiamondDust" }
)

CustomWeather::Handlers::StartMessage.add(:DiamondDust,
  proc { |weather, battle| next _INTL("There is a crystalline fog!") })
CustomWeather::Handlers::ContinueMessage.add(:DiamondDust,
  proc { |weather, battle| next _INTL("The crystals hang in the air!") })
CustomWeather::Handlers::EndMessage.add(:DiamondDust,
  proc { |weather, battle| next _INTL("The diamond dust settled.") })
CustomWeather::Handlers::DamageImmunity.add(:DiamondDust,
  proc { |weather, battler|
    next true if battler.pbHasType?(:ROCK)
    next true if battler.pbHasType?(:ICE)
    next true if battler.hasActiveAbility?([:OVERCOAT, :IMMUNITY, :ICEBODY, :SNOWCLOAK, :MAGICGUARD])
    next true if battler.hasActiveItem?(:SAFETYGOGGLES)
    next false
  })
CustomWeather::Handlers::EORDamage.add(:DiamondDust,
  proc { |weather, battler, battle|
    next if battler.fainted?
    next if CustomWeather::Handlers.triggerDamageImmunity(:DiamondDust, battler)
    next if !battler.takesIndirectDamage?
    battle.pbDisplay(_INTL("{1} is hit by the hard crystals!", battler.pbThis))
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp / 16, false)
  })
