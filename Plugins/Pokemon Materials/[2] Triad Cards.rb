#===============================================================================
# Change how triad cards are gotten.
#===============================================================================

def pbBuyTriads
  commands = []
  show = []
  GameData::Species.each_species do |s|
    next if !$player.owned?(s.species)
    commands.push([s,s.name,s.id,s.get_baby_species])
    show.push(s.name)
  end
  if commands.length == 0
    pbMessage(_INTL("There are no cards that you can buy."))
    return
  end
  commands.sort! { |a, b| a[1] <=> b[1] }
  show.sort!
  pbScrollMap(4, 3, 5)
  cmdwindow = Window_CommandPokemonEx.newWithSize(show, 0, 0, Graphics.width / 2, Graphics.height)
  cmdwindow.z = 99999
  preview = Sprite.new
  preview.x = (Graphics.width * 3 / 4) - 40
  preview.y = (Graphics.height / 2) - 48
  preview.z = 4
  preview.bitmap = TriadCard.new(commands[cmdwindow.index][2]).createBitmap(1)
  olditem = commands[cmdwindow.index][2]
  Graphics.frame_reset  
  loop do
    Graphics.update
    Input.update
    cmdwindow.active = true
    cmdwindow.update
    if commands[cmdwindow.index][2] != olditem
      preview.bitmap&.dispose
      preview.bitmap = TriadCard.new(commands[cmdwindow.index][2]).createBitmap(1)
      olditem = commands[cmdwindow.index][2]
    end
    if Input.trigger?(Input::BACK)
      break
    elsif Input.trigger?(Input::USE)
      pokemon    = commands[cmdwindow.index][0]
      item     = commands[cmdwindow.index][2]
      itemname = commands[cmdwindow.index][1]
      itemdata = GameData::Item.try_get(commands[cmdwindow.index][3])
      cmdwindow.active = false
      cmdwindow.update
      count = pokemon.base_stat_total/50
      if !$bag.has?(itemdata.id, count)
        pbMessage(_INTL("You don't have enough materials."))
        next
      end
      maxafford = $bag.quantity(itemdata.id) / count
      maxafford = 99 if maxafford > 99
      params = ChooseNumberParams.new
      params.setRange(1, maxafford)
      params.setInitialValue(1)
      params.setCancelValue(0)
      quantity = pbMessageChooseNumber(
        _INTL("The {1} card? Certainly. How many would you like?", itemname), params
      )
      next if quantity <= 0
      price = quantity * count
      next if !pbConfirmMessage(_INTL("{1}, and you want {2}. That will require {3} {4}. OK?", itemname, quantity, price.to_s_formatted, itemdata.name))
      if !$bag.has?(itemdata.id, count)
        pbMessage(_INTL("You don't have enough materials."))
        next
      end
      if !$PokemonGlobal.triads.can_add?(item, quantity)
        pbMessage(_INTL("You have no room for more cards."))
        next
      end
      $PokemonGlobal.triads.add(item, quantity)
      $bag.remove(item, quantity)
      pbMessage(_INTL("Here you are! Thank you!") + "\\se[Mart buy item]")
    end
  end  
  cmdwindow.dispose
  preview.bitmap&.dispose
  preview.dispose
  Graphics.frame_reset
  pbScrollMap(6, 3, 5)
end