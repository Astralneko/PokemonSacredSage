#===============================================================================
#                        Custom Text Entry Screen
#                               V 1.0.1
#                        Developed by Carmaniac
#===============================================================================
class PokemonEntryScene2
  GRAPHICS_PATH = "Graphics/Custom UI/Text Entry/"

  @@Characters = [
    [("ABCDEFGHIJ ,." + "KLMNOPQRST '-" + "UVWXYZ     ♂♀" + "             " + "0123456789   ").scan(/./), _INTL("UPPER")],
    [("abcdefghij ,." + "klmnopqrst '-" + "uvwxyz     ♂♀" + "             " + "0123456789   ").scan(/./), _INTL("lower")],
    [("ÀÁÂÄÃàáâäã Ææ" + "ÈÉÊË èéêë  Çç" + "ÌÍÎÏ ìíîï  Œœ" + "ÒÓÔÖÕòóôöõ Ññ" + "ÙÚÛÜ ùúûü  Ýý").scan(/./), _INTL("accents")],
    [(",.:;…•!?¡¿ ♂♀" + "“”‘’﴾﴿*~_^ ΡΚ" + "@\#&%+-×÷/= ΠΜ" + "◎○□△♠♥♦♣★✨  $" + "♈♌♒♐♩♪♫☽☾    ").scan(/./), _INTL("other")]
  ]
  ROWS    = 13
  COLUMNS = 5
  MODE1   = -6
  MODE2   = -5
  MODE3   = -4
  MODE4   = -3
  BACK    = -2
  OK      = -1

  TILE_START_X = 72
  TILE_START_Y = 128
  TILE_WIDTH   = 40
  TILE_HEIGHT  = 56
  TILE_ROW_GAP = 14
  TILE_ROW_STEP = TILE_HEIGHT + TILE_ROW_GAP

  TILE_TEXT_COLOR   = Color.new(255, 255, 255)
  TILE_SHADOW_COLOR = Color.new(32, 32, 32)

  BUTTON_BASE_X = 66
  BUTTON_BASE_Y = 120
  BUTTON_BASE_WIDTH  = 532
  BUTTON_BASE_HEIGHT = 352

  CONTROLS_FINAL_X = 666
  CONTROLS_FINAL_Y = 114
  CONTROLS_OFFSCREEN_X = 800

  MODE_POSITIONS = {
    MODE1 => [702, 150],
    MODE2 => [702, 196],
    MODE3 => [702, 242],
    MODE4 => [702, 288]
  }
  MODE_BUTTON_SIZE = [60, 44]

  BACK_POSITION = [694, 358]
  OK_POSITION   = [694, 428]
  BACK_OK_SIZE  = [60, 44]

  TOP_X_OFFSET = 130

  class NameEntryCursor
    def initialize(viewport)
      @sprite = Sprite.new(viewport)
      @cursortype = 0
      @cursor1 = AnimatedBitmap.new(PokemonEntryScene2::GRAPHICS_PATH + "cursor_1")
      @cursor2 = AnimatedBitmap.new(PokemonEntryScene2::GRAPHICS_PATH + "cursor_2")
      @cursor3 = AnimatedBitmap.new(PokemonEntryScene2::GRAPHICS_PATH + "cursor_3")
      @cursorPos = 0
      updateInternal
    end

    def setCursorPos(value)
      @cursorPos = value
    end

    def updateCursorPos
      value = @cursorPos
      case value
      when PokemonEntryScene2::MODE1, PokemonEntryScene2::MODE2,
           PokemonEntryScene2::MODE3, PokemonEntryScene2::MODE4
        pos = PokemonEntryScene2::MODE_POSITIONS[value]
        @sprite.x = pos[0]
        @sprite.y = pos[1]
        @cursortype = 1
      when PokemonEntryScene2::BACK
        @sprite.x = PokemonEntryScene2::BACK_POSITION[0]
        @sprite.y = PokemonEntryScene2::BACK_POSITION[1]
        @cursortype = 2
      when PokemonEntryScene2::OK
        @sprite.x = PokemonEntryScene2::OK_POSITION[0]
        @sprite.y = PokemonEntryScene2::OK_POSITION[1]
        @cursortype = 2
      else
        if value >= 0
          col = value % PokemonEntryScene2::ROWS
          row = value / PokemonEntryScene2::ROWS
          @sprite.x = PokemonEntryScene2::TILE_START_X + (PokemonEntryScene2::TILE_WIDTH * col)
          @sprite.y = PokemonEntryScene2::TILE_START_Y + (PokemonEntryScene2::TILE_ROW_STEP * row)
          @cursortype = 0
        end
      end
    end

    def visible=(value); @sprite.visible = value; end
    def visible; @sprite.visible; end
    def color=(value); @sprite.color = value; end
    def color; @sprite.color; end
    def disposed?; @sprite.disposed?; end

    def updateInternal
      @cursor1.update
      @cursor2.update
      @cursor3.update
      updateCursorPos
      case @cursortype
      when 0 then @sprite.bitmap = @cursor1.bitmap
      when 1 then @sprite.bitmap = @cursor2.bitmap
      when 2 then @sprite.bitmap = @cursor3.bitmap
      end
    end

    def update
      updateInternal
    end

    def dispose
      @cursor1.dispose
      @cursor2.dispose
      @cursor3.dispose
      @sprite.dispose
    end
  end

  #-----------------------------------------------------------------------------
  # Scene setup
  #-----------------------------------------------------------------------------
  def pbStartScene(helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @helptext = helptext
    @helper = CharacterEntryHelper.new(initialText)
    @mode = 0
    @minlength = minlength
    @maxlength = maxlength
    @cursorpos = 0
    @refreshOverlay = true
    @scrolling = false     # true while a tab-switch scroll animation is in progress
    @gridScrollY = 0       # offset used during tab-switch scroll
    @panelOffsetY = Graphics.height - BUTTON_BASE_Y   # button_base + grid start off the bottom of the screen

    @sprites = {}
    setupBackground
    setupSubjectIcon(subject, pokemon)
    setupButtonBase
    setupLetterGrid
    setupModeIcon
    setupControlsOverlay
    @sprites["mode_icon"].x = @sprites["controls"].x + @modeIconOffsetX   # start locked to controls' off-screen position
    setupBlanksAndHelpOverlay
    setupMouseHitboxes

    @sprites["cursor"] = NameEntryCursor.new(@viewport)
    @sprites["cursor"].visible = false
    @sprites["cursor"].setCursorPos(@cursorpos)

    slideSprites = {}
    ["button_base", "controls", "mode_icon"].each { |k| slideSprites[k] = @sprites.delete(k) }
    (0...(ROWS * COLUMNS)).each { |i| slideSprites["grid#{i}"] = @sprites.delete("grid#{i}") }

    pbFadeInAndShow(@sprites) { pbUpdate }

    slideSprites.each do |k, spr|
      spr.opacity = 255 if spr.respond_to?(:opacity=)
      spr.visible = true if spr.respond_to?(:visible=)
      @sprites[k] = spr
    end

    animateEntrance
    @sprites["cursor"].visible = true
  end

  def setupBackground
    @sprites["bg"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg"].setBitmap(GRAPHICS_PATH + "bg")
    # bg_2 kept available per original code (used as a secondary/alt background layer)
    @sprites["bg2"] = IconSprite.new(0, 0, @viewport)
    @sprites["bg2"].setBitmap(GRAPHICS_PATH + "bg_2")
    @sprites["bg2"].visible = false   # toggle on if/when needed elsewhere
  end

  def setupSubjectIcon(subject, pokemon)
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap(GRAPHICS_PATH + "icon_shadow")
        @sprites["shadow"].x = 66 + TOP_X_OFFSET
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8) + TOP_X_OFFSET
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap(GRAPHICS_PATH + "icon_shadow")
        @sprites["shadow"].x = 66 + TOP_X_OFFSET
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88 + TOP_X_OFFSET
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430 + TOP_X_OFFSET
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap(GRAPHICS_PATH + "icon_shadow")
      @sprites["shadow"].x = 66 + TOP_X_OFFSET
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8) + TOP_X_OFFSET
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = GRAPHICS_PATH + "icon_storage"
      @sprites["subject"].anim_duration = 0.4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8) + TOP_X_OFFSET
      @sprites["subject"].y = 52 - (charheight / 2)
    end
  end

  def setupButtonBase
    @sprites["button_base"] = IconSprite.new(BUTTON_BASE_X, BUTTON_BASE_Y + @panelOffsetY, @viewport)
    @sprites["button_base"].setBitmap(GRAPHICS_PATH + "button_base")
  end

  def setupLetterGrid
    @gridSprites = []
    @tileBitmapNormal = Bitmap.new(TILE_WIDTH, TILE_HEIGHT)
    @tileBitmapNormal.blt(0, 0, RPG::Cache.load_bitmap(GRAPHICS_PATH, "button"), Rect.new(0, 0, TILE_WIDTH, TILE_HEIGHT))
    chset = @@Characters[@mode][0]
    (ROWS * COLUMNS).times do |i|
      col = i % ROWS
      row = i / ROWS
      spr = Sprite.new(@viewport)
      spr.bitmap = Bitmap.new(TILE_WIDTH, TILE_HEIGHT)
      spr.x = TILE_START_X + (TILE_WIDTH * col)
      spr.y = TILE_START_Y + (TILE_ROW_STEP * row) + @gridScrollY + @panelOffsetY
      drawTile(spr, chset[i])
      @gridSprites[i] = spr
      @sprites["grid#{i}"] = spr
    end
  end

  def drawTile(sprite, char, pressed: false)
    sprite.bitmap.clear
    sprite.bitmap.blt(0, 0, RPG::Cache.load_bitmap(GRAPHICS_PATH, pressed ? "button_p" : "button"), Rect.new(0, 0, TILE_WIDTH, TILE_HEIGHT))
    return if !char || char == " "
    pbSetSystemFont(sprite.bitmap)
    # Centered horizontally and vertically within the tile
    textpos = [[char, TILE_WIDTH / 2, (TILE_HEIGHT - sprite.bitmap.font.size) / 2, :center,
                TILE_TEXT_COLOR, TILE_SHADOW_COLOR]]
    pbDrawTextPositions(sprite.bitmap, textpos)
  end

  def flashTile(spr, char)
    2.times do
      drawTile(spr, char, pressed: true)
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }   # brief hold on the pressed frame
      drawTile(spr, char, pressed: false)
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }   # brief hold on the normal frame
    end
  end

  def setupModeIcon
    @modeBitmap = AnimatedBitmap.new(GRAPHICS_PATH + "icon_mode")
    @sprites["mode_icon"] = Sprite.new(@viewport)
    @sprites["mode_icon"].bitmap = @modeBitmap.bitmap
    @sprites["mode_icon"].z = 100   # must render above overlay_controls, which shows the unselected tab art
    @sprites["mode_icon"].src_rect = Rect.new(0, @mode * MODE_BUTTON_SIZE[1], MODE_BUTTON_SIZE[0], MODE_BUTTON_SIZE[1])
    @sprites["mode_icon"].x = MODE_POSITIONS[MODE1][0]
    @sprites["mode_icon"].y = MODE_POSITIONS[MODE1 + @mode][1] rescue MODE_POSITIONS[MODE1][1]
    updateModeIconPosition
    @modeIconOffsetX = @sprites["mode_icon"].x - CONTROLS_FINAL_X
  end

  def updateModeIconPosition
    keys = [MODE1, MODE2, MODE3, MODE4]
    pos = MODE_POSITIONS[keys[@mode]]
    @sprites["mode_icon"].x = @sprites["controls"] ? @sprites["controls"].x + @modeIconOffsetX : pos[0]
    @sprites["mode_icon"].y = pos[1]
    @sprites["mode_icon"].src_rect = Rect.new(0, @mode * MODE_BUTTON_SIZE[1], MODE_BUTTON_SIZE[0], MODE_BUTTON_SIZE[1])
  end

  def setupControlsOverlay
    @sprites["controls"] = IconSprite.new(CONTROLS_OFFSCREEN_X, CONTROLS_FINAL_Y, @viewport)
    @sprites["controls"].setBitmap(GRAPHICS_PATH + "overlay_controls")
  end

  def setupBlanksAndHelpOverlay
    @blanks = []
    @maxlength.times do |i|
      @sprites["blank#{i}"] = Sprite.new(@viewport)
      @sprites["blank#{i}"].x = 160 + (24 * i) + TOP_X_OFFSET
      @sprites["blank#{i}"].y = 78
      @sprites["blank#{i}"].bitmap = underlineBitmap
      @blanks[i] = 0
    end
    @sprites["bgoverlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbDoUpdateOverlay
  end

  def underlineBitmap
    return @underline_bitmap if @underline_bitmap
    @underline_bitmap = Bitmap.new(24, 6)
    @underline_bitmap.fill_rect(2, 2, 22, 4, Color.new(168, 184, 184))
    @underline_bitmap.fill_rect(0, 0, 22, 4, Color.new(16, 24, 32))
    @underline_bitmap
  end

  def pbUpdateOverlay
    @refreshOverlay = true
  end

  def pbDoUpdateOverlay
    return if !@refreshOverlay
    @refreshOverlay = false
    bgoverlay = @sprites["bgoverlay"].bitmap
    bgoverlay.clear
    pbSetSystemFont(bgoverlay)
    textPositions = [
      [@helptext, 160 + TOP_X_OFFSET, 18, :left, Color.new(16, 24, 32), Color.new(168, 184, 184)]
    ]
    chars = @helper.textChars
    x = 172 + TOP_X_OFFSET
    chars.each do |ch|
      textPositions.push([ch, x, 54, :center, Color.new(16, 24, 32), Color.new(168, 184, 184)])
      x += 24
    end
    pbDrawTextPositions(bgoverlay, textPositions)
  end

  def pbChangeTab(newtab = @mode + 1)
    pbSEPlay("GUI naming tab swap start")
    @sprites["cursor"].visible = false
    @scrolling = true

    scrollDistance = Graphics.height - BUTTON_BASE_Y
    timer_start = System.uptime

    loop do
      @gridScrollY = lerp(0, scrollDistance, 0.25, timer_start, System.uptime)
      @sprites["button_base"].y = BUTTON_BASE_Y + @gridScrollY
      repositionGridSprites
      Graphics.update
      Input.update
      pbUpdate
      break if @gridScrollY >= scrollDistance
    end

    # Swap character set + mode while off screen
    @mode = newtab % @@Characters.length
    chset = @@Characters[@mode][0]
    @gridSprites.each_with_index do |spr, i|
      drawTile(spr, chset[i])
    end
    updateModeIconPosition

    @gridScrollY = scrollDistance
    @sprites["button_base"].y = BUTTON_BASE_Y + @gridScrollY
    repositionGridSprites
    timer_start = System.uptime
    loop do
      @gridScrollY = lerp(scrollDistance, 0, 0.25, timer_start, System.uptime)
      @sprites["button_base"].y = BUTTON_BASE_Y + @gridScrollY
      repositionGridSprites
      Graphics.update
      Input.update
      pbUpdate
      break if @gridScrollY <= 0
    end
    @gridScrollY = 0
    @sprites["button_base"].y = BUTTON_BASE_Y
    repositionGridSprites

    @sprites["cursor"].visible = true
    @scrolling = false
    pbSEPlay("GUI naming tab swap end")
  end

  def repositionGridSprites
    @gridSprites.each_with_index do |spr, i|
      col = i % ROWS
      row = i / ROWS
      spr.y = TILE_START_Y + (TILE_ROW_STEP * row) + @gridScrollY + @panelOffsetY
    end
  end

  def animateEntrance
    startY = @panelOffsetY
    startControlsX = @sprites["controls"].x
    timer_start = System.uptime
    loop do
      @panelOffsetY = lerp(startY, 0, 0.4, timer_start, System.uptime)
      @sprites["button_base"].y = BUTTON_BASE_Y + @panelOffsetY
      repositionGridSprites
      @sprites["controls"].x = lerp(startControlsX, CONTROLS_FINAL_X, 0.4, timer_start, System.uptime)
      @sprites["mode_icon"].x = @sprites["controls"].x + @modeIconOffsetX
      Graphics.update
      Input.update
      pbUpdate
      break if @panelOffsetY <= 0 && @sprites["controls"].x <= CONTROLS_FINAL_X
    end
    @panelOffsetY = 0
    @sprites["button_base"].y = BUTTON_BASE_Y
    repositionGridSprites
    @sprites["controls"].x = CONTROLS_FINAL_X
    @sprites["mode_icon"].x = @sprites["controls"].x + @modeIconOffsetX
  end

  #-----------------------------------------------------------------------------
  # Per-frame update
  #-----------------------------------------------------------------------------
  def pbUpdate
    @modeBitmap.update
    cursorpos = @helper.cursor.clamp(0, @maxlength - 1)
    @maxlength.times do |i|
      @blanks[i] = (i == cursorpos) ? 1 : 0
      @sprites["blank#{i}"].y = [78, 82][@blanks[i]]
    end
    pbDoUpdateOverlay
    pbUpdateSpriteHash(@sprites)
  end

  def pbColumnEmpty?(m)
    return false if m >= ROWS - 1
    chset = @@Characters[@mode][0]
    COLUMNS.times do |i|
      return false if chset[(i * ROWS) + m] != " "
    end
    return true
  end

  def wrapmod(x, y)
    result = x % y
    result += y if result < 0
    return result
  end

  def pbMoveCursor
    oldcursor = @cursorpos
    cursordiv = @cursorpos / ROWS
    cursormod = @cursorpos % ROWS
    cursororigin = @cursorpos - cursormod
    # Ordered list of the 6 vertical control stops, top to bottom
    controlOrder = [MODE1, MODE2, MODE3, MODE4, BACK, OK]

    if Input.repeat?(Input::LEFT)
      if @cursorpos < 0
        # Move from the control column back into the grid's rightmost column,
        # landing on the row proportional to where we were in the control list
        idx = controlOrder.index(@cursorpos) || 0
        row = ((idx.to_f / (controlOrder.length - 1)) * (COLUMNS - 1)).round
        @cursorpos = (row * ROWS) + (ROWS - 1)
        loop do
          break unless pbColumnEmpty?(@cursorpos % ROWS)
          @cursorpos -= 1
          break if (@cursorpos % ROWS) == 0
        end
      else
        loop do
          cursormod = wrapmod(cursormod - 1, ROWS)
          @cursorpos = cursororigin + cursormod
          break unless pbColumnEmpty?(cursormod)
        end
      end
    elsif Input.repeat?(Input::RIGHT)
      if @cursorpos < 0
        # Already in the control column - RIGHT does nothing further
      else
        # If already in the rightmost column, jump out to the control panel,
        # landing on whichever control is proportionally closest to this row
        if cursormod >= ROWS - 1 || pbColumnEmpty?(cursormod + 1)
          rowFraction = cursordiv.to_f / (COLUMNS - 1)
          idx = (rowFraction * (controlOrder.length - 1)).round
          @cursorpos = controlOrder[idx]
        else
          loop do
            cursormod = wrapmod(cursormod + 1, ROWS)
            @cursorpos = cursororigin + cursormod
            break unless pbColumnEmpty?(cursormod)
          end
        end
      end
    elsif Input.repeat?(Input::UP)
      if @cursorpos < 0
        idx = controlOrder.index(@cursorpos) || 0
        idx = wrapmod(idx - 1, controlOrder.length)
        @cursorpos = controlOrder[idx]
      else
        cursordiv = wrapmod(cursordiv - 1, COLUMNS)
        @cursorpos = (cursordiv * ROWS) + cursormod
      end
    elsif Input.repeat?(Input::DOWN)
      if @cursorpos < 0
        idx = controlOrder.index(@cursorpos) || 0
        idx = wrapmod(idx + 1, controlOrder.length)
        @cursorpos = controlOrder[idx]
      else
        cursordiv = wrapmod(cursordiv + 1, COLUMNS)
        @cursorpos = (cursordiv * ROWS) + cursormod
      end
    end
    if @cursorpos != oldcursor
      @sprites["cursor"].setCursorPos(@cursorpos)
      pbPlayCursorSE
      return true
    end
    return false
  end

  def setupMouseHitboxes
    @modeHitboxes = {}
    [MODE1, MODE2, MODE3, MODE4].each do |key|
      pos = MODE_POSITIONS[key]
      @modeHitboxes[key] = Rect.new(pos[0], pos[1], MODE_BUTTON_SIZE[0], MODE_BUTTON_SIZE[1])
    end
    @backHitbox = Rect.new(BACK_POSITION[0], BACK_POSITION[1], BACK_OK_SIZE[0], BACK_OK_SIZE[1])
    @okHitbox   = Rect.new(OK_POSITION[0], OK_POSITION[1], BACK_OK_SIZE[0], BACK_OK_SIZE[1])
  end

  def pbUpdateMouseGrid
    return if @scrolling
    chset = @@Characters[@mode][0]
    @gridSprites.each_with_index do |spr, i|
      next unless chset[i]
      next unless spr.over?
      if spr.click?
        @cursorpos = i
        @sprites["cursor"].setCursorPos(@cursorpos)
        selectCurrentTile
      end
    end
  end

  def pbUpdateMouseControls
    return if @scrolling
    keys = [MODE1, MODE2, MODE3, MODE4]
    keys.each_with_index do |key, idx|
      rect = @modeHitboxes[key]
      next unless rect.over?
      if rect.click? && @mode != idx
        @cursorpos = key
        @sprites["cursor"].setCursorPos(@cursorpos)
        pbChangeTab(idx)
      end
    end

    if @backHitbox.over?
      if @backHitbox.click?
        @cursorpos = BACK
        @sprites["cursor"].setCursorPos(@cursorpos)
        @helper.delete
        pbPlayCancelSE
        pbUpdateOverlay
      end
    end

    if @okHitbox.over?
      if @okHitbox.click?
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
        result = confirmEntry
        @pendingResult = result if result
      end
    end
  end

  def selectCurrentTile
    cursormod = @cursorpos % ROWS
    cursordiv = @cursorpos / ROWS
    charpos = (cursordiv * ROWS) + cursormod
    chset = @@Characters[@mode][0]
    @helper.delete if @helper.length >= @maxlength
    @helper.insert(chset[charpos])
    pbPlayCursorSE
    flashTile(@gridSprites[charpos], chset[charpos])
    if @helper.length >= @maxlength
      @cursorpos = OK
      @sprites["cursor"].setCursorPos(@cursorpos)
    end
    pbUpdateOverlay
    pbChangeTab(1) if @mode == 0 && @helper.cursor == 1
  end

  def confirmEntry
    pbSEPlay("GUI naming confirm")
    return nil if @helper.length < @minlength
    return @helper.text
  end

  #-----------------------------------------------------------------------------
  # Main entry loop
  #-----------------------------------------------------------------------------
  def pbEntry
    ret = ""
    loop do
      Graphics.update
      Input.update

      pbUpdate
      pbUpdateMouseGrid
      pbUpdateMouseControls

      next if pbMoveCursor

      if Input.trigger?(Input::SPECIAL)
        pbChangeTab
      elsif Input.trigger?(Input::ACTION)
        @cursorpos = OK
        @sprites["cursor"].setCursorPos(@cursorpos)
      elsif Input.trigger?(Input::BACK)
        @helper.delete
        pbPlayCancelSE
        pbUpdateOverlay
      elsif Input.trigger?(Input::USE)
        case @cursorpos
        when BACK
          @helper.delete
          pbPlayCancelSE
          pbUpdateOverlay
        when OK
          result = confirmEntry
          if result
            ret = result
            break
          end
        when MODE1
          pbChangeTab(0) if @mode != 0
        when MODE2
          pbChangeTab(1) if @mode != 1
        when MODE3
          pbChangeTab(2) if @mode != 2
        when MODE4
          pbChangeTab(3) if @mode != 3
        else
          selectCurrentTile
        end
      end

      if @pendingResult
        ret = @pendingResult
        break
      end
    end
    Input.update
    return ret
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    @gridSprites&.each { |spr| spr.bitmap.dispose if spr.bitmap && !spr.bitmap.disposed? }
    @tileBitmapNormal&.dispose
    @modeBitmap&.dispose
    @underline_bitmap&.dispose
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
# Custom Text Entry Screen - Overwrites PokemonEntryScene (keyboard-typed mode)
#===============================================================================
class PokemonEntryScene
  GRAPHICS_PATH = PokemonEntryScene2::GRAPHICS_PATH
  TOP_X_OFFSET  = PokemonEntryScene2::TOP_X_OFFSET
  USEKEYBOARD = true

  def pbStartScene(helptext, minlength, maxlength, initialText, subject = 0, pokemon = nil)
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    if USEKEYBOARD
      @sprites["entry"] = Window_TextEntry_Keyboard.new(
        initialText, 0, 0, 400 - 112, 96, helptext, true
      )
      Input.text_input = true
    else
      @sprites["entry"] = Window_TextEntry.new(initialText, 0, 0, 400, 96, helptext, true)
    end
    @sprites["entry"].windowskin = nil   # borderless - sits directly over bg_2
    @sprites["entry"].x = (Graphics.width / 2) - (@sprites["entry"].width / 2) + 32 + TOP_X_OFFSET
    @sprites["entry"].viewport = @viewport
    @sprites["entry"].visible = true
    @minlength = minlength
    @maxlength = maxlength
    @symtype = 0
    @sprites["entry"].maxlength = maxlength
    if !USEKEYBOARD
      @sprites["entry2"] = Window_CharacterEntry.new(@@Characters[@symtype][0])
      @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
      @sprites["entry2"].viewport = @viewport
      @sprites["entry2"].visible = true
      @sprites["entry2"].x = (Graphics.width / 2) - (@sprites["entry2"].width / 2) + TOP_X_OFFSET
    end
    if minlength == 0
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard. Press\nEnter to confirm, or Esc to cancel."),
        32 + TOP_X_OFFSET, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    else
      @sprites["helpwindow"] = Window_UnformattedTextPokemon.newWithSize(
        _INTL("Enter text using the keyboard.\nPress Enter to confirm."),
        32 + TOP_X_OFFSET, Graphics.height - 96, Graphics.width - 64, 96, @viewport
      )
    end
    @sprites["helpwindow"].windowskin = nil   # borderless - sits directly over bg_2
    @sprites["helpwindow"].letterbyletter = false
    @sprites["helpwindow"].viewport = @viewport
    @sprites["helpwindow"].visible = USEKEYBOARD
    @sprites["helpwindow"].baseColor = Color.new(16, 24, 32)
    @sprites["helpwindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap(GRAPHICS_PATH + "bg_2")
    @sprites["background"].z = 0
    case subject
    when 1   # Player
      meta = GameData::PlayerMetadata.get($player.character_ID)
      if meta
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap(GRAPHICS_PATH + "icon_shadow")
        @sprites["shadow"].x = 66 + TOP_X_OFFSET
        @sprites["shadow"].y = 64
        filename = pbGetPlayerCharset(meta.walk_charset, nil, true)
        @sprites["subject"] = TrainerWalkingCharSprite.new(filename, @viewport)
        charwidth = @sprites["subject"].bitmap.width
        charheight = @sprites["subject"].bitmap.height
        @sprites["subject"].x = 88 - (charwidth / 8) + TOP_X_OFFSET
        @sprites["subject"].y = 76 - (charheight / 4)
      end
    when 2   # Pokémon
      if pokemon
        @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
        @sprites["shadow"].setBitmap(GRAPHICS_PATH + "icon_shadow")
        @sprites["shadow"].x = 66 + TOP_X_OFFSET
        @sprites["shadow"].y = 64
        @sprites["subject"] = PokemonIconSprite.new(pokemon, @viewport)
        @sprites["subject"].setOffset(PictureOrigin::CENTER)
        @sprites["subject"].x = 88 + TOP_X_OFFSET
        @sprites["subject"].y = 54
        @sprites["gender"] = BitmapSprite.new(32, 32, @viewport)
        @sprites["gender"].x = 430 + TOP_X_OFFSET
        @sprites["gender"].y = 54
        @sprites["gender"].bitmap.clear
        pbSetSystemFont(@sprites["gender"].bitmap)
        textpos = []
        if pokemon.male?
          textpos.push([_INTL("♂"), 0, 6, :left, Color.new(0, 128, 248), Color.new(168, 184, 184)])
        elsif pokemon.female?
          textpos.push([_INTL("♀"), 0, 6, :left, Color.new(248, 24, 24), Color.new(168, 184, 184)])
        end
        pbDrawTextPositions(@sprites["gender"].bitmap, textpos)
      end
    when 3   # NPC
      @sprites["shadow"] = IconSprite.new(0, 0, @viewport)
      @sprites["shadow"].setBitmap(GRAPHICS_PATH + "icon_shadow")
      @sprites["shadow"].x = 66 + TOP_X_OFFSET
      @sprites["shadow"].y = 64
      @sprites["subject"] = TrainerWalkingCharSprite.new(pokemon.to_s, @viewport)
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8) + TOP_X_OFFSET
      @sprites["subject"].y = 76 - (charheight / 4)
    when 4   # Storage box
      @sprites["subject"] = TrainerWalkingCharSprite.new(nil, @viewport)
      @sprites["subject"].altcharset = GRAPHICS_PATH + "icon_storage"
      @sprites["subject"].anim_duration = 0.4
      charwidth = @sprites["subject"].bitmap.width
      charheight = @sprites["subject"].bitmap.height
      @sprites["subject"].x = 88 - (charwidth / 8) + TOP_X_OFFSET
      @sprites["subject"].y = 52 - (charheight / 2)
    end
    pbFadeInAndShow(@sprites)
  end

  def pbEntry1
    ret = ""
    loop do
      Graphics.update
      Input.update
      if Input.triggerex?(:ESCAPE) && @minlength == 0
        ret = ""
        break
      elsif Input.triggerex?(:RETURN) && @sprites["entry"].text.length >= @minlength
        ret = @sprites["entry"].text
        break
      end
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["subject"]&.update
    end
    Input.update
    return ret
  end

  def pbEntry2
    ret = ""
    loop do
      Graphics.update
      Input.update
      @sprites["helpwindow"].update
      @sprites["entry"].update
      @sprites["entry2"].update
      @sprites["subject"]&.update
      if Input.trigger?(Input::USE)
        index = @sprites["entry2"].command
        if index == -3 # Confirm text
          ret = @sprites["entry"].text
          if ret.length < @minlength || ret.length > @maxlength
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            break
          end
        elsif index == -1   # Insert a space
          if @sprites["entry"].insert(" ")
            pbPlayDecisionSE
          else
            pbPlayBuzzerSE
          end
        elsif index == -2   # Change character set
          pbPlayDecisionSE
          @symtype += 1
          @symtype = 0 if @symtype >= @@Characters.length
          @sprites["entry2"].setCharset(@@Characters[@symtype][0])
          @sprites["entry2"].setOtherCharset(@@Characters[@symtype][1])
        else   # Insert given character
          if @sprites["entry"].insert(@sprites["entry2"].character)
            pbPlayDecisionSE
          else
            pbPlayBuzzerSE
          end
        end
        next
      end
    end
    Input.update
    return ret
  end

  def pbEntry
    return USEKEYBOARD ? pbEntry1 : pbEntry2
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites)
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    Input.text_input = false if USEKEYBOARD
  end
end