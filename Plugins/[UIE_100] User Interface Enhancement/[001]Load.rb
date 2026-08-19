#===============================================================================
#                          Custom Load Screen
#                               V 1.0.9
#                        Developed by Carmaniac
#===============================================================================
class PokemonLoad_Scene

  LOAD_FOLDER = "Graphics/Custom UI/Load/"

  # Button text colours
  TEXTBUTTON_COLOR        = Color.new(0, 0, 0)
  TEXTBUTTON_SHADOW_COLOR = Color.new(136, 136, 136)

  # Trainer card text colours
  TEXT_COLOR               = Color.new(232, 232, 232)
  TEXT_SHADOW_COLOR        = Color.new(136, 136, 136)
  MALE_TEXT_COLOR          = Color.new(56, 160, 248)
  MALE_TEXT_SHADOW_COLOR   = Color.new(56, 104, 168)
  FEMALE_TEXT_COLOR        = Color.new(240, 72, 88)
  FEMALE_TEXT_SHADOW_COLOR = Color.new(160, 64, 64)

  # Button layout — save file exists
  CONTINUE_BTN_W = 260
  CONTINUE_BTN_H = 58
  CONTINUE_BTN_X = 512
  CONTINUE_BTN_Y = 96

  # Button layout — no save file
  NEWGAME_BTN_W = 424
  NEWGAME_BTN_H = 58
  NEWGAME_BTN_X = 188
  NEWGAME_BTN_Y = 140

  BTN_GAP      = 12
  VISIBLE_BTNS = 4

  #-----------------------------------------------------------------------------
  # Override pbStartScene — builds custom UI instead of vanilla panels
  #-----------------------------------------------------------------------------
  alias custom_load_pbStartScene pbStartScene
  def pbStartScene(commands, show_continue, trainer, stats, map_id)
    @commands      = commands
    @show_continue = show_continue
    @sprites       = {}
    @trainer       = trainer
    @mapid         = map_id
    @totalsec      = stats&.play_time.to_i || 0

    # Viewports — layered from back to front
    @vp_grid        = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_grid.z      = 100
    @vp_bg          = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_bg.z        = 101
    @vp_card        = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_card.z      = 102
    @vp_buttons     = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_buttons.z   = 103
    @vp_overlay     = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_overlay.z   = 104
    @card_overlay   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @card_overlay.z = 105

    # Grid — always, scrolls left each frame
    @sprites["grid"] = IconSprite.new(@vp_grid)
    @sprites["grid"].setBitmap(LOAD_FOLDER + "Grid.png")
    @sprites["grid"].x = 0
    @sprites["grid"].y = 0
    @sprites["grid"].z = 0

    # Background — always, static
    @sprites["background"] = IconSprite.new(@vp_bg)
    @sprites["background"].setBitmap(LOAD_FOLDER + "Background.png")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 0

    if show_continue
      # Trainer card
      @sprites["trainercard"] = IconSprite.new(@vp_card)
      @sprites["trainercard"].setBitmap(LOAD_FOLDER + "TrainerCard.png")
      @sprites["trainercard"].x = 4
      @sprites["trainercard"].y = 68
      @sprites["trainercard"].z = 0

      # Snapshot — crops 128x128 from center of 800x480 screenshot
      if File.exist?(LOAD_FOLDER + "temp.png")
        @sprites["snapshot"] = Sprite.new(@vp_card)
        @sprites["snapshot"].bitmap = Bitmap.new(LOAD_FOLDER + "temp.png")
        @sprites["snapshot"].src_rect.set(336, 176, 128, 128)
        @sprites["snapshot"].x = 58
        @sprites["snapshot"].y = 124
        @sprites["snapshot"].z = 1
      end

      pbBuildTrainerCardText
    end

    # Button starting position
    # Save file — fixed positions
    # No save file — auto centered vertically in 800x366 area at x=0, y=42
    @btn_sprites = []
    @btn_scroll  = 0
    @btn_target  = 0
    btn_w    = show_continue ? CONTINUE_BTN_W : NEWGAME_BTN_W
    @btn_h   = show_continue ? CONTINUE_BTN_H : NEWGAME_BTN_H
    @btn_x   = show_continue ? CONTINUE_BTN_X : 188
    btn_file = show_continue ? "Continue.png" : "Newgame.png"
    if show_continue
      @btn_y = CONTINUE_BTN_Y
    else
      area_y   = 42
      area_h   = 366
      total_h  = (commands.length * @btn_h) + ((commands.length - 1) * BTN_GAP)
      @btn_y   = area_y + ((area_h - total_h) / 2)
      @btn_y   = [@btn_y, 0].max
    end
    commands.length.times do |i|
      base = Bitmap.new(LOAD_FOLDER + btn_file)
      bmp  = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      pbSetSystemFont(bmp)
      cx = bmp.width / 2
      text_width = bmp.text_size(commands[i].upcase).width
      left_x = cx - (text_width / 2)
      left_x -= 1 if left_x.odd?
      cy = (bmp.height / 2) - 14
      pbDrawTextPositions(bmp, [[commands[i].upcase, left_x, cy, :left, TEXTBUTTON_COLOR, TEXTBUTTON_SHADOW_COLOR]])
      spr = Sprite.new(@vp_buttons)
      spr.bitmap  = bmp
      spr.x       = @btn_x
      spr.y       = @btn_y + (i * (@btn_h + BTN_GAP))
      spr.z       = 0
      spr.opacity = 100
      @btn_sprites << spr
    end

    # Hidden command window — still needed for vanilla logic compatibility
    @sprites["cmdwindow"] = Window_CommandPokemon.new(commands)
    @sprites["cmdwindow"].viewport = @vp_overlay
    @sprites["cmdwindow"].visible  = false

    # Grid scroll width for wrap-around
    gridBitmap       = @sprites["grid"].bitmap
    @gridScrollWidth = gridBitmap ? gridBitmap.width / 2 : 512

    # Visual index — persist between scene instances
    @@savedVisualIndex ||= 0
    @visualIndex  = [@@savedVisualIndex, commands.length - 1].min
    @last_mouse_x = Input.mouse_x
    @last_mouse_y = Input.mouse_y
    @mouse_moved  = false
  end

  #-----------------------------------------------------------------------------
  # Build trainer card text overlay
  #-----------------------------------------------------------------------------
  def pbBuildTrainerCardText
    @sprites["trainerOverlay"]&.bitmap&.dispose
    @sprites["trainerOverlay"]&.dispose
    bmp = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(bmp)
    textPos = []
    textPos.push([_INTL("Badges:"),              250, 120 + 68, :left,  TEXT_COLOR, TEXT_SHADOW_COLOR])
    textPos.push([@trainer.badge_count.to_s,      450, 120 + 68, :right, TEXT_COLOR, TEXT_SHADOW_COLOR])
    textPos.push([_INTL("Pokédex:"),             250, 152 + 68, :left,  TEXT_COLOR, TEXT_SHADOW_COLOR])
    textPos.push([@trainer.pokedex.seen_count.to_s, 450, 152 + 68, :right, TEXT_COLOR, TEXT_SHADOW_COLOR])
    textPos.push([_INTL("Time:"),                250, 184 + 68, :left,  TEXT_COLOR, TEXT_SHADOW_COLOR])
    hour = @totalsec / 60 / 60
    min  = @totalsec / 60 % 60
    if hour > 0
      textPos.push([_INTL("{1}h {2}m", hour, min), 450, 184 + 68, :right, TEXT_COLOR, TEXT_SHADOW_COLOR])
    else
      textPos.push([_INTL("{1}m", min),             450, 184 + 68, :right, TEXT_COLOR, TEXT_SHADOW_COLOR])
    end
    if @trainer.male?
      textPos.push([@trainer.name, 250, 86 + 68, :left, MALE_TEXT_COLOR,   MALE_TEXT_SHADOW_COLOR])
    elsif @trainer.female?
      textPos.push([@trainer.name, 250, 86 + 68, :left, FEMALE_TEXT_COLOR, FEMALE_TEXT_SHADOW_COLOR])
    else
      textPos.push([@trainer.name, 250, 86 + 68, :left, TEXT_COLOR,        TEXT_SHADOW_COLOR])
    end
    mapname = pbGetMapNameFromId(@mapid)
    mapname.gsub!(/\\PN/, @trainer.name)
    textPos.push([mapname, 250, 52 + 68, :left, TEXT_COLOR, TEXT_SHADOW_COLOR])
    pbDrawTextPositions(bmp, textPos)
    @sprites["trainerOverlay"] = Sprite.new(@card_overlay)
    @sprites["trainerOverlay"].bitmap = bmp
    @sprites["trainerOverlay"].z = 1
  end

  #-----------------------------------------------------------------------------
  # Override pbSetParty
  #-----------------------------------------------------------------------------
  alias custom_load_pbSetParty pbSetParty
  def pbSetParty(trainer)
    return if !trainer || !trainer.party
    trainer.party.each_with_index do |pkmn, i|
      @sprites["party#{i}"] = PokemonIconSprite.new(pkmn, @vp_overlay)
      @sprites["party#{i}"].setOffset(PictureOrigin::CENTER)
      @sprites["party#{i}"].x = 96 + (66 * (i % 6))
      @sprites["party#{i}"].y = 316
      @sprites["party#{i}"].z = 99999
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbStartScene2 — fade in
  #-----------------------------------------------------------------------------
  alias custom_load_pbStartScene2 pbStartScene2
  def pbStartScene2
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  #-----------------------------------------------------------------------------
  # Update button positions based on scroll offset
  #-----------------------------------------------------------------------------
  def pbUpdateButtonPositions
    @btn_sprites.each_with_index do |spr, i|
      next if !spr
      vis_pos     = i - @btn_scroll
      spr.y       = @btn_y + (vis_pos * (@btn_h + BTN_GAP))
      spr.visible = (vis_pos >= 0 && vis_pos < VISIBLE_BTNS)
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbUpdate — grid scroll + mouse hover + scroll + opacity
  #-----------------------------------------------------------------------------
  alias custom_load_pbUpdate pbUpdate
  def pbUpdate
    # Scroll grid
    if @sprites["grid"]
      @sprites["grid"].x -= 1
      @sprites["grid"].x = 0 if @sprites["grid"].x <= -(@gridScrollWidth || 512)
    end

    # Smooth scroll towards target
    if @btn_scroll < @btn_target
      @btn_scroll = [@btn_scroll + 1, @btn_target].min
    elsif @btn_scroll > @btn_target
      @btn_scroll = [@btn_scroll - 1, @btn_target].max
    end

    pbUpdateButtonPositions

    # Mouse movement tracking
    cur_x = Input.mouse_x
    cur_y = Input.mouse_y
    @mouse_moved  = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
    @last_mouse_x = cur_x
    @last_mouse_y = cur_y

    # Mouse hover updates visual index only if mouse moved
    if @mouse_moved
      @btn_sprites.each_with_index do |spr, i|
        next if !spr || !spr.visible
        @visualIndex = i if Mouse.over?(spr)
      end
    end

    # Ensure highlighted button is visible, scroll if needed
    if @visualIndex < @btn_target
      @btn_target = @visualIndex
    elsif @visualIndex >= @btn_target + VISIBLE_BTNS
      @btn_target = @visualIndex - VISIBLE_BTNS + 1
    end
    max_scroll  = [@commands.length - VISIBLE_BTNS, 0].max
    @btn_target = @btn_target.clamp(0, max_scroll)

    # Opacity reflects current visual index
    @btn_sprites.each_with_index do |spr, i|
      next if !spr
      target      = (@visualIndex == i) ? 255 : 100
      spr.opacity += (target - spr.opacity) / 10
    end

    # Mouse wheel scroll
    if Mouse.scroll_up?
      if @btn_target > 0
        @btn_target -= 1
        @visualIndex = @btn_target + VISIBLE_BTNS - 1 if @visualIndex >= @btn_target + VISIBLE_BTNS
      end
    elsif Mouse.scroll_down?
      max_scroll = [@commands.length - VISIBLE_BTNS, 0].max
      if @btn_target < max_scroll
        @btn_target += 1
        @visualIndex = @btn_target if @visualIndex < @btn_target
      end
    end

    pbUpdateSpriteHash(@sprites)
  end

  #-----------------------------------------------------------------------------
  # Override pbChoose — keyboard + mouse click support with scroll
  #-----------------------------------------------------------------------------
  alias custom_load_pbChoose pbChoose
  def pbChoose(commands)
    @sprites["cmdwindow"].commands = commands
    @visualIndex = [@@savedVisualIndex || 0, commands.length - 1].min
    loop do
      Graphics.update
      Input.update
      pbUpdate
      # Keyboard navigation — bounded
      if Input.trigger?(Input::UP)
        if @visualIndex > 0
          @visualIndex  -= 1
          @mouse_moved   = false
          @@savedVisualIndex = @visualIndex
          pbPlayCursorSE
        end
      elsif Input.trigger?(Input::DOWN)
        if @visualIndex < commands.length - 1
          @visualIndex  += 1
          @mouse_moved   = false
          @@savedVisualIndex = @visualIndex
          pbPlayCursorSE
        end
      end
      # Keyboard confirm
      if Input.trigger?(Input::USE)
        @@savedVisualIndex = @visualIndex
        return @visualIndex
      end
      # Mouse click
      @btn_sprites.each_with_index do |spr, i|
        next if !spr || !spr.visible
        if Mouse.over?(spr) && Mouse.click?
          @visualIndex       = i
          @@savedVisualIndex = i
          return i
        end
      end
      # Back
      if Input.trigger?(Input::BACK)
        return -1
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbEndScene — fade out and dispose
  #-----------------------------------------------------------------------------
  alias custom_load_pbEndScene pbEndScene
  def pbEndScene
    @btn_sprites&.each_with_index { |s, i| @sprites["_btn#{i}"] = s if s }
    pbFadeOutAndHide(@sprites) { pbUpdate }
    @sprites.delete_if { |k, _| k.start_with?("_") }
    @btn_sprites&.each { |s| s&.bitmap&.dispose; s&.dispose }
    @sprites["snapshot"]&.bitmap&.dispose
    @sprites["trainerOverlay"]&.bitmap&.dispose
    pbDisposeSpriteHash(@sprites)
    @vp_grid&.dispose
    @vp_bg&.dispose
    @vp_card&.dispose
    @vp_buttons&.dispose
    @vp_overlay&.dispose
    @card_overlay&.dispose
  end

  #-----------------------------------------------------------------------------
  # Override pbCloseScene — dispose without fade
  #-----------------------------------------------------------------------------
  alias custom_load_pbCloseScene pbCloseScene
  def pbCloseScene
    @btn_sprites&.each { |s| s&.bitmap&.dispose; s&.dispose }
    @sprites["snapshot"]&.bitmap&.dispose
    @sprites["trainerOverlay"]&.bitmap&.dispose
    pbDisposeSpriteHash(@sprites)
    @vp_grid&.dispose
    @vp_bg&.dispose
    @vp_card&.dispose
    @vp_buttons&.dispose
    @vp_overlay&.dispose
    @card_overlay&.dispose
  end

end