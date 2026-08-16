#===============================================================================
# Core Adventure Menu scene.
#===============================================================================
class AdventureMenuScene
  #-----------------------------------------------------------------------------
  # Party reordering menu.
  #-----------------------------------------------------------------------------
  def pbPartnerMenu
    idxPkmn = 0
    selectionEnd = false
    partner_pkmn = $PokemonGlobal.partner[3].first
    @sprites["pokemon"] = AdventureRentalDatabox.new(partner_pkmn, @style, 1, @viewport)
    PARTY_SIZE.times do |i|
      pkmn = $player.party[i]
      @sprites["party_#{i}"] = AdventurePartyDatabox.new(pkmn, @style, i, @viewport)
      @sprites["party_#{i}"].selected = (i == idxPkmn)
    end
    overlay = @sprites["overlay"].bitmap
    overlay.clear
    statIcon = @sprites["pokemon"].statIcon
    spriteX, spriteY = @sprites["pokemon"].spriteX, @sprites["pokemon"].spriteY
    spriteW, spriteH = @sprites["pokemon"].bitmap.width, @sprites["pokemon"].bitmap.height
    buttonX1 = spriteX + 12
    buttonX2 = spriteW / 2 + buttonX1
    buttonY = spriteH / 2 + spriteY + 8
    trainer_sprite = _INTL("Graphics/Characters/trainer_#{$PokemonGlobal.partner[0]}")
    imagepos = [
      [@path + "buttons", buttonX1, buttonY, 0, 0, 32, 32],
      [@path + "buttons", buttonX2, buttonY, 32, 0, 32, 32],
      [sprintf("%s%s/rental_info", @path, @style), spriteX, spriteY - 58],
      [trainer_sprite, spriteX + 14, spriteY - 58, 0, 0, 32, 48],
      [@path + "stat_icons", Graphics.width - 54, spriteY - 46, 28 * statIcon, 0, 28, 26]
    ]
    textpos = [
      [_INTL("RENTAL PARTY"), 79, 8, :center, BASE_COLOR, SHADOW_COLOR, :outline],
      [_INTL("Change your lead Pokémon?"), 337, 12, :center, BASE_COLOR, SHADOW_COLOR],
      [_INTL("{1}'s lead Pokémon", $PokemonGlobal.partner[1]), spriteX + 52, spriteY - 38, :left, BASE_COLOR, Color.new(248, 32, 32), :outline],
      [_INTL("View Summary"), buttonX1 + 40, buttonY + 10, :left, BASE_COLOR, SHADOW_COLOR, :outline],
      [_INTL("Return"), buttonX2 + 40, buttonY + 10, :left, BASE_COLOR, SHADOW_COLOR, :outline]
    ]
    pbDrawImagePositions(overlay, imagepos)
    pbDrawTextPositions(overlay, textpos)
    until selectionEnd
      Input.update
      Graphics.update
      pbUpdate
      #-------------------------------------------------------------------------
      # UP/DOWN KEYS
      #-------------------------------------------------------------------------
      # Cycles through party Pokemon.
      if Input.repeat?(Input::UP)
        pbPlayCursorSE
        idxPkmn -= 1
        idxPkmn = PARTY_SIZE - 1 if idxPkmn < 0
        PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
      elsif Input.repeat?(Input::DOWN)
        pbPlayCursorSE
        idxPkmn += 1
        idxPkmn = 0 if idxPkmn > PARTY_SIZE - 1
        PARTY_SIZE.times { |i| @sprites["party_#{i}"].selected = (i == idxPkmn) }
      #-------------------------------------------------------------------------
      # ACTION KEY
      #-------------------------------------------------------------------------
      # Opens the Summary for partner's Pokemon.
      elsif Input.trigger?(Input::ACTION)
        pbPlayDecisionSE
        pbSummary(partner_pkmn)
      #-------------------------------------------------------------------------
      # BACK KEY
      #-------------------------------------------------------------------------
      # Exits the menu and keeps the same party order.
      elsif Input.trigger?(Input::BACK)
        selectionEnd = pbConfirmMessage(_INTL("Exit without reordering party?"))
      #-------------------------------------------------------------------------
      # USE KEY
      #-------------------------------------------------------------------------
      # Selects a party Pokemon and opens the command menu.
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        pkmn = $player.party[idxPkmn]
        commands = [_INTL("Summary"), _INTL("Back")]
        commands.insert(0, _INTL("Set as lead")) if idxPkmn > 0
        cmd = 0
        loop do
          cmd = pbShowCommands(commands, cmd)
          break if cmd < 0 || cmd == commands.length - 1
          if commands.length == 3 && cmd == 0
            if pbConfirmMessage(_INTL("Set {1} as your lead Pokémon?", pkmn.name))
              overlay.clear
              textpos = [textpos[0], textpos[2]]
              pbDrawTextPositions(overlay, textpos)
              imagepos = [imagepos[2], imagepos[3], imagepos[4]]
              pbDrawImagePositions(overlay, imagepos)
              startX = @sprites["party_0"].spriteX
              endX = -(@sprites["party_0"].bitmap.width)
              pbSEPlay("GUI party switch")
              pbWait(0.5) do |delta_t|
                @sprites["party_0"].x = lerp(startX, endX, 0.35, delta_t)
                @sprites["party_#{idxPkmn}"].x = lerp(startX, endX, 0.35, delta_t)
              end
              @sprites["party_0"].visible = false
              @sprites["party_#{idxPkmn}"].visible = false
              @sprites["party_#{idxPkmn}"].selected = false
              old_lead = $player.party.first
              $player.party[0] = $player.party[idxPkmn]
              $player.party[idxPkmn] = old_lead
              @sprites["party_0"].pokemon = $player.party.first
              @sprites["party_#{idxPkmn}"].pokemon = $player.party[idxPkmn]
              @sprites["party_0"].visible = true
              @sprites["party_#{idxPkmn}"].visible = true
              pbSEPlay("GUI party switch")
              pbWait(0.5) do |delta_t|
                @sprites["party_0"].x = lerp(endX, startX, 0.35, delta_t)
                @sprites["party_#{idxPkmn}"].x = lerp(endX, startX, 0.35, delta_t)
              end
              new_lead = $player.party.first
              cryFile = GameData::Species.cry_filename_from_pokemon(new_lead)
              pbMessage("\\se[#{cryFile}]" + _INTL("{1} was set as your lead Pokémon!\\wtnp[30]", new_lead.name))
              selectionEnd = true
              break
            end
          else
            pbSummary($player.party[0...PARTY_SIZE], idxPkmn)
          end
        end
      end
    end
  end
end

def pbAdventureMenuPartner
  return if !pbInRaidAdventure?
  style = pbRaidAdventureState.style
  scene = AdventureMenuScene.new
  scene.pbStartScene(style)
  scene.pbPartnerMenu
  scene.pbEndScene
end