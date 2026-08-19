#===============================================================================
#                          Custom Options Screen
#                               V 1.0.3
#                        Developed by Carmaniac
#===============================================================================
class PokemonOption_Scene

  OPTIONS_FOLDER   = "Graphics/Custom UI/Options/"
  SELECTION_W      = 648
  SELECTION_H      = 72
  SELECTION_FRAMES = 4
  FRAME_SPEED      = 7

  # Options list viewport
  LIST_VP_X = 80
  LIST_VP_Y = 84
  LIST_VP_W = 640
  LIST_VP_H = 312

  # Bar layout
  BAR_W       = 636
  BAR_H       = 60
  BAR_X       = 2
  BAR_Y_START = 2
  BAR_GAP     = 2
  BAR_STRIDE  = BAR_H + BAR_GAP

  VISIBLE_BARS = 5

  # Text colours
  TEXT_COLOR        = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(136, 136, 136)

  # Value text area
  VALUE_X      = 332
  VALUE_W      = 262
  VALUE_TEXT_X = 462   # fixed even X for value text — avoids sub-pixel at 0.5 scale

  # Text position relative to bar
  BAR_TEXT_X = 22
  BAR_TEXT_Y = 20

  #-----------------------------------------------------------------------------
  # Get display text for current value of an option
  #-----------------------------------------------------------------------------
  def pbGetOptionValueText(i)
    option = @options[i]
    val    = @sprites["option"][i]
    case option
    when EnumOption
      return option.values[val] || ""
    when SliderOption
      return (option.lowest_value + val).to_s
    when NumberOption
      return (option.lowest_value + val).to_s
    else
      return option.values[val].to_s rescue ""
    end
  end

  #-----------------------------------------------------------------------------
  # Build or rebuild a single bar bitmap with name + current value text
  #-----------------------------------------------------------------------------
  def pbBuildBarBitmap(i)
    base = Bitmap.new(OPTIONS_FOLDER + "bar.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    textPos = []
    # Option name — left aligned
    textPos.push([@options[i].name, BAR_TEXT_X, BAR_TEXT_Y, :left, TEXT_COLOR, TEXT_SHADOW_COLOR])
    # Current value — manually centered to avoid sub-pixel rendering at 0.5 scale
    valueText  = pbGetOptionValueText(i)
    text_width = bmp.text_size(valueText).width
    left_x     = VALUE_TEXT_X - (text_width / 2)
    left_x    -= 1 if left_x.odd?
    textPos.push([valueText, left_x, BAR_TEXT_Y, :left, TEXT_COLOR, TEXT_SHADOW_COLOR])
    pbDrawTextPositions(bmp, textPos)
    return bmp
  end

  #-----------------------------------------------------------------------------
  # Override pbStartScene — builds custom UI, hides vanilla window
  #-----------------------------------------------------------------------------
  alias custom_options_pbStartScene pbStartScene
  def pbStartScene(in_load_screen = false)
    @in_load_screen = in_load_screen
    @options = []
    @hashes  = []
    MenuHandlers.each_available(:options_menu) do |option, hash, name|
      @options.push(
        hash["type"].new(name, hash["parameters"], hash["get_proc"], hash["set_proc"])
      )
      @hashes.push(hash)
    end

    @viewport       = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z     = 99999
    @sprites        = {}

    @sprites["option"] = Window_PokemonOption.new(
      @options, 0, 0, Graphics.width, Graphics.height
    )
    @sprites["option"].viewport = @viewport
    @sprites["option"].visible  = false
    @options.length.times { |i| @sprites["option"].setValueNoRefresh(i, @options[i].get || 0) }
    @sprites["option"].refresh

    @sprites["textbox"] = pbCreateMessageWindow
    @sprites["textbox"].visible = false

    @sprites["background"] = IconSprite.new(@viewport)
    @sprites["background"].setBitmap(OPTIONS_FOLDER + "background.png")
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 0

    @sprites["uparrow"] = IconSprite.new(@viewport)
    @sprites["uparrow"].setBitmap(OPTIONS_FOLDER + "uparrow.png")
    @sprites["uparrow"].x = 742
    @sprites["uparrow"].y = 86
    @sprites["uparrow"].z = 9999

    @sprites["downarrow"] = IconSprite.new(@viewport)
    @sprites["downarrow"].setBitmap(OPTIONS_FOLDER + "downarrow.png")
    @sprites["downarrow"].x = 742
    @sprites["downarrow"].y = 372
    @sprites["downarrow"].z = 9999

    @list_viewport   = Viewport.new(LIST_VP_X, LIST_VP_Y, LIST_VP_W, LIST_VP_H)
    @list_viewport.z = @viewport.z + 1

    @total_entries = @options.length + 1

    @option_bars         = []
    @option_left_arrows  = []
    @option_right_arrows = []

    @options.length.times do |i|
      bmp = pbBuildBarBitmap(i)
      bar = Sprite.new(@list_viewport)
      bar.bitmap = bmp
      bar.x = BAR_X
      bar.y = BAR_Y_START + (i * BAR_STRIDE)
      bar.z = 0
      @option_bars << bar

      left = IconSprite.new(@list_viewport)
      left.setBitmap(OPTIONS_FOLDER + "leftarrow.png")
      left.x = BAR_X + 306
      left.y = BAR_Y_START + (i * BAR_STRIDE) + 10
      left.z = 1
      @option_left_arrows << left

      right = IconSprite.new(@list_viewport)
      right.setBitmap(OPTIONS_FOLDER + "rightarrow.png")
      right.x = BAR_X + 598
      right.y = BAR_Y_START + (i * BAR_STRIDE) + 10
      right.z = 1
      @option_right_arrows << right
    end

    close_idx = @options.length
    base = Bitmap.new(OPTIONS_FOLDER + "bar.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    pbDrawTextPositions(bmp, [[_INTL("Close"), BAR_TEXT_X, BAR_TEXT_Y, :left, TEXT_COLOR, TEXT_SHADOW_COLOR]])
    close_bar = Sprite.new(@list_viewport)
    close_bar.bitmap = bmp
    close_bar.x = BAR_X
    close_bar.y = BAR_Y_START + (close_idx * BAR_STRIDE)
    close_bar.z = 0
    @option_bars << close_bar
    @option_left_arrows  << nil
    @option_right_arrows << nil

    @selection_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @selection_viewport.z = @list_viewport.z + 1

    @sprites["selection"] = Sprite.new(@selection_viewport)
    @sprites["selection"].bitmap = Bitmap.new(OPTIONS_FOLDER + "selection.png")
    @sprites["selection"].src_rect.set(0, 0, SELECTION_W, SELECTION_H)
    @sprites["selection"].x = LIST_VP_X + BAR_X - ((SELECTION_W - BAR_W) / 2)
    @sprites["selection"].y = 0
    @sprites["selection"].z = 0

    @option_index  = 0
    @scroll_top    = 0
    @scroll_target = 0
    @anim_frame    = 0
    @anim_tick     = 0
    @last_mouse_x  = Input.mouse_x
    @last_mouse_y  = Input.mouse_y
    @mouse_moved   = false

    pbDeactivateWindows(@sprites)
    @list_viewport.color      = Color.new(0, 0, 0, 255)
    @selection_viewport.color = Color.new(0, 0, 0, 255)
    pbFadeInAndShow(@sprites) {
      pbUpdate
      alpha = @list_viewport.color.alpha
      @list_viewport.color.alpha      = [alpha - 17, 0].max
      @selection_viewport.color.alpha = [alpha - 17, 0].max
    }
  end

  #-----------------------------------------------------------------------------
  # Update bar/arrow/selection positions and mouse hover
  #-----------------------------------------------------------------------------
  def pbUpdateListPositions
    idx = @option_index

    if idx >= @scroll_top + VISIBLE_BARS
      @scroll_target = idx - VISIBLE_BARS + 1
    end
    if idx < @scroll_top
      @scroll_target = idx
    end

    max_scroll     = [@total_entries - VISIBLE_BARS, 0].max
    @scroll_target = @scroll_target.clamp(0, max_scroll)

    if @scroll_top < @scroll_target
      @scroll_top = [@scroll_top + 3, @scroll_target].min
    elsif @scroll_top > @scroll_target
      @scroll_top = [@scroll_top - 3, @scroll_target].max
    end

    @option_bars.each_with_index do |bar, i|
      next if !bar
      ypos    = BAR_Y_START + ((i - @scroll_top) * BAR_STRIDE)
      visible = (i >= @scroll_top && i < @scroll_top + VISIBLE_BARS)
      bar.y       = ypos
      bar.visible = visible
      left  = @option_left_arrows[i]
      right = @option_right_arrows[i]
      if left
        left.y       = ypos + 10
        left.visible = visible
      end
      if right
        right.y       = ypos + 10
        right.visible = visible
      end
    end

    # Mouse movement tracking
    cur_x = Input.mouse_x
    cur_y = Input.mouse_y
    @mouse_moved  = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
    @last_mouse_x = cur_x
    @last_mouse_y = cur_y

    @mouse_left_clicked  = false
    @mouse_right_clicked = false
    @option_bars.each_with_index do |bar, i|
      next if !bar || !bar.visible
      left  = @option_left_arrows[i]
      right = @option_right_arrows[i]

      # Hovering bar (not arrow) changes selection index only if mouse moved
      if @mouse_moved && Mouse.over?(bar)
        hovering_arrow = (left && Mouse.over?(left)) || (right && Mouse.over?(right))
        @option_index = i unless hovering_arrow
      end

      if left
        left.setBitmap(OPTIONS_FOLDER + (Mouse.over?(left) && Mouse.press? ? "leftarrow_p.png" : "leftarrow.png"))
        @mouse_left_clicked  = true if Mouse.over?(left) && Mouse.click? && i == @option_index
      end
      if right
        right.setBitmap(OPTIONS_FOLDER + (Mouse.over?(right) && Mouse.press? ? "rightarrow_p.png" : "rightarrow.png"))
        @mouse_right_clicked = true if Mouse.over?(right) && Mouse.click? && i == @option_index
      end
    end

    screen_y = LIST_VP_Y + BAR_Y_START + ((idx - @scroll_top) * BAR_STRIDE) - ((SELECTION_H - BAR_H) / 2)
    @sprites["selection"].y = screen_y
  end

  #-----------------------------------------------------------------------------
  # Override pbUpdate — animation + list update
  #-----------------------------------------------------------------------------
  alias custom_options_pbUpdate pbUpdate
  def pbUpdate
	@deltatime = 0 if !@deltatime
	# If it hasn't been 1/60 of a second yet, do nothing
	if System.uptime - @deltatime < 1/60r
		return
	end
	# Set new deltatime
	@deltatime = System.uptime
	# Actual stuff
    if @anim_tick && @anim_frame && @sprites["selection"]
      @anim_tick += 1
      if @anim_tick >= FRAME_SPEED
        @anim_tick  = 0
        @anim_frame = (@anim_frame + 1) % SELECTION_FRAMES
        @sprites["selection"].src_rect.y = @anim_frame * SELECTION_H
      end
      pbUpdateListPositions
    end
    pbUpdateSpriteHash(@sprites)
  end

  #-----------------------------------------------------------------------------
  # Override pbOptions — fully custom input loop using our own index
  #-----------------------------------------------------------------------------
  alias custom_options_pbOptions pbOptions
  def pbOptions
    loop do
      Graphics.update
      Input.update
      pbUpdate

      # Mouse scroll wheel within list viewport area
      if Mouse.over?(@list_viewport)
        if Mouse.scroll_up?
          if @scroll_target > 0
            @scroll_target -= 1
            if @option_index >= @scroll_target + VISIBLE_BARS
              @option_index = @scroll_target + VISIBLE_BARS - 1
              @sprites["option"].index = [@option_index, @options.length - 1].min
            end
          end
        elsif Mouse.scroll_down?
          max_scroll = [@total_entries - VISIBLE_BARS, 0].max
          if @scroll_target < max_scroll
            @scroll_target += 1
            if @option_index < @scroll_target
              @option_index = @scroll_target
              @sprites["option"].index = [@option_index, @options.length - 1].min
            end
          end
        end
      end

      # Up/down arrow button mouse clicks
      if Mouse.over?(@sprites["uparrow"]) && Mouse.click?
        if @scroll_target > 0
          @scroll_target -= 1
          if @option_index >= @scroll_target + VISIBLE_BARS
            @option_index = @scroll_target + VISIBLE_BARS - 1
            @sprites["option"].index = [@option_index, @options.length - 1].min
          end
          pbPlayCursorSE
        end
      end
      if Mouse.over?(@sprites["downarrow"]) && Mouse.click?
        max_scroll = [@total_entries - VISIBLE_BARS, 0].max
        if @scroll_target < max_scroll
          @scroll_target += 1
          if @option_index < @scroll_target
            @option_index = @scroll_target
            @sprites["option"].index = [@option_index, @options.length - 1].min
          end
          pbPlayCursorSE
        end
      end

      # Keyboard navigation — full wrap, resets mouse priority
      if Input.trigger?(Input::UP)
        @option_index = (@option_index - 1) % @total_entries
        @mouse_moved  = false
        pbPlayCursorSE
        @sprites["option"].index = [@option_index, @options.length - 1].min
      elsif Input.trigger?(Input::DOWN)
        @option_index = (@option_index + 1) % @total_entries
        @mouse_moved  = false
        pbPlayCursorSE
        @sprites["option"].index = [@option_index, @options.length - 1].min
      end

      # Left/right change option value with wrap (not on Close)
      if @option_index < @options.length
        changed = false
        if Input.trigger?(Input::LEFT) || @mouse_left_clicked
          newVal = @options[@option_index].prev(@sprites["option"][@option_index])
          if newVal == @sprites["option"][@option_index]
            newVal = @options[@option_index].next(@sprites["option"][@option_index])
            newVal = @options[@option_index].next(newVal) while @options[@option_index].next(newVal) != newVal
          end
          @sprites["option"][@option_index] = newVal
          @options[@option_index].set(newVal, self)
          changed = true
        elsif Input.trigger?(Input::RIGHT) || @mouse_right_clicked
          newVal = @options[@option_index].next(@sprites["option"][@option_index])
          if newVal == @sprites["option"][@option_index]
            newVal = @options[@option_index].prev(@sprites["option"][@option_index])
            newVal = @options[@option_index].prev(newVal) while @options[@option_index].prev(newVal) != newVal
          end
          @sprites["option"][@option_index] = newVal
          @options[@option_index].set(newVal, self)
          changed = true
        end
        if changed
          @option_bars[@option_index]&.bitmap&.dispose
          @option_bars[@option_index].bitmap = pbBuildBarBitmap(@option_index)
        end
      end

      # Mouse click on bar confirms selection
      @option_bars.each_with_index do |bar, i|
        next if !bar || !bar.visible
        if Mouse.over?(bar) && Mouse.click?
          left  = @option_left_arrows[i]
          right = @option_right_arrows[i]
          next if (left && Mouse.over?(left)) || (right && Mouse.over?(right))
          @option_index = i
          if i >= @options.length
            pbPlayCloseMenuSE
            return
          end
        end
      end

      if Input.trigger?(Input::USE) && @option_index >= @options.length
        pbPlayCloseMenuSE
        return
      end
      if Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        return
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbEndScene — dispose everything
  #-----------------------------------------------------------------------------
  alias custom_options_pbEndScene pbEndScene
  def pbEndScene
    @options.length.times do |i|
      @options[i].set(@sprites["option"][i], self) if @sprites["option"]
    end
    pbPlayCloseMenuSE
    pbFadeOutAndHide(@sprites) {
      pbUpdate
      alpha = @list_viewport.color.alpha
      @list_viewport.color.alpha      = [alpha + 17, 255].min
      @selection_viewport.color.alpha = [alpha + 17, 255].min
    }
    @option_bars&.each         { |bar| bar&.bitmap&.dispose; bar&.dispose }
    @option_left_arrows&.each  { |s| s&.dispose }
    @option_right_arrows&.each { |s| s&.dispose }
    @sprites["selection"]&.bitmap&.dispose
    @sprites.delete("selection")
    @list_viewport&.dispose
    @selection_viewport&.dispose
    pbDisposeMessageWindow(@sprites["textbox"]) if @sprites["textbox"]
    pbDisposeSpriteHash(@sprites)
    pbUpdateSceneMap
    @viewport&.dispose
  end

end