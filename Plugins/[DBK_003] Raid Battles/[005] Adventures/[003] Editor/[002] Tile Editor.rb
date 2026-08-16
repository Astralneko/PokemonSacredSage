#===============================================================================
# Utilities related to setting and editing tiles in the Adventure Map editor.
#===============================================================================
class AdventureMapEditor
  #-----------------------------------------------------------------------------
  # Main tile editor loop.
  #-----------------------------------------------------------------------------
  def pbEditMapTiles
    copied_tile = nil
    player_tile = nil
    moving_tile = false
    linking_tile = false
    paint_mode = false
    erase_mode = false
    screenX = Graphics.width - 49
    screenY = Graphics.height - 49
    map = @map_sprites["map"]
    mapX = Graphics.width - (@width * 32)
    mapY = Graphics.height - (@height * 32)
    @ui_sprites.each_value { |s| s.visible = true }
    @helpWindow.visible = false
    pbUpdateControls
    pbUpdateCursor
    loop do
      Graphics.update
      Input.update
      self.update
      @ui_sprites["map_arrow_0"].visible = @cursor_tile.map_y > 0
      @ui_sprites["map_arrow_1"].visible = @cursor_tile.map_y < @height - 1
      @ui_sprites["map_arrow_2"].visible = @cursor_tile.map_x > 0
      @ui_sprites["map_arrow_3"].visible = @cursor_tile.map_x < @width - 1
      #-------------------------------------------------------------------------
      # ARROW KEYS
      #-------------------------------------------------------------------------
      # Cursor movement.
      #-------------------------------------------------------------------------
      # Paint/Erase mode directional controls.
      if paint_mode || erase_mode
        moved = false
        c = @cursor_tile.coords
        if Input.repeat?(Input::UP) && c[1] > 0
          moved = true
          pbAutoPosition(c[0], c[1] - 1)
        elsif Input.repeat?(Input::DOWN) && c[1] < @height - 1
          moved = true
          pbAutoPosition(c[0], c[1] + 1)
        elsif Input.repeat?(Input::LEFT) && c[0] > 0
          moved = true
          pbAutoPosition(c[0] - 1, c[1])
        elsif Input.repeat?(Input::RIGHT) && c[0] < @width - 1
          moved = true
          pbAutoPosition(c[0] + 1, c[1])
        end
        if moved
          if paint_mode && @cursor_tile.isTile?(:Empty)
            if pbHaveRequiredTiles?(copied_tile.tile_id)
              pbMessage(_INTL("The maximum amount of this tile has already been reached."))
              pbMessage(_INTL("Exiting paint mode."))
              pbSEPlay("GUI storage pick up")
              @ui_sprites["copy"].clearBitmap
              copied_tile = nil
              paint_mode = false
              pbUpdateControls
              pbUpdateCursor
            else
              pbSEPlay("GUI storage put down")
              pbUpdateTile(copied_tile.tile_id)
              @changedTiles = true
            end  
          elsif erase_mode && !@cursor_tile.isTile?(:Empty) && !pbCursorOnPlayer?
            pbSEPlay("GUI storage pick up")
            pbUpdateTile(nil)
            pbUpdateWarpPoints(*@cursor_tile.coords, true)
            @changedTiles = true
          else
            pbPlayCursorSE
          end
        elsif Input.trigger?(Input::USE) ||
              Input.trigger?(Input::BACK) ||		
              Input.trigger?(Input::ACTION)
          pbSEPlay("GUI storage pick up") if paint_mode
          pbSEPlay("GUI storage put down") if erase_mode
          paint_mode = false
          erase_mode = false
          pbUpdateControls((copied_tile.nil? ? 0 : 1))
          pbUpdateCursor
        end
        next
      #-------------------------------------------------------------------------
      # Normal directional controls.
      else
        if Input.press?(Input::UP)
          @map_sprites.each_value { |s| s.y += 2 } if map.y < -1
          pbSetCursor(0, -2) if @ui_sprites["cursor"].y > -16
          pbUpdateCursor
        end
        if Input.press?(Input::DOWN)
          @map_sprites.each_value { |s| s.y -= 2 } if map.y > mapY
          pbSetCursor(0, 2) if @ui_sprites["cursor"].y <= screenY
          pbUpdateCursor
        end
        if Input.press?(Input::LEFT)
          @map_sprites.each_value { |s| s.x += 2 } if map.x < -1
          pbSetCursor(-2, 0) if @ui_sprites["cursor"].x > -16
          pbUpdateCursor
        end
        if Input.press?(Input::RIGHT)
          @map_sprites.each_value { |s| s.x -= 2 } if map.x > mapX
          pbSetCursor(2, 0) if @ui_sprites["cursor"].x <= screenX
          pbUpdateCursor
        end
      end
      #-------------------------------------------------------------------------
      # USE KEY
      #-------------------------------------------------------------------------
      # Accesses tile menu, or confirms a copy/move/link.
      #-------------------------------------------------------------------------
      if Input.trigger?(Input::USE)
        #-----------------------------------------------------------------------
        # USAGE 1: Moves the player starting position to the selected tile.
        #-----------------------------------------------------------------------
        if player_tile
          pbSetCursor(*@cursor_tile.coords, 1)
          if !@cursor_tile.isTile?(:Pathway, :Empty)
            pbMessage(_INTL("The player cannot be placed on an occupied tile."))
          else
            pbSEPlay("GUI storage put down")
            @mapData.player = pbConvertCoords(@cursor_tile.coords)
            @map_sprites["player"].x = @cursor_tile.x
            @map_sprites["player"].y = @cursor_tile.y
            @map_sprites["player"].visible = true
            x, y = *player_tile.coords
            pbUpdateTile(:Empty, @map_sprites["tile_#{x}_#{y}"])
            pbUpdateTile(:Pathway)
            @ui_sprites["copy"].clearBitmap
            player_tile = nil
            moving_tile = false
            pbUpdateControls
            pbUpdateCursor
            @changedTiles = true
          end
        #-----------------------------------------------------------------------
        # USAGE 2: Links a Warp tile with the selected tile.
        #-----------------------------------------------------------------------
        elsif linking_tile
          pbSetCursor(*@cursor_tile.coords, 1)
          if @cursor_tile.isTile?(:Warp) && @cursor_tile.coords != copied_tile.coords
            if pbConfirmMessage(_INTL("Set the warp coordinates to this tile?"))
              pbSEPlay("GUI storage put down")
              c = copied_tile.coords
              @map_sprites["tile_#{c[0]}_#{c[1]}"].setWarp(@cursor_tile.coords)
              @cursor_tile.setWarp(c) if !@cursor_tile.warp_point
              if @cursor_tile.toggleable != copied_tile.toggleable
                @cursor_tile.setToggle(copied_tile.toggleable)
              end
              @ui_sprites["copy"].clearBitmap
              copied_tile = nil
              linking_tile = false
              pbUpdateControls
              @changedTiles = true
            end
          else
            pbMessage(_INTL("You can't set the warp coodinates to that tile."))
          end
        #-----------------------------------------------------------------------
        # USAGE 3: Places a copied tile when selecting an empty tile.
        #-----------------------------------------------------------------------
        elsif copied_tile && @cursor_tile.isTile?(:Empty)
          pbSetCursor(*@cursor_tile.coords, 1)
          if pbHaveRequiredTiles?(copied_tile.tile_id)
            pbMessage(_INTL("The maximum amount of this tile has already been reached."))
          else
            pbSEPlay("GUI storage put down")
            pbUpdateTile(copied_tile.tile_id)
            pbUpdateWarpPoints(*copied_tile.coords)
            @cursor_tile.setWarp(copied_tile.warp_point)
            if moving_tile
              copied_tile = nil
              moving_tile = false
              @ui_sprites["copy"].clearBitmap
              pbUpdateControls
            end
            pbUpdateCursor
            @changedTiles = true
          end
        #-----------------------------------------------------------------------
        # USAGE 4: Opens the tile command menu.
        #-----------------------------------------------------------------------
        elsif !copied_tile || copied_tile.tile_id != @cursor_tile.tile_id
          pbPlayCursorSE
          pbSetCursor(*@cursor_tile.coords, 1)
          @ui_sprites["controls"].visible = false
          topWindow = @ui_sprites["cursor"].y > Graphics.height / 2
          commands = []
          if @cursor_tile.isTile?(:Empty)
            commands.push(_INTL("Set"))
          else
            commands.push(_INTL("Replace"))
            if copied_tile
              commands.push(_INTL("Swap")) if !pbCursorOnPlayer?
            else
              commands.push(_INTL("Move"))
              commands.push(_INTL("Copy"))
              commands.push(_INTL("Clear"))
              commands.push(_INTL("Properties")) if pbTileHasProperties?
            end
          end
          case pbShowCommands(nil, commands, 0, topWindow)
          #---------------------------------------------------------------------
          when 0 # Set/Replace tile
            if pbCursorOnPlayer?
              pbMessage(_INTL("Cannot replace a tile the player is standing on."))
            else
              tile = (copied_tile) ? copied_tile.tile_id : pbTileSelect
              if pbHaveRequiredTiles?(tile)
                pbMessage(_INTL("The maximum amount of this tile has already been reached."))
              else
                pbUpdateTile(tile) if tile
                pbUpdateWarpPoints(*copied_tile.coords) if copied_tile
                if moving_tile
                  copied_tile = nil
                  moving_tile = false
                  @ui_sprites["copy"].clearBitmap
                end
                pbUpdateCursor
                @changedTiles = true
              end
            end
          #---------------------------------------------------------------------
          when 1 # Swap/Move tile or player position.
            if copied_tile
              this_tile = @cursor_tile.clone
              pbUpdateTile(copied_tile.tile_id)
              @ui_sprites["copy"].setTile(this_tile.tile_id)
              copied_tile = this_tile
              pbSEPlay("GUI storage put down")
              pbUpdateCursor
            elsif pbCursorOnPlayer?
              player_tile = @cursor_tile.clone
              @ui_sprites["copy"].setTile(:Player)
              @ui_sprites["copy"].opacity = 200
              @map_sprites["player"].visible = false
              moving_tile = true
              pbUpdateControls(2)
            else
              copied_tile = @cursor_tile.clone
              @ui_sprites["copy"].setTile(copied_tile.tile_id)
              @ui_sprites["copy"].opacity = 200
              pbUpdateTile(nil)
              moving_tile = true
              pbUpdateCursor
              pbUpdateControls(2)
            end
          #---------------------------------------------------------------------
          when 2 # Copy tile
            if pbCursorOnPlayer?
              pbMessage(_INTL("Cannot copy a tile the player is standing on."))
            elsif pbHaveRequiredTiles?(@cursor_tile.tile_id)
              pbMessage(_INTL("The maximum amount of this tile has already been reached."))
            else
              copied_tile = @cursor_tile.clone
              @ui_sprites["copy"].setTile(copied_tile.tile_id)
              @ui_sprites["copy"].opacity = 200
              moving_tile = false
              pbUpdateControls(1)
            end
          #---------------------------------------------------------------------
          when 3 # Clear tile
            if pbCursorOnPlayer?
              pbMessage(_INTL("Cannot clear a tile the player is standing on."))
            else
              pbUpdateTile(nil)
              pbUpdateWarpPoints(*@cursor_tile.coords, true)
              pbUpdateCursor
              @changedTiles = true
            end
          #---------------------------------------------------------------------
          when 4 # Properties
            linking_tile = pbSetTileProperties
            if linking_tile
              copied_tile = @cursor_tile.clone 
              @ui_sprites["copy"].setTile(copied_tile.tile_id)
              @ui_sprites["copy"].opacity = 200
              pbUpdateControls(3)
            end
          end
          @ui_sprites["controls"].visible = true
        end
      #-------------------------------------------------------------------------
      # BACK KEY
      #-------------------------------------------------------------------------
      # Returns to main menu, or cancels a copy/move/link.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        if player_tile
          @ui_sprites["copy"].clearBitmap
          @map_sprites["player"].visible = true
          player_tile = nil
          moving_tile = false
          pbUpdateControls
        elsif copied_tile
          if moving_tile
            x, y = copied_tile.map_x, copied_tile.map_y
            pbUpdateTile(copied_tile.tile_id, @map_sprites["tile_#{x}_#{y}"])
            @map_sprites["tile_#{x}_#{y}"].setWarp(copied_tile.warp_point)
          end
          copied_tile = nil
          moving_tile = false
          linking_tile = false
          @ui_sprites["copy"].clearBitmap
          pbUpdateControls
        else
          @map_sprites["grid"].visible = true
          @ui_sprites.each_value { |s| s.visible = false }
          break
        end
      #-------------------------------------------------------------------------
      # ACTION KEY
      #-------------------------------------------------------------------------
      # Toggles paint/erase modes.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::ACTION) && !moving_tile
        if copied_tile
          if pbHaveRequiredTiles?(copied_tile.tile_id)
            pbMessage(_INTL("The maximum amount of this tile has already been reached."))
            next
          else
            pbSEPlay("GUI storage pick up")
            paint_mode = true
          end
        else
          pbSEPlay("GUI storage put down")
          erase_mode = true
        end
        pbUpdateControls(4)
        pbUpdateCursor(true)
        pbSetCursor(*@cursor_tile.coords, 1)
      #-------------------------------------------------------------------------
      # CTRL KEY
      #-------------------------------------------------------------------------
      # Toggles grid and info displays.
      #-------------------------------------------------------------------------
      elsif Input.trigger?(Input::CTRL)
        pbPlayDecisionSE
        @map_sprites["grid"].visible     = !@map_sprites["grid"].visible
        @ui_sprites["grid_info"].visible = !@ui_sprites["grid_info"].visible
        @ui_sprites["controls"].visible  = !@ui_sprites["controls"].visible
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Menu for selecting a tile to place on a loaded map.
  #-----------------------------------------------------------------------------
  def pbTileSelect
    tile_id = nil
    tile_hash = Hash.new { |key, value| key[value] = [] }
    # Creates categories of tiles to select from.
    GameData::AdventureTile.each do |tile|
      next if tile.id == :Empty
      tile_hash[tile.type] << tile.id
    end
    tile_types = tile_hash.keys
    # Selects a particular tile within a category.
    typeCmd = 0
    loop do
      typeCmd = pbShowCommands(_INTL("Select a tile type."), tile_types, typeCmd)
      break if typeCmd < 0
      type = tile_types[typeCmd]
      tile_names = []
      tile_hash[type].each do |tile| 
        tile_names.push(GameData::AdventureTile.get(tile).name)
      end
      tileCmd = pbShowCommands(_INTL("Select a tile."), tile_names)
      tile_id = (tileCmd < 0) ? nil : tile_hash[type][tileCmd]
      if pbHaveRequiredTiles?(tile_id)
        tile = GameData::AdventureTile.get(tile_id)
        pbMessage(_INTL("The {1} tile count on this map aready meets the maximum amount. ({2})", 
          tile.name, (tile.required || tile.max_number)))
        tile_id = nil
      end
      break if tile_id
    end
    @helpWindow.visible = false
    return tile_id
  end
  
  #-----------------------------------------------------------------------------
  # Updates a tile with a new tile type.
  #-----------------------------------------------------------------------------
  def pbUpdateTile(id, tile = nil)
    tile = @cursor_tile if !tile
    tile.setTile(id)
    if id == :Battle
      range = (0..(tile.tile.required - 1)).to_a
      @map_sprites.each_value do |sprite|
        next if !sprite.is_a?(AdventureTileSprite)
        next if !sprite.isTile?(:Battle)
        range.delete(sprite.battle_id)
      end
      tile.setBattleID(range.first)
    end
  end
  
  #-----------------------------------------------------------------------------
  # Checks if the maximum or required amount of an alotted tile has been met.
  #-----------------------------------------------------------------------------
  def pbHaveRequiredTiles?(tile)
    tile = GameData::AdventureTile.try_get(tile)
    return false if !tile
    return false if !tile.max_number && !(tile.required && tile.required > 0)
    num_tiles = 0
    @map_sprites.each_value do |sprite|
      next if !sprite.is_a?(AdventureTileSprite)
      next if sprite.tile_id != tile.id
      num_tiles += 1
    end
    return true if tile.required && num_tiles >= tile.required
    return true if tile.max_number && num_tiles >= tile.max_number
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Utilities related to setting and updating special properties on certain tiles.
  #-----------------------------------------------------------------------------
  def pbSetTileProperties
    case @cursor_tile.tile_id
    # Setting a battle ID for Battle tiles.
    when :Battle
      value  = @cursor_tile.battle_id || 0
      maxVal = @cursor_tile.tile.required - 1
      params = ChooseNumberParams.new
      params.setRange(0, maxVal)
      params.setInitialValue(value)
      params.setCancelValue(value)
      msg = _INTL("Enter the ID number for this Battle tile.\n(Boss = {1})", maxVal)
      idNum = pbMessageChooseNumber(msg, params)
      if idNum != value
        @map_sprites.each_value do |sprite|
          next if !sprite.is_a?(AdventureTileSprite)
          next if !sprite.isTile?(:Battle)
          next if sprite.battle_id != idNum
          sprite.setBattleID(value)
        end
        @cursor_tile.setBattleID(idNum)
        @changedTiles = true
      end
    # Setting warp points and switch toggles for Warp tiles.
    when :Warp
      commands = [_INTL("Set tile to warp to"), _INTL("Set switch toggle")]
      case pbShowCommands(nil, commands)
      when 0 then return true
      when 1
        if pbConfirmMessage(_INTL("Should this tile be disabled until a Switch tile is flipped ON?"))
          pbSEPlay("GUI storage put down")
          pbUpdateToggle(true)
        else
          pbSEPlay("GUI storage pick up")
          pbUpdateToggle(false)
        end
        @changedTiles = true
      end
    # Setting switch toggles for all other eligible tiles.
    else
      if pbConfirmMessage(_INTL("Should this tile be disabled until a Switch tile is flipped ON?"))
        pbSEPlay("GUI storage put down")
        pbUpdateToggle(true)
      else
        pbSEPlay("GUI storage pick up")
        pbUpdateToggle(false)
      end
      @changedTiles = true
    end
    return false
  end
  
  def pbTileHasProperties?
    return false if @cursor_tile.isTile?(:Empty, :Pathway)
    return true if !@cursor_tile.tile.required
    return true if @cursor_tile.isTile?(:Battle)
    return false
  end
  
  def pbUpdateToggle(value)
    @cursor_tile.setToggle(value)
    if @cursor_tile.isTile?(:Warp)
      @map_sprites.each_value do |sprite|
        next if !sprite.is_a?(AdventureTileSprite)
        next if !sprite.warp_point
        next if sprite.warp_point != @cursor_tile.coords
        sprite.setToggle(value)
      end
    end
  end
  
  def pbUpdateWarpPoints(x, y, delete = false)
    coords = [x, y]
    @map_sprites.each_value do |sprite|
      next if !sprite.is_a?(AdventureTileSprite)
      next if !sprite.warp_point
      next if sprite.warp_point != coords
      if delete
        sprite.setWarp(nil)
      else
        sprite.setWarp(@cursor_tile.coords)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Utilities related to updating and repositioning the cursor and other map UI's.
  #-----------------------------------------------------------------------------
  def pbSetCursor(x, y, mode = 0)
    case mode
    when 0 # Sets the cursor to the exact pixel coordinates.
      @ui_sprites["cursor"].x += x if x
      @ui_sprites["cursor"].y += y if y
      @ui_sprites["copy"].x   += x if x
      @ui_sprites["copy"].y   += y if y
    when 1 # Sets the cursor to a particular map tile.
      map = @map_sprites["map"]
      ox = (map.x < 0) ? map.x : 0
      oy = (map.y < 0) ? map.y : 0
      @ui_sprites["cursor"].x = x * 32 + ox - 16 if x
      @ui_sprites["cursor"].y = y * 32 + oy - 16 if y
      @ui_sprites["copy"].x   = x * 32 + ox if x
      @ui_sprites["copy"].y   = y * 32 + oy if y
    end
  end
  
  def pbCursorOnPlayer?
    cx = @cursor_tile.x
    cy = @cursor_tile.y
    px = @map_sprites["player"].x
    py = @map_sprites["player"].y
    return cx == px && cy == py
  end
  
  def pbUpdateCursor(paint_mode = false)
    checkX = @ui_sprites["cursor"].x + 16
    checkY = @ui_sprites["cursor"].y + 16
    @map_sprites.each_value do |sprite|
      next if !sprite.is_a?(AdventureTileSprite)
      next if !(sprite.x - 20..sprite.x + 20).include?(checkX)
      next if !(sprite.y - 20..sprite.y + 20).include?(checkY)
      @cursor_tile = sprite
      break
    end
    # Yellow cursor (Tile highlight)
    if @cursor_tile.active? && @cursor_tile.cursor_react?
      @ui_sprites["cursor"].src_rect.x = 64
    # Blue cursor (Paint/Erase mode)
    elsif paint_mode
      @ui_sprites["cursor"].src_rect.x = 128
    # Red cursor (Normal)
    else
      @ui_sprites["cursor"].src_rect.x = 0
    end
    # Hides controls display when overlapping the cursor.
    if @ui_sprites["cursor"].x <= 192 && @ui_sprites["cursor"].y <= 96
      @ui_sprites["controls"].opacity = 0
    else
      @ui_sprites["controls"].opacity = 200
    end
    # Draws tile info.
    overlay = @ui_sprites["grid_info"].bitmap
    overlay.clear
    tile_bg = [[@path + "tile_bg", Graphics.width - 192, 0]]
    if !paint_mode && @cursor_tile.cursor_react?
      tile_bg.push([@path + "info_bg", 10, 310])
    end
    pbDrawImagePositions(overlay, tile_bg)
    x, y = *@cursor_tile.coords
    text_display = [:right, Color.white, Color.black, :outline]
    tile_text = [["#{x}, #{y}", Graphics.width - 8, 8, *text_display]]
    if !paint_mode && @cursor_tile.cursor_react?
      tile_name = @cursor_tile.tile.name
      if @cursor_tile.toggleable
        tile_name += " (Disabled)"
      else
        case @cursor_tile.tile_id
        when :Battle
          if @cursor_tile.battle_id
            tile_name += sprintf(" (#%d)", @cursor_tile.battle_id)
          end
        when :Warp
          coords = @cursor_tile.warp_point
          tile_name += sprintf(" to %d, %d", *coords) if coords
        end
      end
      tile_text.push([_INTL(tile_name), Graphics.width - 8, 40, *text_display])
      drawTextEx(overlay, 18, 318, 476, 2, @cursor_tile.tile.description, Color.white, Color.black)
    end
    pbDrawTextPositions(overlay, tile_text)
  end
  
  def pbUpdateControls(mode = 0)
    overlay = @ui_sprites["controls"].bitmap
    overlay.clear
    text_display = [:left, Color.white, Color.black, :outline]
    case mode
    when 0 # Normal controls
      controls = [
        [_INTL("[USE]"),     4,  8, *text_display],
        [_INTL("[ACTION]"),  4, 28, *text_display],
        [_INTL("[BACK]"),    4, 48, *text_display],
        [_INTL("[CTRL]"),    4, 68, *text_display],
        [_INTL("Select"),   82,  8, *text_display],
        [_INTL("Eraser"),   82, 28, *text_display],
        [_INTL("Return"),   82, 48, *text_display],
        [_INTL("Hide"),     82, 68, *text_display]
      ]
    when 1 # Copy controls
      controls = [
        [_INTL("[USE]"),     4,  8, *text_display],
        [_INTL("[ACTION]"),  4, 28, *text_display],
        [_INTL("[BACK]"),    4, 48, *text_display],
        [_INTL("[CTRL]"),    4, 68, *text_display],
        [_INTL("Paste"),    82,  8, *text_display],
        [_INTL("Paint"),    82, 28, *text_display],
        [_INTL("Return"),   82, 48, *text_display],
        [_INTL("Hide"),     82, 68, *text_display]
      ]
    when 2 # Move controls
      controls = [
        [_INTL("[USE]"),     4,  8, *text_display],
        [_INTL("[BACK]"),    4, 28, *text_display],
        [_INTL("[CTRL]"),    4, 48, *text_display],
        [_INTL("Place"),    82,  8, *text_display],
        [_INTL("Return"),   82, 28, *text_display],
        [_INTL("Hide"),     82, 48, *text_display]
      ]
    when 3 # Link controls
      controls = [
        [_INTL("[USE]"),     4,  8, *text_display],
        [_INTL("[BACK]"),    4, 28, *text_display],
        [_INTL("[CTRL]"),    4, 48, *text_display],
        [_INTL("Link"),     62,  8, *text_display],
        [_INTL("Return"),   62, 28, *text_display],
        [_INTL("Hide"),     62, 48, *text_display]
      ]
    when 4 # Paint/Erase controls
      controls = [
        [_INTL("[BACK]"),    4,  8, *text_display],
        [_INTL("Return"),   62,  8, *text_display]
      ]
    end
    pbDrawTextPositions(overlay, controls)
  end
  
  #-----------------------------------------------------------------------------
  # Used to instantly center the camera on the entered coordinates.
  #-----------------------------------------------------------------------------
  def pbAutoPosition(x, y)
    sprite = @map_sprites["tile_#{x}_#{y}"]
    return if !sprite
    map = @map_sprites["map"]
    centerX = (Graphics.width / 2) - 16
    centerY = (Graphics.height / 2) - 16
    mapX = Graphics.width - (@width * 32)
    mapY = Graphics.height - (@height * 32)
    loop do
      moveX, moveY = false, false
      if sprite.x > centerX
        shiftX = -1
        moveX = map.x - 1 > mapX
      elsif sprite.x < centerX
        shiftX = 1
        moveX = map.x + 1 < 0
      end
      if sprite.y > centerY
        shiftY = -1
        moveY = map.y - 1 > mapY
      elsif sprite.y < centerY
        shiftY = 1
        moveY = map.y + 1 < 0
      end
      break if !moveX && !moveY
      @map_sprites.each_value do |s|
        s.x += shiftX if moveX
        s.y += shiftY if moveY
      end
    end
    pbSetCursor(x, y, 1)
    pbUpdateCursor(true)
  end
end