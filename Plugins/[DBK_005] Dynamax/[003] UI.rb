################################################################################
#
# Dynamax sprites.
#
################################################################################

#-------------------------------------------------------------------------------
# Dynamax sprite patterns.
#-------------------------------------------------------------------------------
class Sprite
  def apply_dynamax_pattern(species)
    return if !self.pattern.nil?
    path = Settings::DYNAMAX_GRAPHICS_PATH + "Patterns/"
    species_path = path + species.to_s
    filename = (pbResolveBitmap(species_path)) ? species_path : path + "dynamax"
    self.pattern = Bitmap.new(filename)
    self.pattern_opacity = 150
    self.pattern_type = :dynamax
  end

  def set_dynamax_pattern(pokemon, override = false)
    return if !pokemon.is_a?(Symbol) && pokemon&.shadowPokemon?
    return if !pokemon.is_a?(Symbol) && pokemon&.tera?
    if override || pokemon&.dynamax?
      if Settings::SHOW_DYNAMAX_SIZE
        self.zoom_x = self.zoom_y = 1.5
      end
      if Settings::SHOW_DYNAMAX_OVERLAY
        if pokemon.is_a?(Battle::Battler)
          pokemon = pokemon.visiblePokemon
        end
        if pokemon.is_a?(Pokemon)
          species = pokemon.species
        else
          species = GameData::Species.get(pokemon).species
        end
        apply_dynamax_pattern(species)
      end
    else
      clear_dynamax_pattern
    end
  end
  
  def set_dynamax_icon_pattern
    return if !self.pokemon
    return if self.pokemon.shadowPokemon?
    return if self.pokemon.tera?
    if self.pokemon.dynamax?
      if Settings::SHOW_DYNAMAX_SIZE && self.bitmap.height <= 64
        self.zoom_x = self.zoom_y = 1.5
      else
        self.zoom_x = self.zoom_y = 1
      end
      return if !Settings::SHOW_DYNAMAX_OVERLAY
      apply_dynamax_pattern(self.pokemon.species)
    else
      clear_dynamax_pattern
    end
  end
  
  def clear_dynamax_pattern
    self.zoom_x = 1 if self.zoom_x > 1
    self.zoom_y = 1 if self.zoom_y > 1
    self.pattern = nil
    self.pattern_type = nil
  end
  
  def update_dynamax_pattern
    return if self.pattern_type != :dynamax
    if (System.uptime / 0.05).to_i % 2 == 0
      case Settings::DYNAMAX_PATTERN_MOVEMENT[0]
      when :left    then self.pattern_scroll_x -= 1 
      when :right   then self.pattern_scroll_x += 1
      when :erratic then self.pattern_scroll_x += rand(-5..5) 
      end
      case Settings::DYNAMAX_PATTERN_MOVEMENT[1]
      when :up      then self.pattern_scroll_y -= 1 
      when :down    then self.pattern_scroll_y += 1
      when :erratic then self.pattern_scroll_y += rand(-5..5)
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Compatibility with other plugins that add sprite patterns.
  #-----------------------------------------------------------------------------
  alias dynamax_set_plugin_pattern set_plugin_pattern
  def set_plugin_pattern(pokemon, override = false)
    dynamax_set_plugin_pattern(pokemon, override)
    set_dynamax_pattern(pokemon, override)
  end
  
  alias dynamax_set_plugin_icon_pattern set_plugin_icon_pattern
  def set_plugin_icon_pattern
    dynamax_set_plugin_icon_pattern
	set_dynamax_icon_pattern
  end
  
  alias dynamax_update_plugin_pattern update_plugin_pattern
  def update_plugin_pattern
    dynamax_update_plugin_pattern
	update_dynamax_pattern
  end
end


################################################################################
#
# Changes to UI screens.
#
################################################################################

#-------------------------------------------------------------------------------
# For displaying G-Max Factor in various UI's.
#-------------------------------------------------------------------------------
def pbDisplayGmaxFactor(pokemon, overlay, xpos, ypos)
  return if !pokemon.gmax_factor?
  summaryBW = PluginManager.installed?("BW Party Screen")
  path = (summaryBW) ? "Graphics/Pictures/Summary/gfactor" : Settings::DYNAMAX_GRAPHICS_PATH + "gmax_factor"
  pbDrawImagePositions(overlay, [ [path, xpos, ypos] ])
end

#-------------------------------------------------------------------------------
# Pokemon Storage UI.
#-------------------------------------------------------------------------------
# Adds G-Max Factor display.
#-------------------------------------------------------------------------------
class PokemonStorageScene
  alias dynamax_pbUpdateOverlay pbUpdateOverlay
  def pbUpdateOverlay(selection, party = nil)
    dynamax_pbUpdateOverlay(selection, party)
    return if !Settings::STORAGE_GMAX_FACTOR
    if @sprites["pokemon"].visible
      if !@sprites["plugin_overlay"]
        @sprites["plugin_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @boxsidesviewport)
      end
      plugin_overlay = @sprites["plugin_overlay"].bitmap
      if @screen.pbHeldPokemon
        pokemon = @screen.pbHeldPokemon
      elsif selection >= 0
        pokemon = (party) ? party[selection] : @storage[@storage.currentBox, selection]
      end
      pbDisplayGmaxFactor(pokemon, plugin_overlay, 8, 52)
    end
  end
end

#-------------------------------------------------------------------------------
# Pokemon Summary UI.
#-------------------------------------------------------------------------------
# Adds G-Max Factor display.
# Adds Dynamax meter display.
# Clears Dynamax properties from sprites/icons.
#-------------------------------------------------------------------------------
class PokemonSummary_Scene
  alias dynamax_drawPage drawPage
  def drawPage(page)
    if !@sprites["dynamax_overlay"]
      @sprites["dynamax_overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    else
      @sprites["dynamax_overlay"].bitmap.clear
    end
    dynamax_drawPage(page)
    if @pokemon.dynamax?
      @sprites["pokemon"].clear_dynamax_pattern
      @sprites["pokeicon"].clear_dynamax_pattern
    end
    overlay = @sprites["overlay"].bitmap
    coords = (PluginManager.installed?("BW Summary Screen")) ? [454, 82] : [88, 95]
    pbDisplayGmaxFactor(@pokemon, overlay, coords[0], coords[1])
  end
  
  alias dynamax_drawPageTwo drawPageTwo
  def drawPageTwo
    if PluginManager.installed?("BW Summary Screen")
      if @pokemon.dynamax_able? && !$game_switches[Settings::NO_DYNAMAX]
        path = "Graphics/Pictures/Summary/"
        meter = (SUMMARY_B2W2_STYLE) ? "overlay_dynamax_B2W2" : "overlay_dynamax"
        xpos = Graphics.width - 262
        imagepos = [[sprintf(path + meter), xpos, 322]]
        overlay = @sprites["dynamax_overlay"].bitmap
        pbSetSmallFont(overlay)
        pbDrawImagePositions(overlay, imagepos)
        dlevel = @pokemon.dynamax_lvl
        levels = AnimatedBitmap.new(_INTL(path + "dynamax_bar"))
        overlay.blt(xpos + 82, 352, levels.bitmap, Rect.new(0, 0, dlevel * 16, 14))
        pbDrawTextPositions(overlay, [ [_INTL("Dynamax Lv."), Graphics.width - 102, 324, 2, Color.new(255, 255, 255), Color.new(123, 123, 123)] ])
      end
    end
    dynamax_drawPageTwo
  end
  
  # Moved 474 px right and 60 px up
  alias dynamax_drawPageThree drawPageThree
  def drawPageThree
    if !PluginManager.installed?("BW Summary Screen")
      if @pokemon.dynamax_able? && !$game_switches[Settings::NO_DYNAMAX]
        imagepos = [[sprintf(Settings::DYNAMAX_GRAPHICS_PATH + "dynamax_meter"), 530, 248]]
        overlay = @sprites["dynamax_overlay"].bitmap
        pbDrawImagePositions(overlay, imagepos)
        dlevel = @pokemon.dynamax_lvl
        levels = AnimatedBitmap.new(_INTL(Settings::DYNAMAX_GRAPHICS_PATH + "dynamax_levels"))
        overlay.blt(543, 265, levels.bitmap, Rect.new(0, 0, dlevel * 12, 21))
      end
    end
    dynamax_drawPageThree
  end
  
  alias dynamax_drawSelectedMove drawSelectedMove
  def drawSelectedMove(move_to_learn, selected_move)
    dynamax_drawSelectedMove(move_to_learn, selected_move)
    @sprites["pokeicon"].clear_dynamax_pattern
  end
end

#-------------------------------------------------------------------------------
# Pokedex UI.
#-------------------------------------------------------------------------------
# Displays weight as "????.?" for Gigantamax forms.
#-------------------------------------------------------------------------------
# Handled by a rewrite to 004_UI_Pokedex_Entry now, so this was deleted