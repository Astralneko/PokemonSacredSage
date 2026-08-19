#===============================================================================
#                          Custom Save Screen
#                               V 1.0.2
#                        Developed by Carmaniac
#===============================================================================
class PokemonSave_Scene

  SAVE_FOLDER = "Graphics/Custom UI/Save/"

  YES_BTN_X = 622
  YES_BTN_Y = 104
  NO_BTN_X  = 622
  NO_BTN_Y  = 172

  HIGHLIGHT_W      = 182
  HIGHLIGHT_H      = 64
  HIGHLIGHT_FRAMES = 4
  HIGHLIGHT_SPEED  = 7
  HIGHLIGHT_OFFSET = -4

  SNAPSHOT_FOLDER = "Graphics/Custom UI/Load/"
  TEMP_FILE       = SNAPSHOT_FOLDER + "temp.png"
  TEMP1_FILE      = SNAPSHOT_FOLDER + "temp1.png"

  TEXT_COLOR        = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(173, 189, 189)
  MALE_TEXT_COLOR          = Color.new(56, 160, 248)
  MALE_TEXT_SHADOW_COLOR   = Color.new(56, 104, 168)
  FEMALE_TEXT_COLOR        = Color.new(240, 72, 88)
  FEMALE_TEXT_SHADOW_COLOR = Color.new(160, 64, 64)

  def pbStartScreen
    @viewport       = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z     = 99999
    @vp_highlight   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @vp_highlight.z = @viewport.z + 1
    @sprites        = {}

    # Build background with all info text baked in
    base = Bitmap.new(SAVE_FOLDER + "background.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    totalsec = $stats.play_time.to_i
    hour     = totalsec / 60 / 60
    min      = totalsec / 60 % 60
    time_str = sprintf("%02dH:%02dM", hour, min)
    mapname  = $game_map ? pbGetMapNameFromId($game_map.map_id) : ""
    mapname.gsub!(/\\PN/, $player&.name || "")
    if $player&.male?
      name_color  = MALE_TEXT_COLOR
      name_shadow = MALE_TEXT_SHADOW_COLOR
    elsif $player&.female?
      name_color  = FEMALE_TEXT_COLOR
      name_shadow = FEMALE_TEXT_SHADOW_COLOR
    else
      name_color  = TEXT_COLOR
      name_shadow = TEXT_SHADOW_COLOR
    end
    textPos = [
      [mapname,                          122, 164, :left, TEXT_COLOR,  TEXT_SHADOW_COLOR],
      [$player&.name || "",              426, 164, :left, name_color,  name_shadow],
      [_INTL("BADGES:"),                 122, 226, :left, TEXT_COLOR,  TEXT_SHADOW_COLOR],
      [($player&.badge_count || 0).to_s, 426, 226, :left, TEXT_COLOR,  TEXT_SHADOW_COLOR],
      [_INTL("POKéDEX:"),               122, 288, :left, TEXT_COLOR,  TEXT_SHADOW_COLOR],
      [($player&.has_pokedex ? $player.pokedex.seen_count : 0).to_s, 426, 286, :left, TEXT_COLOR, TEXT_SHADOW_COLOR],
      [_INTL("TIME:"),                   122, 350, :left, TEXT_COLOR,  TEXT_SHADOW_COLOR],
      [time_str,                         426, 350, :left, TEXT_COLOR,  TEXT_SHADOW_COLOR]
    ]
    # Last save time
    last_save_color  = Color.new(255, 255, 255)
    last_save_shadow = Color.new(153, 153, 153)
    if SaveData.exists? && File.exist?(SaveData::FILE_PATH)
      mtime = File.mtime(SaveData::FILE_PATH)
      last_save_text = _INTL("Last saved on: {1}", mtime.strftime("%d/%m/%Y %H:%M"))
    else
      last_save_text = _INTL("Last saved on:")
    end
    textPos.push([last_save_text, 106, 436, :left, last_save_color, last_save_shadow])
    pbDrawTextPositions(bmp, textPos)
    @sprites["background"] = Sprite.new(@viewport)
    @sprites["background"].bitmap = bmp
    @sprites["background"].x = 0
    @sprites["background"].y = 0
    @sprites["background"].z = 0

    @sprites["msgwindow"] = pbCreateMessageWindow(nil, nil)
    @sprites["msgwindow"].viewport = @viewport
    @sprites["msgwindow"].x        = 0
    @sprites["msgwindow"].y        = 0
    @sprites["msgwindow"].z        = 2
    @sprites["msgwindow"].visible  = false

    # Yes button — text baked in
    yes_base = Bitmap.new(SAVE_FOLDER + "buttonbase.png")
    yes_bmp  = Bitmap.new(yes_base.width, yes_base.height)
    yes_bmp.blt(0, 0, yes_base, yes_base.rect)
    yes_base.dispose
    pbSetSystemFont(yes_bmp)
    pbDrawTextPositions(yes_bmp, [[_INTL("YES"), 22, 18, :left, TEXT_COLOR, TEXT_SHADOW_COLOR]])
    @sprites["btn_yes"] = Sprite.new(@viewport)
    @sprites["btn_yes"].bitmap  = yes_bmp
    @sprites["btn_yes"].x       = YES_BTN_X
    @sprites["btn_yes"].y       = YES_BTN_Y
    @sprites["btn_yes"].z       = 1
    @sprites["btn_yes"].visible = false

    # No button — text baked in
    no_base = Bitmap.new(SAVE_FOLDER + "buttonbase.png")
    no_bmp  = Bitmap.new(no_base.width, no_base.height)
    no_bmp.blt(0, 0, no_base, no_base.rect)
    no_base.dispose
    pbSetSystemFont(no_bmp)
    pbDrawTextPositions(no_bmp, [[_INTL("NO"), 22, 18, :left, TEXT_COLOR, TEXT_SHADOW_COLOR]])
    @sprites["btn_no"] = Sprite.new(@viewport)
    @sprites["btn_no"].bitmap  = no_bmp
    @sprites["btn_no"].x       = NO_BTN_X
    @sprites["btn_no"].y       = NO_BTN_Y
    @sprites["btn_no"].z       = 1
    @sprites["btn_no"].visible = false

    @sprites["highlight"] = Sprite.new(@vp_highlight)
    @sprites["highlight"].bitmap = Bitmap.new(SAVE_FOLDER + "highlight.png")
    @sprites["highlight"].src_rect.set(0, 0, HIGHLIGHT_W, HIGHLIGHT_H)
    @sprites["highlight"].z       = 0
    @sprites["highlight"].visible = false

    @save_index      = 0
    @highlight_frame = 0
    @highlight_tick  = 0
  end

  def pbEndScreen
    @sprites["highlight"]&.bitmap&.dispose
    @sprites["highlight"]&.dispose
    @vp_highlight&.dispose
    @sprites["background"]&.bitmap&.dispose
    @sprites["btn_yes"]&.bitmap&.dispose
    @sprites["btn_no"]&.bitmap&.dispose
    pbDisposeMessageWindow(@sprites["msgwindow"]) if @sprites["msgwindow"]
    @sprites.delete("msgwindow")
    pbDisposeSpriteHash(@sprites)
    @viewport&.dispose
  end

  def pbUpdate
    pbUpdateSaveHighlight
    @sprites["msgwindow"].x = 0 if @sprites["msgwindow"]
    @sprites["msgwindow"].y = 0 if @sprites["msgwindow"]
    pbUpdateSpriteHash(@sprites)
  end

  def pbUpdateSaveHighlight
    return if !@sprites["highlight"] || !@sprites["highlight"].visible
    btn = @save_index == 0 ? @sprites["btn_yes"] : @sprites["btn_no"]
    @sprites["highlight"].x = btn.x + HIGHLIGHT_OFFSET
    @sprites["highlight"].y = btn.y + HIGHLIGHT_OFFSET
    @highlight_tick += 1
    if @highlight_tick >= HIGHLIGHT_SPEED
      @highlight_tick  = 0
      @highlight_frame = (@highlight_frame + 1) % HIGHLIGHT_FRAMES
      @sprites["highlight"].src_rect.y = @highlight_frame * HIGHLIGHT_H
    end
  end

  def pbShowMessage(text)
    @sprites["msgwindow"].text    = text
    @sprites["msgwindow"].visible = true
    pbMessageDisplay(@sprites["msgwindow"], text) { pbUpdate }
  end

  def pbShowConfirm(text)
    @sprites["msgwindow"].text    = text
    @sprites["msgwindow"].visible = true
    @sprites["btn_yes"].visible   = true
    @sprites["btn_no"].visible    = true
    @sprites["highlight"].visible = true
    @save_index    = 0
    @last_mouse_x  = Input.mouse_x
    @last_mouse_y  = Input.mouse_y
    @mouse_moved   = false
    ret = false
    loop do
      Graphics.update
      Input.update
      pbUpdate
      # Detect mouse movement
      cur_x = Input.mouse_x
      cur_y = Input.mouse_y
      @mouse_moved = (cur_x != @last_mouse_x || cur_y != @last_mouse_y)
      @last_mouse_x = cur_x
      @last_mouse_y = cur_y
      # Mouse hover only updates index if mouse has moved
      if @mouse_moved
        @save_index = 0 if Mouse.over?(@sprites["btn_yes"])
        @save_index = 1 if Mouse.over?(@sprites["btn_no"])
      end
      # Keyboard navigation
      if Input.trigger?(Input::UP) || Input.trigger?(Input::DOWN)
        @save_index  = (@save_index == 0) ? 1 : 0
        @mouse_moved = false
        pbPlayCursorSE
      end
      # Confirm keyboard
      if Input.trigger?(Input::USE)
        ret = (@save_index == 0)
        pbPlayDecisionSE
        break
      end
      # Mouse click
      if Mouse.over?(@sprites["btn_yes"]) && Mouse.click?
        ret = true
        pbPlayDecisionSE
        break
      end
      if Mouse.over?(@sprites["btn_no"]) && Mouse.click?
        ret = false
        pbPlayDecisionSE
        break
      end
      # Cancel
      if Input.trigger?(Input::BACK)
        ret = false
        pbPlayCancelSE
        break
      end
    end
    @sprites["btn_yes"].visible   = false
    @sprites["btn_no"].visible    = false
    @sprites["highlight"].visible = false
    @sprites["msgwindow"].visible = false
    return ret
  end

  def pbUpdateSnapshot
    temp_full  = TEMP_FILE
    temp1_full = TEMP1_FILE
    File.delete(temp_full)  if File.exist?(temp_full)
    File.rename(temp1_full, temp_full) if File.exist?(temp1_full)
  end

end

#===============================================================================
# Fully replace PokemonSaveScreen — owns the entire save flow
#===============================================================================
class PokemonSaveScreen
  def initialize(scene)
    @scene = scene
  end

  def pbSaveScreen
    ret = false
    @scene.pbStartScreen
    if @scene.pbShowConfirm(_INTL("Would you like to save the game?"))
      if SaveData.exists? && $game_temp.begun_new_game
        @scene.pbShowMessage(_INTL("WARNING!") + "\1")
        @scene.pbShowMessage(_INTL("There is a different game file that is already saved.") + "\1")
        @scene.pbShowMessage(_INTL("If you save now, the other file's adventure, including items and Pokémon, will be entirely lost.") + "\1")
        if !@scene.pbShowConfirm(_INTL("Are you sure you want to save now and overwrite the other save file?"))
          pbSEPlay("GUI save choice")
          @scene.pbEndScreen
          return false
        end
      end
      $game_temp.begun_new_game = false
      pbSEPlay("GUI save choice")
      if Game.save
        @scene.pbShowMessage("\\se[]" + _INTL("{1} saved the game.", $player.name) + "\\me[GUI save game]\\wtnp[20]")
        @scene.pbUpdateSnapshot
        ret = true
      else
        @scene.pbShowMessage("\\se[]" + _INTL("Save failed.") + "\\wtnp[30]")
        ret = false
      end
    else
      pbSEPlay("GUI save choice")
    end
    @scene.pbEndScreen
    return ret
  end
end