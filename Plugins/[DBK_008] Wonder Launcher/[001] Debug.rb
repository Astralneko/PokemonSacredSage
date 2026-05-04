#===============================================================================
# Debug menus.
#===============================================================================

#-------------------------------------------------------------------------------
# General Debug options
#-------------------------------------------------------------------------------
MenuHandlers.add(:debug_menu, :deluxe_wonder_launcher, {
  "name"        => _INTL("Toggle Wonder Launcher"),
  "parent"      => :deluxe_gimmick_toggles,
  "description" => _INTL("Toggles Wonder Launcher functionality during trainer battles."),
  "effect"      => proc {
    $game_switches[Settings::WONDER_LAUNCHER_SWITCH] = !$game_switches[Settings::WONDER_LAUNCHER_SWITCH]
    toggle = ($game_switches[Settings::WONDER_LAUNCHER_SWITCH]) ? "enabled" : "disabled"
    pbMessage(_INTL("Wonder Launcher {1}.", toggle))
  }
})

MenuHandlers.add(:battle_rules_menu, :wonderLauncher, {
  "name"        => "Launcher battle: [{1}]",
  "rule"        => "wonderLauncher",
  "order"       => 313,
  "parent"      => :set_battle_rules,
  "description" => _INTL("Determines whether or not the Wonder Launcher is enabled."),
  "effect"      => proc { |menu|
    next pbApplyBattleRule("wonderLauncher", :Boolean, nil, 
      _INTL("Set whether the Wonder Launcher is enabled. (Trainer battles only)"))
  }
})


#-------------------------------------------------------------------------------
# Battle Debug options.
#-------------------------------------------------------------------------------
MenuHandlers.add(:battle_debug_menu, :deluxe_battle_wonder_launcher, {
  "name"        => _INTL("Wonder Launcher"),
  "parent"      => :trainers,
  "description" => _INTL("Whether each trainer is able to use Wonder Launcher items."),
  "effect"      => proc { |battle|
    cmd = 0
    loop do
      commands = []
      cmds = []
      battle.launcherCounter.each_with_index do |side_values, side|
        trainers = (side == 0) ? battle.player : battle.opponent
        next if !trainers
        side_values.each_with_index do |value, i|
          next if !trainers[i]
          text = (side == 0) ? "Your side:" : "Foe side:"
          text += sprintf(" %d: %s", i, trainers[i].name)
          text += sprintf(" [ABLE]") if value
          text += sprintf(" [UNABLE]") if !value
          commands.push(text)
          cmds.push([side, i])
        end
      end
      if battle.launcherBattle?
        cmd = pbMessage("\\ts[]" + _INTL("Choose trainer to toggle whether they can use the Wonder Launcher."),
                        commands, -1, nil, cmd)
        break if cmd < 0
        real_cmd = cmds[cmd]
        if battle.launcherCounter[real_cmd[0]][real_cmd[1]]
          battle.launcherCounter[real_cmd[0]][real_cmd[1]] = false
        else
          battle.launcherCounter[real_cmd[0]][real_cmd[1]] = true
        end
      elsif battle.wildBattle?
        pbMessage(_INTL("The Wonder Launcher cannot be used in wild battles."))
        break
      else
        pbMessage(_INTL("The Wonder Launcher is not available in this battle."))
        break
      end
    end
  }
})


MenuHandlers.add(:battle_debug_menu, :deluxe_battle_wonder_launcher_points, {
  "name"        => _INTL("Launcher Points"),
  "parent"      => :trainers,
  "description" => _INTL("Total Launcher Points accumulated by each trainer."),
  "effect"      => proc { |battle|
    cmd = 0
    loop do
      commands = []
      cmds = []
      battle.launcherPoints.each_with_index do |side_values, side|
        trainers = (side == 0) ? battle.player : battle.opponent
        next if !trainers
        side_values.each_with_index do |value, i|
          next if !trainers[i]
          text = (side == 0) ? "Your side:" : "Foe side:"
          text += sprintf(" %d: %s", i, trainers[i].name)
          text += sprintf(" (%d)", value)
          commands.push(text)
          cmds.push([side, i])
        end
      end
      if battle.launcherBattle?
        cmd = pbMessage("\\ts[]" + _INTL("Choose a trainer's total Wonder Launcher points to edit."),
                        commands, -1, nil, cmd)
        break if cmd < 0
        real_cmd = cmds[cmd]
        pointMax = Settings::WONDER_LAUNCHER_MAX_POINTS
        points = battle.launcherPoints[real_cmd[0]][real_cmd[1]]
        params = ChooseNumberParams.new
        params.setRange(0, pointMax)
        params.setInitialValue(points)
        params.setCancelValue(points)
        new_points = pbMessageChooseNumber(
          "\\ts[]" + _INTL("Set Wonder Launcher points (max={1}).", pointMax), params
        )
        if new_points != points
          battle.launcherPoints[real_cmd[0]][real_cmd[1]] = new_points
          $game_temp.player_launcher_points = new_points if real_cmd == [0, 0]
        end
      elsif battle.wildBattle?
        pbMessage(_INTL("The Wonder Launcher cannot be used in wild battles."))
        break
      else
        pbMessage(_INTL("The Wonder Launcher is not available in this battle."))
        break
      end
    end
  }
})