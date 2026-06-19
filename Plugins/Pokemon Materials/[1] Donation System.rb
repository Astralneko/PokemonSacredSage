#===============================================================================
# Randomizer provided items.
#===============================================================================

MATERIAL_POINTS = 74
$materialList = []

def pbChooseRandomItems(cnt = 1, items = nil)
  return if !items
  sellList = []
  for i in 0...cnt
    sellList.push([items[rand(0...items.length)],rand(3,20)])
  end
  return sellList
end

def pbMaterialSelling(cnt = 10)
  items = []
  GameData::Item.each do |itm|
    itm.flags.include?("Material")
    next if itm.pocket != 8
    items.push(itm)
  end
  return pbChooseRandomItems(cnt,items)
end

def pbDonateMaterials(cnt = 10)
  return if !$materialList
  points = 0
  choices = []
  $materialList.each do |i|
    choice = i[0].real_name + ": " + i[1].to_s
    choices.push(choice)
  end
  choices.push("Cancel")
  @message_waiting = true
  command = pbShowCommands(nil, choices, choices.length)
  @message_waiting = false
  @branch[@list[@index].indent] = choices[2][command] || command
  Input.update
  if command == choices.length - 1
    return false
  end
  if $bag.quantity($materialList[command][0]) > $materialList[command][1]
    params = ChooseNumberParams.new
    params.setMaxDigits(2)
    params.setDefaultValue(0)
    maxdonate = $bag.quantity($materialList[command][0]) - $bag.quantity($materialList[command][0]) % $materialList[command][1]
    quantity = pbChooseNumber(nil, params)
    if quantity <= $bag.quantity($materialList[command][0]) && quantity >= $materialList[command][1]
      if quantity % $materialList[command][1] != 0
        quantity = quantity - quantity % $materialList[command][1]
        pbMessage("I have rounded down to prevent you from losing any extra materials.")
      end
      if quantity > 1
        pbMessage(_INTL("Do you wish to donate {1} {2}?",quantity,$materialList[command][0].real_name_plural))
      else
        pbMessage(_INTL("Do you wish to donate a {1}?",$materialList[command][0].real_name))
      end
      @message_waiting = true
      command = pbShowCommands(nil, ["Yes","No"], 2)
      @message_waiting = false
      @branch[@list[@index].indent] = choices[2][command] || command
      Input.update
      if command == 0
        $bag.remove($materialList[command][0].id, quantity)
        points = quantity / $materialList[command][1]
        points = 1 if points < 1
        $game_variables[MATERIAL_POINTS] += points
        $materialList.delete($materialList[command])
      else
        return true
      end
      meName = "BP get"
      pbMessage("\\me[#{meName}]" + _INTL("You received {1} points!",points) + "\\wtnp[40]")
      return true
    else
      pbMessage("It doesn't seem like you can donate that much.")
      return true
    end
  end
end
