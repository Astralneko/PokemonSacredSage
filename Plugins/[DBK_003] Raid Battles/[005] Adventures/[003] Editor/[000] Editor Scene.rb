#===============================================================================
# Adventure Map editor scene.
#===============================================================================
class AdventureMapEditor
  #-----------------------------------------------------------------------------
  # Map editor core.
  #-----------------------------------------------------------------------------
  def pbOpen
    @path = Settings::RAID_GRAPHICS_PATH + "Adventures/"
    @sprites     = {}
    @ui_sprites  = {}
    @map_sprites = {}
    @viewport    = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z  = 99999
    @viewport2   = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport2.z = 99999
    @ui_sprites["copy"] = AdventureTileSprite.new(0, 0, { id: :Empty }, nil, nil, @viewport2)
    @ui_sprites["cursor"] = IconSprite.new(0, 0, @viewport2)
    @ui_sprites["cursor"].setBitmap(@path + "cursor")
    @ui_sprites["cursor"].src_rect.set(0, 0, 64, 64)
    @ui_sprites["cursor"].visible = false
    @ui_sprites["map_arrow_0"] = AnimatedSprite.new("Graphics/UI/up_arrow", 8, 28, 40, 2, @viewport2)
    @ui_sprites["map_arrow_0"].x = (Graphics.width / 2) - 14
    @ui_sprites["map_arrow_0"].y = 0
    @ui_sprites["map_arrow_0"].visible = false
    @ui_sprites["map_arrow_0"].play
    @ui_sprites["map_arrow_1"] = AnimatedSprite.new("Graphics/UI/down_arrow", 8, 28, 40, 2, @viewport2)
    @ui_sprites["map_arrow_1"].x = (Graphics.width / 2) - 14
    @ui_sprites["map_arrow_1"].y = Graphics.height - 44
    @ui_sprites["map_arrow_1"].visible = false
    @ui_sprites["map_arrow_1"].play
    @ui_sprites["map_arrow_2"] = AnimatedSprite.new("Graphics/UI/left_arrow", 8, 40, 28, 2, @viewport2)
    @ui_sprites["map_arrow_2"].x = 0
    @ui_sprites["map_arrow_2"].y = (Graphics.height / 2) - 14
    @ui_sprites["map_arrow_2"].visible = false
    @ui_sprites["map_arrow_2"].play
    @ui_sprites["map_arrow_3"] = AnimatedSprite.new("Graphics/UI/right_arrow", 8, 40, 28, 2, @viewport2)
    @ui_sprites["map_arrow_3"].x = Graphics.width - 44
    @ui_sprites["map_arrow_3"].y = (Graphics.height / 2) - 14
    @ui_sprites["map_arrow_3"].visible = false
    @ui_sprites["map_arrow_3"].play
    @ui_sprites["grid_info"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport2)
    pbSetSystemFont(@ui_sprites["grid_info"].bitmap)
    @ui_sprites["controls"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport2)
    @ui_sprites["controls"].opacity = 150
    pbSetSmallFont(@ui_sprites["controls"].bitmap)
    @sprites["preview"] = IconSprite.new(0, 0, @viewport2)
    @descWindow = Window_UnformattedTextPokemon.new("")
    @descWindow.width = Graphics.width
    @descWindow.height = (@descWindow.borderY rescue 32) + 64
    @descWindow.viewport = @viewport2
    @descWindow.visible  = false
    @helpWindow = Window_UnformattedTextPokemon.new("")
    @helpWindow.viewport = @viewport2
    @helpWindow.visible  = false
    pbBottomLeftLines(@helpWindow, 1)
    pbMenu
  end
  
  def pbClose
    pbFadeOutIn {
      pbDisposeSpriteHash(@sprites)
      pbDisposeSpriteHash(@map_sprites)
      pbDisposeSpriteHash(@ui_sprites)
      @helpWindow.dispose
      @viewport.dispose
      @viewport2.dispose
    }
  end
  
  def update
    pbUpdateSpriteHash(@sprites)
    pbUpdateSpriteHash(@map_sprites)
    pbUpdateSpriteHash(@ui_sprites)
  end
  
  #-----------------------------------------------------------------------------
  # General command window for editor menus.
  #-----------------------------------------------------------------------------
  def pbShowCommands(text, commands, cmd = 0, top = false)
    ret = -1
    using(cmdwindow = Window_CommandPokemonColor.new(commands)) do
      cmdwindow.z     = @viewport2.z + 1
      cmdwindow.index = cmd
      cmdwindow.x = Graphics.width - cmdwindow.width
      @descWindow.resizeHeightToFit(@descWindow.text, Graphics.width - cmdwindow.width)
      if !nil_or_empty?(text)
        @helpWindow.visible = true
        @helpWindow.resizeHeightToFit(text, Graphics.width - cmdwindow.width)
        @helpWindow.text = text
        @helpWindow.x = 0
      else
        @helpWindow.visible = false
      end
      if top
        cmdwindow.y = 0
        @helpWindow.y = 0
      else
        cmdwindow.y = Graphics.height - cmdwindow.height
        @helpWindow.y = Graphics.height - @helpWindow.height
      end
      loop do
        Graphics.update
        Input.update
        cmdwindow.update
        self.update
        yield(cmdwindow.index, cmdwindow.width) if block_given?
        if Input.trigger?(Input::BACK)
          pbPlayCancelSE
          ret = -1
          break
        elsif Input.trigger?(Input::USE)
          pbPlayDecisionSE
          ret = cmdwindow.index
          break
        end
      end
    end
    return ret
  end
  
  #-----------------------------------------------------------------------------
  # Updates the background and description of a map while scrolling through the menu.
  #-----------------------------------------------------------------------------
  def pbUpdatePreview(idxMap, cmdwidth = 0)
    map_data = GameData::AdventureMap::DATA[idxMap]
    if map_data
      @sprites["preview"].setBitmap(@path + "Maps/#{map_data.filename}")
      @sprites["preview"].x = (Graphics.width - @sprites["preview"].bitmap.width) / 2
      @sprites["preview"].y = (Graphics.height - @sprites["preview"].bitmap.height) / 2
      @sprites["preview"].visible = true
      if cmdwidth > 0
        @descWindow.resizeHeightToFit(map_data.description, Graphics.width - cmdwidth)
        @descWindow.text = map_data.description
        @descWindow.visible = true
      end
    else
      @sprites["preview"].visible = false
      @descWindow.visible = false
    end
  end
  
  #-----------------------------------------------------------------------------
  # Main menu utility that leads to all other menus.
  #-----------------------------------------------------------------------------
  def pbMenu
    loop do
      pbDisposeSpriteHash(@map_sprites)
      @ui_sprites.each_value { |s| s.visible = false }
      @mapData = nil
      @changedTiles = false
      @changedProperties = false
      pbMapSelect
      break if !@mapData
      pbMapOptions
    end
  end
  
  #-----------------------------------------------------------------------------
  # Menu for selecting which existing map to edit, or a start new map.
  #-----------------------------------------------------------------------------
  def pbMapSelect
    maps = []
    map_ids = []
    GameData::AdventureMap.each do |m|
      maps.push(_INTL("{1} [{2}]", m.name, m.id))
      map_ids.push(m.id)
    end
    maps.push(_INTL("New map"))
    pbUpdatePreview(map_ids[0])
    loop do
      cmd = pbShowCommands(_INTL("Select a map."), maps) do |idxMap, cmdwidth|
        pbUpdatePreview(idxMap, cmdwidth)
      end
      if cmd >= 0
        pbLoadMap(map_ids[cmd])
        break if @mapData
      elsif pbConfirmMessage(_INTL("Exit map editor?"))
        break
      end
    end
    pbUpdatePreview(nil)
    pbRefreshMap
  end
  
  #-----------------------------------------------------------------------------
  # Menu for selecting what to do with a loaded map.
  #-----------------------------------------------------------------------------
  def pbMapOptions
    commands = [
      _INTL("Edit map tiles"),
      _INTL("Clear all tiles"),
      _INTL("Map properties"),
      _INTL("Playtest map"),
      _INTL("Save map"),
      _INTL("Delete map")
    ]
    loop do
      case pbShowCommands(nil, commands)
      when 0 then pbEditMapTiles
      when 1 then pbRefreshMap(true)
      when 2 then pbMapDataEditor
      when 3 then pbPlayTestMap
      when 4 then break if pbSaveMap
      when 5 then break if pbDeleteMap
      else
        if @changedProperties || @changedTiles
          if pbConfirmMessage(_INTL("Map changes detected.\nExit this map without saving?"))
            GameData::AdventureMap.load
            break
          end
        else
          break
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Menu for selecting a background to use for a map.
  #-----------------------------------------------------------------------------
  def pbBackgroundSelect
    maps = []
    files = FilenameUpdater.readDirectoryFiles(@path + "Maps/", ["*.png"])
    files.each { |f| maps.push(f.split(".png").first) }
    cmd = pbShowCommands(_INTL("Select a background."), maps) do |idxMap, cmdwidth|
      pbUpdatePreview(idxMap, cmdwidth)
    end
    pbUpdatePreview(nil)
    @helpWindow.visible = false
    return (cmd < 0) ? nil : maps[cmd]
  end
  
  #-----------------------------------------------------------------------------
  # Menu for selecting various properties to edit for a loaded map.
  #-----------------------------------------------------------------------------
  def pbMapDataEditor
    commands = [
      _INTL("Edit map name"),
      _INTL("Edit description"),
      _INTL("Edit background"),
      _INTL("Edit darkness chance")
    ]
    cmd = 0
    loop do
      cmd = pbShowCommands(nil, commands, cmd)
      case cmd
      when 0 # Name
        name = pbMessageFreeText(
          _INTL("Enter a name for this map."), @mapData.name, false, 250, Graphics.width)
        if !nil_or_empty?(name) && name != @mapData.real_name
          @mapData.real_name = name
          @changedProperties = true
        end
      when 1 # Description
        desc = pbMessageFreeText(
          _INTL("Enter a description for this map."), @mapData.description, false, 250, Graphics.width)
        if !nil_or_empty?(desc) && desc != @mapData.description
          @mapData.description = desc
          @changedProperties = true
        end
      when 2 # Background
        old_bg = @mapData.filename
        new_bg = pbBackgroundSelect
        if new_bg && new_bg != old_bg
          @mapData.filename = new_bg
          pbMessage(_INTL("WARNING!\nChanging the background will erase all current tiles."))
          @mapData.filename = old_bg if !pbRefreshMap(true)
        end
      when 3 # Darkness
        params = ChooseNumberParams.new
        params.setRange(0, 100)
        params.setInitialValue(@mapData.darkness)
        params.setCancelValue(@mapData.darkness)
        dark = pbMessageChooseNumber(_INTL("Enter the odds of this map being played in Darkness Mode."), params)
        if dark != @mapData.darkness
          @mapData.darkness = dark
          @changedProperties = true
        end
      else break
      end
    end
  end
end

#===============================================================================
# Calls the Adventure Map editor.
#===============================================================================
class AdventureMapEditorScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStart
    @scene.pbOpen
    @scene.pbClose
  end
end