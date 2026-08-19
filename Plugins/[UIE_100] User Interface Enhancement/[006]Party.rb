#===============================================================================
#                        Custom Party Screen
#                               V 1.0.0
#                        Developed by Carmaniac
#===============================================================================
class PokemonParty_Scene

  attr_accessor :screen_owner

  PARTY_FOLDER = "Graphics/Custom UI/Party/"

  GRID_SCROLL_W = 800

  BAR_REST_X     = 0
  BAR_REST_Y     = 342
  OVERLAY_REST_X = 0
  OVERLAY_REST_Y = 450
  SLIDE_FRAMES        = 15
  OVERLAY_SLIDE_DELAY = 5   # frames bg_overlay waits before it starts sliding

  NAME_BAR_REST_X = 0
  NAME_BAR_REST_Y = 14
  NAME_BAR_W      = 384
  NAME_BAR_H      = 78

  BUTTON_BG_REST_X = 418
  BUTTON_BG_REST_Y = 8

  POKEMON_BASE_REST_X = 28
  POKEMON_BASE_REST_Y = 248
  POKEMON_BASE_W      = 252
  POKEMON_BASE_H      = 66
  POKEMON_SPRITE_Y_OFFSET = -40

  BOX_REST_Y = 362
  BOX_X_POSITIONS = [70, 180, 290, 400, 510, 620]

  BAR_OVERLAY_OFFSET_X = 2
  BAR_OVERLAY_OFFSET_Y = 80

  HP_OVERLAY_OFFSET_X = 2
  HP_OVERLAY_OFFSET_Y = 2
  HP_OVERLAY_W        = 100
  HP_OVERLAY_H        = 12

  SPECIES_ICON_OFFSET_X = 34 #22
  SPECIES_ICON_OFFSET_Y = 12

  EXP_OVERLAY_OFFSET_X = 2
  EXP_OVERLAY_OFFSET_Y = 8
  EXP_OVERLAY_W        = 100
  EXP_OVERLAY_H        = 4

  NAME_BAR_TEXT_COLOR  = Color.new(255, 255, 255)
  NAME_BAR_TEXT_SHADOW = Color.new(33, 33, 33)
  NAME_BAR_NAME_X = 22
  NAME_BAR_NAME_Y = 10
  NAME_BAR_GENDER_X = 226
  NAME_BAR_GENDER_Y = 10
  NAME_BAR_LV_X = 244
  NAME_BAR_LV_Y = 14
  NAME_BAR_MEGA_X = 303
  NAME_BAR_MEGA_Y = 8
  NAME_BAR_ITEM_X = 332
  NAME_BAR_ITEM_Y = 22
  NAME_BAR_MAIL_X = 350
  NAME_BAR_MAIL_Y = 22

  NAME_BAR_HP_LABEL_X = 22
  NAME_BAR_HP_LABEL_Y = 50
  NAME_BAR_HP_VALUE_CENTER_X = 180
  NAME_BAR_HP_VALUE_Y        = 50
  NAME_BAR_STATUS_X = 14
  NAME_BAR_STATUS_Y = 80
  NAME_BAR_HPBAR_OVERLAY_X = 70
  NAME_BAR_HPBAR_OVERLAY_Y = 80
  NAME_BAR_HP_FILL_OFFSET_X = 30
  NAME_BAR_HP_FILL_OFFSET_Y = 4
  NAME_BAR_HP_FILL_W = 176
  NAME_BAR_HP_FILL_H = 30

  NAME_SELECTOR_W = 184
  NAME_SELECTOR_H = 56
  NAME_SELECTOR_Y = 480 - 118
  NAME_SELECTOR_OFFSET_X = -38
  NAME_SELECTOR_TEXT_Y_OFFSET = -44
  NAME_SELECTOR_TEXT_COLOR  = Color.new(255, 255, 255)
  NAME_SELECTOR_TEXT_SHADOW = Color.new(33, 33, 33)
  NAME_SELECTOR_ZOOM_FRAMES = 12

  CMD_BTN_OFFSET_X   = 24
  CMD_BTN_START_Y    = 40
  CMD_BTN_AREA_W     = 264
  CMD_BTN_AREA_H     = 236
  CMD_BTN_W          = 264
  CMD_BTN_H          = 44
  CMD_BTN_GAP        = 4
  CMD_BTN_STRIDE     = CMD_BTN_H + CMD_BTN_GAP
  CMD_BTN_VISIBLE    = (CMD_BTN_AREA_H + CMD_BTN_GAP) / CMD_BTN_STRIDE   # 5
  CMD_BTN_TEXT_COLOR  = Color.new(0, 0, 0)
  CMD_BTN_TEXT_SHADOW = Color.new(173, 189, 189)
  CMD_BTN_TEXT_Y      = 12

  BUTTON_BG_W = 312
  BUTTON_BG_H = 300
  BUTTON_BG_TEXT_Y = 10
  BUTTON_BG_TEXT_COLOR  = Color.new(255, 255, 255)
  BUTTON_BG_TEXT_SHADOW = Color.new(40, 40, 40)

  CMD_HIGHLIGHT_W      = 272
  CMD_HIGHLIGHT_H      = 208
  CMD_HIGHLIGHT_FRAMES = 4
  CMD_HIGHLIGHT_SPEED  = 7
  CMD_HIGHLIGHT_OFFSET_X = -4
  CMD_HIGHLIGHT_OFFSET_Y = -4

  def pbStartScene(party, starthelptext, annotations = nil, multiselect = false, can_access_storage = false)
    @sprites = {}
    @party = party
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @multiselect = multiselect
    @can_access_storage = can_access_storage

    @sprites["custom_grid"] = IconSprite.new(@viewport)
    @sprites["custom_grid"].setBitmap(PARTY_FOLDER + "grid.png")
    @sprites["custom_grid"].x = 0
    @sprites["custom_grid"].y = 0
    @sprites["custom_grid"].z = 0

    @sprites["bg_bar"] = IconSprite.new(@viewport)
    @sprites["bg_bar"].setBitmap(PARTY_FOLDER + "bg_bar.png")
    @sprites["bg_bar"].x = BAR_REST_X
    @sprites["bg_bar"].y = Graphics.height
    @sprites["bg_bar"].z = 1

    @sprites["bg_overlay"] = IconSprite.new(@viewport)
    @sprites["bg_overlay"].setBitmap(PARTY_FOLDER + "bg_overlay.png")
    @sprites["bg_overlay"].x = OVERLAY_REST_X
    @sprites["bg_overlay"].y = Graphics.height
    @sprites["bg_overlay"].z = 6

    @sprites["name_bar"] = Sprite.new(@viewport)
    base_name_bar = Bitmap.new(PARTY_FOLDER + "name_bar.png")
    @sprites["name_bar"].bitmap = Bitmap.new(base_name_bar.width, base_name_bar.height)
    @sprites["name_bar"].bitmap.blt(0, 0, base_name_bar, base_name_bar.rect)
    base_name_bar.dispose
    @sprites["name_bar"].x = -NAME_BAR_W
    @sprites["name_bar"].y = NAME_BAR_REST_Y
    @sprites["name_bar"].z = 4

    @sprites["namebar_mega"] = IconSprite.new(@viewport)
    @sprites["namebar_mega"].setBitmap(PARTY_FOLDER + "icon_mega.png")
    @sprites["namebar_mega"].z = 5
    @sprites["namebar_mega"].visible = false

    @sprites["namebar_item"] = IconSprite.new(@viewport)
    @sprites["namebar_item"].setBitmap(PARTY_FOLDER + "icon_item.png")
    @sprites["namebar_item"].z = 5
    @sprites["namebar_item"].visible = false

    @sprites["namebar_mail"] = IconSprite.new(@viewport)
    @sprites["namebar_mail"].setBitmap(PARTY_FOLDER + "icon_mail.png")
    @sprites["namebar_mail"].z = 5
    @sprites["namebar_mail"].visible = false

    @sprites["namebar_status"] = IconSprite.new(@viewport)
    @sprites["namebar_status"].setBitmap(_INTL("Graphics/UI/statuses"))
    @sprites["namebar_status"].z = 5
    @sprites["namebar_status"].visible = false

    @sprites["namebar_hpbaroverlay"] = IconSprite.new(@viewport)
    @sprites["namebar_hpbaroverlay"].setBitmap(PARTY_FOLDER + "hp_bar_overlay.png")
    @sprites["namebar_hpbaroverlay"].z = 5
    @sprites["namebar_hpbaroverlay"].visible = false

    @sprites["namebar_hpfill"] = IconSprite.new(@viewport)
    @sprites["namebar_hpfill"].setBitmap(PARTY_FOLDER + "overlay_hp.png")
    @sprites["namebar_hpfill"].src_rect.set(0, 0, NAME_BAR_HP_FILL_W, NAME_BAR_HP_FILL_H / 3)
    @sprites["namebar_hpfill"].z = 6
    @sprites["namebar_hpfill"].visible = false

    @sprites["button_bg"] = Sprite.new(@viewport)
    base_button_bg = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    @sprites["button_bg"].bitmap = Bitmap.new(base_button_bg.width, base_button_bg.height)
    @sprites["button_bg"].bitmap.blt(0, 0, base_button_bg, base_button_bg.rect)
    base_button_bg.dispose
    @sprites["button_bg"].x = Graphics.width
    @sprites["button_bg"].y = BUTTON_BG_REST_Y
    @sprites["button_bg"].z = 4

    @sprites["pokemon_base"] = IconSprite.new(@viewport)
    @sprites["pokemon_base"].setBitmap(PARTY_FOLDER + "pokemon_base.png")
    @sprites["pokemon_base"].x = -POKEMON_BASE_W
    @sprites["pokemon_base"].y = POKEMON_BASE_REST_Y
    @sprites["pokemon_base"].z = 4

    @sprites["party_pokemon_sprite"] = PokemonSprite.new(@viewport)
    @sprites["party_pokemon_sprite"].z = 5
    @last_party_sprite_species = nil

    6.times do |i|
      spr = IconSprite.new(@viewport)
      spr.setBitmap(PARTY_FOLDER + "icon_box.png")
      spr.x = BOX_X_POSITIONS[i]
      spr.y = Graphics.height
      spr.z = 2
      @sprites["box#{i}"] = spr

      bar_spr = IconSprite.new(@viewport)
      bar_spr.setBitmap(PARTY_FOLDER + "icon_bar_overlay.png")
      bar_spr.x = spr.x + BAR_OVERLAY_OFFSET_X
      bar_spr.y = spr.y + BAR_OVERLAY_OFFSET_Y
      bar_spr.z = 3
      bar_spr.visible = false
      @sprites["barover#{i}"] = bar_spr

      hp_spr = IconSprite.new(@viewport)
      hp_spr.setBitmap(PARTY_FOLDER + "icon_overlay_hp.png")
      hp_spr.src_rect.set(0, 0, HP_OVERLAY_W, HP_OVERLAY_H / 3)
      hp_spr.x = bar_spr.x + HP_OVERLAY_OFFSET_X
      hp_spr.y = bar_spr.y + HP_OVERLAY_OFFSET_Y
      hp_spr.z = 4
      hp_spr.visible = false
      @sprites["hpover#{i}"] = hp_spr

      exp_spr = IconSprite.new(@viewport)
      exp_spr.setBitmap(PARTY_FOLDER + "icon_exp.png")
      exp_spr.src_rect.set(0, 0, 0, EXP_OVERLAY_H)
      exp_spr.x = bar_spr.x + EXP_OVERLAY_OFFSET_X
      exp_spr.y = bar_spr.y + EXP_OVERLAY_OFFSET_Y
      exp_spr.z = 4
      exp_spr.visible = false
      @sprites["expover#{i}"] = exp_spr

      species_spr = PokemonIconSprite.new(nil, @viewport)
      species_spr.x = spr.x + SPECIES_ICON_OFFSET_X
      species_spr.y = spr.y + SPECIES_ICON_OFFSET_Y
      species_spr.z = 3
      species_spr.visible = false
	  species_spr.zoom = 2.0
      @sprites["speciesicon#{i}"] = species_spr
    end

    @activecmd = 0
    @sprites["name_selector"] = Sprite.new(@viewport)
    base_selector = Bitmap.new(PARTY_FOLDER + "name_box_selector.png")
    @sprites["name_selector"].bitmap = Bitmap.new(base_selector.width, base_selector.height)
    @sprites["name_selector"].bitmap.blt(0, 0, base_selector, base_selector.rect)
    base_selector.dispose
    @sprites["name_selector"].oy = NAME_SELECTOR_H   # anchor from the bottom
    @sprites["name_selector"].y  = NAME_SELECTOR_Y
    @sprites["name_selector"].x  = BOX_X_POSITIONS[0] + NAME_SELECTOR_OFFSET_X
    @sprites["name_selector"].zoom_y = 0
    @sprites["name_selector"].z  = 5
    pbDrawNameSelectorText

    pbUpdatePartyIcons
    pbUpdateBoxSelection

    @cmdindex     = 0
    @cmdscroll    = 0
    @command_list = []
    @command_data = []
    @menu_mode    = :main
    @highlight_frame = 0
    @highlight_tick  = 0
    @sprites["cmd_highlight"] = IconSprite.new(@viewport)
    @sprites["cmd_highlight"].setBitmap(PARTY_FOLDER + "highlight.png")
    @sprites["cmd_highlight"].src_rect.set(0, 0, CMD_HIGHLIGHT_W, CMD_HIGHLIGHT_H / CMD_HIGHLIGHT_FRAMES)
    @sprites["cmd_highlight"].z = 6
    pbBuildCommandList
    pbUpdateCommandButtons(true)
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[@activecmd])

    pbFadeInAndShow(@sprites) { update }
    pbSlideDecorIn
    pbZoomNameSelectorIn
  end

  def pbSetUseItemMode(item)
    @special_mode = :use_item
    @special_item = item
  end

  def pbSetGiveItemMode(item)
    @special_mode = :give_item
    @special_item = item
  end

  def pbSetTeachMoveMode(move_id)
    @special_mode = :teach_move
    @special_move = move_id
  end

  def pbSetBattleMode(battle_indices, battle_scene = nil, idx_battler = nil)
    @special_mode = :battle
    @battle_indices = battle_indices || []
    @battle_scene_ref = battle_scene
    @battle_idx_battler = idx_battler
  end

  def pbClearSpecialMode
    @special_mode = nil
    @special_item = nil
    @special_move = nil
    @battle_indices = nil
  end

  def pbBuildCommandList
    @menu_mode ||= :main
    if @special_mode
      case @special_mode
      when :use_item
        pbBuildUseItemCommandList
      when :give_item
        pbBuildGiveItemCommandList
      when :teach_move
        pbBuildTeachMoveCommandList
      when :battle
        pbBuildBattleCommandList
      end
      @cmdindex  = 0
      @cmdscroll = 0
      return
    end
    case @menu_mode
    when :item
      pbBuildItemCommandList
    when :move
      pbBuildMoveCommandList
    else
      pbBuildMainCommandList
    end
    @cmdindex  = 0
    @cmdscroll = 0
    pbDrawButtonBgHeader
  end

  def pbBuildUseItemCommandList
    @command_list = [_INTL("Use"), _INTL("Cancel")]
    @command_data = [:special_use, :special_cancel]
    itemname = @special_item ? GameData::Item.get(@special_item).name : ""
    pbDrawButtonBgHeaderText(_INTL("Use {1}?", itemname))
  end

  def pbBuildGiveItemCommandList
    pkmn = @party[@activecmd]
    name = pkmn ? pkmn.name : ""
    itemname = @special_item ? GameData::Item.get(@special_item).name : ""

    if pkmn && pkmn.hasItem?
      holding_name = GameData::Item.get(pkmn.item).name
      @command_list = [_INTL("Swap"), _INTL("Cancel")]
      @command_data = [:special_give, :special_cancel]
      pbDrawButtonBgHeaderText(_INTL("Holding {1}", holding_name))
    else
      @command_list = [_INTL("Give"), _INTL("Cancel")]
      @command_data = [:special_give, :special_cancel]
      pbDrawButtonBgHeaderText(_INTL("Give {1} {2}?", name, itemname))
    end
  end

  def pbBuildTeachMoveCommandList
    pkmn = @party[@activecmd]
    move_data = @special_move ? GameData::Move.get(@special_move) : nil
    movename  = move_data ? move_data.name : ""
    can_learn = pkmn && move_data && !pkmn.egg? &&
                pkmn.compatible_with_move?(@special_move) && !pkmn.hasMove?(@special_move)
    if can_learn
      @command_list = [_INTL("Learn"), _INTL("Cancel")]
      @command_data = [:special_learn, :special_cancel]
      pbDrawButtonBgHeaderText(_INTL("Teach {1}?", movename))
    else
      @command_list = [_INTL("Cancel")]
      @command_data = [:special_cancel]
      pbDrawButtonBgHeaderText(_INTL("Can't learn {1}", movename))
    end
  end

  def pbBuildBattleCommandList
    pkmn = @party[@activecmd]
    in_battle = @battle_indices && @battle_indices.include?(@activecmd)

    @command_list = []
    @command_data = []
    if !in_battle
      @command_list.push(_INTL("Switch"))
      @command_data.push(:special_battle_switch)
    end
    @command_list.push(_INTL("Restore"))
    @command_data.push(:special_battle_restore)
    @command_list.push(_INTL("Summary"))
    @command_data.push(:special_battle_summary)
    @command_list.push(_INTL("Check Moves"))
    @command_data.push(:special_battle_moves)
    @command_list.push(_INTL("Cancel"))
    @command_data.push(:special_cancel)

    name = pkmn ? pkmn.name : ""
    pbDrawButtonBgHeaderText(_INTL("Do what with {1}?", name))
  end

  def pbBuildMainCommandList
    @command_list = []
    @command_data = []
    pkmn = @party[@activecmd]
    return if !pkmn

    MenuHandlers.each_available(:party_menu, self, @party, @activecmd) do |option, hash, name|
      @command_list.push(name)
      @command_data.push(hash)
    end

    if !pkmn.egg?
      insert_index = ($DEBUG) ? 2 : 1
      pkmn.moves.each_with_index do |move, i|
        next if !HiddenMoveHandlers.hasHandler(move.id) &&
                ![:MILKDRINK, :SOFTBOILED].include?(move.id)
        @command_list.insert(insert_index, move.name)
        @command_data.insert(insert_index, [:move, i])
        insert_index += 1
      end
    end

    @command_list.push(_INTL("Cancel"))
    @command_data.push(:cancel)
  end

  def pbBuildItemCommandList
    pkmn = @party[@activecmd]
    @command_list = [_INTL("Give")]
    @command_data = [:item_give]
    if pkmn && pkmn.hasItem?
      @command_list.push(_INTL("Take"))
      @command_data.push(:item_take)
    end
    @command_list.push(_INTL("Back"))
    @command_data.push(:back)
  end

  def pbBuildMoveCommandList
    @command_list = [_INTL("Use"), _INTL("Back")]
    @command_data = [:move_use, :back]
  end

  def pbDrawButtonBgHeader
    spr = @sprites["button_bg"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)

    pkmn = @party[@activecmd]
    name = pkmn ? pkmn.name : ""
    text = (@menu_mode == :switch_target) ? _INTL("{1} selected", name) : _INTL("Do what with {1}?", name)

    text_w = bmp.text_size(text).width
    left_x = (BUTTON_BG_W / 2) - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, BUTTON_BG_TEXT_Y, :left,
                                BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])

    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
  end

  def pbZoomNameSelectorIn
    spr = @sprites["name_selector"]
    return if !spr
    NAME_SELECTOR_ZOOM_FRAMES.times do |frame|
      t = (frame + 1) / NAME_SELECTOR_ZOOM_FRAMES.to_f
      spr.zoom_y = 1 - (1 - t) ** 2   # ease out
      update
      Graphics.update
      Input.update
    end
    spr.zoom_y = 1
  end

  def pbZoomNameSelectorOut
    spr = @sprites["name_selector"]
    return if !spr
    NAME_SELECTOR_ZOOM_FRAMES.times do |frame|
      t = (frame + 1) / NAME_SELECTOR_ZOOM_FRAMES.to_f
      spr.zoom_y = 1 - (t ** 2)   # ease in
      update
      Graphics.update
      Input.update
    end
    spr.zoom_y = 0
  end

  def pbDrawNameSelectorText
    spr = @sprites["name_selector"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "name_box_selector.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    pkmn = @party[@activecmd]
    if pkmn
      text_y = NAME_SELECTOR_H + NAME_SELECTOR_TEXT_Y_OFFSET
      center_x = NAME_SELECTOR_W / 2
      text_w = bmp.text_size(pkmn.name).width
      left_x = center_x - (text_w / 2)
      left_x -= 1 if left_x.odd?
      left_x = 0 if left_x < 0
      pbDrawTextPositions(bmp, [[pkmn.name, left_x, text_y, :left,
                                  NAME_SELECTOR_TEXT_COLOR, NAME_SELECTOR_TEXT_SHADOW]])
    end
    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
    spr.oy = NAME_SELECTOR_H
  end

  def pbDrawNameBarContent
    spr = @sprites["name_bar"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "name_bar.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)

    pkmn = @party[@activecmd]
    textpos = []
    if pkmn
      textpos.push([pkmn.name, NAME_BAR_NAME_X, NAME_BAR_NAME_Y, :left,
                     NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])

      if !pkmn.egg? && !pkmn.genderless?
        gender_text  = pkmn.male? ? _INTL("♂") : _INTL("♀")
        base_color   = pkmn.male? ? Color.new(0, 112, 248) : Color.new(232, 32, 16)
        shadow_color = pkmn.male? ? Color.new(120, 184, 232) : Color.new(248, 168, 184)
        textpos.push([gender_text, NAME_BAR_GENDER_X, NAME_BAR_GENDER_Y, :left, base_color, shadow_color])
      end

      if !pkmn.egg?
        pbDrawImagePositions(bmp, [[PARTY_FOLDER + "overlay_lv", NAME_BAR_LV_X, NAME_BAR_LV_Y + 4, 0, 0, 22, 14]])
        pbSetSmallFont(bmp)
        textpos.push([pkmn.level.to_s, NAME_BAR_LV_X + 22, NAME_BAR_LV_Y - 4, :left,
                       NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])
        pbSetSystemFont(bmp)
      end

      textpos.push(["HP", NAME_BAR_HP_LABEL_X, NAME_BAR_HP_LABEL_Y, :left,
                     NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])

      if !pkmn.egg?
        hp_text = sprintf("%d/%d", pkmn.hp, pkmn.totalhp)
        hp_text_w = bmp.text_size(hp_text).width
        hp_left_x = NAME_BAR_HP_VALUE_CENTER_X - (hp_text_w / 2)
        hp_left_x -= 1 if hp_left_x.odd?
        hp_left_x = 0 if hp_left_x < 0
        textpos.push([hp_text, hp_left_x, NAME_BAR_HP_VALUE_Y, :left,
                       NAME_BAR_TEXT_COLOR, NAME_BAR_TEXT_SHADOW])
      end
    end
    pbDrawTextPositions(bmp, textpos)

    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp

    pbUpdateNameBarIcons(pkmn)
  end

  def pbUpdateNameBarIcons(pkmn)
    mega_spr = @sprites["namebar_mega"]
    item_spr = @sprites["namebar_item"]
    mail_spr = @sprites["namebar_mail"]
    status_spr  = @sprites["namebar_status"]
    hpbar_spr   = @sprites["namebar_hpbaroverlay"]
    hpfill_spr  = @sprites["namebar_hpfill"]

    can_mega = pkmn && !pkmn.egg? && pkmn.respond_to?(:hasMegaRing?) &&
               $player.has_mega_ring? && pkmn.mega_stone_exists?
    mega_spr.visible = !!can_mega if mega_spr

    has_item = pkmn && !pkmn.egg? && pkmn.hasItem? && !(pkmn.item && pkmn.item.is_mail?)
    item_spr.visible = !!has_item if item_spr

    has_mail = pkmn && !pkmn.egg? && pkmn.mail
    mail_spr.visible = !!has_mail if mail_spr

    if status_spr
      status = -1
      if pkmn && !pkmn.egg?
        if pkmn.fainted?
          status = GameData::Status.count - 1
        elsif pkmn.status != :NONE
          status = GameData::Status.get(pkmn.status).icon_position
        elsif pkmn.pokerusStage == 1
          status = GameData::Status.count
        end
      end
      if status >= 0
        status_spr.visible = true
        status_spr.src_rect.set(0, 16 * status, 44, 16)
      else
        status_spr.visible = false
      end
    end

    if hpbar_spr && hpfill_spr
      if pkmn && !pkmn.egg?
        hpbar_spr.visible  = true
        hpfill_spr.visible = true
        zone_h = NAME_BAR_HP_FILL_H / 3
        zone = 0
        zone = 1 if pkmn.hp <= (pkmn.totalhp / 2.0).floor
        zone = 2 if pkmn.hp <= (pkmn.totalhp / 4.0).floor
        target_w = pkmn.totalhp > 0 ? (pkmn.hp * NAME_BAR_HP_FILL_W / pkmn.totalhp.to_f).round : 0
        target_w = target_w.clamp(0, NAME_BAR_HP_FILL_W)
        pbStartHPBarAnim("namebar", hpfill_spr, target_w, zone, zone_h, NAME_BAR_HP_FILL_W, pkmn.object_id)
      else
        hpbar_spr.visible  = false
        hpfill_spr.visible = false
      end
    end

    pbSyncNameBarIconPositions
  end

  def pbStartHPBarAnim(key, spr, target_w, zone, zone_h, max_w, identity = nil)
    @hp_bar_anim ||= {}
    entry = @hp_bar_anim[key]
    identity_changed = entry && identity && entry[:identity] != identity
    current_w = entry ? entry[:current_w] : target_w
    if entry.nil? || identity_changed
      current_w = target_w
    end
    @hp_bar_anim[key] = {
      sprite: spr, current_w: current_w, target_w: target_w,
      zone: zone, zone_h: zone_h, max_w: max_w, identity: identity,
      start_w: current_w, start_time: System.uptime
    }
    spr.src_rect.set(0, zone * zone_h, current_w.clamp(0, max_w), zone_h)
  end

  def pbAnimateHPBars
    return if !@hp_bar_anim
    @hp_bar_anim.each_value do |entry|
      spr = entry[:sprite]
      next if !spr || spr.disposed?
      next if entry[:current_w] == entry[:target_w]
      t = (System.uptime - entry[:start_time]) / HP_BAR_ANIM_SECONDS
      t = t.clamp(0.0, 1.0)
      entry[:current_w] = (entry[:start_w] + ((entry[:target_w] - entry[:start_w]) * t)).round
      w = entry[:current_w].clamp(0, entry[:max_w])
      fraction = entry[:max_w] > 0 ? w.to_f / entry[:max_w] : 0
      zone = 0
      zone = 1 if fraction <= 0.5
      zone = 2 if fraction <= 0.25
      spr.src_rect.set(0, zone * entry[:zone_h], w, entry[:zone_h])
    end
  end

  def pbSyncNameBarIconPositions
    bar = @sprites["name_bar"]
    return if !bar
    if @sprites["namebar_mega"]
      @sprites["namebar_mega"].x = bar.x + NAME_BAR_MEGA_X
      @sprites["namebar_mega"].y = bar.y + NAME_BAR_MEGA_Y
    end
    if @sprites["namebar_item"]
      @sprites["namebar_item"].x = bar.x + NAME_BAR_ITEM_X
      @sprites["namebar_item"].y = bar.y + NAME_BAR_ITEM_Y
    end
    if @sprites["namebar_mail"]
      @sprites["namebar_mail"].x = bar.x + NAME_BAR_MAIL_X
      @sprites["namebar_mail"].y = bar.y + NAME_BAR_MAIL_Y
    end
    if @sprites["namebar_status"]
      @sprites["namebar_status"].x = bar.x + NAME_BAR_STATUS_X
      @sprites["namebar_status"].y = bar.y + NAME_BAR_STATUS_Y
    end
    if @sprites["namebar_hpbaroverlay"]
      @sprites["namebar_hpbaroverlay"].x = bar.x + NAME_BAR_HPBAR_OVERLAY_X
      @sprites["namebar_hpbaroverlay"].y = bar.y + NAME_BAR_HPBAR_OVERLAY_Y
    end
    if @sprites["namebar_hpfill"]
      hpbar_x = bar.x + NAME_BAR_HPBAR_OVERLAY_X
      hpbar_y = bar.y + NAME_BAR_HPBAR_OVERLAY_Y
      @sprites["namebar_hpfill"].x = hpbar_x + NAME_BAR_HP_FILL_OFFSET_X
      @sprites["namebar_hpfill"].y = hpbar_y + NAME_BAR_HP_FILL_OFFSET_Y
    end
  end

  def pbUpdatePartySpriteGraphic(pkmn)
    spr = @sprites["party_pokemon_sprite"]
    return if !spr
    if !pkmn
      spr.visible = false
      @last_party_sprite_species = nil
      return
    end
    display_key = pkmn.species
    if display_key != @last_party_sprite_species
      @last_party_sprite_species = display_key
      gender = pkmn.gender
      form   = pkmn.form
      shiny  = pkmn.shiny?
      spr.setSpeciesBitmap(pkmn.species, gender, form, shiny)
    end
    bmp = spr.bitmap
    if bmp && !bmp.disposed?
      ox = bmp.width / 2
      oy = bmp.height / 2
      spr.ox = ox
      spr.oy = oy
    end
    spr.visible = true
    pbSyncPartySpritePosition
  end

  def pbSyncPartySpritePosition
    spr  = @sprites["party_pokemon_sprite"]
    base = @sprites["pokemon_base"]
    return if !spr || !base || !spr.visible
    ox = spr.ox
    oy = spr.oy
    target_x = base.x + (POKEMON_BASE_W / 2)
    target_y = base.y + (POKEMON_BASE_H / 2) + POKEMON_SPRITE_Y_OFFSET
    target_x += 1 if (target_x - ox).odd?
    target_y += 1 if (target_y - oy).odd?
    spr.x = target_x
    spr.y = target_y
  end

  HP_BAR_ANIM_SECONDS = 0.5

  def pbUpdatePartyIcons
    @hp_bar_anim ||= {}
    6.times do |i|
      pkmn = @party[i]
      bar_spr     = @sprites["barover#{i}"]
      hp_spr      = @sprites["hpover#{i}"]
      exp_spr     = @sprites["expover#{i}"]
      species_spr = @sprites["speciesicon#{i}"]
      next if !bar_spr

      if pkmn
        bar_spr.visible = true

        if hp_spr
          hp_spr.visible = true
          zone_h = HP_OVERLAY_H / 3
          zone = 0
          zone = 1 if pkmn.hp <= (pkmn.totalhp / 2.0).floor
          zone = 2 if pkmn.hp <= (pkmn.totalhp / 4.0).floor
          target_w = pkmn.totalhp > 0 ? (pkmn.hp * HP_OVERLAY_W / pkmn.totalhp.to_f).round : 0
          target_w = target_w.clamp(0, HP_OVERLAY_W)
          pbStartHPBarAnim("box#{i}", hp_spr, target_w, zone, zone_h, HP_OVERLAY_W, pkmn.object_id)
        end

        if exp_spr
          # Same calculation vanilla uses for its own exp gauge: how far
          # through the current level's exp range the Pokémon currently is
          if pkmn.egg? || pkmn.level >= GameData::GrowthRate.max_level
            exp_fraction = 0
          else
            cur_level_exp  = pkmn.growth_rate.minimum_exp_for_level(pkmn.level)
            next_level_exp = pkmn.growth_rate.minimum_exp_for_level(pkmn.level + 1)
            range = next_level_exp - cur_level_exp
            exp_fraction = (range > 0) ? (pkmn.exp - cur_level_exp).to_f / range : 0
          end
          exp_fraction = exp_fraction.clamp(0.0, 1.0)
          exp_w = (EXP_OVERLAY_W * exp_fraction).to_i
          exp_spr.visible = true
          exp_spr.src_rect.set(0, 0, exp_w, EXP_OVERLAY_H)
        end

        if species_spr
          begin
            species_spr.pokemon = pkmn
			species_spr.zoom = 2.0
            species_spr.visible = true
          rescue StandardError => e
            Console.echo_warn("Party screen: couldn't load box icon for #{pkmn.species}: #{e.message}") rescue nil
            species_spr.visible = false
          end
        end
      else
        bar_spr.visible = false
        hp_spr.visible      = false if hp_spr
        exp_spr.visible     = false if exp_spr
        species_spr.visible = false if species_spr
      end
    end
  end

  def pbEndScene
    return if @scene_already_ended
    @scene_already_ended = true
    pbClearSpecialMode
    pbClearHeaderTextScroll
    pbZoomNameSelectorOut
    pbSlideDecorOut
    pbFadeOutAndHide(@sprites) { update }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    if @move_to_trigger
      move_id = @move_to_trigger
      pkmn = @pokemon_for_move
      @move_to_trigger = nil
      @pokemon_for_move = nil
      HiddenMoveHandlers.triggerUseMove(move_id, pkmn)
    end
  end

  def pbSlideDecorIn
    bar_start = Graphics.height
    bar_dist  = bar_start - BAR_REST_Y
    overlay_start = Graphics.height
    overlay_dist  = overlay_start - OVERLAY_REST_Y
    box_start = Graphics.height
    box_dist  = box_start - BOX_REST_Y

    name_bar_start = -NAME_BAR_W
    name_bar_dist  = NAME_BAR_REST_X - name_bar_start
    button_bg_start = Graphics.width
    button_bg_dist  = button_bg_start - BUTTON_BG_REST_X
    pokemon_base_start = -POKEMON_BASE_W
    pokemon_base_dist  = POKEMON_BASE_REST_X - pokemon_base_start

    total_frames = SLIDE_FRAMES + OVERLAY_SLIDE_DELAY
    total_frames.times do |frame|
      t = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      progress = 1 - (1 - t) ** 2   # ease out
      @sprites["bg_bar"].y = bar_start - (bar_dist * progress).to_i
      @sprites["name_bar"].x     = name_bar_start + (name_bar_dist * progress).to_i
      @sprites["button_bg"].x    = button_bg_start - (button_bg_dist * progress).to_i
      @sprites["pokemon_base"].x = pokemon_base_start + (pokemon_base_dist * progress).to_i

      overlay_frame = frame - OVERLAY_SLIDE_DELAY
      if overlay_frame >= 0
        ot = [(overlay_frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
        oprogress = 1 - (1 - ot) ** 2
        @sprites["bg_overlay"].y = overlay_start - (overlay_dist * oprogress).to_i
        6.times do |i|
          @sprites["box#{i}"].y = box_start - (box_dist * oprogress).to_i
          pbSyncBarOverlayToBox(i)
        end
      end

      update
      Graphics.update
      Input.update
    end
    @sprites["bg_bar"].y     = BAR_REST_Y
    @sprites["bg_overlay"].y = OVERLAY_REST_Y
    @sprites["name_bar"].x     = NAME_BAR_REST_X
    @sprites["button_bg"].x    = BUTTON_BG_REST_X
    @sprites["pokemon_base"].x = POKEMON_BASE_REST_X
    6.times do |i|
      @sprites["box#{i}"].y = BOX_REST_Y
      pbSyncBarOverlayToBox(i)
    end
  end

  def pbSyncBarOverlayToBox(i)
    box = @sprites["box#{i}"]
    bar = @sprites["barover#{i}"]
    hp  = @sprites["hpover#{i}"]
    exp = @sprites["expover#{i}"]
    species_spr = @sprites["speciesicon#{i}"]
    return if !box || !bar
    bar.x = box.x + BAR_OVERLAY_OFFSET_X
    bar.y = box.y + BAR_OVERLAY_OFFSET_Y
    if hp
      hp.x = bar.x + HP_OVERLAY_OFFSET_X
      hp.y = bar.y + HP_OVERLAY_OFFSET_Y
    end
    if exp
      exp.x = bar.x + EXP_OVERLAY_OFFSET_X
      exp.y = bar.y + EXP_OVERLAY_OFFSET_Y
    end
    if species_spr
      species_spr.x = box.x + SPECIES_ICON_OFFSET_X
      species_spr.y = box.y + SPECIES_ICON_OFFSET_Y
    end
  end

  def pbUpdateCommandButtons(force = false)
    return if !@sprites["button_bg"]
    base_x = @sprites["button_bg"].x + CMD_BTN_OFFSET_X
    base_y = @sprites["button_bg"].y + CMD_BTN_START_Y

    CMD_BTN_VISIBLE.times do |slot|
      cmd_idx = @cmdscroll + slot
      key = "cmdbtn#{slot}"
      btn = @sprites[key]
      if !btn
        btn = Sprite.new(@viewport)
        btn.z = 5
        @sprites[key] = btn
      end
      btn.x = base_x
      btn.y = base_y + (slot * CMD_BTN_STRIDE)

      if cmd_idx < @command_list.length
        btn.visible = true
        btn.bitmap&.dispose
        btn.bitmap = pbDrawCommandButtonBitmap(@command_list[cmd_idx])
      else
        btn.visible = false
      end
    end

    pbUpdateCommandHighlight
  end

  def pbDrawCommandButtonBitmap(text)
    base = Bitmap.new(PARTY_FOLDER + "button_base.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    center_x = CMD_BTN_W / 2
    text_w = bmp.text_size(text).width
    left_x = center_x - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, CMD_BTN_TEXT_Y, :left,
                                CMD_BTN_TEXT_COLOR, CMD_BTN_TEXT_SHADOW]])
    return bmp
  end

  def pbUpdateCommandHighlight
    return if !@sprites["cmd_highlight"]
    slot = @cmdindex - @cmdscroll
    if slot < 0 || slot >= CMD_BTN_VISIBLE || !@sprites["cmdbtn#{slot}"]
      @sprites["cmd_highlight"].visible = false
      return
    end
    btn = @sprites["cmdbtn#{slot}"]
    @sprites["cmd_highlight"].visible = true
    @sprites["cmd_highlight"].x = btn.x + CMD_HIGHLIGHT_OFFSET_X
    @sprites["cmd_highlight"].y = btn.y + CMD_HIGHLIGHT_OFFSET_Y
  end

  def pbUpdateCommandHighlightAnim
    return if !@sprites["cmd_highlight"] || !@sprites["cmd_highlight"].visible
    @highlight_tick += 1
    return if @highlight_tick < CMD_HIGHLIGHT_SPEED
    @highlight_tick = 0
    @highlight_frame = (@highlight_frame + 1) % CMD_HIGHLIGHT_FRAMES
    frame_h = CMD_HIGHLIGHT_H / CMD_HIGHLIGHT_FRAMES
    @sprites["cmd_highlight"].src_rect.y = @highlight_frame * frame_h
  end

  def pbMoveCommandSelection(delta)
    return if @command_list.empty?
    @cmdindex = (@cmdindex + delta) % @command_list.length
    if @cmdindex < @cmdscroll
      @cmdscroll = @cmdindex
    elsif @cmdindex >= @cmdscroll + CMD_BTN_VISIBLE
      @cmdscroll = @cmdindex - CMD_BTN_VISIBLE + 1
    end
    max_scroll = [@command_list.length - CMD_BTN_VISIBLE, 0].max
    @cmdscroll = @cmdscroll.clamp(0, max_scroll)
    pbUpdateCommandButtons
  end

  def pbSlideDecorOut
    bar_dist     = Graphics.height - BAR_REST_Y
    overlay_dist = Graphics.height - OVERLAY_REST_Y
    box_dist     = Graphics.height - BOX_REST_Y
    name_bar_dist     = NAME_BAR_REST_X - (-NAME_BAR_W)
    button_bg_dist    = Graphics.width - BUTTON_BG_REST_X
    pokemon_base_dist = POKEMON_BASE_REST_X - (-POKEMON_BASE_W)

    total_frames = SLIDE_FRAMES + OVERLAY_SLIDE_DELAY
    total_frames.times do |frame|
      ot = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      oprogress = ot ** 2   # ease in
      @sprites["bg_overlay"].y = OVERLAY_REST_Y + (overlay_dist * oprogress).to_i
      @sprites["name_bar"].x     = NAME_BAR_REST_X - (name_bar_dist * oprogress).to_i
      @sprites["button_bg"].x    = BUTTON_BG_REST_X + (button_bg_dist * oprogress).to_i
      @sprites["pokemon_base"].x = POKEMON_BASE_REST_X - (pokemon_base_dist * oprogress).to_i
      6.times do |i|
        @sprites["box#{i}"].y = BOX_REST_Y + (box_dist * oprogress).to_i
        pbSyncBarOverlayToBox(i)
      end

      bar_frame = frame - OVERLAY_SLIDE_DELAY
      if bar_frame >= 0
        t = [(bar_frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
        progress = t ** 2
        @sprites["bg_bar"].y = BAR_REST_Y + (bar_dist * progress).to_i
      end

      update
      Graphics.update
      Input.update
    end
  end

  def pbSyncCommandButtonsToBg
    return if !@sprites["button_bg"]
    base_x = @sprites["button_bg"].x + CMD_BTN_OFFSET_X
    base_y = @sprites["button_bg"].y + CMD_BTN_START_Y
    CMD_BTN_VISIBLE.times do |slot|
      btn = @sprites["cmdbtn#{slot}"]
      next if !btn
      btn.x = base_x
      btn.y = base_y + (slot * CMD_BTN_STRIDE)
    end
    pbUpdateCommandHighlight
  end

  def update
	@deltatime = 0 if !@deltatime
	# If it hasn't been 1/60 of a second yet, do nothing
	if System.uptime - @deltatime < 1/60r
		return
	end
	# Set new deltatime
	@deltatime = System.uptime
	# Actual stuff
    if @sprites["custom_grid"]
      @sprites["custom_grid"].x -= 1
      @sprites["custom_grid"].x = 0 if @sprites["custom_grid"].x <= -GRID_SCROLL_W
    end
    pbSyncCommandButtonsToBg
    pbSyncNameBarIconPositions
    pbSyncPartySpritePosition
    pbUpdateCommandHighlightAnim
    pbAnimateHPBars
    pbSyncHeaderTextScrollPosition
    pbUpdateHeaderTextScroll
    pbUpdateSpriteHash(@sprites)
  end

  def pbSetHelpText(helptext); end
  def pbHasAnnotations?; return false; end
  def pbAnnotate(annot); end

  def pbShowCommands(helptext, commands, index = 0)
    saved_list      = @command_list
    saved_data      = @command_data
    saved_cmdindex  = @cmdindex
    saved_cmdscroll = @cmdscroll
    saved_mode      = @menu_mode

    commands = commands.dup
    last = commands.last.to_s.downcase
    added_back = false
    if !["cancel", "back"].include?(last)
      commands.push(_INTL("Back"))
      added_back = true
    end

    @command_list = commands
    @command_data = commands.map { |c| c }   # plain values; index is the answer we want back
    @cmdindex     = index.clamp(0, [commands.length - 1, 0].max)
    @cmdscroll    = 0
    max_scroll = [@command_list.length - CMD_BTN_VISIBLE, 0].max
    if @cmdindex >= CMD_BTN_VISIBLE
      @cmdscroll = [@cmdindex - CMD_BTN_VISIBLE + 1, max_scroll].min
    end
    pbDrawButtonBgHeaderText(helptext)
    pbUpdateCommandButtons(true)

    ret = -1
    clicked_index = nil
    loop do
      Graphics.update
      Input.update
      update

      CMD_BTN_VISIBLE.times do |slot|
        btn = @sprites["cmdbtn#{slot}"]
        next if !btn || !btn.visible
        if Mouse.over?(btn) && Mouse.click?
          cmd_idx = @cmdscroll + slot
          next if cmd_idx >= @command_list.length
          clicked_index = cmd_idx
        end
      end
      if clicked_index
        @cmdindex = clicked_index
        pbUpdateCommandHighlight
        pbPlayDecisionSE
        ret = (added_back && @cmdindex == commands.length - 1) ? -1 : @cmdindex
        break
      end
      if Mouse.scroll_up?
        pbMoveCommandSelection(-1)
      elsif Mouse.scroll_down?
        pbMoveCommandSelection(1)
      end

      if Input.trigger?(Input::UP)
        pbPlayCursorSE
        pbMoveCommandSelection(-1)
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        pbMoveCommandSelection(1)
      elsif Input.trigger?(Input::BACK)
        pbPlayCancelSE
        ret = -1
        break
      elsif Input.trigger?(Input::USE)
        pbPlayDecisionSE
        ret = (added_back && @cmdindex == commands.length - 1) ? -1 : @cmdindex
        break
      end
    end

    @command_list = saved_list
    @command_data = saved_data
    @cmdindex     = saved_cmdindex
    @cmdscroll    = saved_cmdscroll
    @menu_mode    = saved_mode
    pbBuildCommandList
    pbUpdateCommandButtons(true)
    Input.update
    return ret
  end

  def pbDrawButtonBgHeaderText(text)
    spr = @sprites["button_bg"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)

    max_width = BUTTON_BG_W - 16   # small margin either side
    text_w = bmp.text_size(text).width

    if text_w <= max_width
      pbClearHeaderTextScroll
      left_x = (BUTTON_BG_W / 2) - (text_w / 2)
      left_x -= 1 if left_x.odd?
      left_x = 0 if left_x < 0
      pbDrawTextPositions(bmp, [[text, left_x, BUTTON_BG_TEXT_Y, :left,
                                  BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])
      old_bitmap = spr.bitmap
      spr.bitmap = bmp
      old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
    else
      # Text is too wide — draw the plain background (no baked text) and
      # set up a scrolling overlay for the text itself
      old_bitmap = spr.bitmap
      spr.bitmap = bmp
      old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
      pbSetupHeaderTextScroll(text, text_w, max_width)
    end
  end

  HEADER_SCROLL_SPEED = 1.5
  HEADER_SCROLL_PAUSE = 40

  def pbSetupHeaderTextScroll(text, text_w, max_width)
    pbClearHeaderTextScroll
    spr = @sprites["button_bg"]
    return if !spr
    left_x = (BUTTON_BG_W / 2) - (max_width / 2)
    @header_scroll_viewport = Viewport.new(spr.x + left_x, spr.y + BUTTON_BG_TEXT_Y, max_width, 20)
    @header_scroll_viewport.z = spr.z + 1
    text_spr = Sprite.new(@header_scroll_viewport)
    bmp = Bitmap.new(text_w, 20)
    pbSetSystemFont(bmp)
    pbDrawTextPositions(bmp, [[text, 0, 0, :left, BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])
    text_spr.bitmap = bmp
    text_spr.x = 0
    @header_scroll_sprite = text_spr
    @header_scroll_x       = 0.0
    @header_scroll_dir     = -1
    @header_scroll_max     = text_w - max_width
    @header_scroll_pause   = HEADER_SCROLL_PAUSE
  end

  def pbClearHeaderTextScroll
    @header_scroll_sprite&.bitmap&.dispose
    @header_scroll_sprite&.dispose
    @header_scroll_viewport&.dispose
    @header_scroll_sprite   = nil
    @header_scroll_viewport = nil
  end

  def pbSyncHeaderTextScrollPosition
    return if !@header_scroll_viewport
    spr = @sprites["button_bg"]
    return if !spr
    max_width = @header_scroll_viewport.rect.width
    left_x = (BUTTON_BG_W / 2) - (max_width / 2)
    @header_scroll_viewport.rect.x = spr.x + left_x
    @header_scroll_viewport.rect.y = spr.y + BUTTON_BG_TEXT_Y
  end

  def pbUpdateHeaderTextScroll
    return if !@header_scroll_sprite
    if @header_scroll_pause > 0
      @header_scroll_pause -= 1
      return
    end
    @header_scroll_x += HEADER_SCROLL_SPEED * @header_scroll_dir
    if @header_scroll_x <= -@header_scroll_max
      @header_scroll_x = -@header_scroll_max
      @header_scroll_dir = 1
      @header_scroll_pause = HEADER_SCROLL_PAUSE
    elsif @header_scroll_x >= 0
      @header_scroll_x = 0
      @header_scroll_dir = -1
      @header_scroll_pause = HEADER_SCROLL_PAUSE
    end
    @header_scroll_sprite.x = @header_scroll_x.to_i
  end

  def pbDisplay(text)
    pbShowCommands(text, [_INTL("OK")], 0)
  end

  def pbConfirm(text)
    return pbDisplayConfirm(text)
  end

  def pbDisplayConfirm(text)
    ret = pbShowCommands(text, [_INTL("Yes"), _INTL("No")], 0)
    return ret == 0
  end

  def pbSelect(item)
    @activecmd = item
    pbUpdateBoxSelection
    pbDrawNameSelectorText
    @sprites["name_selector"].x = BOX_X_POSITIONS[@activecmd] + NAME_SELECTOR_OFFSET_X if @sprites["name_selector"]
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[@activecmd])
    @menu_mode = :main
    pbBuildCommandList
    pbUpdateCommandButtons(true)
  end

  def pbPreSelect(item); @activecmd = item; end
  def pbRefresh
    pbUpdatePartyIcons
    pbUpdateBoxSelection
    pbDrawNameBarContent
  end

  def pbRefreshSingle(i)
    pbUpdatePartyIcons
    pbUpdateBoxSelection
    pbDrawNameBarContent if i == @activecmd
  end
  def pbHardRefresh; pbUpdatePartyIcons; pbUpdateBoxSelection; end
  def pbClearSwitching; end

  def pbUpdateBoxSelection
    6.times do |i|
      box = @sprites["box#{i}"]
      next if !box
      pkmn = @party[i]
      fainted = pkmn && pkmn.fainted?
      file = if i == @activecmd
               "icon_box_sel.png"
             elsif fainted
               "icon_box_faint.png"
             else
               "icon_box.png"
             end
      box.setBitmap(PARTY_FOLDER + file)

      species_spr = @sprites["speciesicon#{i}"]
      species_spr.active = !fainted if species_spr && species_spr.respond_to?(:active=)
    end
  end

  def pbHandleMouseInput
    6.times do |i|
      box = @sprites["box#{i}"]
      next if !box || !box.visible
      if Mouse.over?(box) && Mouse.click? && @party[i]
        pbPlayCursorSE
        pbSelect(i)
        return nil
      end
    end

    CMD_BTN_VISIBLE.times do |slot|
      btn = @sprites["cmdbtn#{slot}"]
      next if !btn || !btn.visible
      if Mouse.over?(btn) && Mouse.click?
        cmd_idx = @cmdscroll + slot
        next if cmd_idx >= @command_list.length
        @cmdindex = cmd_idx
        pbUpdateCommandHighlight
        pbPlayDecisionSE
        return pbExecuteCommand
      end
    end

    if Mouse.scroll_up?
      pbMoveCommandSelection(-1)
    elsif Mouse.scroll_down?
      pbMoveCommandSelection(1)
    end
    return nil
  end

  def pbChoosePokemon(switching = false, initialsel = -1, canswitch = 0)
    @activecmd = initialsel if initialsel >= 0
    @activecmd = 0 if !@party[@activecmd]
    pbSelect(@activecmd)
    loop do
      Graphics.update
      Input.update
      update
      ret = pbHandleMouseInput
      return ret if ret
      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        pbSelect(pbPrevPartyIndex(@activecmd))
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        pbSelect(pbNextPartyIndex(@activecmd))
      elsif Input.trigger?(Input::UP)
        pbPlayCursorSE
        pbMoveCommandSelection(-1)
      elsif Input.trigger?(Input::DOWN)
        pbPlayCursorSE
        pbMoveCommandSelection(1)
      elsif Input.trigger?(Input::USE)
        ret = pbExecuteCommand
        return ret if ret
      elsif Input.trigger?(Input::BACK)
        if @menu_mode != :main
          pbPlayCancelSE
          @menu_mode = :main
          pbBuildCommandList
          pbUpdateCommandButtons(true)
          Input.update
        else
          pbPlayCloseMenuSE
          pbClearSpecialMode
          return -1
        end
      end
    end
  end

  def pbPerformItemGive(screen)
    pkmn = @party[@activecmd]
    return if !pkmn
    bagscene  = PokemonBag_Scene.new
    bagscreen = PokemonBagScreen.new(bagscene, $bag)
    item = nil
    pbFadeOutIn do
      item = bagscreen.pbChooseItemScreen(proc { |i| GameData::Item.get(i).can_hold? })
    end
    return if !item
    if pkmn.hasItem?
      if !$bag.can_add?(pkmn.item, 1)
        pbDisplay(_INTL("The Bag is full. The {1} couldn't be taken.", GameData::Item.get(pkmn.item).name))
        return
      end
      $bag.add(pkmn.item, 1)
      pkmn.item = nil
    end
    pkmn.item = item
    $bag.remove(item, 1)
    pbRefreshSingle(@activecmd)
    pbDisplay(_INTL("Gave {1} {2}.", pkmn.name, GameData::Item.get(item).name))
  end

  def pbPerformItemTake(screen)
    pkmn = @party[@activecmd]
    return if !pkmn || !pkmn.hasItem?
    item = pkmn.item
    if !$bag.can_add?(item, 1)
      pbDisplay(_INTL("The Bag is full. The item couldn't be taken."))
      return
    end
    $bag.add(item, 1)
    pkmn.item = nil
    pbRefreshSingle(@activecmd)
    pbDisplay(_INTL("Took away {1}.", GameData::Item.get(item).name))
  end

  def pbPerformMoveUse(screen)
    pkmn = @party[@activecmd]
    return false if !pkmn || @pending_move_index.nil?
    move = pkmn.moves[@pending_move_index]
    return false if !move

    if HiddenMoveHandlers.hasHandler(move.id)
      if HiddenMoveHandlers.triggerCanUseMove(move.id, pkmn, true)
        @move_to_trigger = move.id
        @pokemon_for_move = pkmn
        return true
      end
    elsif [:MILKDRINK, :SOFTBOILED].include?(move.id)
      # These restore HP rather than doing a field effect — no need to
      # close the screen for this one
      if pkmn.hp == pkmn.totalhp
        pbDisplay(_INTL("It won't have any effect."))
      else
        pkmn.hp = pkmn.totalhp
        pbSEPlay("Player heal")
        pbRefreshSingle(@activecmd)
      end
    end
    @pending_move_index = nil
    return false
  end

  def pbPerformSwitch(screen)
    old_idx = @activecmd
    target  = @activecmd
    @menu_mode = :switch_target
    pbRefreshSwitchTargetUI(old_idx, target)

    loop do
      Graphics.update
      Input.update
      update

      clicked_box = nil
      6.times do |i|
        box = @sprites["box#{i}"]
        next if !box || !box.visible
        if Mouse.over?(box) && Mouse.click? && @party[i]
          clicked_box = i
        end
      end
      if clicked_box && clicked_box != target
        pbPlayCursorSE
        target = clicked_box
        pbRefreshSwitchTargetUI(old_idx, target)
        next
      end

      clicked_confirm = false
      clicked_cancel  = false
      CMD_BTN_VISIBLE.times do |slot|
        btn = @sprites["cmdbtn#{slot}"]
        next if !btn || !btn.visible
        if Mouse.over?(btn) && Mouse.click?
          cmd_idx = @cmdscroll + slot
          next if cmd_idx >= @command_data.length
          case @command_data[cmd_idx]
          when :switch_confirm then clicked_confirm = true
          when :back then clicked_cancel = true
          end
        end
      end

      if Input.trigger?(Input::LEFT)
        pbPlayCursorSE
        target = pbPrevPartyIndex(target)
        pbRefreshSwitchTargetUI(old_idx, target)
      elsif Input.trigger?(Input::RIGHT)
        pbPlayCursorSE
        target = pbNextPartyIndex(target)
        pbRefreshSwitchTargetUI(old_idx, target)
      elsif Input.trigger?(Input::BACK) || clicked_cancel
        pbPlayCancelSE
        @activecmd = old_idx
        break
      elsif Input.trigger?(Input::USE) || clicked_confirm
        if target != old_idx
          pbPlayDecisionSE
          pbAnimateSwitch(old_idx, target, screen)
          @activecmd = target
        else
          @activecmd = old_idx
        end
        break
      end
    end

    @menu_mode = :main
    pbSelect(@activecmd)
  end

  def pbRefreshSwitchTargetUI(old_idx, target)
    6.times do |i|
      box = @sprites["box#{i}"]
      next if !box
      pkmn = @party[i]
      fainted = pkmn && pkmn.fainted?
      file = if i == old_idx || i == target
               "icon_box_sel.png"
             elsif fainted
               "icon_box_faint.png"
             else
               "icon_box.png"
             end
      box.setBitmap(PARTY_FOLDER + file)
    end
    @sprites["cmd_highlight"].visible = false if @sprites["cmd_highlight"]
    @activecmd = target
    pbDrawNameSelectorText
    @sprites["name_selector"].x = BOX_X_POSITIONS[target] + NAME_SELECTOR_OFFSET_X if @sprites["name_selector"]
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[target])

    @command_list = (target == old_idx) ? [_INTL("Back")] : [_INTL("Select"), _INTL("Back")]
    @command_data = (target == old_idx) ? [:back] : [:switch_confirm, :back]
    @cmdindex  = 0
    @cmdscroll = 0
    pbDrawSwitchHeader(old_idx)
    pbUpdateCommandButtons(true)
  end

  def pbDrawSwitchHeader(old_idx)
    spr = @sprites["button_bg"]
    return if !spr
    base = Bitmap.new(PARTY_FOLDER + "button_bg.png")
    bmp  = Bitmap.new(base.width, base.height)
    bmp.blt(0, 0, base, base.rect)
    base.dispose
    pbSetSystemFont(bmp)
    pkmn = @party[old_idx]
    text = _INTL("{1} selected", pkmn ? pkmn.name : "")
    text_w = bmp.text_size(text).width
    left_x = (BUTTON_BG_W / 2) - (text_w / 2)
    left_x -= 1 if left_x.odd?
    left_x = 0 if left_x < 0
    pbDrawTextPositions(bmp, [[text, left_x, BUTTON_BG_TEXT_Y, :left,
                                BUTTON_BG_TEXT_COLOR, BUTTON_BG_TEXT_SHADOW]])
    old_bitmap = spr.bitmap
    spr.bitmap = bmp
    old_bitmap.dispose if old_bitmap && !old_bitmap.disposed? && old_bitmap != bmp
  end

  def pbAnimateSwitch(old_idx, target, screen)
    pbSEPlay("GUI party switch") rescue nil
    pbZoomNameSelectorOut

    box_dist  = Graphics.height - BOX_REST_Y
    name_bar_dist     = NAME_BAR_REST_X - (-NAME_BAR_W)
    pokemon_base_dist = POKEMON_BASE_REST_X - (-POKEMON_BASE_W)

    SLIDE_FRAMES.times do |frame|
      t = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      progress = t ** 2   # ease in, same as the normal slide-out
      [old_idx, target].each do |i|
        @sprites["box#{i}"].y = BOX_REST_Y + (box_dist * progress).to_i
        pbSyncBarOverlayToBox(i)
      end
      @sprites["name_bar"].x     = NAME_BAR_REST_X - (name_bar_dist * progress).to_i
      @sprites["pokemon_base"].x = POKEMON_BASE_REST_X - (pokemon_base_dist * progress).to_i
      update
      Graphics.update
      Input.update
    end

    @party[old_idx], @party[target] = @party[target], @party[old_idx]
    @activecmd = target
    pbUpdatePartyIcons
    pbUpdateBoxSelection
    pbDrawNameBarContent
    pbUpdatePartySpriteGraphic(@party[target])
    pbDrawNameSelectorText
    @sprites["name_selector"].x = BOX_X_POSITIONS[target] + NAME_SELECTOR_OFFSET_X if @sprites["name_selector"]

    SLIDE_FRAMES.times do |frame|
      t = [(frame + 1) / SLIDE_FRAMES.to_f, 1.0].min
      progress = 1 - (1 - t) ** 2   # ease out, same as the normal slide-in
      [old_idx, target].each do |i|
        @sprites["box#{i}"].y = Graphics.height - ((Graphics.height - BOX_REST_Y) * progress).to_i
        pbSyncBarOverlayToBox(i)
      end
      @sprites["name_bar"].x     = -NAME_BAR_W + (name_bar_dist * progress).to_i
      @sprites["pokemon_base"].x = -POKEMON_BASE_W + (pokemon_base_dist * progress).to_i
      update
      Graphics.update
      Input.update
    end
    [old_idx, target].each { |i| @sprites["box#{i}"].y = BOX_REST_Y }
    @sprites["name_bar"].x     = NAME_BAR_REST_X
    @sprites["pokemon_base"].x = POKEMON_BASE_REST_X
    6.times { |i| pbSyncBarOverlayToBox(i) }

    pbZoomNameSelectorIn
  end

  def pbGetPartyScreenOwner
    @screen_owner || self
  end

  def pbExecuteCommand
    return nil if @command_data.empty?
    data = @command_data[@cmdindex]
    pkmn = @party[@activecmd]
    screen = pbGetPartyScreenOwner

    case data
    when :special_cancel
      pbPlayCloseMenuSE
      pbClearSpecialMode
      return -1

    when :special_use
      pbPlayDecisionSE
      return @activecmd

    when :special_give
      pbPlayDecisionSE
      pbClearSpecialMode
      return @activecmd

    when :special_learn
      pbPlayDecisionSE
      pbClearSpecialMode
      return @activecmd

    when :special_battle_switch
      pbPlayDecisionSE
      pbClearSpecialMode
      return @activecmd

    when :special_battle_restore
      if @battle_scene_ref && @battle_idx_battler
        oldsprites = pbFadeOutAndHide(@sprites)
        battle = @battle_scene_ref.instance_variable_get(:@battle)
        idxBattler = @battle_idx_battler
        item_used = false
        battle.pbItemMenu(idxBattler, false) do |item_id, useType, idxPkmn, idxMove, itemScene|
          next false if !item_id
          battler = pkmn2 = nil
          case useType
          when 1, 2
            next false if !ItemHandlers.hasBattleUseOnPokemon(item_id)
            battler = battle.pbFindBattler(idxPkmn, idxBattler)
            pkmn2   = battle.pbParty(idxBattler)[idxPkmn]
            next false if !battle.pbCanUseItemOnPokemon?(item_id, pkmn2, battler, itemScene)
          when 3
            next false if !ItemHandlers.hasBattleUseOnBattler(item_id)
            battler = battle.pbFindBattler(idxPkmn, idxBattler)
            pkmn2   = battler.pokemon if battler
            next false if !battle.pbCanUseItemOnPokemon?(item_id, pkmn2, battler, itemScene)
          when 4
            next false if idxPkmn < 0
            battler = battle.battlers[idxPkmn]
            pkmn2   = battler.pokemon if battler
          when 5
            battler = battle.battlers[idxBattler]
            pkmn2   = battler.pokemon if battler
          else
            next false
          end
          next false if !pkmn2
          next false if !ItemHandlers.triggerCanUseInBattle(item_id, pkmn2, battler, idxMove,
                                                             false, battle, itemScene)
          next false if !battle.pbRegisterItem(idxBattler, item_id, idxPkmn, idxMove)
          item_used = true
          next true
        end
        pbFadeInAndShow(@sprites, oldsprites)
        if item_used
          pbClearSpecialMode
          return -1
        end
      end
      pbUpdatePartyIcons
      pbUpdateBoxSelection
      pbDrawNameBarContent
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when :special_battle_summary
      pkmn.able? rescue nil
      oldsprites = pbFadeOutAndHide(@sprites)
      summary_scene = PokemonSummary_Scene.new
      summary_screen = PokemonSummaryScreen.new(summary_scene, true)
      summary_screen.pbStartScreen(@party, @activecmd)
      pbFadeInAndShow(@sprites, oldsprites)
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when :special_battle_moves
      oldsprites = pbFadeOutAndHide(@sprites)
      summary_scene = PokemonSummary_Scene.new
      summary_screen = PokemonSummaryScreen.new(summary_scene, true)
      summary_screen.pbStartScreen(@party, @activecmd)
      pbFadeInAndShow(@sprites, oldsprites)
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when :cancel
      pbPlayCloseMenuSE
      return -1

    when :back
      pbPlayCancelSE
      @menu_mode = :main
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when :item_give
      pbPlayDecisionSE
      @menu_mode = :main
      pbPerformItemGive(screen)
      return nil

    when :item_take
      pbPlayDecisionSE
      @menu_mode = :main
      pbPerformItemTake(screen)
      return nil

    when :move_use
      pbPlayDecisionSE
      @menu_mode = :main
      closed = pbPerformMoveUse(screen)
      return -1 if closed
      return nil

    when Hash
      name = data["name"]
      if name == _INTL("Switch")
        pbPlayDecisionSE
        pbPerformSwitch(screen)
        return nil
      elsif name == _INTL("Item")
        pbPlayDecisionSE
        @menu_mode = :item
        pbBuildCommandList
        pbUpdateCommandButtons(true)
        return nil
      end
      pbPlayDecisionSE
      data["effect"].call(screen, @party, @activecmd)
      pbBuildCommandList
      pbUpdateCommandButtons(true)
      return nil

    when Array
      if data[0] == :move
        @pending_move_index = data[1]
        pbPlayDecisionSE
        @menu_mode = :move
        pbBuildCommandList
        pbUpdateCommandButtons(true)
      end
      return nil

    else
      return nil
    end
  end

  def pbPrevPartyIndex(from)
    idx = from
    6.times do
      idx = (idx - 1) % 6
      return idx if @party[idx]
    end
    return from
  end

  def pbNextPartyIndex(from)
    idx = from
    6.times do
      idx = (idx + 1) % 6
      return idx if @party[idx]
    end
    return from
  end

  def scene
    self
  end

end

class PokemonPartyScreen
  alias custom_party_screen_initialize initialize
  def initialize(scene, party)
    custom_party_screen_initialize(scene, party)
    scene.screen_owner = self if scene.respond_to?(:screen_owner=)
  end

  def pbPokemonGiveScreen(item)
    @scene.pbSetGiveItemMode(item) if @scene.respond_to?(:pbSetGiveItemMode)
    @scene.pbStartScene(@party, _INTL("Give to which Pokémon?"))
    ret = false
    loop do
      @scene.pbSetGiveItemMode(item) if @scene.respond_to?(:pbSetGiveItemMode)
      pkmnid = @scene.pbChoosePokemon
      break if pkmnid < 0
      if pbGiveItemToPokemon(item, @party[pkmnid], self, pkmnid)
        ret = true
        break
      end
    end
    pbRefreshSingle(pkmnid) if defined?(pkmnid) && pkmnid && pkmnid >= 0
    @scene.pbEndScene
    return ret
  end
end

def pbGiveItemToPokemon(item, pkmn, scene, pkmnid = 0)
  newitemname = GameData::Item.get(item).portion_name
  if pkmn.egg?
    scene.pbDisplay(_INTL("Eggs can't hold items."))
    return false
  elsif pkmn.mail
    scene.pbDisplay(_INTL("{1}'s mail must be removed before giving it an item.", pkmn.name))
    return false if !pbTakeItemFromPokemon(pkmn, scene)
  end
  if pkmn.hasItem?
    olditemname = pkmn.item.portion_name
    if scene.pbConfirm(_INTL("Swap for {1}?", newitemname))
      $bag.remove(item)
      if !$bag.add(pkmn.item)
        raise _INTL("Couldn't re-store deleted item in Bag somehow") if !$bag.add(item)
        scene.pbDisplay(_INTL("The Bag is full. The Pokémon's item could not be removed."))
      elsif GameData::Item.get(item).is_mail?
        if pbWriteMail(item, pkmn, pkmnid, scene)
          pkmn.item = item
          scene.pbDisplay(_INTL("Gave {1}.", newitemname))
          return true
        elsif !$bag.add(item)
          raise _INTL("Couldn't re-store deleted item in Bag somehow")
        end
      else
        pkmn.item = item
        scene.pbDisplay(_INTL("Gave {1}.", newitemname))
        return true
      end
    end
  elsif !GameData::Item.get(item).is_mail? || pbWriteMail(item, pkmn, pkmnid, scene)
    $bag.remove(item)
    pkmn.item = item
    scene.pbDisplay(_INTL("Gave {1}.", newitemname))
    return true
  end
  return false
end

def pbMoveTutorChoose(move, movelist = nil, bymachine = false, oneusemachine = false)
  ret = false
  move = GameData::Move.get(move).id
  if movelist.is_a?(Array)
    movelist.map! { |m| GameData::Move.get(m).id }
  end
  pbFadeOutIn do
    movename = GameData::Move.get(move).name
    annot = pbMoveTutorAnnotations(move, movelist)
    scene = PokemonParty_Scene.new
    screen = PokemonPartyScreen.new(scene, $player.party)
    scene.pbSetTeachMoveMode(move) if scene.respond_to?(:pbSetTeachMoveMode)
    screen.pbStartScene(_INTL("Teach which Pokémon?"), false, annot)
    loop do
      chosen = screen.pbChoosePokemon
      break if chosen < 0
      pokemon = $player.party[chosen]
      if pokemon.egg?
        pbMessage(_INTL("Eggs can't be taught any moves.")) { screen.pbUpdate }
      elsif pokemon.shadowPokemon?
        pbMessage(_INTL("Shadow Pokémon can't be taught any moves.")) { screen.pbUpdate }
      elsif movelist && movelist.none? { |j| j == pokemon.species }
        pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
      elsif !pokemon.compatible_with_move?(move)
        pbMessage(_INTL("{1} can't learn {2}.", pokemon.name, movename)) { screen.pbUpdate }
      elsif pbLearnMove(pokemon, move, false, bymachine) { screen.pbUpdate }
        $stats.moves_taught_by_item += 1 if bymachine
        $stats.moves_taught_by_tutor += 1 if !bymachine
        pokemon.add_first_move(move) if oneusemachine
        ret = true
        break
      end
      scene.pbSetTeachMoveMode(move) if scene.respond_to?(:pbSetTeachMoveMode)
    end
    screen.pbEndScene
  end
  return ret   # Returns whether the move was learned by a Pokemon
end

def pbUseItem(bag, item, bagscene = nil)
  itm = GameData::Item.get(item)
  useType = itm.field_use
  if useType == 1   # Item is usable on a Pokémon
    if $player.pokemon_count == 0
      pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret = false
    annot = nil
    if itm.is_evolution_stone?
      annot = []
      $player.party.each do |pkmn|
        elig = pkmn.check_evolution_on_use_item(item)
        annot.push((elig) ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn do
      scene = PokemonParty_Scene.new
      screen = PokemonPartyScreen.new(scene, $player.party)
      scene.pbSetUseItemMode(item) if scene.respond_to?(:pbSetUseItemMode)
      screen.pbStartScene(_INTL("Use on which Pokémon?"), false, annot)
      loop do
        scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
        chosen = screen.pbChoosePokemon
        if chosen < 0
          ret = false
          break
        end
        pkmn = $player.party[chosen]
        next if !pbCheckUseOnPokemon(item, pkmn, screen)
        qty = 1
        max_at_once = ItemHandlers.triggerUseOnPokemonMaximum(item, pkmn)
        max_at_once = [max_at_once, $bag.quantity(item)].min
        if max_at_once > 1
          qty = screen.scene.pbChooseNumber(
            _INTL("How many {1} do you want to use?", GameData::Item.get(item).portion_name_plural), max_at_once
          )
          screen.scene.pbSetHelpText("") if screen.is_a?(PokemonPartyScreen)
        end
        next if qty <= 0
        ret = ItemHandlers.triggerUseOnPokemon(item, qty, pkmn, screen)
        next unless ret && itm.consumed_after_use?
        bag.remove(item, qty)
        next if bag.has?(item)
        pbMessage(_INTL("You used your last {1}.", itm.portion_name)) { screen.pbUpdate }
        break
      end
      screen.pbEndScene
      bagscene&.pbRefresh
    end
    return (ret) ? 1 : 0
  elsif useType == 2 || itm.is_machine?   # Item is usable from Bag or teaches a move
    intret = ItemHandlers.triggerUseFromBag(item)
    if intret >= 0
      bag.remove(item) if intret == 1 && itm.consumed_after_use?
      return intret
    end
    pbMessage(_INTL("Can't use that here."))
    return 0
  end
  pbMessage(_INTL("Can't use that here."))
  return 0
end

class Battle::Scene
  alias custom_party_pbPartyScreen pbPartyScreen
  def pbPartyScreen(idxBattler, canCancel = false, mode = 0)
    return custom_party_pbPartyScreen(idxBattler, canCancel, mode) if mode != 0

    visibleSprites = pbFadeOutAndHide(@sprites)
    partyPos = @battle.pbPartyOrder(idxBattler)
    partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
    modParty = @battle.pbPlayerDisplayParty(idxBattler)

    # A display-party index counts as "in battle" if some non-fainted
    # battler on the player's side currently points at it
    battle_indices = modParty.length.times.select do |i|
      @battle.battlers.any? { |b| b && !b.fainted? && b.index.even? == idxBattler.even? && b.pokemonIndex == i }
    end

    scene = PokemonParty_Scene.new
    switchScreen = PokemonPartyScreen.new(scene, modParty)
    scene.pbSetBattleMode(battle_indices, self, idxBattler)
    scene.pbStartScene(modParty, _INTL("Choose a Pokémon."))

    loop do
      idxParty = switchScreen.pbChoosePokemon
      if idxParty < 0
        next if !canCancel
        break
      end
      idxPartyRet = -1
      partyPos.each_with_index do |pos, i|
        next if pos != idxParty + partyStart
        idxPartyRet = i
        break
      end
      break if yield idxPartyRet, switchScreen
      scene.pbSetBattleMode(battle_indices, self, idxBattler)
    end
    switchScreen.pbEndScene
    pbFadeInAndShow(@sprites, visibleSprites)
  end

  def pbItemMenu(idxBattler, _firstAction)
    visibleSprites = pbFadeOutAndHide(@sprites)
    oldLastPocket = $bag.last_viewed_pocket
    oldChoices    = $bag.last_pocket_selections.clone
    if @bagLastPocket
      $bag.last_viewed_pocket     = @bagLastPocket
      $bag.last_pocket_selections = @bagChoices
    else
      $bag.reset_last_selections
    end
    itemScene = PokemonBag_Scene.new
    itemScene.pbStartScene($bag, true,
                           proc { |item|
                             useType = GameData::Item.get(item).battle_use
                             next useType && useType > 0
                           }, false)
    wasTargeting = false
    loop do
      item = itemScene.pbChooseItem
      break if !item
      item = GameData::Item.get(item)
      itemName = item.name
      useType = item.battle_use
      cmdUse = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType != 0
      commands[commands.length]          = _INTL("Cancel")
      command = itemScene.pbShowCommands(_INTL("{1} is selected.", itemName), commands)
      next unless cmdUse >= 0 && command == cmdUse

      case useType
      when 1, 2, 3
        case useType
        when 1
          if @battle.pbTeamLengthFromBattlerIndex(idxBattler) == 1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        when 3
          if @battle.pbPlayerBattlerCount == 1
            break if yield item.id, useType, @battle.battlers[idxBattler].pokemonIndex, -1, itemScene
          end
        end
        itemScene.pbFadeOutScene
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene, modParty)
        pkmnScene.pbSetUseItemMode(item.id) if pkmnScene.respond_to?(:pbSetUseItemMode)
        pkmnScreen.pbStartScene(_INTL("Use on which Pokémon?"), @battle.pbNumPositions(0, 0))
        idxParty = -1
        loop do
          pkmnScene.pbSetHelpText(_INTL("Use on which Pokémon?"))
          idxParty = pkmnScreen.pbChoosePokemon
          break if idxParty < 0
          idxPartyRet = -1
          partyPos.each_with_index do |pos, i|
            next if pos != idxParty + partyStart
            idxPartyRet = i
            break
          end
          next if idxPartyRet < 0
          pkmn = party[idxPartyRet]
          next if !pkmn || pkmn.egg?
          idxMove = -1
          if useType == 2
            idxMove = pkmnScreen.pbChooseMove(pkmn, _INTL("Restore which move?"))
            next if idxMove < 0
          end
          break if yield item.id, useType, idxPartyRet, idxMove, pkmnScene
          pkmnScene.pbSetUseItemMode(item.id) if pkmnScene.respond_to?(:pbSetUseItemMode)
        end
        pkmnScene.pbEndScene
        break if idxParty >= 0
        itemScene.pbFadeInScene
      when 4
        idxTarget = -1
        if @battle.pbOpposingBattlerCount(idxBattler) == 1
          @battle.allOtherSideBattlers(idxBattler).each { |b| idxTarget = b.index }
          break if yield item.id, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          itemScene.pbFadeOutScene
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(:Foe), tempVisibleSprites)
          if idxTarget >= 0
            break if yield item.id, useType, idxTarget, -1, self
          end
          wasTargeting = false
          pbFadeOutAndHide(@sprites)
          itemScene.pbFadeInScene
        end
      when 5
        break if yield item.id, useType, idxBattler, -1, itemScene
      end
    end
    @bagLastPocket = $bag.last_viewed_pocket
    @bagChoices    = $bag.last_pocket_selections.clone
    $bag.last_viewed_pocket     = oldLastPocket
    $bag.last_pocket_selections = oldChoices
    itemScene.pbEndScene
    pbFadeInAndShow(@sprites, visibleSprites) if !wasTargeting
  end
end