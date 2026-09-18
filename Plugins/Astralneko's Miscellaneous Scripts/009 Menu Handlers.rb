MenuHandlers.add(:pause_menu, :quests, {
	"name" => _INTL("Quests"),
  "icon_name" => "quests",
	"order" => 52,
	"condition" => proc { next hasAnyQuests? },
	"effect" => proc { |menu| 
		pbPlayDecisionSE
		pbFadeOutIn {
			scene = QuestList_Scene.new
			screen = QuestList_Screen.new(scene)
			screen.pbStartScreen
			menu.pbRefresh
		}
		next false
	}
})

MenuHandlers.add(:pause_menu, :pokegear, {
  "name"      => _INTL("Phone"),
  "icon_name" => "phone",
  "order"     => 40,
#  "condition" => proc { next $PokemonGlobal.phone && $PokemonGlobal.phone.contacts.length > 0 },
  "effect"    => proc { |menu|
    pbFadeOutIn do
      scene = PokemonPhone_Scene.new
      screen = PokemonPhoneScreen.new(scene)
      screen.pbStartScreen
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :map, {
  "name"      => _INTL("Map"),
  "icon_name" => "town_map",
  "order"     => 42,
  "effect"    => proc { |menu|
    pbFadeOutIn do
      scene = PokemonRegionMap_Scene.new(-1, false)
      screen = PokemonRegionMapScreen.new(scene)
      ret = screen.pbStartScreen
      if ret
        $game_temp.fly_destination = ret
        menu.dispose
        next 99999
      end
    end
    next $game_temp.fly_destination
  }
})

MenuHandlers.add(:pause_menu, :jukebox, {
  "name"      => _INTL("Jukebox"),
  "icon_name" => "jukebox",
  "order"     => 51,
  "effect"    => proc { |menu|
    pbFadeOutIn do
      scene = PokemonJukebox_Scene.new
      screen = PokemonJukeboxScreen.new(scene)
      screen.pbStartScreen
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :berrydex, {
  "name"      => _INTL("Berrydex"),
  "icon_name" => "berry",
  "order"     => 11,
  "effect"    => proc { |menu|
    pbFadeOutIn do
      scene = PokemonJukebox_Scene.new
      screen = PokemonJukeboxScreen.new(scene)
      screen.pbStartScreen
    end
    next false
  }
})

MenuHandlers.add(:pause_menu, :messages, {
  "name"      => _INTL("Messages"),
  "icon_name" => "messages",
  "order"     => 41,
  "effect"    => proc { |menu|
    # pbInstantMessages already handles everything this option needs to do
    pbInstantMessages
    next false
  }
})