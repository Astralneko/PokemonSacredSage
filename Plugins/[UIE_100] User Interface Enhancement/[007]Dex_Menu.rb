#===============================================================================
#                        Custom Dex Menu Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
class PokemonPokedexMenu_Scene

  DEX_FOLDER   = "Graphics/Custom UI/Dex/"
  FRONT_FOLDER = "Graphics/Custom UI/Dex/Front Page/"

  GRID_SCROLL_W = 800
  SCROLL_FRAMES = 15

  # Overlay layout
  TOPOVERLAY_H         = 112
  TOPOVERLAY_REST_Y    = 0
  BOTTOMOVERLAY_REST_Y = 368

  # Cancel button
  CANCEL_X = 764
  CANCEL_Y = 8

  # Region button layout
  BTN_FOLDER   = "Graphics/Custom UI/Dex/Front Page/"
  BTN_W        = 592
  BTN_H        = 70
  BTN_X        = 104
  BTN_Y_START  = 100
  BTN_GAP      = 2
  BTN_STRIDE   = BTN_H + BTN_GAP
  BTN_MAX_H    = 286
  BTN_ACTIVE_X = 94

  # Button text
  BTN_TEXT_COLOR    = Color.new(255, 255, 255)
  BTN_TEXT_SHADOW   = Color.new(156, 156, 156)
  BTN_NAME_X        = 62
  BTN_NAME_Y        = 24
  BTN_CAUGHT_ICON_X = 362
  BTN_SEEN_ICON_X   = 450
  BTN_ICON_Y        = 16
  BTN_CAUGHT_TEXT_X = 404
  BTN_SEEN_TEXT_X   = 492
  BTN_NUM_Y         = 22

  #-----------------------------------------------------------------------------
  # Override pbUpdate
  #-----------------------------------------------------------------------------
  alias custom_dex_menu_pbUpdate pbUpdate
  def pbUpdate
    if @sprites["grid"]
      @sprites["grid"].x -= 1
      @sprites["grid"].x = 0 if @sprites["grid"].x <= -GRID_SCROLL_W
    end
    @region_btns_visible ||= false
    pbUpdateRegionButtons if @region_btns
    if @sprites["cancel"]
      if Mouse.over?(@sprites["cancel"]) && Mouse.press?
        @sprites["cancel"].setBitmap(DEX_FOLDER + "cancel_p.png")
      else
        @sprites["cancel"].setBitmap(DEX_FOLDER + "cancel.png")
      end
    end
    custom_dex_menu_pbUpdate
  end

  #-----------------------------------------------------------------------------
  # Slide overlays in — ease out
  #-----------------------------------------------------------------------------
  def pbSlideOverlaysIn
    SCROLL_FRAMES.times do |frame|
      t        = (frame + 1) / SCROLL_FRAMES.to_f
      progress = 1 - (1 - t) ** 2
      @sprites["topoverlay"].y    = -TOPOVERLAY_H + (TOPOVERLAY_H * progress).to_i
      @sprites["bottomoverlay"].y = Graphics.height - ((Graphics.height - BOTTOMOVERLAY_REST_Y) * progress).to_i
      pbUpdate
      Graphics.update
      Input.update
    end
    @sprites["topoverlay"].y    = TOPOVERLAY_REST_Y
    @sprites["bottomoverlay"].y = BOTTOMOVERLAY_REST_Y
  end

  #-----------------------------------------------------------------------------
  # Slide overlays out — ease in
  #-----------------------------------------------------------------------------
  def pbSlideOverlaysOut
    SCROLL_FRAMES.times do |frame|
      t        = (frame + 1) / SCROLL_FRAMES.to_f
      progress = t ** 2
      @sprites["topoverlay"].y    = TOPOVERLAY_REST_Y - (TOPOVERLAY_H * progress).to_i
      @sprites["bottomoverlay"].y = BOTTOMOVERLAY_REST_Y + ((Graphics.height - BOTTOMOVERLAY_REST_Y) * progress).to_i
      pbUpdate
      Graphics.update
      Input.update
    end
  end

  #-----------------------------------------------------------------------------
  # Build a button bitmap with name and stats baked in
  #-----------------------------------------------------------------------------
  def pbBuildRegionButtonBitmap(name, stats, highlighted)
    btn_file = highlighted ? "regionbutton_s.png" : "regionbutton.png"
    base = Bitmap.new(BTN_FOLDER + btn_file)
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    textPos = []
    textPos.push([name, BTN_NAME_X, BTN_NAME_Y, :left, BTN_TEXT_COLOR, BTN_TEXT_SHADOW])
    if stats
      textPos.push([stats[1].to_s, BTN_CAUGHT_TEXT_X, BTN_NUM_Y, :left, BTN_TEXT_COLOR, BTN_TEXT_SHADOW])
      textPos.push([stats[0].to_s, BTN_SEEN_TEXT_X,   BTN_NUM_Y, :left, BTN_TEXT_COLOR, BTN_TEXT_SHADOW])
    end
    pbDrawTextPositions(bmp, textPos)
    return bmp
  end

  #-----------------------------------------------------------------------------
  # Build region button sprites
  #-----------------------------------------------------------------------------
  def pbBuildRegionButtons(commands, commands2 = nil)
    @region_btns        = []
    @region_btn_bmps    = []
    @region_btn_bmps_h  = []
    @region_icon_caught = []
    @region_icon_seen   = []
    @region_index       = 0
    @region_scroll      = 0
    @last_mouse_x       = Input.mouse_x
    @last_mouse_y       = Input.mouse_y
    @mouse_moved        = false
    @region_commands    = commands
    @region_commands2   = commands2 || []
    @region_count       = [commands.length - 1, 0].max
    total_h = @region_count * BTN_STRIDE
    if total_h < BTN_MAX_H
      offset = (BTN_MAX_H - total_h) / 2
      offset -= 1 if offset.odd?
      @btn_start_y = BTN_Y_START + offset
    else
      @btn_start_y = BTN_Y_START
    end
    @btn_start_y -= 1 if @btn_start_y.odd?
    @region_count.times do |i|
      name  = commands[i]
      stats = commands2 ? commands2[i] : nil
      bmp   = pbBuildRegionButtonBitmap(name, stats, false)
      bmp_h = pbBuildRegionButtonBitmap(name, stats, true)
      @region_btn_bmps   << bmp
      @region_btn_bmps_h << bmp_h
      spr = Sprite.new(@viewport)
      spr.bitmap  = bmp
      spr.x       = BTN_X
      spr.y       = @btn_start_y + (i * BTN_STRIDE)
      spr.z       = 3
      spr.visible = false
      @region_btns << spr
      caught = IconSprite.new(@viewport)
      caught.setBitmap(DEX_FOLDER + "caughticon.png")
      caught.x       = BTN_X + BTN_CAUGHT_ICON_X
      caught.y       = @btn_start_y + (i * BTN_STRIDE) + BTN_ICON_Y
      caught.z       = 4
      caught.visible = false
      @region_icon_caught << caught
      seen = IconSprite.new(@viewport)
      seen.setBitmap(DEX_FOLDER + "seenicon.png")
      seen.x       = BTN_X + BTN_SEEN_ICON_X
      seen.y       = @btn_start_y + (i * BTN_STRIDE) + BTN_ICON_Y
      seen.z       = 4
      seen.visible = false
      @region_icon_seen << seen
    end
  end

  #-----------------------------------------------------------------------------
  # Show/hide region buttons and icons
  #-----------------------------------------------------------------------------
  def pbShowRegionButtons
    pbUpdateRegionButtons
    @region_btns.each        { |s| s.visible = true }
    @region_icon_caught.each { |s| s.visible = true }
    @region_icon_seen.each   { |s| s.visible = true }
  end

  def pbHideRegionButtons
    @region_btns.each        { |s| s.visible = false }
    @region_icon_caught.each { |s| s.visible = false }
    @region_icon_seen.each   { |s| s.visible = false }
  end

  #-----------------------------------------------------------------------------
  # Update region button positions, highlight, icons and mouse hover
  #-----------------------------------------------------------------------------
  def pbUpdateRegionButtons
    return if !@region_btns
    cur_x         = Input.mouse_x
    cur_y         = Input.mouse_y
    @mouse_moved  = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
    @last_mouse_x = cur_x
    @last_mouse_y = cur_y
    max_visible   = (BTN_MAX_H / BTN_STRIDE).floor
    if @region_index < @region_scroll
      @region_scroll = @region_index
    elsif @region_index >= @region_scroll + max_visible
      @region_scroll = @region_index - max_visible + 1
    end
    @region_btns.each_with_index do |spr, i|
      next if !spr
      vis_pos = i - @region_scroll
      visible = (vis_pos >= 0 && vis_pos < max_visible) && @region_btns_visible
      y_pos   = @btn_start_y + (vis_pos * BTN_STRIDE)
      y_pos  -= 1 if y_pos.odd?
      if i == @region_index
        spr.bitmap = @region_btn_bmps_h[i]
        spr.x      = BTN_ACTIVE_X
      else
        spr.bitmap = @region_btn_bmps[i]
        spr.x      = BTN_X
      end
      spr.y       = y_pos
      spr.visible = visible
      icon_x = (i == @region_index) ? BTN_ACTIVE_X : BTN_X
      caught = @region_icon_caught[i]
      if caught
        caught.x       = icon_x + BTN_CAUGHT_ICON_X
        caught.y       = y_pos + BTN_ICON_Y
        caught.visible = visible
      end
      seen = @region_icon_seen[i]
      if seen
        seen.x       = icon_x + BTN_SEEN_ICON_X
        seen.y       = y_pos + BTN_ICON_Y
        seen.visible = visible
      end
      @region_index = i if @mouse_moved && visible && Mouse.over?(spr)
    end
  end

  #-----------------------------------------------------------------------------
  # Flash cancel_p briefly — used for keyboard back press
  #-----------------------------------------------------------------------------
  def pbCancelWithFlash
    @sprites["cancel"].setBitmap(DEX_FOLDER + "cancel_p.png") if @sprites["cancel"]
    10.times { Graphics.update; Input.update; pbUpdate }
    @sprites["cancel"].setBitmap(DEX_FOLDER + "cancel.png") if @sprites["cancel"]
  end

  #-----------------------------------------------------------------------------
  # Override pbStartScene
  #-----------------------------------------------------------------------------
  alias custom_dex_menu_pbStartScene pbStartScene
  def pbStartScene(commands, commands2)
    @commands = commands
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}
    @sprites["grid"] = IconSprite.new(@viewport)
    @sprites["grid"].setBitmap(DEX_FOLDER + "Grid.png")
    @sprites["grid"].x = 0
    @sprites["grid"].y = 0
    @sprites["grid"].z = 0
    @sprites["topoverlay"] = IconSprite.new(@viewport)
    @sprites["topoverlay"].setBitmap(FRONT_FOLDER + "topoverlay.png")
    @sprites["topoverlay"].x = 0
    @sprites["topoverlay"].y = -TOPOVERLAY_H
    @sprites["topoverlay"].z = 2
    @sprites["bottomoverlay"] = IconSprite.new(@viewport)
    @sprites["bottomoverlay"].setBitmap(FRONT_FOLDER + "bottomoverlay.png")
    @sprites["bottomoverlay"].x = 0
    @sprites["bottomoverlay"].y = Graphics.height
    @sprites["bottomoverlay"].z = 2
    @sprites["cancel"] = IconSprite.new(@viewport)
    @sprites["cancel"].setBitmap(DEX_FOLDER + "cancel.png")
    @sprites["cancel"].x = CANCEL_X
    @sprites["cancel"].y = CANCEL_Y
    @sprites["cancel"].z = 3
    @sprites["cancel"].visible = false
    pbBuildRegionButtons(commands, commands2)
    pbSlideOverlaysIn
    @sprites["cancel"].visible = true
    @region_btns_visible = true
    pbShowRegionButtons
  end

  #-----------------------------------------------------------------------------
  # Override pbScene — input loop
  #-----------------------------------------------------------------------------
  alias custom_dex_menu_pbScene pbScene
  def pbScene
    ret = -1
    loop do
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::UP)
        @region_index = [@region_index - 1, 0].max
        @mouse_moved  = false
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        @region_index = [@region_index + 1, @region_count - 1].min
        @mouse_moved  = false
        pbPlayCursorSE
      end
      if @region_btns
        @region_btns.each_with_index do |spr, i|
          next if !spr || !spr.visible
          if Mouse.over?(spr) && Mouse.click?
            @region_index = i
            pbSEPlay("GUI pokedex open")
            ret = i
            break
          end
        end
      end
      break if ret >= 0
      if Input.trigger?(Input::USE)
        ret = @region_index
        pbSEPlay("GUI pokedex open")
        break
      end
      if Mouse.over?(@sprites["cancel"]) && Mouse.click?
        pbPlayCloseMenuSE
        ret = -1
        break
      end
      if Input.trigger?(Input::BACK)
        pbCancelWithFlash
        pbPlayCloseMenuSE
        ret = -1
        break
      end
    end
    return ret
  end

  #-----------------------------------------------------------------------------
  # Override pbEndScene — hide, slide out, fade, dispose
  #-----------------------------------------------------------------------------
  alias custom_dex_menu_pbEndScene pbEndScene
  def pbEndScene
    @sprites["cancel"].visible = false if @sprites["cancel"]
    @region_btns_visible = false
    pbHideRegionButtons
    pbSlideOverlaysOut
    @region_btns&.each(&:dispose)
    @region_btn_bmps&.each   { |b| b&.dispose }
    @region_btn_bmps_h&.each { |b| b&.dispose }
    @region_icon_caught&.each(&:dispose)
    @region_icon_seen&.each(&:dispose)
    @region_btns        = nil
    @region_btn_bmps    = nil
    @region_btn_bmps_h  = nil
    @region_icon_caught = nil
    @region_icon_seen   = nil
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

end

#-------------------------------------------------------------------------------
# Override PokemonPokedexMenuScreen to use our custom button index
#-------------------------------------------------------------------------------
class PokemonPokedexMenuScreen
  def pbStartScreen
    commands  = []
    commands2 = []
    dexnames = Settings.pokedex_names
    $player.pokedex.accessible_dexes.each do |dex|
      if dexnames[dex].nil?
        commands.push(_INTL("Pokédex"))
      elsif dexnames[dex].is_a?(Array)
        commands.push(dexnames[dex][0])
      else
        commands.push(dexnames[dex])
      end
      commands2.push([$player.pokedex.seen_count(dex),
                      $player.pokedex.owned_count(dex),
                      pbGetRegionalDexLength(dex)])
    end
    commands.push(_INTL("Exit"))
    @scene.pbStartScene(commands, commands2)
    loop do
      cmd = @scene.pbScene
      break if cmd < 0 || cmd >= commands2.length
      $PokemonGlobal.pokedexDex = $player.pokedex.accessible_dexes[cmd]
      pbFadeOutIn do
        scene = PokemonPokedex_Scene.new
        screen = PokemonPokedexScreen.new(scene)
        screen.pbStartScreen
      end
    end
    @scene.pbEndScene
  end
end