#===============================================================================
#                        Custom Dex Main Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
class PokemonPokedex_Scene

  DEX_FOLDER  = "Graphics/Custom UI/Dex/"
  MAIN_FOLDER = "Graphics/Custom UI/Dex/Main Page/"

  GRID_SCROLL_W = 800

  TEXT_COLOR  = Color.new(255, 255, 255)
  TEXT_SHADOW = Color.new(156, 156, 156)

  # Grid layout
  GRID_COLS     = 4
  GRID_ROWS     = 3
  GRID_CELL_W   = 112
  GRID_CELL_H   = 118
  GRID_X_GAP    = 6
  GRID_Y_GAP    = 6
  GRID_X_STRIDE = GRID_CELL_W + GRID_X_GAP
  GRID_Y_STRIDE = GRID_CELL_H + GRID_Y_GAP
  GRID_START_X  = 284
  GRID_START_Y  = 56

  GRID_ICON_X   = 24
  GRID_ICON_Y   = 6
  GRID_STATUS_X = 6
  GRID_STATUS_Y = 80
  GRID_NUM_RIGHT_X = 100
  GRID_NUM_Y    = 84

  HIGHLIGHT_OFFSET_X = -4
  HIGHLIGHT_OFFSET_Y = -4
  HIGHLIGHT_W        = 120
  HIGHLIGHT_H        = 120
  HIGHLIGHT_FRAMES   = 4
  HIGHLIGHT_SPEED    = 7

  CELL_OPACITY_UNSELECTED = 100
  CELL_OPACITY_SELECTED   = 255

  # Scrollbar
  SCROLLBAR_X = 768
  SCROLLBAR_Y = 52
  SCROLLBAR_W = 12
  SCROLLBAR_H = 368
  SCROLLBAR_BAR_X       = 766
  SCROLLBAR_BAR_Y_START = 52
  SCROLLBAR_BAR_W = 16
  SCROLLBAR_BAR_H = 24

  CANCEL_X = 768
  CANCEL_Y = 448

  UPARROW_X   = 10
  UPARROW_Y   = 444
  DOWNARROW_X = 50
  DOWNARROW_Y = 444

  # Search button
  SEARCH_BTN_X = 90
  SEARCH_BTN_Y = 444
  SEARCH_BTN_W = 106
  SEARCH_BTN_H = 34
  SEARCH_BTN_TEXT_COLOR  = Color.new(0, 0, 0)
  SEARCH_BTN_TEXT_SHADOW = Color.new(173, 189, 189)

  FILTER_MODE_NAMES = {
    MODENUMERICAL => "Number",
    MODEATOZ      => "Name",
    MODETALLEST   => "Height",
    MODESMALLEST  => "Height",
    MODEHEAVIEST  => "Weight",
    MODELIGHTEST  => "Weight"
  }

  #-----------------------------------------------------------------------------
  # Build grid box sprites
  #-----------------------------------------------------------------------------
  def pbBuildGrid
    pbDisposeGrid
    @grid_cells  = []
    @grid_icons  = []
    @grid_scroll = 0
    @last_mouse_x = Input.mouse_x
    @last_mouse_y = Input.mouse_y
    @mouse_moved  = false
    (GRID_ROWS * GRID_COLS).times do |i|
      row = i / GRID_COLS
      col = i % GRID_COLS
      x   = GRID_START_X + (col * GRID_X_STRIDE)
      y   = GRID_START_Y + (row * GRID_Y_STRIDE)
      x  -= 1 if x.odd?
      y  -= 1 if y.odd?
      spr = IconSprite.new(@viewport)
      spr.x = x
      spr.y = y
      spr.z = 4
      spr.opacity = CELL_OPACITY_UNSELECTED
      @grid_cells << spr
      @sprites["custom_gridcell#{i}"] = spr

      icon_spr = IconSprite.new(@viewport)
      icon_spr.x = x + GRID_ICON_X
      icon_spr.y = y + GRID_ICON_Y
      icon_spr.z = 5
      icon_spr.opacity = CELL_OPACITY_UNSELECTED
      icon_spr.visible = false
      @grid_icons << icon_spr
      @sprites["custom_gridicon#{i}"] = icon_spr
    end
    @grid_cell_content = Array.new(GRID_ROWS * GRID_COLS, :uninitialized)

    # Selection highlight sprite (animated, sits above the selected box)
    @sprites["custom_gridhighlight"] = IconSprite.new(@viewport)
    @sprites["custom_gridhighlight"].setBitmap(DEX_FOLDER + "highlight.png")
    @sprites["custom_gridhighlight"].src_rect.set(0, 0, HIGHLIGHT_W, HIGHLIGHT_H)
    @sprites["custom_gridhighlight"].z = 6
    @highlight_frame = 0
    @highlight_tick  = 0

    pbRefreshGridCells(true)
    pbUpdateGridOpacity
  end

  def pbDisposeGrid
    if @grid_cells
      @grid_cells.each_with_index { |spr, i| spr&.dispose; @sprites.delete("custom_gridcell#{i}") }
    end
    @grid_cells = nil
    if @grid_icons
      @grid_icons.each_with_index { |spr, i| spr&.dispose; @sprites.delete("custom_gridicon#{i}") }
    end
    @grid_icons = nil
    @grid_cell_content = nil
    @sprites["custom_gridhighlight"]&.dispose
    @sprites.delete("custom_gridhighlight")
  end

  #-----------------------------------------------------------------------------
  # Scrollbar
  #-----------------------------------------------------------------------------
  def pbBuildScrollbar
    @sprites["custom_scrollbartrack"] = IconSprite.new(@viewport)
    @sprites["custom_scrollbartrack"].setBitmap(DEX_FOLDER + "scrollbar.png")
    @sprites["custom_scrollbartrack"].x = SCROLLBAR_X
    @sprites["custom_scrollbartrack"].y = SCROLLBAR_Y
    @sprites["custom_scrollbartrack"].z = 7

    @sprites["custom_scrollbarbar"] = IconSprite.new(@viewport)
    @sprites["custom_scrollbarbar"].setBitmap(DEX_FOLDER + "bar.png")
    @sprites["custom_scrollbarbar"].x = SCROLLBAR_BAR_X
    @sprites["custom_scrollbarbar"].y = SCROLLBAR_BAR_Y_START
    @sprites["custom_scrollbarbar"].z = 8

    pbUpdateScrollbar
  end

  def pbUpdateScrollbar
    return if !@sprites["custom_scrollbarbar"] || !@dexlist
    total_rows = (@dexlist.length.to_f / GRID_COLS).ceil
    max_scroll = [total_rows - GRID_ROWS, 0].max
    travel = SCROLLBAR_H - SCROLLBAR_BAR_H
    travel = 0 if travel < 0
    progress = (max_scroll > 0) ? (@grid_scroll.to_f / max_scroll) : 0
    progress = progress.clamp(0.0, 1.0)
    offset = (travel * progress).round
    offset = 0 if offset < 0
    @sprites["custom_scrollbarbar"].y = SCROLLBAR_BAR_Y_START + offset
  end

  #-----------------------------------------------------------------------------
  # Cancel button
  #-----------------------------------------------------------------------------
  def pbBuildCancelButton
    @sprites["custom_cancel"] = IconSprite.new(@viewport)
    @sprites["custom_cancel"].setBitmap(DEX_FOLDER + "cancel.png")
    @sprites["custom_cancel"].x = CANCEL_X
    @sprites["custom_cancel"].y = CANCEL_Y
    @sprites["custom_cancel"].z = 8
  end

  def pbFlashCancelButton
    2.times do
      @sprites["custom_cancel"].setBitmap(DEX_FOLDER + "cancel_p.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      @sprites["custom_cancel"].setBitmap(DEX_FOLDER + "cancel.png")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  #-----------------------------------------------------------------------------
  # Search button — text is drawn on its own full-screen overlay rather than
  # baked into the button graphic itself, so it lines up with the rest of
  # the UI's text
  #-----------------------------------------------------------------------------
  def pbDrawSearchButtonBase(pressed)
    file = pressed ? (DEX_FOLDER + "button_small_p.png") : (DEX_FOLDER + "button_small.png")
    @sprites["custom_search"].setBitmap(file)
  end

  def pbBuildSearchButton
    @sprites["custom_search"] = IconSprite.new(@viewport)
    pbDrawSearchButtonBase(false)
    @sprites["custom_search"].x = SEARCH_BTN_X
    @sprites["custom_search"].y = SEARCH_BTN_Y
    @sprites["custom_search"].z = 8

    @sprites["custom_searchtext"] = Sprite.new(@viewport)
    @sprites["custom_searchtext"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(@sprites["custom_searchtext"].bitmap)
    @sprites["custom_searchtext"].z = 9
    pbDrawSearchButtonText
  end

  def pbDrawSearchButtonText
    bmp = @sprites["custom_searchtext"].bitmap
    bmp.clear
    center_x = SEARCH_BTN_X + (SEARCH_BTN_W / 2)
    text_y   = SEARCH_BTN_Y + [(SEARCH_BTN_H - bmp.font.size) / 2, 0].max + 4
    textPositions = [[_INTL("Search"), center_x, text_y, :center,
                       SEARCH_BTN_TEXT_COLOR, SEARCH_BTN_TEXT_SHADOW]]
    pbDrawTextPositions(bmp, textPositions)
  end

  def pbFlashSearchButton
    2.times do
      pbDrawSearchButtonBase(true)
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      pbDrawSearchButtonBase(false)
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  #-----------------------------------------------------------------------------
  # Up/down arrow buttons — mouse only, scrolls one row per click
  #-----------------------------------------------------------------------------
  def pbBuildArrowButtons
    @sprites["custom_uparrow"] = IconSprite.new(@viewport)
    @sprites["custom_uparrow"].setBitmap(DEX_FOLDER + "uparrow.png")
    @sprites["custom_uparrow"].x = UPARROW_X
    @sprites["custom_uparrow"].y = UPARROW_Y
    @sprites["custom_uparrow"].z = 8

    @sprites["custom_downarrow"] = IconSprite.new(@viewport)
    @sprites["custom_downarrow"].setBitmap(DEX_FOLDER + "downarrow.png")
    @sprites["custom_downarrow"].x = DOWNARROW_X
    @sprites["custom_downarrow"].y = DOWNARROW_Y
    @sprites["custom_downarrow"].z = 8
  end

  #-----------------------------------------------------------------------------
  # Cancel/search/up/down button input, checked every frame.
  # Returns [cancel_triggered, search_triggered]
  #-----------------------------------------------------------------------------
  def pbHandleDexButtons
    cancel_triggered = false
    search_triggered = false

    if @sprites["custom_uparrow"]
      if @sprites["custom_uparrow"].over? && @sprites["custom_uparrow"].press?
        @sprites["custom_uparrow"].setBitmap(DEX_FOLDER + "uparrow_p.png")
      else
        @sprites["custom_uparrow"].setBitmap(DEX_FOLDER + "uparrow.png")
      end
      pbScrollGridBy(-1) if @sprites["custom_uparrow"].click?
    end
    if @sprites["custom_downarrow"]
      if @sprites["custom_downarrow"].over? && @sprites["custom_downarrow"].press?
        @sprites["custom_downarrow"].setBitmap(DEX_FOLDER + "downarrow_p.png")
      else
        @sprites["custom_downarrow"].setBitmap(DEX_FOLDER + "downarrow.png")
      end
      pbScrollGridBy(1) if @sprites["custom_downarrow"].click?
    end

    cancel_triggered = true if @sprites["custom_cancel"] && @sprites["custom_cancel"].click?

    if @sprites["custom_search"]
      pressed = @sprites["custom_search"].over? && @sprites["custom_search"].press?
      if pressed != @search_btn_was_pressed
        pbDrawSearchButtonBase(pressed)
        @search_btn_was_pressed = pressed
      end
      search_triggered = true if @sprites["custom_search"].click?
    end

    return [cancel_triggered, search_triggered]
  end

  #-----------------------------------------------------------------------------
  # Scrolls the grid by whole rows, keeping the selection on the same
  # relative row within the visible window
  #-----------------------------------------------------------------------------
  def pbScrollGridBy(row_delta)
    return if !@dexlist || @dexlist.empty?
    idx      = @sprites["pokedex"].index
    max_idx  = @dexlist.length - 1
    col      = idx % GRID_COLS
    row      = idx / GRID_COLS
    total_rows = (@dexlist.length.to_f / GRID_COLS).ceil
    max_scroll = [total_rows - GRID_ROWS, 0].max
    new_scroll = (@grid_scroll + row_delta).clamp(0, max_scroll)
    return if new_scroll == @grid_scroll

    idx_row_in_view = row - @grid_scroll
    @grid_scroll = new_scroll
    target_row = @grid_scroll + idx_row_in_view
    target_row = target_row.clamp(0, max_idx / GRID_COLS)
    target_idx = (target_row * GRID_COLS) + col
    row_end    = [(target_row * GRID_COLS) + GRID_COLS - 1, max_idx].min
    idx = [target_idx, row_end].min
    idx = idx.clamp(0, max_idx)

    @sprites["pokedex"].index = idx
    pbUpdateGridScroll
    pbUpdateGrid
    pbUpdateScrollbar
    pbRefresh
  end

  #-----------------------------------------------------------------------------
  # Selection highlight — cycles through its animation frames and follows
  # whichever box is currently selected
  #-----------------------------------------------------------------------------
  def pbUpdateGridHighlight
    return if !@sprites["custom_gridhighlight"] || !@dexlist || @dexlist.empty?
    idx = @sprites["pokedex"].index
    local_idx = idx - (@grid_scroll * GRID_COLS)
    if local_idx < 0 || local_idx >= (GRID_ROWS * GRID_COLS) || !@grid_cells[local_idx]
      @sprites["custom_gridhighlight"].visible = false
      return
    end
    cell = @grid_cells[local_idx]
    @sprites["custom_gridhighlight"].visible = true
    @sprites["custom_gridhighlight"].x = cell.x + HIGHLIGHT_OFFSET_X
    @sprites["custom_gridhighlight"].y = cell.y + HIGHLIGHT_OFFSET_Y
    @highlight_tick += 1
    if @highlight_tick >= HIGHLIGHT_SPEED
      @highlight_tick  = 0
      @highlight_frame = (@highlight_frame + 1) % HIGHLIGHT_FRAMES
      @sprites["custom_gridhighlight"].src_rect.y = @highlight_frame * HIGHLIGHT_H
    end
  end

  #-----------------------------------------------------------------------------
  # Cell opacity — selected box full brightness, everything else dimmed
  #-----------------------------------------------------------------------------
  def pbUpdateGridOpacity
    return if !@grid_cells || !@dexlist
    idx = @sprites["pokedex"].index
    local_idx = idx - (@grid_scroll * GRID_COLS)
    @grid_cells.each_with_index do |spr, i|
      next if !spr
      selected = (i == local_idx)
      opacity  = selected ? CELL_OPACITY_SELECTED : CELL_OPACITY_UNSELECTED
      spr.opacity = opacity
      @grid_icons[i].opacity = opacity if @grid_icons[i]
    end
  end

  #-----------------------------------------------------------------------------
  # Draws one grid box — background, status icon, dex number. Species icon
  # is handled separately by pbUpdateGridCellIcon since it needs to animate.
  #-----------------------------------------------------------------------------
  def pbDrawGridCellBitmap(spr, dex_idx)
    if !dex_idx || !@dexlist || dex_idx >= @dexlist.length
      spr.visible = false
      return
    end
    spr.visible = true

    bmp = Bitmap.new(GRID_CELL_W, GRID_CELL_H)
    bmp.blt(0, 0, Bitmap.new(MAIN_FOLDER + "box.png"), Rect.new(0, 0, GRID_CELL_W, GRID_CELL_H))

    entry   = @dexlist[dex_idx]
    species = entry[:species]
    empty   = !species || species == 0
    seen    = !empty && $player.seen?(species)
    owned   = !empty && $player.owned?(species)

    if !empty
      status_file = owned ? (MAIN_FOLDER + "caught.png") : (MAIN_FOLDER + "empty.png")
      status_bitmap = Bitmap.new(status_file)
      bmp.blt(GRID_STATUS_X, GRID_STATUS_Y, status_bitmap, status_bitmap.rect)
      status_bitmap.dispose
    end

    if !empty
      pbSetSystemFont(bmp)
      indexNumber = entry[:number]
      indexNumber -= 1 if entry[:shift]
      num_text = sprintf("%03d", indexNumber)
      textPositions = [[num_text, GRID_NUM_RIGHT_X, GRID_NUM_Y, :right, TEXT_COLOR, TEXT_SHADOW]]
      pbDrawTextPositions(bmp, textPositions)
    end

    spr.bitmap&.dispose
    spr.bitmap = bmp
  end

  #-----------------------------------------------------------------------------
  # Sets up the species icon for one box. Actual frame stepping for the
  # animation happens in pbUpdateGridIconAnimation.
  #-----------------------------------------------------------------------------
  def pbUpdateGridCellIcon(icon_spr, dex_idx)
    if dex_idx && @dexlist && dex_idx < @dexlist.length
      entry   = @dexlist[dex_idx]
      species = entry[:species]
      empty   = !species || species == 0
      seen    = !empty && $player.seen?(species)

      if !empty
        if seen
          gender, form, _shiny = $player.pokedex.last_form_seen(species)
          icon_filename = GameData::Species.icon_filename(species, form, gender, false)
        else
          icon_filename = GameData::Species.icon_filename(0, 0, 0, false)
        end
        if icon_filename
          icon_spr.setBitmap(icon_filename)
          if icon_spr.bitmap && !icon_spr.bitmap.disposed?
            frame_h = icon_spr.bitmap.height
            frame_count = (frame_h > 0) ? (icon_spr.bitmap.width / frame_h) : 1
            frame_count = 1 if frame_count < 1
            icon_spr.src_rect.set(0, 0, frame_h, frame_h)
            icon_spr.instance_variable_set(:@grid_icon_frame_count, frame_count)
            icon_spr.instance_variable_set(:@grid_icon_frame_size, frame_h)
            icon_spr.visible = true
            return
          end
        end
      end
    end
    icon_spr.visible = false
  end

  #-----------------------------------------------------------------------------
  # Steps every visible box icon forward one animation frame
  #-----------------------------------------------------------------------------
  ICON_ANIM_SPEED = 16

  def pbUpdateGridIconAnimation
    return if !@grid_icons
    @icon_anim_tick ||= 0
    @icon_anim_tick += 1
    return if @icon_anim_tick < ICON_ANIM_SPEED
    @icon_anim_tick = 0
    @grid_icons.each do |icon_spr|
      next if !icon_spr || !icon_spr.visible || !icon_spr.bitmap || icon_spr.bitmap.disposed?
      frame_count = icon_spr.instance_variable_get(:@grid_icon_frame_count) || 1
      next if frame_count <= 1
      frame_size = icon_spr.instance_variable_get(:@grid_icon_frame_size) || icon_spr.bitmap.height
      current_frame = icon_spr.src_rect.x / frame_size
      next_frame = (current_frame + 1) % frame_count
      icon_spr.src_rect.x = next_frame * frame_size
    end
  end

  #-----------------------------------------------------------------------------
  # Redraws boxes whose contents actually changed since last time (scrolled
  # into view, or seen/owned status flipped)
  #-----------------------------------------------------------------------------
  def pbRefreshGridCells(force = false)
    return if !@grid_cells || !@dexlist
    @grid_cells.each_with_index do |spr, i|
      dex_idx = (@grid_scroll * GRID_COLS) + i
      if dex_idx < @dexlist.length
        species = @dexlist[dex_idx][:species]
        content_key = [dex_idx, species, $player.seen?(species), $player.owned?(species)]
      else
        content_key = nil
      end
      next if !force && @grid_cell_content[i] == content_key
      @grid_cell_content[i] = content_key
      valid_idx = (dex_idx < @dexlist.length) ? dex_idx : nil
      pbDrawGridCellBitmap(spr, valid_idx)
      pbUpdateGridCellIcon(@grid_icons[i], valid_idx) if @grid_icons[i]
    end
  end

  #-----------------------------------------------------------------------------
  # Repositions the boxes on screen. Mouse handling lives in pbHandleGridMouse.
  #-----------------------------------------------------------------------------
  def pbUpdateGrid
    return if !@grid_cells || !@dexlist
    pbRefreshGridCells
    @grid_cells.each_with_index do |spr, i|
      next if !spr
      row = i / GRID_COLS
      col = i % GRID_COLS
      x   = GRID_START_X + (col * GRID_X_STRIDE)
      y   = GRID_START_Y + (row * GRID_Y_STRIDE)
      x  -= 1 if x.odd?
      y  -= 1 if y.odd?
      spr.x = x
      spr.y = y
      if @grid_icons[i]
        @grid_icons[i].x = x + GRID_ICON_X
        @grid_icons[i].y = y + GRID_ICON_Y
      end
    end
    pbUpdateGridOpacity
  end

  #-----------------------------------------------------------------------------
  # Mouse hover + click, checked every frame. Returns true if a box was
  # clicked (equivalent to pressing USE on it).
  #-----------------------------------------------------------------------------
  def pbHandleGridMouse
    return false if !@grid_cells || !@dexlist || @dexlist.empty?
    activate = false
    @grid_cells.each_with_index do |spr, i|
      next if !spr || !spr.visible
      next if !Mouse.over?(spr)
      dex_idx = (@grid_scroll * GRID_COLS) + i
      next if dex_idx >= @dexlist.length
      if @mouse_moved && @sprites["pokedex"].index != dex_idx
        @sprites["pokedex"].index = dex_idx
        pbUpdateGrid
        pbRefresh
      end
      if @mouse_moved && Mouse.click?
        @sprites["pokedex"].index = dex_idx
        activate = true
      end
      break
    end
    return activate
  end

  #-----------------------------------------------------------------------------
  # Keeps the visible rows centred on whatever's currently selected
  #-----------------------------------------------------------------------------
  def pbUpdateGridScroll
    return if !@dexlist
    idx      = @sprites["pokedex"].index
    row      = idx / GRID_COLS
    max_rows = [(@dexlist.length.to_f / GRID_COLS).ceil - GRID_ROWS, 0].max
    old_scroll = @grid_scroll
    if row < @grid_scroll
      @grid_scroll = row
    elsif row >= @grid_scroll + GRID_ROWS
      @grid_scroll = row - GRID_ROWS + 1
    end
    @grid_scroll = @grid_scroll.clamp(0, max_rows)
    pbRefreshGridCells(true) if old_scroll != @grid_scroll
    pbUpdateScrollbar
  end

  #-----------------------------------------------------------------------------
  # Grid keyboard/mouse navigation
  #-----------------------------------------------------------------------------
  def pbHandleGridInput
    return if !@dexlist || @dexlist.empty?
    idx      = @sprites["pokedex"].index
    max_idx  = @dexlist.length - 1
    col      = idx % GRID_COLS
    row      = idx / GRID_COLS
    last_row = max_idx / GRID_COLS
    changed  = false

    # Sticky flag: stays true across frames once the mouse moves, only reset
    # by keyboard input below. Otherwise a click without any further mouse
    # movement between hover and click would get missed.
    cur_x = Input.mouse_x
    cur_y = Input.mouse_y
    if cur_x != @last_mouse_x || cur_y != @last_mouse_y
      @mouse_moved = true
    end
    @last_mouse_x = cur_x
    @last_mouse_y = cur_y

    if Input.trigger?(Input::LEFT)
      if col > 0
        idx -= 1
        @mouse_moved = false
        changed = true
      end
    elsif Input.trigger?(Input::RIGHT)
      row_end = [(row * GRID_COLS) + GRID_COLS - 1, max_idx].min
      if idx < row_end
        idx += 1
        @mouse_moved = false
        changed = true
      end
    elsif Input.trigger?(Input::UP)
      if row > 0
        target_row = row - 1
        target_idx = (target_row * GRID_COLS) + col
        row_end    = [(target_row * GRID_COLS) + GRID_COLS - 1, max_idx].min
        idx = [target_idx, row_end].min
        @mouse_moved = false
        changed = true
      end
    elsif Input.trigger?(Input::DOWN)
      if row < last_row
        target_row = row + 1
        target_idx = (target_row * GRID_COLS) + col
        row_end    = [(target_row * GRID_COLS) + GRID_COLS - 1, max_idx].min
        idx = [target_idx, row_end].min
        @mouse_moved = false
        changed = true
      end
    end

    # Mouse wheel — keep the selection on the same row within the view
    max_scroll = [(@dexlist.length.to_f / GRID_COLS).ceil - GRID_ROWS, 0].max
    if Mouse.scroll_up? && @grid_scroll > 0
      idx_row_in_view = row - @grid_scroll
      @grid_scroll -= 1
      target_row = @grid_scroll + idx_row_in_view
      target_idx = (target_row * GRID_COLS) + col
      row_end    = [(target_row * GRID_COLS) + GRID_COLS - 1, max_idx].min
      idx = [target_idx, row_end].min
      changed = true
    elsif Mouse.scroll_down? && @grid_scroll < max_scroll
      idx_row_in_view = row - @grid_scroll
      @grid_scroll += 1
      target_row = @grid_scroll + idx_row_in_view
      target_idx = (target_row * GRID_COLS) + col
      row_end    = [(target_row * GRID_COLS) + GRID_COLS - 1, max_idx].min
      idx = [target_idx, row_end].min
      changed = true
    end

    idx = idx.clamp(0, max_idx)
    if idx != @sprites["pokedex"].index || changed
      @sprites["pokedex"].index = idx
      pbUpdateGridScroll
      pbUpdateGrid
      pbRefresh
    end

    clicked = pbHandleGridMouse
    if clicked
      $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
      pbRefresh
    end
    return clicked
  end
  alias custom_dex_main_pbUpdate pbUpdate
  def pbUpdate
	# If it hasn't been 1/60 of a second yet, do nothing
	@deltatime = 0 if !@deltatime
	if System.uptime - @deltatime < 1/60r
		return
	end
	# Set new deltatime
	@deltatime = System.uptime
	# Do things
    if @sprites["custom_grid"]
      @sprites["custom_grid"].x -= 1
      @sprites["custom_grid"].x = 0 if @sprites["custom_grid"].x <= -GRID_SCROLL_W
    end
    pbUpdateGridHighlight
    pbUpdateGridIconAnimation
    custom_dex_main_pbUpdate
  end

  #-----------------------------------------------------------------------------
  # Big Pokémon sprite, centred on 138,240
  #-----------------------------------------------------------------------------
  def pbUpdateCustomPokemonSprite
    return if !@sprites["custom_pokemon"]
    species = @sprites["pokedex"]&.species
    empty   = !species || species == 0
    if empty
      @sprites["custom_pokemon"].visible = false
      @last_dex_species = nil
      return
    end
    seen = $player.seen?(species)
    display_key = seen ? species : :unseen
    return if display_key == @last_dex_species
    @last_dex_species = display_key
    if seen
      gender, form, _shiny = $player.pokedex.last_form_seen(species)
      @sprites["custom_pokemon"].setSpeciesBitmap(species, gender, form, false)
    else
      @sprites["custom_pokemon"].setSpeciesBitmap(nil, 0, 0, false)
    end
    bmp = @sprites["custom_pokemon"].bitmap
    if bmp && !bmp.disposed?
      # Odd-width/height sprites round down when centred, which is invisible
      # at full res but shows up as a soft/blurry edge once the display is
      # scaled down. Nudge x/y so the actual rendered edge (x - ox) always
      # lands on an even pixel.
      ox = bmp.width / 2
      oy = bmp.height / 2
      @sprites["custom_pokemon"].ox = ox
      @sprites["custom_pokemon"].oy = oy
      target_x = 138
      target_y = 240
      target_x += 1 if (target_x - ox).odd?
      target_y += 1 if (target_y - oy).odd?
      @sprites["custom_pokemon"].x = [target_x, ox].max
      @sprites["custom_pokemon"].y = [target_y, oy].max
    end
    @sprites["custom_pokemon"].visible = true
  end

  def pbBuildStatsOverlay
    @sprites["custom_statsoverlay"]&.bitmap&.dispose
    @sprites["custom_statsoverlay"]&.dispose
    bmp = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(bmp)
    region       = pbGetPokedexRegion
    seen_count   = $player.pokedex.seen_count(region)
    caught_count = $player.pokedex.owned_count(region)
    filter_name  = FILTER_MODE_NAMES[$PokemonGlobal.pokedexMode] || "Number"
    textPos = [
      ["#{caught_count} Caught", 46,  8, :left, TEXT_COLOR, TEXT_SHADOW],
      ["#{seen_count} Seen",     228, 8, :left, TEXT_COLOR, TEXT_SHADOW],
      [_INTL("By {1}", filter_name), 450, 8, :left, TEXT_COLOR, TEXT_SHADOW]
    ]
    pbDrawTextPositions(bmp, textPos)
    @sprites["custom_statsoverlay"] = Sprite.new(@viewport)
    @sprites["custom_statsoverlay"].bitmap = bmp
    @sprites["custom_statsoverlay"].z      = 10
  end

  #-----------------------------------------------------------------------------
  # Build pokemon name overlay — updates when highlighted species changes
  #-----------------------------------------------------------------------------
  def pbBuildNameOverlay
    @sprites["custom_nameoverlay"]&.bitmap&.dispose
    @sprites["custom_nameoverlay"]&.dispose
    bmp = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(bmp)
    species = @sprites["pokedex"]&.species
    if species && species != 0 && $player.seen?(species)
      name = GameData::Species.get(species).name
      pbDrawTextPositions(bmp, [[name, 38, 82, :left, TEXT_COLOR, TEXT_SHADOW]])
    end
    @sprites["custom_nameoverlay"] = Sprite.new(@viewport)
    @sprites["custom_nameoverlay"].bitmap = bmp
    @sprites["custom_nameoverlay"].z      = 11
  end

  #-----------------------------------------------------------------------------
  # Override pbStartScene — full takeover, no vanilla visuals
  #-----------------------------------------------------------------------------
  alias custom_dex_main_pbStartScene pbStartScene
  def pbStartScene
    # Set up vanilla support objects needed for logic
    @sliderbitmap       = AnimatedBitmap.new("Graphics/UI/Pokedex/icon_slider")
    @typebitmap         = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_types"))
    @shapebitmap        = AnimatedBitmap.new("Graphics/UI/Pokedex/icon_shapes")
    @hwbitmap           = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_hw"))
    @selbitmap          = AnimatedBitmap.new("Graphics/UI/Pokedex/icon_searchsel")
    @searchsliderbitmap = AnimatedBitmap.new(_INTL("Graphics/UI/Pokedex/icon_searchslider"))
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    # Hidden vanilla sprites needed for internal logic
    @sprites["pokedex"] = Window_Pokedex.new(206, 30, 276, 364, @viewport)
    @sprites["pokedex"].visible = false
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Pokedex/bg_list")
    @sprites["background"].visible = false
    @sprites["searchbg"] = IconSprite.new(0, 0, @viewport)
    @sprites["searchbg"].setBitmap("Graphics/UI/Pokedex/bg_search")
    @sprites["searchbg"].visible = false
    @sprites["overlay"]      = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    @sprites["overlay"].visible = false
    pbSetSystemFont(@sprites["overlay"].bitmap)
    @sprites["searchcursor"] = PokedexSearchSelectionSprite.new(@viewport)
    @sprites["searchcursor"].visible = false
    @sprites["icon"]         = PokemonSprite.new(@viewport)
    @sprites["icon"].setOffset(PictureOrigin::CENTER)
    @sprites["icon"].x = 112
    @sprites["icon"].y = 196
    @sprites["icon"].visible = false

    # Search state
    @searchResults = false
    @searchParams  = [$PokemonGlobal.pokedexMode, -1, -1, -1, -1, -1, -1, -1, -1, -1]
    pbRefreshDexList($PokemonGlobal.pokedexIndex[pbGetSavePositionIndex])
    pbDeactivateWindows(@sprites)

    # Scrolling grid
    @sprites["custom_grid"] = IconSprite.new(@viewport)
    @sprites["custom_grid"].setBitmap(DEX_FOLDER + "grid.png")
    @sprites["custom_grid"].x = 0
    @sprites["custom_grid"].y = 0
    @sprites["custom_grid"].z = 0

    # Static overlay
    @sprites["custom_overlay"] = IconSprite.new(@viewport)
    @sprites["custom_overlay"].setBitmap(MAIN_FOLDER + "overlay.png")
    @sprites["custom_overlay"].x = 0
    @sprites["custom_overlay"].y = 0
    @sprites["custom_overlay"].z = 1

    # Caught icon
    @sprites["custom_caughticon"] = IconSprite.new(@viewport)
    @sprites["custom_caughticon"].setBitmap(DEX_FOLDER + "caughticon.png")
    @sprites["custom_caughticon"].x = 4
    @sprites["custom_caughticon"].y = 2
    @sprites["custom_caughticon"].z = 2

    # Seen icon
    @sprites["custom_seenicon"] = IconSprite.new(@viewport)
    @sprites["custom_seenicon"].setBitmap(DEX_FOLDER + "seenicon.png")
    @sprites["custom_seenicon"].x = 186
    @sprites["custom_seenicon"].y = 2
    @sprites["custom_seenicon"].z = 2

    # List window graphic
    @sprites["custom_window"] = IconSprite.new(@viewport)
    @sprites["custom_window"].setBitmap(MAIN_FOLDER + "window.png")
    @sprites["custom_window"].x = 12
    @sprites["custom_window"].y = 58
    @sprites["custom_window"].z = 3

    # Grid cells
    pbBuildGrid

    # Stats text
    pbBuildStatsOverlay

    # Pokémon sprite — centered at 138,240 based on frame 1
    @sprites["custom_pokemon"] = PokemonSprite.new(@viewport)
    @sprites["custom_pokemon"].z = 5
    @last_dex_species = nil
    pbUpdateCustomPokemonSprite

    # Pokémon name text
    @last_dex_index = nil
    pbBuildNameOverlay

    # Scrollbar, cancel button, up/down arrows, search button
    pbBuildScrollbar
    pbBuildCancelButton
    pbBuildArrowButtons
    pbBuildSearchButton
    @search_btn_was_pressed = false

    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  #-----------------------------------------------------------------------------
  # Override pbRefresh — rebuild name overlay when index changes
  #-----------------------------------------------------------------------------
  alias custom_dex_main_pbRefresh pbRefresh
  def pbRefresh
    custom_dex_main_pbRefresh
    current_index = @sprites["pokedex"]&.index
    if current_index != @last_dex_index
      @last_dex_index = current_index
      pbBuildNameOverlay
      pbUpdateCustomPokemonSprite
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbPokedex — swaps in grid navigation and the extra buttons
  #-----------------------------------------------------------------------------
  alias custom_dex_main_pbPokedex pbPokedex
  def pbPokedex
    pbActivateWindow(@sprites, "pokedex") do
      # pbActivateWindow turns the window's own input handling back on, which
      # would otherwise move the cursor on top of what pbHandleGridInput does.
      # Keep it switched off — we're doing navigation ourselves.
      @sprites["pokedex"].active = false
      loop do
        Graphics.update
        Input.update
        oldindex = @sprites["pokedex"].index
        pbUpdate
        clicked = pbHandleGridInput
        cancel_clicked, search_clicked = pbHandleDexButtons
        if oldindex != @sprites["pokedex"].index
          $PokemonGlobal.pokedexIndex[pbGetSavePositionIndex] = @sprites["pokedex"].index if !@searchResults
          pbRefresh
        end
        if clicked
          if $player.seen?(@sprites["pokedex"].species)
            pbSEPlay("GUI pokedex open")
            pbDexEntry(@sprites["pokedex"].index)
            Input.update
          end
        elsif cancel_clicked
          pbPlayCloseMenuSE
          pbFlashCancelButton
          if @searchResults
            pbCloseSearch
            Input.update
          else
            break
          end
        elsif Input.trigger?(Input::ACTION)
          pbSEPlay("GUI pokedex open")
          pbFlashSearchButton
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = false
          pbBuildStatsOverlay
          Input.update
        elsif search_clicked
          pbSEPlay("GUI pokedex open")
          @sprites["pokedex"].active = false
          pbDexSearch
          @sprites["pokedex"].active = false
          pbBuildStatsOverlay
          Input.update
        elsif Input.trigger?(Input::BACK)
          pbPlayCloseMenuSE
          pbFlashCancelButton
          if @searchResults
            pbCloseSearch
            Input.update
          else
            break
          end
        elsif Input.trigger?(Input::USE)
          if $player.seen?(@sprites["pokedex"].species)
            pbSEPlay("GUI pokedex open")
            pbDexEntry(@sprites["pokedex"].index)
            Input.update
          end
        end
      end
    end
  end
  alias custom_dex_main_pbEndScene pbEndScene
  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeGrid
    @sprites["custom_statsoverlay"]&.bitmap&.dispose
    @sprites["custom_statsoverlay"]&.dispose
    @sprites["custom_nameoverlay"]&.bitmap&.dispose
    @sprites["custom_nameoverlay"]&.dispose
    @sprites["custom_pokemon"]&.dispose
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap.dispose
    @typebitmap.dispose
    @shapebitmap.dispose
    @hwbitmap.dispose
    @selbitmap.dispose
    @searchsliderbitmap.dispose
    @viewport.dispose
  end

end