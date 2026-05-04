#===============================================================================
# Battle::Scene class.
#===============================================================================
class Battle::Scene
  #-----------------------------------------------------------------------------
  # Aliased to initialize Wonder Launcher splash bars.
  #-----------------------------------------------------------------------------
  alias launcher_pbInitSprites pbInitSprites
  def pbInitSprites
    launcher_pbInitSprites
    if @battle.launcherBattle?
      2.times do |side|
        trainers = (side == 0) ? @battle.player : @battle.opponent
        next if !trainers || trainers.empty?
        trainers.length.times do |index|
          next if !trainers[index]
          @sprites["launcherBar_#{side}_#{index}"] = WonderLauncherPointsBar.new(
            side, index, trainers[index], @viewport)
        end
      end
    end
  end
  
  #-----------------------------------------------------------------------------
  # Utilities for the display of Wonder Launcher splash bars.
  #-----------------------------------------------------------------------------
  def pbShowLauncherPoints(idxSide, idxTrainer, points = nil)
    return if !@battle.launcherBattle?
    @sprites["launcherBar_#{idxSide}_#{idxTrainer}"].points = points if points
    launcherAnim = Animation::WonderLauncherBarAppear.new(@sprites, @viewport, idxSide, idxTrainer)
    loop do
      launcherAnim.update
      pbUpdate
      break if launcherAnim.animDone?
    end
    launcherAnim.dispose
  end

  def pbHideAllLauncherPoints(speed = 1)
    return if !@battle.launcherBattle?
    launcherAnim = Animation::WonderLauncherBarsDisappear.new(@sprites, @viewport, @battle)
    timer_start = System.uptime
    until System.uptime - timer_start >= speed || Input.trigger?(Input::USE)
      pbUpdate
    end
    loop do
      launcherAnim.update
      pbUpdate
      break if launcherAnim.animDone?
    end
    launcherAnim.dispose
  end
  
  #-----------------------------------------------------------------------------
  # Aliased to increase Wonder Launcher points each turn.
  #-----------------------------------------------------------------------------
  alias launcher_pbBeginCommandPhase pbBeginCommandPhase
  def pbBeginCommandPhase
    launcher_pbBeginCommandPhase
    return if !@battle.launcherBattle?
    2.times do |side|
      trainers = (side == 0) ? @battle.player : @battle.opponent
      next if !trainers || trainers.empty?
      trainers.length.times do |index|
        next if !trainers[index]
        @battle.pbStartTurnLauncher(side, index)
      end
    end
    pbHideAllLauncherPoints(2)
  end

  #-----------------------------------------------------------------------------
  # Used for displaying only eligible Wonder Launcher items in the bag screen.
  #-----------------------------------------------------------------------------
  def pbLauncherMenu(idxBattler)
    visibleSprites = pbFadeOutAndHide(@sprites)
    side = (@battle.pbOwnedByPlayer?(idxBattler)) ? 0 : 1
    idxTrainer = @battle.pbGetOwnerIndexFromBattlerIndex(idxBattler)
    itemScene = PokemonBag_Scene.new
    args = [$bag, true]
    modParty = @battle.pbPlayerDisplayParty(idxBattler)
    args.insert(1, modParty) if PluginManager.installed?("Bag Screen w/int. Party")
    itemScene.pbStartScene(*args,
                           proc { |item|
                             itm = GameData::Item.get(item)
                             useType = itm.launcher_use
                             next useType && useType > 0 && itm.is_launcher_item?
                           }, false)
    wasTargeting = false
    loop do
      item = itemScene.pbChooseItem
      break if !item
      item = GameData::Item.get(item)
      itemName = item.name
      itemPoints = item.launcher_points
      useType = item.launcher_use
      cmdUse = -1
      commands = []
      commands[cmdUse = commands.length] = _INTL("Use") if useType && useType != 0
      commands[commands.length]          = _INTL("Cancel")
      pointText = (itemPoints == 1) ? "Launcher Point" : "Launcher Points"
      command = itemScene.pbShowCommands(_INTL("{1} is selected.\nRequires {2} {3}.", 
        itemName, itemPoints, pointText), commands)
      next unless cmdUse >= 0 && command == cmdUse
      if itemPoints > @battle.launcherPoints[side][idxTrainer] 
        pbMessage(_INTL("Not enough Launcher Points."))
        useType = 0
      end
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
            next
          end
        end
        itemScene.pbFadeOutScene
        party    = @battle.pbParty(idxBattler)
        partyPos = @battle.pbPartyOrder(idxBattler)
        partyStart, _partyEnd = @battle.pbTeamIndexRangeFromBattlerIndex(idxBattler)
        modParty = @battle.pbPlayerDisplayParty(idxBattler)
        pkmnScene = PokemonParty_Scene.new
        pkmnScreen = PokemonPartyScreen.new(pkmnScene, modParty)
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
        end
        pkmnScene.pbEndScene
        break if idxParty >= 0
        itemScene.pbFadeInScene
      when 4, 6
        idxTarget = -1
        if useType == 4 && @battle.pbOpposingBattlerCount(idxBattler) == 1
          @battle.allOtherSideBattlers(idxBattler).each { |b| idxTarget = b.index }
          break if yield item.id, useType, idxTarget, -1, itemScene
        else
          wasTargeting = true
          itemScene.pbFadeOutScene
          tempVisibleSprites = visibleSprites.clone
          tempVisibleSprites["commandWindow"] = false
          tempVisibleSprites["targetWindow"]  = true
          if tempVisibleSprites["enhancedUIPrompts"]
            @sprites["enhancedUIPrompts"].x = -164
            tempVisibleSprites["enhancedUIPrompts"] = false
          end
          targetType = (useType == 4) ? :Foe : :UserOrOther
          idxTarget = pbChooseTarget(idxBattler, GameData::Target.get(targetType), tempVisibleSprites)
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
    itemScene.pbEndScene
    pbFadeInAndShow(@sprites, visibleSprites) if !wasTargeting
  end
end

#===============================================================================
# Animation used for displaying a trainer's Wonder Launcher splash bar.
#===============================================================================
class Battle::Scene::Animation::WonderLauncherBarAppear < Battle::Scene::Animation
  def initialize(sprites, viewport, idxSide, idxTrainer)
    @side = idxSide
    @index = idxTrainer
    super(sprites, viewport)
  end

  def createProcesses
    sprite = @sprites["launcherBar_#{@side}_#{@index}"]
    return if !sprite
    bar = addSprite(sprite)
    bar.setVisible(0, true)
    bar.setSE(0, "Exclaim")
    dir = (@side == 0) ? 1 : -1
    bar.moveDelta(0, 4, dir * (sprite.bitmap.width - 14), 0)
  end
end

#===============================================================================
# Animation used for hiding all Wonder Launcher splash bars.
#===============================================================================
class Battle::Scene::Animation::WonderLauncherBarsDisappear < Battle::Scene::Animation
  def initialize(sprites, viewport, battle)
    @battle = battle
    super(sprites, viewport)
  end

  def createProcesses
    delay = 0
    2.times do |side|
      trainers = (side == 0) ? @battle.player : @battle.opponent
      next if !trainers || trainers.empty?
      trainers.length.times do |index|
        sprite = @sprites["launcherBar_#{side}_#{index}"]
        next if !sprite || !sprite.visible
        bar = addSprite(sprite)
        dir = (side == 0) ? -1 : 1
        bar.moveDelta(0, 4, dir * (sprite.bitmap.width - 14), 0)
        bar.setVisible(4, false)
      end
    end
  end
end

#===============================================================================
# Class used for the Wonder Launcher splash bar.
#===============================================================================
class Battle::Scene::WonderLauncherPointsBar < Sprite
  attr_reader :trainer, :index, :side, :points
  
  TEXT_BASE_COLOR   = Color.new(0, 0, 0)
  TEXT_SHADOW_COLOR = Color.new(248, 248, 248)
  
  def initialize(idxSide, idxTrainer, trainer, viewport = nil)
    super(viewport)
    @side = idxSide
    @index = idxTrainer
    @trainer = trainer
    @points = 0
    @maxPoints = Settings::WONDER_LAUNCHER_MAX_POINTS
    @path = Settings::WONDER_LAUNCHER_PATH
    @bgBitmap = AnimatedBitmap.new(@path + "point_bar")
    @bgSprite = Sprite.new(viewport)
    @bgSprite.bitmap = @bgBitmap.bitmap
    @contents = Bitmap.new(@bgBitmap.width, @bgBitmap.height)
    self.bitmap = @contents
    pbSetSystemFont(self.bitmap)
    ypos = (idxSide == 0) ? 156 : 0
    self.x = (idxSide == 0) ? -self.bitmap.width : Graphics.width
    self.y = ypos + 68 * idxTrainer
    self.z = 300
    self.visible = false
  end

  def dispose
    @bgSprite.dispose
    @bgBitmap.dispose
    super
  end

  def x=(value)
    super
    @bgSprite.x = value
  end

  def y=(value)
    super
    @bgSprite.y = value
  end

  def z=(value)
    super
    @bgSprite.z = value - 1
  end

  def opacity=(value)
    super
    @bgSprite.opacity = value
  end

  def visible=(value)
    super
    @bgSprite.visible = value
  end

  def color=(value)
    super
    @bgSprite.color = value
  end

  def trainer=(value)
    @trainer = value
    refresh
  end
  
  def points=(value) 
    @points = value
    if @points < 0
      @points = 0
    elsif @points > @maxPoints
      @points = @maxPoints
    end
    refresh
  end

  def refresh
    return if !@trainer
    imagepos = []
    spriteX = (@side == 0) ? 18 : self.bitmap.width - 50
    trySprite = "Graphics/Characters/trainer_" + @trainer.trainer_type.to_s
    if @side == 0 && @index == 0 && $player.outfit > 0
      if pbResolveBitmap(trySprite + "_#{$player.outfit}")
        trySprite += "_#{$player.outfit}"
      end
    end
    imagepos.push([trySprite, spriteX, 10, 0, 0, 32, 48]) if pbResolveBitmap(trySprite) 
    @maxPoints.times do |i|
      xpos = (@side == 0) ? (spriteX + 40) + 10 * i : (spriteX - 20) - 10 * i
      imagepos.push([@path + "points", xpos, 36, 0, 0, 12, 14])
      imagepos.push([@path + "points", xpos, 36, 12, 0, 12, 14]) if @points >= i + 1
    end
    pbDrawImagePositions(self.bitmap, imagepos)
    textX = (@side == 0) ? self.bitmap.width - 18 : 20
    align = (@side == 0) ? :right : :left
    pbDrawTextPositions(self.bitmap, [
      [_INTL("{1}", @trainer.name), textX, 12, align, TEXT_BASE_COLOR, TEXT_SHADOW_COLOR, :outline]
    ])
  end

  def update
    super
    @bgSprite.update
  end
end