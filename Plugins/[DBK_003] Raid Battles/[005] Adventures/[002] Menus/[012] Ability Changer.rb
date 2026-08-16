#===============================================================================
# Draws ability databoxes in Adventure menus.
#===============================================================================
class AdventureAbilitybox < AdventureAttributebox
  #-----------------------------------------------------------------------------
  # Sets up an ability databox.
  #-----------------------------------------------------------------------------
  def initialize(ability, index, viewport = nil)
    super(ability, index, viewport)
    @attribute = (GameData::Ability.exists?(ability)) ? ability : nil
    self.y += SLOT_BASE_Y
    refresh
  end
  
  #-----------------------------------------------------------------------------
  # Returns the ability ID assigned to an ability databox.
  #-----------------------------------------------------------------------------
  def ability
    return @attribute
  end
  
  #-----------------------------------------------------------------------------
  # Changes the ability assigned to an ability databox and refreshes it.
  #-----------------------------------------------------------------------------
  def ability=(value)
    if GameData::Ability.exists?(value)
      @attribute = value
    else
      @attribute = nil
    end
    refresh
  end
  
  #-----------------------------------------------------------------------------
  # Returns the display name of the ability assigned to an ability box.
  #-----------------------------------------------------------------------------
  def ability_name
    data = GameData::Ability.try_get(@attribute)
    return (data.nil?) ? "" : data.name
  end
  
  #-----------------------------------------------------------------------------
  # Returns the description of the ability assigned to an ability box.
  #-----------------------------------------------------------------------------
  def ability_desc
    data = GameData::Ability.try_get(@attribute)
    return (data.nil?) ? "" : data.description
  end
  
  #-----------------------------------------------------------------------------
  # Refreshes and draws the entire ability databox.
  #-----------------------------------------------------------------------------
  def refresh
    self.bitmap.clear
    return if !@attribute
    rectY = (@selected) ? SLOT_BASE_HEIGHT * 2 : SLOT_BASE_HEIGHT
    imagepos = [[@path + "text_slot", 0, 0, 0, rectY, SLOT_BASE_WIDTH, SLOT_BASE_HEIGHT]]
    imagepos.push([@path + "text_slot", 0, 0, 0, 0, SLOT_BASE_WIDTH, SLOT_BASE_HEIGHT]) if @selected
    pbDrawImagePositions(self.bitmap, imagepos)
    base   = (@selected) ? LIGHT_BASE_COLOR   : DARK_BASE_COLOR
    shadow = (@selected) ? LIGHT_SHADOW_COLOR : DARK_SHADOW_COLOR
    outline = (@selected) ? :outline : nil
    pbDrawTextPositions(self.bitmap, [[self.ability_name, SLOT_BASE_WIDTH / 2, 20, :center, base, shadow, outline]])
  end
end

#===============================================================================
# Core Adventure menu scene.
#===============================================================================
class AdventureMenuScene
  ABILITY_LIST_SIZE = 3
  
  #-----------------------------------------------------------------------------
  # Generates up to 3 abilities for a Pokemon.
  #-----------------------------------------------------------------------------
  def pbGenerateAbilityList(pkmn)
    abilities = []
    pkmn.getAbilityList.each do |abil|
	  next if abil[0] == pkmn.ability_id
      abilities.push(abil[0])
    end
    return abilities.sample(ABILITY_LIST_SIZE)
  end
  
  #-----------------------------------------------------------------------------
  # Abilities menu.
  #-----------------------------------------------------------------------------
  def pbAbilitiesMenu
    abils = []
    idxPkmn = 0
    idxAbil = 0
    selectionMode = 0
    party_select = (0...PARTY_SIZE).to_a
    PARTY_SIZE.times do |i|
      pkmn = $player.party[i]
      new_abils = pbGenerateAbilityList(pkmn)
      abils.push(new_abils)
      @sprites["party_#{i}"] = AdventurePartyDatabox.new(pkmn, @style, i, @viewport)
      @sprites["party_#{i}"].selected = (i == idxPkmn)
    end
    ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"] = AdventureAbilitybox.new(abils[idxPkmn][i], i, @viewport) }
    @sprites["button"] = IconSprite.new(20, Graphics.height - 32, @viewport)
    @sprites["button"].setBitmap(@path + "buttons")
    @sprites["button"].src_rect.width = 32
    @sprites["descbox"] = IconSprite.new(166, 298, @viewport)
    @sprites["descbox"].setBitmap(@path + "desc_box")
    @sprites["descbox"].src_rect.y = 44
    @sprites["window"] = Window_AdvancedTextPokemon.newWithSize("", 160, 282, 362, 132, @viewport)
    @sprites["window"].windowskin = nil
    @sprites["window"].lineHeight = 28
    @sprites["window"].baseColor = Color.new(248, 248, 248)
    @sprites["window"].shadowColor = Color.new(64, 64, 64)
    pbSetSmallFont(@sprites["window"].contents)
    pkmn = @sprites["party_#{idxPkmn}"].pokemon
    if abils[idxPkmn].empty?
      @sprites["window"].text = _INTL("{1} has no other abilities.", pkmn.name)
    else
      @sprites["window"].text = _INTL("{1}'s current Ability:\n{2}.", pkmn.name, pkmn.ability.name)
    end
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    textpos = [
      [_INTL("RENTAL PARTY"), 79, 8, :center, BASE_COLOR, SHADOW_COLOR, :outline],
      [_INTL("Select a party member to edit."), 337, 12, :center, BASE_COLOR, SHADOW_COLOR],
      [_INTL("Summary"), 56, Graphics.height - 20, :left, BASE_COLOR, SHADOW_COLOR, :outline]
    ]
    pbDrawTextPositions(overlay, textpos)
    loop do
      Input.update
      Graphics.update
      pbUpdate
      #-------------------------------------------------------------------------
      # UP KEY
      #-------------------------------------------------------------------------
      # Cycles through party Pokemon or ability lists, depending on selectionMode.
      if Input.repeat?(Input::UP)
        case selectionMode
        when 0 # Cycles through party.
          next if party_select.length <= 1
          pbPlayCursorSE
          nextIdx = party_select.index(idxPkmn) - 1
          idxPkmn = party_select[nextIdx] || party_select.last
          PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
          ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].ability = abils[idxPkmn][i] }
          pkmn = @sprites["party_#{idxPkmn}"].pokemon
          if abils[idxPkmn].empty?
            @sprites["window"].text = _INTL("{1} has no other abilities.", pkmn.name)
          else
            @sprites["window"].text = _INTL("{1}'s current Ability:\n{2}.", pkmn.name, pkmn.ability.name)
          end
        when 1 # Cycles through abilities.
          pbPlayCursorSE
          idxAbil -= 1
          idxAbil = abils[idxPkmn].length - 1 if idxAbil < 0
          ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].selected = (i == idxAbil) }
          @sprites["window"].text = @sprites["ability_#{idxAbil}"].ability_desc
        end
      #-------------------------------------------------------------------------
      # DOWN KEY
      #-------------------------------------------------------------------------
      # Cycles through party Pokemon or ability lists, depending on selectionMode.
      elsif Input.repeat?(Input::DOWN)
        case selectionMode
        when 0 # Cycles through party.
          next if party_select.length <= 1
          pbPlayCursorSE
          nextIdx = party_select.index(idxPkmn) + 1
          idxPkmn = party_select[nextIdx] || party_select.first
          PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
          ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].ability = abils[idxPkmn][i] }
          pkmn = @sprites["party_#{idxPkmn}"].pokemon
          if abils[idxPkmn].empty?
            @sprites["window"].text = _INTL("{1} has no other abilities.", pkmn.name)
          else
            @sprites["window"].text = _INTL("{1}'s current Ability:\n{2}.", pkmn.name, pkmn.ability.name)
          end
        when 1 # Cycles through abilities.
          pbPlayCursorSE
          idxAbil += 1
          idxAbil = 0 if idxAbil > abils[idxPkmn].length - 1
          ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].selected = (i == idxAbil) }
          @sprites["window"].text = @sprites["ability_#{idxAbil}"].ability_desc
        end
      #-------------------------------------------------------------------------
      # ACTION KEY
      #-------------------------------------------------------------------------
      # Opens the Summary for the party.
      elsif Input.trigger?(Input::ACTION)
        pbPlayDecisionSE
        pbSummary($player.party[0...PARTY_SIZE], idxPkmn)
      #-------------------------------------------------------------------------
      # BACK KEY
      #-------------------------------------------------------------------------
      # Exits the menu or returns to party selection, depending on selectionMode.
      elsif Input.trigger?(Input::BACK)
        case selectionMode
        when 0 # Exits the menu.
          break if pbConfirmMessage(_INTL("Exit and stop granting abilities to the party?"))
        when 1 # Returns to party selection.
          pbPlayCancelSE
          overlay.clear
          textpos[1][0] = _INTL("Select a party member to edit.")
          pbDrawTextPositions(overlay, textpos)
          ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].selected = false }
          @sprites["window"].text = _INTL("{1}'s current Ability:\n{2}.", pkmn.name, pkmn.ability.name)
          selectionMode = 0
          idxAbil = 0
        end
      #-------------------------------------------------------------------------
      # USE KEY
      #-------------------------------------------------------------------------
      # Selects a party Pokemon or an ability, depending on selectionMode.
      elsif Input.trigger?(Input::USE)
        case selectionMode
        when 0 # Selects a party Pokemon.
          if abils[idxPkmn].empty?
            pbPlayBuzzerSE
          else
            pbPlayDecisionSE
            overlay.clear
            textpos[1][0] = _INTL("Grant {1} a new ability.", pkmn.name)
            pbDrawTextPositions(overlay, textpos)
            ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].selected = (i == idxAbil) }
            @sprites["window"].text = @sprites["ability_#{idxAbil}"].ability_desc
            selectionMode = 1
          end
        when 1 # Selects an ability.
          abilName = @sprites["ability_#{idxAbil}"].ability_name
          if pbConfirmMessage(_INTL("Grant {1} the {2} ability?", pkmn.name, abilName))
            pbMessage(_INTL("1, 2, and...\\wt[16] ...\\wt[16] ...\\wt[16] Ta-da!") + "\\se[Battle ball drop]\1")
            pbMessage(_INTL("{1} lost {2}.\\nAnd..." + "\1", pkmn.name, pkmn.ability.name))
            pkmn.ability = abils[idxPkmn][idxAbil]
            abils[idxPkmn].delete_at(idxAbil)
            idxAbil = 0
            ABILITY_LIST_SIZE.times do |i|
              @sprites["ability_#{i}"].ability = abils[idxPkmn][i]
              @sprites["ability_#{i}"].selected = false
            end
            pbMessage("\\se[]" + _INTL("{1}'s Ability is now {2}!", pkmn.name, pkmn.ability.name) + "\\se[Pkmn move learnt]")
            party_select.delete(idxPkmn)
            idxPkmn = party_select.first
            PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
            if party_select.length > 0
              ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].ability = abils[idxPkmn][i] }
              pkmn = @sprites["party_#{idxPkmn}"].pokemon
              textpos[1][0] = _INTL("Select a party member to edit.")
              if abils[idxPkmn].empty?
                @sprites["window"].text = _INTL("{1} has no other abilities.", pkmn.name)
              else
                @sprites["window"].text = _INTL("{1}'s current Ability:\n{2}.", pkmn.name, pkmn.ability.name)
              end
              selectionMode = 0
            else
              ABILITY_LIST_SIZE.times { |i| @sprites["ability_#{i}"].ability = nil }
              textpos = [textpos.first]
              @sprites["window"].text = ""
              @sprites["button"].visible = false
              @sprites["descbox"].visible = false
            end
            overlay.clear
            pbDrawTextPositions(overlay, textpos)
          end
        end
      end
      break if party_select.empty?
    end
  end
end

def pbAdventureMenuAbilities
  return if !pbInRaidAdventure?
  style = pbRaidAdventureState.style
  scene = AdventureMenuScene.new
  scene.pbStartScene(style)
  scene.pbAbilitiesMenu
  scene.pbEndScene
end