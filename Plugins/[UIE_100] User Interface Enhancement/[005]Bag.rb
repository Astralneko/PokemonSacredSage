#===============================================================================
#                          Custom Bag Screen
#                               V 1.0.4
#                        Developed by Carmaniac
#===============================================================================
class PokemonBag_Scene

  BAG_FOLDER    = "Graphics/Custom UI/Bag/"
  GRID_SCROLL_W = 800

  # Item list layout
  ITEM_VP_X       = 8
  ITEM_VP_Y       = 106
  ITEM_VP_W       = 420
  ITEM_VP_H       = 286
  ITEM_BTN_W      = 400
  ITEM_BTN_H      = 54
  ITEM_BTN_GAP    = 4
  ITEM_BTN_STRIDE = ITEM_BTN_H + ITEM_BTN_GAP
  ITEM_VISIBLE    = 5
  ITEM_CACHE_PAD  = 3   # extra buttons cached either side of visible area
  ITEM_TEXT_COLOR  = Color.new(255, 255, 255)
  ITEM_TEXT_SHADOW = Color.new(156, 156, 156)
  ITEM_HIGHLIGHT_OFFSET = 20

  # Description area
  DESC_VP_X          = 440
  DESC_VP_Y          = 274
  DESC_VP_W          = 350
  DESC_VP_H          = 116
  DESC_SCROLL_SPEED  = 0.5
  DESC_SCROLL_PAUSE  = 90

  # Pocket name text
  POCKET_NAME_COLOR        = Color.new(16, 24, 33)
  POCKET_NAME_SHADOW_COLOR = Color.new(173, 189, 189)

  # Command menu
  CMD_BTN_W        = 182
  CMD_BTN_H        = 64
  CMD_BTN_X        = 622
  CMD_BTN_START_Y  = 420
  CMD_BTN_GAP      = 4
  CMD_BTN_STRIDE   = CMD_BTN_H + CMD_BTN_GAP
  CMD_TEXT_X       = 22
  CMD_TEXT_Y       = 18
  CMD_TEXT_COLOR   = Color.new(0, 0, 0)
  CMD_TEXT_SHADOW  = Color.new(173, 189, 189)
  CMD_HIGHLIGHT_W      = 182
  CMD_HIGHLIGHT_H      = 64
  CMD_HIGHLIGHT_FRAMES = 4
  CMD_HIGHLIGHT_SPEED  = 7
  CMD_HIGHLIGHT_OFFSET = -4

  #-----------------------------------------------------------------------------
  # Full pbStartScene — builds everything ourselves, no vanilla flash
  #-----------------------------------------------------------------------------
  alias custom_bag_pbStartScene pbStartScene
  def pbStartScene(bag, choosing = false, filterproc = nil, resetpocket = true)
    @bag        = bag
    @choosing   = choosing
    @filterproc = filterproc
    pbRefreshFilter

    lastpocket = @bag.last_viewed_pocket
    numfilledpockets = @bag.pockets.length - 1
    if @choosing
      numfilledpockets = 0
      if @filterlist.nil?
        (1...@bag.pockets.length).each { |i| numfilledpockets += 1 if @bag.pockets[i].length > 0 }
      else
        (1...@bag.pockets.length).each { |i| numfilledpockets += 1 if @filterlist[i].length > 0 }
      end
      lastpocket = (resetpocket) ? 1 : @bag.last_viewed_pocket
      if (@filterlist && @filterlist[lastpocket].length == 0) ||
         (!@filterlist && @bag.pockets[lastpocket].length == 0)
        (1...@bag.pockets.length).each do |i|
          if @filterlist && @filterlist[i].length > 0
            lastpocket = i
            break
          elsif !@filterlist && @bag.pockets[i].length > 0
            lastpocket = i
            break
          end
        end
      end
    end
    @bag.last_viewed_pocket = lastpocket

    # Vanilla support objects — kept hidden, used for logic only
    @sliderbitmap = AnimatedBitmap.new("Graphics/UI/Bag/icon_slider")
    @pocketbitmap = AnimatedBitmap.new("Graphics/UI/Bag/icon_pocket")
    @sprites = {}

    # Viewport
    @viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999

    # Hidden vanilla item list window — drives pocket/index logic
    @sprites["itemlist"] = Window_PokemonBag.new(
      @bag, @filterlist, lastpocket,
      168, -8, 314, 40 + 32 + (ITEMSVISIBLE * 32)
    )
    @sprites["itemlist"].viewport    = @viewport
    @sprites["itemlist"].pocket      = lastpocket
    @sprites["itemlist"].index       = @bag.last_viewed_index(lastpocket)
    @sprites["itemlist"].baseColor   = ITEMLISTBASECOLOR
    @sprites["itemlist"].shadowColor = ITEMLISTSHADOWCOLOR
    @sprites["itemlist"].visible     = false

    # Hidden message/help windows — used by vanilla command logic
    @sprites["helpwindow"] = Window_UnformattedTextPokemon.new("")
    @sprites["helpwindow"].visible  = false
    @sprites["helpwindow"].viewport = @viewport
    @vp_msg   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_msg.z = 999999
    @sprites["msgwindow"] = Window_AdvancedTextPokemon.new("")
    @sprites["msgwindow"].visible  = false
    @sprites["msgwindow"].viewport = @vp_msg
    @sprites["msgwindow"].z        = 0

    # Scrolling grid
    @sprites["custom_grid"] = IconSprite.new(@viewport)
    @sprites["custom_grid"].setBitmap(BAG_FOLDER + "backgroundgrid.png")
    @sprites["custom_grid"].x = 0
    @sprites["custom_grid"].y = 0
    @sprites["custom_grid"].z = 0

    # Static overlay
    @sprites["custom_overlay"] = IconSprite.new(@viewport)
    @sprites["custom_overlay"].setBitmap(BAG_FOLDER + "backgroundoverlay.png")
    @sprites["custom_overlay"].x = 0
    @sprites["custom_overlay"].y = 0
    @sprites["custom_overlay"].z = 1

    # Bag sprite (male/female) — uses vanilla logic
    fbagexists = pbResolveBitmap(sprintf("Graphics/UI/Bag/bag_%d_f", lastpocket))
    if $player.female? && fbagexists
      @sprites["bagsprite"] = IconSprite.new(@viewport)
      @sprites["bagsprite"].setBitmap(sprintf("Graphics/UI/Bag/bag_%d_f", lastpocket))
    else
      @sprites["bagsprite"] = IconSprite.new(@viewport)
      @sprites["bagsprite"].setBitmap(sprintf("Graphics/UI/Bag/bag_%d", lastpocket))
    end
    @sprites["bagsprite"].x = 550
    @sprites["bagsprite"].y = 88
    @sprites["bagsprite"].z = 2

    # Navigation buttons
    @sprites["btn_left"] = IconSprite.new(@viewport)
    @sprites["btn_left"].setBitmap(BAG_FOLDER + "left.png")
    @sprites["btn_left"].x = 24
    @sprites["btn_left"].y = 442
    @sprites["btn_left"].z = 3

    @sprites["btn_right"] = IconSprite.new(@viewport)
    @sprites["btn_right"].setBitmap(BAG_FOLDER + "right.png")
    @sprites["btn_right"].x = 94
    @sprites["btn_right"].y = 442
    @sprites["btn_right"].z = 3

    @sprites["btn_cancel"] = IconSprite.new(@viewport)
    @sprites["btn_cancel"].setBitmap(BAG_FOLDER + "cancel.png")
    @sprites["btn_cancel"].x = 758
    @sprites["btn_cancel"].y = 442
    @sprites["btn_cancel"].z = 3

    # Clipped viewport for item list
    @item_viewport   = Viewport.new(ITEM_VP_X, ITEM_VP_Y, ITEM_VP_W, ITEM_VP_H)
    @item_viewport.z = @viewport.z + 2

    # Description viewport
    @desc_viewport   = Viewport.new(DESC_VP_X, DESC_VP_Y, DESC_VP_W, DESC_VP_H)
    @desc_viewport.z = @viewport.z + 3

    # Tracking
    @grid_x                = 0
    @item_scroll           = 0
    @item_btn_sprites      = []
    @item_icon_sprites     = []
    @item_btn_x            = []
    @item_bitmap_cache     = {}   # index => bitmap
    @current_pocket        = nil
    @last_registered_state = []
    @last_mouse_x          = Input.mouse_x
    @last_mouse_y          = Input.mouse_y
    @mouse_moved           = false
    @cmd_menu_open         = false
    @desc_scroll_y         = 0.0
    @desc_scroll_dir       = 1
    @desc_pause            = DESC_SCROLL_PAUSE
    @last_item_index       = -1

    pbDeactivateWindows(@sprites)
    $game_temp.custom_bag_scene = self if $game_temp
    pbBuildPocketName
    pbBuildItemButtons
    pbBuildItemDescription(@sprites["itemlist"]&.item)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  #-----------------------------------------------------------------------------
  # Refresh filter (vanilla method kept)
  #-----------------------------------------------------------------------------
  def pbRefreshFilter
    @filterlist = nil
    return if !@choosing
    return if @filterproc.nil?
    @filterlist = []
    (1...@bag.pockets.length).each do |i|
      @filterlist[i] = []
      @bag.pockets[i].length.times do |j|
        @filterlist[i].push(j) if @filterproc.call(@bag.pockets[i][j][0])
      end
    end
  end

  #-----------------------------------------------------------------------------
  # Build pocket name sprite
  #-----------------------------------------------------------------------------
  def pbBuildPocketName
    @sprites["custom_pocketname"]&.bitmap&.dispose
    @sprites["custom_pocketname"]&.dispose
    bmp = Bitmap.new(Graphics.width, Graphics.height)
    pbSetSystemFont(bmp)
    pocket_name = PokemonBag.pocket_names[@bag.last_viewed_pocket - 1]
    # Center at x=616 with even pixel fix to avoid sub-pixel rendering
    text_w = bmp.text_size(pocket_name).width
    left_x = 616 - (text_w / 2)
    left_x -= 1 if left_x.odd?
    pbDrawTextPositions(bmp, [[pocket_name, left_x, 240, :left, POCKET_NAME_COLOR, POCKET_NAME_SHADOW_COLOR]])
    @sprites["custom_pocketname"] = Sprite.new(@viewport)
    @sprites["custom_pocketname"].bitmap = bmp
    @sprites["custom_pocketname"].z      = 3
  end

  #-----------------------------------------------------------------------------
  # Build item bitmap for a given index (with caching)
  #-----------------------------------------------------------------------------
  def pbGetItemBitmap(i)
    return @item_bitmap_cache[i] if @item_bitmap_cache[i]
    itemlist = @sprites["itemlist"]
    pocket   = @bag.pockets[itemlist.pocket]
    if i < pocket.length
      item = pocket[i][0]
      qty  = pocket[i][1]
      itm  = GameData::Item.get(item)
      registered  = @bag.registered?(item)
      btn_file    = registered ? "itembase_registered.png" : "itembase.png"
      base = Bitmap.new(BAG_FOLDER + btn_file)
      bmp  = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      pbSetSystemFont(bmp)
      textPos = [[itm.name, 68, 12, :left, ITEM_TEXT_COLOR, ITEM_TEXT_SHADOW]]
      if itm.show_quantity?
        textPos.push([_ISPRINTF("x{1: 3d}", qty), ITEM_BTN_W - 60, 12, :right, ITEM_TEXT_COLOR, ITEM_TEXT_SHADOW])
      end
      pbDrawTextPositions(bmp, textPos)
    else
      # Close Bag
      base = Bitmap.new(BAG_FOLDER + "itembase.png")
      bmp  = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      pbSetSystemFont(bmp)
      pbDrawTextPositions(bmp, [[_INTL("CLOSE BAG"), 68, 12, :left, ITEM_TEXT_COLOR, ITEM_TEXT_SHADOW]])
    end
    @item_bitmap_cache[i] = bmp
    return bmp
  end

  #-----------------------------------------------------------------------------
  # Get highlighted bitmap for a given index
  #-----------------------------------------------------------------------------
  def pbGetItemBitmapHighlighted(i)
    cache_key = "#{i}_h"
    return @item_bitmap_cache[cache_key] if @item_bitmap_cache[cache_key]
    itemlist = @sprites["itemlist"]
    pocket   = @bag.pockets[itemlist.pocket]
    if i < pocket.length
      item = pocket[i][0]
      qty  = pocket[i][1]
      itm  = GameData::Item.get(item)
      registered = @bag.registered?(item)
      btn_file   = registered ? "itembase_registered_h.png" : "itembase_h.png"
      base = Bitmap.new(BAG_FOLDER + btn_file)
      bmp  = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      pbSetSystemFont(bmp)
      textPos = [[itm.name, 68, 12, :left, ITEM_TEXT_COLOR, ITEM_TEXT_SHADOW]]
      if itm.show_quantity?
        textPos.push([_ISPRINTF("x{1: 3d}", qty), ITEM_BTN_W - 60, 12, :right, ITEM_TEXT_COLOR, ITEM_TEXT_SHADOW])
      end
      pbDrawTextPositions(bmp, textPos)
    else
      base = Bitmap.new(BAG_FOLDER + "itembase_h.png")
      bmp  = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      pbSetSystemFont(bmp)
      pbDrawTextPositions(bmp, [[_INTL("CLOSE BAG"), 68, 12, :left, ITEM_TEXT_COLOR, ITEM_TEXT_SHADOW]])
    end
    @item_bitmap_cache[cache_key] = bmp
    return bmp
  end

  #-----------------------------------------------------------------------------
  # Clear bitmap cache (called on pocket change)
  #-----------------------------------------------------------------------------
  def pbClearItemBitmapCache
    @item_bitmap_cache = {}
  end

  #-----------------------------------------------------------------------------
  # Build visible item button sprites + cache neighbours
  #-----------------------------------------------------------------------------
  def pbBuildItemButtons
    # Dispose existing sprites
    @item_btn_sprites.each  { |s| s&.dispose }
    @item_icon_sprites.each { |s| s&.dispose }
    @item_btn_sprites  = []
    @item_icon_sprites = []
    @item_btn_x        = []
    @last_item_index   = -1
    itemlist = @sprites["itemlist"]
    return if !itemlist
    pocket = @bag.pockets[itemlist.pocket]
    count  = pocket.length + 1
    count.times do |i|
      btn = Sprite.new(@item_viewport)
      btn.bitmap = nil
      btn.x = 0
      btn.y = i * ITEM_BTN_STRIDE
      btn.z = 0
      @item_btn_sprites << btn
      @item_btn_x       << 0.0
      if i < pocket.length
        item = pocket[i][0]
        icon = ItemIconSprite.new(14, i * ITEM_BTN_STRIDE, item, @item_viewport)
        icon.ox = 2
        icon.oy = 8
        icon.z  = 1
        @item_icon_sprites << icon
      else
        @item_icon_sprites << nil
      end
    end
    pbUpdateItemBitmaps
  end

  #-----------------------------------------------------------------------------
  # Dynamically load bitmaps for visible range + cache padding
  #-----------------------------------------------------------------------------
  def pbUpdateItemBitmaps
    return if !@sprites["itemlist"]
    current  = @sprites["itemlist"].index
    cache_start = [0, @item_scroll - ITEM_CACHE_PAD].max
    cache_end   = [@item_btn_sprites.length - 1, @item_scroll + ITEM_VISIBLE - 1 + ITEM_CACHE_PAD].min
    (cache_start..cache_end).each do |i|
      btn = @item_btn_sprites[i]
      next if !btn
      bmp = (i == current) ? pbGetItemBitmapHighlighted(i) : pbGetItemBitmap(i)
      btn.bitmap = bmp if btn.bitmap != bmp
    end
    # Clear bitmaps outside cache range to save memory
    @item_btn_sprites.each_with_index do |btn, i|
      next if !btn
      next if i >= cache_start && i <= cache_end
      btn.bitmap = nil
    end
  end

  #-----------------------------------------------------------------------------
  # Update item button positions, highlight, mouse hover
  #-----------------------------------------------------------------------------
  def pbUpdateItemButtons
    return if !@item_btn_sprites || @cmd_menu_open
    itemlist = @sprites["itemlist"]
    return if !itemlist
    current = itemlist.index

    # Mouse movement
    cur_x        = Input.mouse_x
    cur_y        = Input.mouse_y
    @mouse_moved  = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
    @last_mouse_x = cur_x
    @last_mouse_y = cur_y

    # Index-driven scroll
    if current < @item_scroll
      @item_scroll = current
    elsif current >= @item_scroll + ITEM_VISIBLE
      @item_scroll = current - ITEM_VISIBLE + 1
    end

    @item_btn_sprites.each_with_index do |btn, i|
      next if !btn
      vis_pos     = i - @item_scroll
      btn.y       = vis_pos * ITEM_BTN_STRIDE
      btn.visible = (vis_pos >= 0 && vis_pos < ITEM_VISIBLE)
      icon = @item_icon_sprites[i]
      if icon
        icon.y       = vis_pos * ITEM_BTN_STRIDE
        icon.visible = btn.visible
      end
      # Mouse hover
      @mouse_moved && btn.visible && Mouse.over?(btn) && itemlist.index = i
      # Smooth slide
      target         = (i == current) ? ITEM_HIGHLIGHT_OFFSET.to_f : 0.0
      @item_btn_x[i] = (@item_btn_x[i] || 0.0) + (target - (@item_btn_x[i] || 0.0)) / 5.0
      final_x        = @item_btn_x[i].round
      btn.x          = final_x
      icon.x         = final_x + 14 if icon
    end

    # Rebuild description if index changed
    new_index = itemlist.index
    if new_index != @last_item_index
      @last_item_index = new_index
      pbBuildItemDescription(itemlist.item)
    end

    # Update bitmaps dynamically
    pbUpdateItemBitmaps
  end

  #-----------------------------------------------------------------------------
  # Build item description
  #-----------------------------------------------------------------------------
  def pbBuildItemDescription(item)
    @sprites["desc_text"]&.bitmap&.dispose
    @sprites["desc_text"]&.dispose
    desc  = item ? GameData::Item.get(item).description : _INTL("Close bag.")
    bmp   = Bitmap.new(DESC_VP_W, DESC_VP_H * 4)
    pbSetSystemFont(bmp)
    lines = []
    words = desc.split(" ")
    line  = ""
    words.each do |word|
      test = line.empty? ? word : "#{line} #{word}"
      if bmp.text_size(test).width > DESC_VP_W - 4
        lines << line
        line = word
      else
        line = test
      end
    end
    lines << line unless line.empty?
    line_h    = bmp.text_size("A").height + 2
    total_h   = lines.length * line_h
    actual_bmp = Bitmap.new(DESC_VP_W, [total_h, DESC_VP_H].max)
    pbSetSystemFont(actual_bmp)
    textPos = []
    lines.each_with_index { |l, i| textPos.push([l, 0, i * line_h, :left, POCKET_NAME_COLOR, POCKET_NAME_SHADOW_COLOR]) }
    pbDrawTextPositions(actual_bmp, textPos)
    bmp.dispose
    @sprites["desc_text"]      = Sprite.new(@desc_viewport)
    @sprites["desc_text"].bitmap = actual_bmp
    @sprites["desc_text"].x    = 0
    @sprites["desc_text"].y    = 0
    @sprites["desc_text"].z    = 0
    @desc_total_h              = total_h
    @desc_scroll_y             = 0.0
    @desc_scroll_dir           = 1
    @desc_pause                = DESC_SCROLL_PAUSE
  end

  #-----------------------------------------------------------------------------
  # Update description scroll
  #-----------------------------------------------------------------------------
  def pbUpdateDescScroll
    return if !@sprites["desc_text"] || !@desc_total_h
    return if @desc_total_h <= DESC_VP_H
    if @desc_pause > 0
      @desc_pause -= 1
      return
    end
    @desc_scroll_y += DESC_SCROLL_SPEED * @desc_scroll_dir
    max_scroll = @desc_total_h - DESC_VP_H
    if @desc_scroll_y >= max_scroll
      @desc_scroll_y   = max_scroll
      @desc_scroll_dir = -1
      @desc_pause      = DESC_SCROLL_PAUSE
    elsif @desc_scroll_y <= 0
      @desc_scroll_y   = 0
      @desc_scroll_dir = 1
      @desc_pause      = DESC_SCROLL_PAUSE
    end
    @sprites["desc_text"].oy = @desc_scroll_y.to_i
  end

  #-----------------------------------------------------------------------------
  # Snapshot of registered states for change detection
  #-----------------------------------------------------------------------------
  def pbGetRegisteredState
    return [] if !@sprites["itemlist"]
    pocket = @bag.pockets[@sprites["itemlist"].pocket]
    return pocket.map { |item_data| @bag.registered?(item_data[0]) }
  end

  #-----------------------------------------------------------------------------
  # Override pbRefresh — pocket/registration change detection
  #-----------------------------------------------------------------------------
  alias custom_bag_pbRefresh pbRefresh
  def pbRefresh
    # Don't call original pbRefresh — we handle everything ourselves
    new_pocket    = @sprites["itemlist"]&.pocket
    new_reg_state = pbGetRegisteredState
    pocket_changed = new_pocket != @current_pocket
    reg_changed    = new_reg_state != @last_registered_state
    if pocket_changed || reg_changed
      @current_pocket        = new_pocket
      @last_registered_state = new_reg_state
      if pocket_changed
        @item_scroll = 0
        @sprites["itemlist"].index = 0 if @sprites["itemlist"]
        pbClearItemBitmapCache
        # Update bag sprite for new pocket
        fbagexists = pbResolveBitmap(sprintf("Graphics/UI/Bag/bag_%d_f", new_pocket))
        if $player.female? && fbagexists
          @sprites["bagsprite"]&.setBitmap(sprintf("Graphics/UI/Bag/bag_%d_f", new_pocket))
        else
          @sprites["bagsprite"]&.setBitmap(sprintf("Graphics/UI/Bag/bag_%d", new_pocket))
        end
      else
        pbClearItemBitmapCache
      end
      pbBuildPocketName
      pbBuildItemButtons
    end
  end

  #-----------------------------------------------------------------------------
  # Override pbRefreshIndexChanged — update description
  #-----------------------------------------------------------------------------
  alias custom_bag_pbRefreshIndexChanged pbRefreshIndexChanged
  def pbRefreshIndexChanged
    # Don't call original — it updates vanilla sprites we don't use
    pbBuildItemDescription(@sprites["itemlist"]&.item)
  end

  #-----------------------------------------------------------------------------
  # Override pbUpdate
  #-----------------------------------------------------------------------------
  alias custom_bag_pbUpdate pbUpdate
  def pbUpdate
	@deltatime = 0 if !@deltatime
	# If it hasn't been 1/60 of a second yet, do nothing
	if System.uptime - @deltatime < 1/60r
		return
	end
	# Set new deltatime
	@deltatime = System.uptime
	# Actual stuff
    # Grid scroll
    @grid_x = (@grid_x || 0) - 1
    @grid_x = 0 if @grid_x <= -GRID_SCROLL_W
    @sprites["custom_grid"].x = @grid_x if @sprites["custom_grid"]
    # Keyboard resets mouse priority
    if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
      @mouse_moved = false
    end
    # Mouse wheel scroll
    if @item_btn_sprites && @sprites["itemlist"] && !@cmd_menu_open
      itemlist   = @sprites["itemlist"]
      total      = itemlist.itemCount
      max_scroll = [total - ITEM_VISIBLE, 0].max
      if Mouse.scroll_up? && @item_scroll > 0
        @item_scroll -= 1
        itemlist.index = @item_scroll if itemlist.index > @item_scroll + ITEM_VISIBLE - 1
      elsif Mouse.scroll_down? && @item_scroll < max_scroll
        @item_scroll += 1
        itemlist.index = @item_scroll if itemlist.index < @item_scroll
      end
    end
    pbUpdateItemButtons
    pbUpdateDescScroll
    # Nav button pressed states and click handling
    if @sprites["btn_left"]
      @sprites["btn_left"].setBitmap(BAG_FOLDER + (Mouse.over?(@sprites["btn_left"]) && Mouse.press? ? "left_p.png" : "left.png"))
      if Mouse.over?(@sprites["btn_left"]) && Mouse.click?
        itemwindow = @sprites["itemlist"]
        newpocket  = itemwindow.pocket
        loop do
          newpocket = (newpocket == 1) ? PokemonBag.pocket_count : newpocket - 1
          break if !@choosing || newpocket == itemwindow.pocket
          break if @filterlist ? @filterlist[newpocket].length > 0 : @bag.pockets[newpocket].length > 0
        end
        if itemwindow.pocket != newpocket
          itemwindow.pocket = newpocket
          @bag.last_viewed_pocket = itemwindow.pocket
          pbPlayCursorSE
          pbRefresh
        end
      end
    end
    if @sprites["btn_right"]
      @sprites["btn_right"].setBitmap(BAG_FOLDER + (Mouse.over?(@sprites["btn_right"]) && Mouse.press? ? "right_p.png" : "right.png"))
      if Mouse.over?(@sprites["btn_right"]) && Mouse.click?
        itemwindow = @sprites["itemlist"]
        newpocket  = itemwindow.pocket
        loop do
          newpocket = (newpocket == PokemonBag.pocket_count) ? 1 : newpocket + 1
          break if !@choosing || newpocket == itemwindow.pocket
          break if @filterlist ? @filterlist[newpocket].length > 0 : @bag.pockets[newpocket].length > 0
        end
        if itemwindow.pocket != newpocket
          itemwindow.pocket = newpocket
          @bag.last_viewed_pocket = itemwindow.pocket
          pbPlayCursorSE
          pbRefresh
        end
      end
    end
    if @sprites["btn_cancel"]
      @sprites["btn_cancel"].setBitmap(BAG_FOLDER + (Mouse.over?(@sprites["btn_cancel"]) && Mouse.press? ? "cancel_p.png" : "cancel.png"))
      if Mouse.over?(@sprites["btn_cancel"]) && Mouse.click?
        $game_temp.custom_bag_cancel = true if $game_temp
        pbPlayCancelSE
      end
    end
    # Item button mouse click
    if @item_btn_sprites && !@cmd_menu_open
      @item_btn_sprites.each_with_index do |btn, i|
        next if !btn || !btn.visible
        if Mouse.over?(btn) && Mouse.click?
          @sprites["itemlist"].index = i
          $game_temp.custom_bag_use = true if $game_temp
          pbPlayDecisionSE
          break
        end
      end
    end
    pbUpdateSpriteHash(@sprites)
  end

  #-----------------------------------------------------------------------------
  # Override pbShowCommands — custom tone overlay + buttons
  #-----------------------------------------------------------------------------
  alias custom_bag_pbShowCommands pbShowCommands
  def pbShowCommands(helptext, commands, index = 0)
    vp_tone = Viewport.new(0, 0, Graphics.width, Graphics.height)
    vp_tone.z = @viewport.z + 10
    tone_spr = IconSprite.new(vp_tone)
    tone_spr.setBitmap(BAG_FOLDER + "tone.png")
    tone_spr.x = 0
    tone_spr.y = 0
    tone_spr.z = 0
    vp_buttons = Viewport.new(0, 0, Graphics.width, Graphics.height)
    vp_buttons.z = @viewport.z + 11
    cmd_btns = []
    commands.length.times do |i|
      base = Bitmap.new(BAG_FOLDER + "buttonbase.png")
      bmp  = Bitmap.new(base.width, base.height)
      bmp.blt(0, 0, base, base.rect)
      base.dispose
      pbSetSystemFont(bmp)
      pbDrawTextPositions(bmp, [[commands[i], CMD_TEXT_X, CMD_TEXT_Y, :left, CMD_TEXT_COLOR, CMD_TEXT_SHADOW]])
      btn     = Sprite.new(vp_buttons)
      btn.bitmap = bmp
      btn.x   = CMD_BTN_X
      btn.y   = CMD_BTN_START_Y - ((commands.length - 1 - i) * CMD_BTN_STRIDE)
      btn.z   = 0
      cmd_btns << btn
    end
    vp_highlight = Viewport.new(0, 0, Graphics.width, Graphics.height)
    vp_highlight.z = @viewport.z + 12
    hl_spr = Sprite.new(vp_highlight)
    hl_spr.bitmap = Bitmap.new(BAG_FOLDER + "highlight.png")
    hl_spr.src_rect.set(0, 0, CMD_HIGHLIGHT_W, CMD_HIGHLIGHT_H)
    hl_spr.z = 0
    vp_msg  = Viewport.new(0, 0, Graphics.width, Graphics.height)
    vp_msg.z = @viewport.z + 13
    msg_win = Window_AdvancedTextPokemon.new(helptext)
    msg_win.setSkin(MessageConfig.pbGetSystemFrame)
    msg_win.viewport = vp_msg
    msg_win.x        = 0
    msg_win.y        = 0
    msg_win.width    = 500
    msg_win.visible  = true
    cmd_index    = index.to_i.clamp(0, commands.length - 1)
    hl_frame     = 0
    hl_tick      = 0
    last_mouse_x = Input.mouse_x
    last_mouse_y = Input.mouse_y
    mouse_moved  = false
    ret          = -1
    @cmd_menu_open = true
    loop do
      Graphics.update
      Input.update
      pbUpdate
      cur_x        = Input.mouse_x
      cur_y        = Input.mouse_y
      mouse_moved  = (cur_x != last_mouse_x || cur_y != last_mouse_y)
      last_mouse_x = cur_x
      last_mouse_y = cur_y
      if mouse_moved
        cmd_btns.each_with_index { |btn, i| cmd_index = i if Mouse.over?(btn) }
      end
      if Input.trigger?(Input::UP)
        cmd_index   = (cmd_index - 1) % commands.length
        mouse_moved = false
        pbPlayCursorSE
      elsif Input.trigger?(Input::DOWN)
        cmd_index   = (cmd_index + 1) % commands.length
        mouse_moved = false
        pbPlayCursorSE
      end
      if cmd_btns[cmd_index]
        hl_spr.x = cmd_btns[cmd_index].x + CMD_HIGHLIGHT_OFFSET
        hl_spr.y = cmd_btns[cmd_index].y + CMD_HIGHLIGHT_OFFSET
      end
      hl_tick += 1
      if hl_tick >= CMD_HIGHLIGHT_SPEED
        hl_tick  = 0
        hl_frame = (hl_frame + 1) % CMD_HIGHLIGHT_FRAMES
        hl_spr.src_rect.y = hl_frame * CMD_HIGHLIGHT_H
      end
      if Input.trigger?(Input::USE)
        ret = cmd_index
        pbPlayDecisionSE
        break
      end
      clicked = false
      cmd_btns.each_with_index do |btn, i|
        if Mouse.over?(btn) && Mouse.click?
          ret     = i
          clicked = true
          pbPlayDecisionSE
          break
        end
      end
      break if clicked
      if Input.trigger?(Input::BACK)
        ret = commands.length - 1
        pbPlayCancelSE
        break
      end
    end
    @cmd_menu_open = false
    msg_win.dispose
    vp_msg.dispose
    cmd_btns.each { |b| b.bitmap&.dispose; b.dispose }
    hl_spr.bitmap&.dispose
    hl_spr.dispose
    tone_spr.dispose
    vp_highlight.dispose
    vp_buttons.dispose
    vp_tone.dispose
    return ret
  end

  #-----------------------------------------------------------------------------
  # Display methods
  #-----------------------------------------------------------------------------
  def pbDisplay(msg, brief = false)
    UIHelper.pbDisplay(@sprites["msgwindow"], msg, brief) { pbUpdate }
  end

  def pbConfirm(msg)
    return UIHelper.pbConfirm(@sprites["msgwindow"], msg) { pbUpdate }
  end

  def pbChooseNumber(helptext, maximum, initnum = 1)
    return UIHelper.pbChooseNumber(@sprites["helpwindow"], helptext, maximum, initnum) { pbUpdate }
  end

  #-----------------------------------------------------------------------------
  # pbFadeOutScene
  #-----------------------------------------------------------------------------
  def pbHideItemSprites
    @item_btn_sprites&.each  { |s| s.visible = false if s && !s.disposed? }
    @item_icon_sprites&.each { |s| s.visible = false if s && !s.disposed? }
    @sprites["desc_text"].visible = false if @sprites["desc_text"] && !@sprites["desc_text"].disposed?
  end

  def pbShowItemSprites
    @item_btn_sprites&.each_with_index do |s, i|
      next if !s || s.disposed?
      vis_pos   = i - (@item_scroll || 0)
      s.visible = (vis_pos >= 0 && vis_pos < ITEM_VISIBLE)
    end
    @item_icon_sprites&.each_with_index do |s, i|
      next if !s || s.disposed?
      vis_pos   = i - (@item_scroll || 0)
      s.visible = (vis_pos >= 0 && vis_pos < ITEM_VISIBLE)
    end
    @sprites["desc_text"].visible = true if @sprites["desc_text"] && !@sprites["desc_text"].disposed?
  end

  def pbFadeOutScene
    pbHideItemSprites
    @oldsprites = pbFadeOutAndHide(@sprites)
  end

  def pbFadeInScene
    pbFadeInAndShow(@sprites, @oldsprites)
    pbShowItemSprites
    @oldsprites = nil
  end

  #-----------------------------------------------------------------------------
  # pbEndScene
  #-----------------------------------------------------------------------------
  def pbEndScene
    if !@oldsprites
      @item_btn_sprites&.each  { |s| s&.visible = false }
      @item_icon_sprites&.each { |s| s&.visible = false }
      @sprites["desc_text"]&.visible = false
      pbFadeOutAndHide(@sprites)
    end
    @oldsprites = nil
    dispose
  end

  #-----------------------------------------------------------------------------
  # dispose
  #-----------------------------------------------------------------------------
  def dispose
    # Nil out bitmap references before disposing to prevent recycled object errors
    @item_btn_sprites&.each { |s| s.bitmap = nil; s&.dispose }
    @item_icon_sprites&.each { |s| s&.dispose }
    @item_bitmap_cache&.each { |_, bmp| bmp&.dispose }
    @item_bitmap_cache = {}
    @sprites["desc_text"]&.bitmap&.dispose
    @sprites["desc_text"]&.dispose
    @sprites["desc_text"] = nil
    @desc_viewport&.dispose
    @desc_viewport = nil
    @item_viewport&.dispose
    @item_viewport = nil
    @vp_msg&.dispose
    @vp_msg = nil
    @sprites["custom_pocketname"]&.bitmap&.dispose
    @sprites["custom_pocketname"]&.dispose
    @sprites["custom_pocketname"] = nil
    pbDisposeSpriteHash(@sprites)
    @sliderbitmap&.dispose
    @pocketbitmap&.dispose
    @viewport&.dispose
    $game_temp.custom_bag_scene = nil if $game_temp
  end

end

#-------------------------------------------------------------------------------
# Track bag scene instance so pbFadeOutIn can hide item sprites
#-------------------------------------------------------------------------------
class Game_Temp
  attr_accessor :custom_bag_cancel
  attr_accessor :custom_bag_use
  attr_accessor :custom_bag_scene
end

module CustomBagFadeOutInPatch
  def pbFadeOutIn(*args, &block)
    scene = $game_temp&.custom_bag_scene
    scene&.pbHideItemSprites
    super(*args, &block)
    scene&.pbShowItemSprites
  end
end

Object.prepend(CustomBagFadeOutInPatch)

module CustomBagInputPatch
  def trigger?(button)
    if button == Input::BACK && $game_temp&.custom_bag_cancel
      $game_temp.custom_bag_cancel = false
      return true
    end
    if button == Input::USE && $game_temp&.custom_bag_use
      $game_temp.custom_bag_use = false
      return true
    end
    return super
  end
end

module Input
  class << self
    prepend CustomBagInputPatch
  end
end