class PokemonMartAdapter
  def getQuantityBasket(item)
    return 0 if $bill.nil?
    curAmount = $bill[:basket]&.dig(item, :qty) || 0
    othAmount = findItemInBillFromGameMap(item)
    return curAmount + othAmount
  end

  def findItemInBillFromGameMap(item = nil)
    amount = total = 0
    $ArckyGlobal.pokeMartTracker[$game_map.map_id].each do |eventID, keys|
      next if keys.nil? || keys.empty?
      bill = keys[:bill]
      next if bill.nil? || bill.empty? || bill[:event] == $bill[:event]
      if item
        amount += bill[:basket][item][:qty] if bill[:total] != 0 && bill[:basket].key?(item)
      else
        total += bill[:total] if bill[:currency] == $bill[:currency]
      end
    end
    if item
      return amount
    else
      #total -= $bill[:total] if $bill[:total] == total
      return total
    end
  end

  def setChangeBill(value)
    bill = $bill[:total] + value
    times = value.abs > 50 ? 50 : value.abs
    amount = (bill - $bill[:total]) / times.to_f
    $amount = (1..times).map { |step| ($bill[:total] + (amount * step)).round }
  end

  def setBill(money)
    $bill[:total] = money
  end

  def getBillString
    case $currency.downcase
    when "money", "gold"
      return _INTL("Bill:\n<r>${1}", getBill.to_s_formatted || 0)
    when "coins"
      return _INTL("Bill:\n<r>{1} coins", getBill.to_s_formatted || 0)
    when "battle points", "bp"
      return _INTL("Bill: \n<r>{1} BP", getBill.to_s_formatted || 0)
    end
  end

  def getBill
    return $bill[:total] + findItemInBillFromGameMap
  end
end

class PokemonMart_Scene
  def pbRefreshShelf
    item = GameData::Item.get(@stock[@shelfIndex[:index]])
    @sprites["itemTextWindow"].text = "#{@adapter.getDisplayName(item)}: #{@adapter.getDescription(item)}"
    pbDrawShelfItemPrice
    qtyText = @showBasket ? _INTL("In Basket:<r>#{@adapter.getQuantityBasket(item.id)}") : _INTL("In Bag:<r>#{@adapter.getQuantity(item)}")
    @sprites["qtyWindow"].visible = !item.nil?
    @sprites["qtyWindow"].text = qtyText
    @sprites["qtyWindow"].y = Graphics.height - 102 - @sprites["qtyWindow"].height
    if @showBasket
      updateCurrencyWindow(@sprites["billWindow"], @adapter, true)
    else
      @sprites["billWindow"].text = @adapter.getMoneyString
    end
  end

  def pbStartShelfScene(stock, adapter, pokeMartTracker, discount)
    pbScrollMap(6, 5, 5)
    pbSEPlay('GUI menu open')
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @viewportItems = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewportItems.z = 100000
    @pokeMartTracker = pokeMartTracker
    @stock = stock
    @discount = discount
    @adapter = adapter
    @shelfIndex = { :index => 0, :row => 0, :col => 0, :max => @stock.length }
    @showBasket = true
    @sprites = {}
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    if Essentials::VERSION.include?("21")
      @sprites["background"].setBitmap("Graphics/UI/Mart/bg_shelf")
    else
      @sprites["background"].setBitmap("Graphics/Pictures/martShelfScreen")
    end
    @sprites["background"].z = 1
    @sprites["icon"] = ItemIconSprite.new(240, 65, nil, @viewport)
    pbDrawShelfItems
    pbDrawShelfItemPrice
    @sprites["cursor"] = IconSprite.new(204, 32, @viewport)
    if Essentials::VERSION.include?("21")
      @sprites["cursor"].setBitmap("Graphics/UI/Mart/cursor_shelf")
    else
      @sprites["cursor"].setBitmap("Graphics/Pictures/martShelfSel")
    end
    @sprites["cursor"].z = 10
    @winAdapter = BuyAdapter.new(adapter)
    @sprites["itemTextWindow"] = Window_UnformattedTextPokemon.newWithSize(
      "", 0, Graphics.height - 96 - 16, Graphics.width, 128, @viewport
    )
    pbPrepareWindow(@sprites["itemTextWindow"])
    @sprites["itemTextWindow"].baseColor = Color.new(248, 248, 248)
    @sprites["itemTextWindow"].shadowColor = Color.black
    @sprites["itemTextWindow"].windowskin = nil
    @sprites["helpwindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["helpwindow"])
    @sprites["helpwindow"].visible = false
    @sprites["helpwindow"].viewport = @viewportItems
    pbBottomLeftLines(@sprites["helpwindow"], 1)
    @sprites["helpwindow"].z = 20
    @sprites["billWindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["billWindow"])
    @sprites["billWindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["billWindow"].visible = true
    @sprites["billWindow"].viewport = @viewport
    @sprites["billWindow"].x = 0
    @sprites["billWindow"].y = 0
    @sprites["billWindow"].width = 190
    @sprites["billWindow"].height = 96
    @sprites["billWindow"].baseColor = Color.new(88, 88, 80)
    @sprites["billWindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtyWindow"] = Window_AdvancedTextPokemon.new("")
    pbPrepareWindow(@sprites["qtyWindow"])
    @sprites["qtyWindow"].setSkin("Graphics/Windowskins/goldskin")
    @sprites["qtyWindow"].viewport = @viewport
    @sprites["qtyWindow"].width = 190
    @sprites["qtyWindow"].height = 64
    @sprites["qtyWindow"].baseColor = Color.new(88, 88, 80)
    @sprites["qtyWindow"].shadowColor = Color.new(168, 184, 184)
    @sprites["qtyWindow"].text = _INTL("In Basket:<r>{1}", @adapter.getQuantityBasket(@stock[@shelfIndex[:index]]))
    @sprites["qtyWindow"].y    = @sprites["billWindow"].height
    pbDeactivateWindows(@sprites)
    @buying = true
    pbRefreshShelf
    Graphics.frame_reset
  end

  def pbDrawShelfItems
    if !@sprites["shelfItems"]
      @sprites["shelfItems"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["shelfItems"].x = 204
      @sprites["shelfItems"].y = 0
      @sprites["shelfItems"].z = 5
      @sprites["shelfSoldOutItems"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["shelfSoldOutItems"].x = 204
      @sprites["shelfSoldOutItems"].y = 0
      @sprites["shelfSoldOutItems"].z = 5
      @sprites["shelfSoldOutItems"].tone = Tone.new(0, 0, 0, 255)
    end
    @sprites["shelfItems"].bitmap.clear
    @sprites["shelfSoldOutItems"].bitmap.clear
    if @stock.length > 18
      Console.echoln_li _INTL("Your Item list is too long, the following items won't be shown and used: #{mergeArrayToString(@stock[18..-1])}")
      @stock.slice!(18..-1)
    end
    dcols = 6
    @scols = @stock.length >= dcols ? dcols : @stock.length
    @srows = @scols == dcols ? (@stock.length.to_f / @scols).ceil : 1
    irows = 3
    icols = 1
    x = 0
    y = 34
    item_index = 0
    soldOut = $pokeMartTracker[:items].select { |entry| ($bill[:basket].key?(entry[:name]) && (entry[:limit] == $bill[:basket][entry[:name]][:qty]) || entry[:limit] == 0 ) } if $bill && $pokeMartTracker.key?(:items)
    # Loop through shelf rows
    for srow in 1..@srows
      # Loop through shelf columns
      for scol in 1..@scols
        break if item_index >= @stock.length # Stop if all items are drawn
        item = @stock[item_index]
        itemImage = GameData::Item.icon_filename(item)
        # Draw the item according to its irows and icols
        for row in 0...irows
          for col in 0...icols
            if soldOut && soldOut.any? { |hash| hash[:name] == item }
              pbDrawImagePositions(@sprites["shelfSoldOutItems"].bitmap, [[itemImage, x + (49 * col), y + (12 * row)]])
            else
              pbDrawImagePositions(@sprites["shelfItems"].bitmap, [[itemImage, x + (49 * col), y + (12 * row)]])
            end
          end
        end
        # Move x position for the next item
        x += (49 * icols)
        item_index += 1
      end
      # Reset x position, and move y position for the next shelf row
      x = 0
      y += 86
    end
  end

  def pbDrawShelfItemPrice
    if !@sprites["shelfItemPrice"]
      @sprites["shelfItemPrice"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      pbSetSmallFont(@sprites["shelfItemPrice"].bitmap)
      @sprites["shelfItemPrice"].z = 15
      @sprites["shelfItemPrice"].x = 185
      @sprites["shelfItemPrice"].y = 0
      @sprites["shelfItemPrice"].bitmap.font.size = 19
    end
    @sprites["shelfItemPrice"].bitmap.clear
    base = Color.new(248, 248, 248)
    shadow = Color.new(0, 0, 0)
    item = @stock[@shelfIndex[:index]]
    price = @adapter.getDisplayPrice(item, nil, @discount)
    x = 44 + (@shelfIndex[:col] * 49)
    y = 95 + (@shelfIndex[:row] * 86)
    pbDrawTextPositions(@sprites["shelfItemPrice"].bitmap, [[price, x, y, :center, base, shadow]])
  end

  def pbChooseShelfItem
    pbRefreshShelf
    @sprites["helpwindow"].visible = false
    loop do
      Graphics.update
      Input.update
      self.update
      if Input.trigger?(Input::RIGHT)
        if @shelfIndex[:index] < @shelfIndex[:max] - 1 # not last item
          @shelfIndex[:index] += 1
          if @shelfIndex[:col] < @scols - 1 # not last col
            @shelfIndex[:col] += 1
          else
            @shelfIndex[:col] = 0
            @shelfIndex[:row] += 1
          end
        else
          @shelfIndex[:index] = 0
          @shelfIndex[:row] = 0
          @shelfIndex[:col] = 0
        end
        updateCursorPostion
      elsif Input.trigger?(Input::LEFT)
        if @shelfIndex[:index] > 0 # not first item
          @shelfIndex[:index] -= 1
          if @shelfIndex[:col] > 0 # not first col
            @shelfIndex[:col] -= 1
          else
            @shelfIndex[:col] = @scols - 1
            @shelfIndex[:row] -= 1 if @shelfIndex[:row] > 0
          end
        else
          @shelfIndex[:index] = @shelfIndex[:max] - 1
          @shelfIndex[:row] = @srows - 1
          @shelfIndex[:col] = (@shelfIndex[:max] - 1) % @scols
        end
        updateCursorPostion
      elsif Input.trigger?(Input::DOWN)
        if @srows == 1
          # If there's only 1 row, loop between the first and last items
          if @shelfIndex[:index] == @shelfIndex[:max] - 1 # is last item
            @shelfIndex[:index] = 0
            @shelfIndex[:col] = 0
          else
            @shelfIndex[:index] = @shelfIndex[:max] - 1
            @shelfIndex[:col] = @shelfIndex[:index] % @scols
          end
        else
          # If there's more than 1 row
          if @shelfIndex[:index] + @scols <= @shelfIndex[:max] - 1 # not last row
            @shelfIndex[:index] += @scols
            @shelfIndex[:row] += 1
          else
            if @shelfIndex[:row] == @srows - 1
              @shelfIndex[:index] = @shelfIndex[:col]
              @shelfIndex[:row] = 0
            else
              @shelfIndex[:index] = @shelfIndex[:max] - 1
              @shelfIndex[:row] = @srows - 1
              @shelfIndex[:col] = @shelfIndex[:index] % @scols
            end
          end
        end
        updateCursorPostion
      elsif Input.trigger?(Input::UP)
        if @srows == 1
          # If there's only 1 row, loop between the first and last items
          if @shelfIndex[:index] == 0 # is first item
            @shelfIndex[:index] = @shelfIndex[:max] - 1
            @shelfIndex[:col] = @shelfIndex[:index] % @scols
          else
            @shelfIndex[:index] = 0
            @shelfIndex[:col] = 0
          end
        else
          # If there's more than 1 row
          if @shelfIndex[:index] - @scols >= 0 # not first row
            @shelfIndex[:index] -= @scols
            @shelfIndex[:row] -= 1
          else
            if (@srows - 1) * @scols + @shelfIndex[:col] > @shelfIndex[:max] - 1
              @shelfIndex[:index] = @shelfIndex[:max] - 1
            else
              @shelfIndex[:index] = (@srows - 1) * @scols + @shelfIndex[:col]
            end
            @shelfIndex[:row] = @srows - 1
            @shelfIndex[:col] = @shelfIndex[:index] % @scols
          end
        end
        updateCursorPostion
      elsif Input.trigger?(Input::BACK)
        pbPlayCloseMenuSE
        return nil
      elsif Input.trigger?(Input::USE)
        pbRefreshShelf
        return @stock[@shelfIndex[:index]]
      elsif Input.trigger?(Input::CTRL)
        @showBasket = !@showBasket
        pbRefreshShelf
      end
      pbRefreshShelf
    end
  end

  def updateCursorPostion
    @sprites["cursor"].x = 204 + (49 * @shelfIndex[:col])
    @sprites["cursor"].y = 32 + (86 * @shelfIndex[:row])
  end

  def pbEndShelfScene
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
    pbScrollMap(4, 5, 5)
  end

  def pbPrepareWindow(window)
    window.visible = true
    window.letterbyletter = false
  end
end

class PokemonMartScreen
  def pbShelfScreen
    @scene.pbStartShelfScene(@stock, @adapter, $pokeMartTracker, @discount)
    item = nil
    loop do
      item = @scene.pbChooseShelfItem
      break if !item
      basketItem = $bill[:basket][item]
      quantity = basketItem ? basketItem[:qty] : 1
      oldQuanity = basketItem ? quantity : 0
      itemName = @adapter.getDisplayName(item)
      itemNamePlural = @adapter.getDisplayNamePlural(item)
      price = @adapter.getPrice(item, @discount)
      changeAmount = false
      if @adapter.getBill + price > @adapter.getMoney
        basket = $bill[:basket].key?(item) ? $bill[:basket][item][:qty] : 0
        if basket != 0
          next if !pbConfirm(_INTL(@getSpeech[:NotEnoughMoneyItem]&.sample || "You don't have enough {1}. Do you want to change the quantity of {2}?", @adapter.getCurrency, itemNamePlural))
        else
          pbDisplayPaused(_INTL(@getSpeech[:NotEnoughMoney]&.sample || "You don't have enough {1} to add any {2}.", @adapter.getCurrency, itemNamePlural))
          next
        end
        changeAmount = true
      end
      unless GameData::Item.get(item).is_important?
        totAddItems = getMaxAddableItems(item)
        maxafford = (price <= 0) ? Settings::BAG_MAX_PER_SLOT : (@adapter.getMoney - @adapter.getBill) / price
        maxafford = Settings::BAG_MAX_PER_SLOT if maxafford > Settings::BAG_MAX_PER_SLOT
        maxafford = totAddItems if Settings::BAG_MAX_PER_SLOT > totAddItems && totAddItems > 0
        entry = $pokeMartTracker[:items].find { |entry| entry[:name] == item } if $pokeMartTracker.key?(:items)
        maxafford = entry[:limit] if !entry.nil? && entry[:limit] < maxafford && entry[:limit] <= Settings::BAG_MAX_PER_SLOT
        maxafford += quantity if basketItem && basketItem[:qty] != maxafford
        maxafford = entry[:limit] if entry && maxafford > entry[:limit]
        minimum = basketItem && basketItem[:qty] != 0 ? 0 : 1
        if entry && entry[:limit] == 0
          pbDisplayPaused(_INTL(@getSpeech[:ShelfOutOfStock]&.sample || "{1} are out of stock, come back {2}.", itemNamePlural, $pokeMartTracker[:refresh]))
          next
        end
        if !changeAmount
          if basketItem && entry && basketItem[:qty] == entry[:limit]
            text = @getSpeech[:ShelfLimitAmountItem]&.sample || "Your basket has all {1} that are in stock, change it to how many?"
          elsif basketItem && basketItem[:qty] != 0
            text = @getSpeech[:ShelfChangeAmountItem]&.sample || "You currently have {2} {1} in your basket, change it to how many?"
          else
            text = @getSpeech[:ShelfAmountItem]&.sample || "How many {1} would you like to add to your basket?"
          end
          oldPrice = @adapter.getPrice(item)
          if !@discount.nil? && $game_variables[@discount] >= 0 && price != oldPrice
            if price != oldPrice
              percentage = "of #{(100 - ((price.to_f / oldPrice) * 100).round(0)).abs}%"
              if price < oldPrice
                quantity = @scene.pbChooseNumber(
                  _INTL(@getSpeech[:ShelfItemAmountDiscount]&.sample || "There's a discount of {1} {2}, how many would you like?", percentage, itemNamePlural),
                  item, maxafford, minimum, quantity) unless maxafford == 0
              elsif price > oldPrice
                quantity = @scene.pbChooseNumber(
                  _INTL(@getSpeech[:ShelfItemAmountOvercharge]&.sample || "There's an overcharge of {1} on {2}, how many would you like?", percentage, itemNamePlural),
                  item, maxafford, minimum, quantity) unless maxafford == 0
              end
            else
              Console.echoln_li _INTL("Please check the value of game variable #{@discount}, it's too high according to it's Discounts values")
            end
          else
            quantity = @scene.pbChooseNumber(
              _INTL(text, quantity > 1 ? itemNamePlural : itemName, quantity),
              item, maxafford, minimum, quantity) unless maxafford == 0
          end
        else
          quantity = @scene.pbChooseNumber(
            _INTL(@getSpeech[:NotEnoughMoneyAmount]&.sample || "Change the amount of {1} you have in your basket to how many?", itemNamePlural),
            item, maxafford, minimum, quantity) unless maxafford == 0
        end
        if quantity == 0 && oldQuanity != 0
          $bill[:basket].delete(item)
          pbDisplayPaused(_INTL(@getSpeech[:ShelfRemoveAmountItem]&.sample || "You removed {1} {2} from your basket. Your bill was decreased by {3}", oldQuanity, oldQuanity > 1 ? itemNamePlural : itemName, @adapter.getCurrencyPrice(price * oldQuanity)))
        else
          $bill[:basket][item] = { :qty => quantity } if quantity != 0
          if quantity > oldQuanity
            pbDisplayPaused(_INTL(@getSpeech[:ShelfIncreaseAmountItem]&.sample || "{1} {2} have been added to your basket. Your bill was increased by {3}", quantity - oldQuanity, quantity > 1 ? "#{itemNamePlural} have" : "#{itemName} has", @adapter.getCurrencyPrice(price * (quantity - oldQuanity))))
          elsif quantity < oldQuanity
            pbDisplayPaused(_INTL(@getSpeech[:ShelfDecreaseAmountItem]&.sample || "You removed {1} {2} from your basket. Your bill bas decreased by {3}", oldQuanity - quantity, quantity > 1 ? itemNamePlural : itemName, @adapter.getCurrencyPrice(price * (oldQuanity - quantity))))
          end
        end
        @adapter.setChangeBill((-oldQuanity * price) + (quantity * price))
      end
      @scene.pbDrawShelfItems
    end
    $game_switches[APMSettings::BillSwitch] = $bill[:basket].length > 0
    @scene.pbEndShelfScene
  end
end

def payBill(speech)
  adapter = PokemonMartAdapter.new
  moneyWindow = Window_AdvancedTextPokemon.new(adapter.getMoneyString)
  moneyWindow.width = 190
  moneyWindow.height = 96
  moneyWindow.baseColor = Color.new(88, 88, 80)
  moneyWindow.shadowColor = Color.new(168, 184, 184)
  items = Hash.new { |hash, key| hash[key] = { qty: 0, bonus: [] } }
  bonusItems = []
  price = 0
  addedAll = [true, true]
  $ArckyGlobal.pokeMartTracker[@map_id].each do |eventID, keys|
    next if eventID == @event_id
    bill = keys[:bill]
    next if bill[:currency] != $currency || bill[:basket]&.empty?
    bill[:basket].each do |item, amount|
      # Update item quantities
      items[item][:qty] += amount[:qty]
      amount[:qty].times { adapter.addItem(item) }
      # Update entry limits if applicable
      if keys.key?(:items)
        entry = keys[:items].find { |e| e[:name] == item }
        entry[:limit] -= amount[:qty] if entry && entry[:limit]
      end
      # Fetch bonus items and merge them
      bonus, added = getBonusItems(item, adapter, amount[:qty], speech, true)
      unless bonus.nil? || bonus.empty?
        items[item][:bonus].concat(bonus)
        addedAll = added
      end
    end
    price += bill[:total]
    # Make the Bill empty after retrieving the data
    keys[:bill][:total] = 0
    keys[:bill][:basket] = {}
  end
  itemString = items.map do |item, details|
    itemData = GameData::Item.try_get(item)
    next unless itemData
    quantity = details[:qty]
    itemName = quantity > 1 ? itemData.name_plural : itemData.name
    "#{quantity} #{itemName}"
  end.compact
  itemList = mergeArrayToString(itemString)
  finalString = _INTL(speech[:BillCheckOut]&.sample || "Your basket contains {1} which comes to a total of {2}, please.", itemList, adapter.getCurrencyPrice(price))
  pbMessage(finalString)
  adapter.setChangeMoney(adapter.getMoney - price)
  updateCurrencyWindow(moneyWindow, adapter)
  bonusString = items.values.flat_map { |details| details[:bonus] }
  bonusList = mergeArrayToString(bonusString)
  pbMessage(getBonusItemsString(addedAll, bonusList, speech)) unless bonusList.nil?
  $game_switches[APMSettings::BillSwitch] = false
  moneyWindow.dispose
end

def updateCurrencyWindow(sprite, adapter, bill = false)
  sprite.text = bill ? adapter.getBillString : adapter.getMoneyString
  if $amount && !$amount.empty?
    $amount.each do |money|
      if bill
        adapter.setBill(money)
      else
        adapter.setMoney(money)
      end
      sprite.text = bill ? adapter.getBillString : adapter.getMoneyString
      if Essentials::VERSION.include?("21")
        pbWait(0.01)
      else
        pbWait(1)
      end
    end
    $amount = []
  else
    sprite.text = bill ? adapter.getBillString : adapter.getMoneyString
  end
end
