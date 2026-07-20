
EMBER_SPRITE_COUNT = 150

class Spriteset_Map
  def ember_make_bitmaps
    @ember_bitmaps = []
    [
      [4, 4, Color.new(255, 120,  20, 240), Color.new(255, 200,  60, 120)],
      [3, 3, Color.new(255,  80,  10, 220), Color.new(255, 160,  40, 100)],
      [5, 5, Color.new(255, 160,  40, 230), Color.new(255, 220, 100, 110)],
      [3, 4, Color.new(220,  60,   5, 200), Color.new(255, 140,  30,  90)],
      [4, 3, Color.new(255, 200,  80, 250), Color.new(255, 240, 160, 130)],
    ].each do |w, h, core, glow|
      bm = Bitmap.new(w + 2, h + 2)
      bm.fill_rect(0,     0,     w + 2, 1, glow)
      bm.fill_rect(0,     h + 1, w + 2, 1, glow)
      bm.fill_rect(0,     1,     1,     h, glow)
      bm.fill_rect(w + 1, 1,     1,     h, glow)
      bm.fill_rect(1, 1, w, h, core)
      @ember_bitmaps.push(bm)
    end
  end

  def ember_setup_layer
    @ember_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @ember_viewport.z = 200
    EMBER_SPRITE_COUNT.times do
      sprite         = Sprite.new(@ember_viewport)
      sprite.z       = 1000
      sprite.bitmap  = @ember_bitmaps[rand(@ember_bitmaps.size)]
      sprite.opacity = rand(140) + 20

      wx = cw_map_offset_x + rand(Graphics.width + 200) - 100
      wy = cw_map_offset_y + rand(Graphics.height)
      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @ember_sprites.push(sprite)
      @ember_info.push([rand(3), wx, wy])
      @ember_phase.push(rand(60))
    end
    @ember_active = true
  end

  def ember_update_sprites
    @ember_sprites.each_with_index do |sprite, i|
      rise, wx, wy = @ember_info[i]

      wy -= (rise % 3) + 1
      @ember_phase[i] = (@ember_phase[i] + 1) % 60
      wx -= 1 if @ember_phase[i] < 15
      wx += 1 if @ember_phase[i] >= 45

      sprite.opacity -= 2
      sprite.opacity += rand(6) - 2

      sprite.x = cw_world_to_screen_x(wx)
      sprite.y = cw_world_to_screen_y(wy)

      @ember_info[i] = [rise, wx, wy]

      if sprite.opacity <= 0 || sprite.y < -sprite.bitmap.height
        sprite.opacity  = rand(80) + 80
        sprite.bitmap   = @ember_bitmaps[rand(@ember_bitmaps.size)]
        wx = cw_map_offset_x + rand(Graphics.width + 200) - 100
        wy = cw_map_offset_y + Graphics.height + rand(30)
        sprite.x        = cw_world_to_screen_x(wx)
        sprite.y        = cw_world_to_screen_y(wy)
        @ember_info[i]  = [rand(3), wx, wy]
        @ember_phase[i] = rand(60)
      end
    end
  end

  def ember_clear_layer
    @ember_sprites.each { |s| s.dispose }
    @ember_sprites.clear
    @ember_info.clear
    @ember_phase.clear
    @ember_viewport.dispose if @ember_viewport
    @ember_viewport = nil
    @ember_active   = false
  end
end

CustomWeather::SpritesetHandlers.register(:Embers) do |spriteset|
  spriteset.instance_eval do
    unless @ember_bitmaps
      @ember_bitmaps  = []
      @ember_sprites  = []
      @ember_info     = []
      @ember_phase    = []
      @ember_viewport = nil
      @ember_active   = false
      ember_make_bitmaps
    end

    if $game_screen.weather_type == :Embers
      ember_setup_layer unless @ember_active
      ember_update_sprites
    elsif @ember_active
      ember_clear_layer
    end
  end
end

CustomWeather::SpritesetHandlers.register_dispose(:Embers) do |spriteset|
  spriteset.instance_eval do
    ember_clear_layer if @ember_active
    if @ember_bitmaps
      @ember_bitmaps.each { |bm| bm.dispose }
      @ember_bitmaps.clear
    end
  end
end

CustomWeather.register_weather(
  { :id => :Embers, :id_number => 14, :category => :None, :graphics => [],
    :tone_proc => proc { |strength| Tone.new(strength / 3, -strength / 6, -strength / 3, 0) } },
  { :id => :Embers, :name => _INTL("Embers"), :animation => "Embers" }
)

CustomWeather::Handlers::StartMessage.add(:Embers,
  proc { |weather, battle| next _INTL("Glowing embers rained down from the sky!") })
CustomWeather::Handlers::ContinueMessage.add(:Embers,
  proc { |weather, battle| next _INTL("Embers continued to rain down!") })
CustomWeather::Handlers::EndMessage.add(:Embers,
  proc { |weather, battle| next _INTL("The embers faded and went cold.") })
CustomWeather::Handlers::DamageImmunity.add(:Embers,
  proc { |weather, battler|
    next true if battler.pbHasType?(:FIRE)
    next true if battler.pbHasType?(:ROCK)
    next true if battler.hasActiveAbility?([:OVERCOAT, :FLASHFIRE, :THICKFAT])
    next true if battler.hasActiveItem?(:SAFETYGOGGLES)
    next false
  })
CustomWeather::Handlers::EORDamage.add(:Embers,
  proc { |weather, battler, battle|
    next if battler.fainted?
    next if CustomWeather::Handlers.triggerDamageImmunity(:Embers, battler)
    next if !battler.takesIndirectDamage?
    battle.pbDisplay(_INTL("{1} is scorched by the falling embers!", battler.pbThis))
    battle.scene.pbDamageAnimation(battler)
    battler.pbReduceHP(battler.totalhp / 16, false)
  })
CustomWeather::Handlers::TypeBoost.add(:Embers,
  proc { |weather, move_type, user, target|
    next 1.5 if move_type == :FIRE
    next 1.0
  })
