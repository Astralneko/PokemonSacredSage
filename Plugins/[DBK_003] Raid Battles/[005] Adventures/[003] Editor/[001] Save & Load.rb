#===============================================================================
# Utilities for saving and loading map data in the Adventure Map editor.
#===============================================================================
class AdventureMapEditor
  #-----------------------------------------------------------------------------
  # Loads the data for a selected map, or creates data for a new one.
  #-----------------------------------------------------------------------------
  def pbLoadMap(id_num)
    if GameData::AdventureMap.exists?(id_num)
      @mapData = GameData::AdventureMap::DATA[id_num]
    else
      bg = nil
      id_num = nil
      loop do
        params = ChooseNumberParams.new
        params.setRange(0, 999)
        params.setDefaultValue(0)
        id_num = pbMessageChooseNumber(_INTL("Select an ID number for this new map."), params)
        break if id_num == 0
        if GameData::AdventureMap.exists?(id_num)
          pbMessage(_INTL("A map with that ID already exists."))
          id_num = nil
        else
          bg = pbBackgroundSelect
          break
        end
      end
      if bg && id_num
        GameData::AdventureMap.register({
          :id       => id_num,
          :filename => bg
        })
        @mapData = GameData::AdventureMap::DATA[id_num]
        @changedProperties = true
        @changedTiles = true
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Clears all tile data from a loaded map or begins a new map.
  #-----------------------------------------------------------------------------
  def pbRefreshMap(message = false)
    return false if !@mapData
    return false if message && !pbConfirmMessage(_INTL("Are you sure you want to clear all tiles on this map?"))
    if message
      @mapData.pathways.clear
      @mapData.battles.clear
      @mapData.tiles.clear
      @changedTiles = true
    end
    pbDisposeSpriteHash(@map_sprites)
    @map_sprites["map"] = IconSprite.new(0, 0, @viewport)
    @map_sprites["map"].setBitmap(@path + "Maps/#{@mapData.filename}")
    @width = (@map_sprites["map"].bitmap.width / 32).floor
    @width = 32 if @width > 32
    @height = (@map_sprites["map"].bitmap.height / 32).floor
    @height = 32 if @height > 32
    @mapData.dimensions = [@width, @height]
    player_coords = [0, 0]
    @width.times do |x|
      @height.times do |y|
        tile_data = @mapData.get_tile(x, y)
        setPlayer = tile_data[:id] == :Player
        if setPlayer
          tile_data[:id] = :Pathway
          player_coords = [x, y] 
        end
        @map_sprites["tile_#{x}_#{y}"] = AdventureTileSprite.new(x, y, tile_data, nil, nil, @viewport)
      end
    end
    x, y = *player_coords
    @cursor_tile = @map_sprites["tile_#{x}_#{y}"]
    @map_sprites["player"] = IconSprite.new(@cursor_tile.x, @cursor_tile.y, @viewport)
    player_icon = GameData::TrainerType.player_map_icon_filename($player.trainer_type)
    @map_sprites["player"].setBitmap(player_icon)
    @map_sprites["grid"] = IconSprite.new(0, 0, @viewport)
    @map_sprites["grid"].setBitmap(@path + "map_grid")
    pbAutoPosition(x, y)
    pbSetCursor(*@cursor_tile.coords, 1)
    pbUpdateCursor
    self.update
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Saves changes to the currently loaded map.
  #-----------------------------------------------------------------------------
  def pbSaveMap
    # Immediately saves if only map properties have been changed.
    if !@changedTiles
      if @changedProperties
        GameData::AdventureMap.save
        Compiler.write_adventure_maps
        pbMessage(_INTL("Map properties saved."))
        @changedProperties = false
      else
        pbMessage(_INTL("No changes detected.\nExiting map."))
      end
      return true
    end
    # Playtests map before it may be saved.
    pbMessage(_INTL("You must playtest your map first to ensure it's clearable before it can be saved."))
    if pbConfirmMessage(_INTL("Would you like to playtest your map?"))
      if pbPlayTestMap
        pbMessage(_INTL("This map has been cleared!\n\\se[]All changes will now be saved.\\me[GUI save game]\\wtnp[20]"))
        GameData::AdventureMap.save
        Compiler.write_adventure_maps
        return true
      end
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Deletes the currently loaded map.
  #-----------------------------------------------------------------------------
  def pbDeleteMap
    return if !@mapData
    if pbConfirmMessageSerious(_INTL("Are you sure you want to permanently delete this Adventure Map?"))
      GameData::AdventureMap::DATA.delete(@mapData.id)
      GameData::AdventureMap.save
      Compiler.write_adventure_maps
      return true
    end
    return false
  end
  
  #-----------------------------------------------------------------------------
  # Playtests the current map to ensure it can function. Required before saving.
  #-----------------------------------------------------------------------------
  def pbPlayTestMap
    return false if !pbValidMapTiles?
    @mapData.pathways.clear
    @mapData.battles.clear
    @mapData.tiles.clear
    tiles = []
    @map_sprites.each_value do |sprite|
      next if !sprite.is_a?(AdventureTileSprite)
      next if sprite.tile_id == :Empty
      coords = pbConvertCoords(sprite.coords)
      case sprite.tile_id
      when :Pathway
        @mapData.pathways.push(coords)
      when :Battle
        @mapData.battles[sprite.battle_id] = coords
      else
        data = [sprite.tile_id, coords]
        data.push(((sprite.toggleable) ? true : nil))
        data.push(pbConvertCoords(sprite.warp_point)) if sprite.tile_id == :Warp
        tiles.push(data)
      end
    end
    if !tiles.empty?
      tiles.sort_by! { |tile| tile[0].to_s }
      @mapData.tiles = tiles
    end
    $PokemonGlobal.raid_adventure_state = FakeRaidAdventureState.new(@mapData)
    pbFadeOutIn { pbRaidAdventureState.processAdventure }
    ret = pbRaidAdventureState.outcome
    $PokemonGlobal.raid_adventure_state = nil
    return ret == 1
  end
  
  #-----------------------------------------------------------------------------
  # Ensures that the map contains all the required tiles for a functional map.
  #-----------------------------------------------------------------------------
  def pbValidMapTiles?
    required = {}
    maximum  = {}
    detected = {}
    GameData::AdventureTile.each do |tile|
      if tile.required && tile.required > 0
        required[tile.id] = tile.required
        detected[tile.id] = 0
      elsif tile.max_number
        maximum[tile.id] = tile.max_number
        detected[tile.id] = 0
      end
    end
    @map_sprites.each_value do |sprite|
      next if !sprite.is_a?(AdventureTileSprite)
      tile = sprite.tile
      if sprite.isTile?(:Warp) && !sprite.warp_point
        pbMessage(_INTL("A {1} tile is detected that doesn't have any warp coordinates set.", tile.name))
        pbMessage(_INTL("Select 'Properties' on a {1} tile to set its warp coordinates.", tile.name))
        return false
      end
      detected[tile.id] += 1 if tile.max_number || tile.required && tile.required > 0
    end
    required.keys.each do |key|
      next if detected[key] == required[key]
      tile = GameData::AdventureTile.get(key)
      pbMessage(_INTL("Invalid number of {1} tiles detected.", tile.name))
      pbMessage(_INTL("The number of {1} tiles required must be exactly {2}.", tile.name, tile.required))
      return false
    end
    maximum.keys.each do |key|
      next if detected[key] <= maximum[key]
      tile = GameData::AdventureTile.get(key)
      pbMessage(_INTL("Invalid number of {1} tiles detected.", tile.name))
      pbMessage(_INTL("The maximum number of {1} tiles per map cannot exceed {1}.", tile.name, tile.max_number))
      return false
    end
    return true
  end
  
  #-----------------------------------------------------------------------------
  # Converts map coordinates into a string that can be saved as map data.
  #-----------------------------------------------------------------------------
  def pbConvertCoords(coords)
    string = ""
    coords.each do |c|
      coord = c.to_s
      coord.insert(0, "0") if coord.length == 1
      string += coord
    end
    return string
  end
end