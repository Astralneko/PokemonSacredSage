
#===============================================================================
#                        Custom Trainer Card Screen
#                               V 1.0.1
#                        Developed by Carmaniac
#===============================================================================
class PokemonTrainerCard_Scene
  GRAPHICS_PATH = "Graphics/Custom UI/Trainer/"

  # Grid background scroll settings
  GRID_WIDTH  = 1600
  GRID_HEIGHT = 960
  GRID_SCROLL_SPEED_X = 1
  GRID_SCROLL_SPEED_Y = 1
  GRID_RESET_X = -Graphics.width
  GRID_RESET_Y = -Graphics.height

  def pbUpdate
	# If it hasn't been 1/60 of a second yet, do nothing
	@deltatime = 0 if !@deltatime
	if System.uptime - @deltatime < 1/60r
		return
	end
	# Set new deltatime
	@deltatime = System.uptime
	# Do things
    updateGridScroll
    pbUpdateSpriteHash(@sprites)
  end

  def pbStartScene
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @sprites = {}

    setupGridBackground

    @sprites["footer_overlay"] = IconSprite.new(0, 420, @viewport)
    @sprites["footer_overlay"].setBitmap(GRAPHICS_PATH + "overlay")
    @sprites["footer_overlay"].z = 1

    @sprites["cancel"] = IconSprite.new(754, 438, @viewport)
    @sprites["cancel"].setBitmap(GRAPHICS_PATH + "cancel")
    @sprites["cancel"].z = 3

    @region = 0
    @page = 0
    setupCard

    pbFadeInAndShow(@sprites) { pbUpdate }
    animateCardFlip
  end

  CARD_ORIGIN_X = 90
  CARD_ORIGIN_Y = 32

  def setupCard
    @sprites["card"] = IconSprite.new(CARD_ORIGIN_X, CARD_ORIGIN_Y, @viewport)
    @sprites["card"].setBitmap(GRAPHICS_PATH + "card")
    pbSetSystemFont(@sprites["card"].bitmap)
    @sprites["card"].ox = @sprites["card"].bitmap.width / 2
    @sprites["card"].oy = @sprites["card"].bitmap.height / 2
    @sprites["card"].x = CARD_ORIGIN_X + @sprites["card"].ox
    @sprites["card"].y = CARD_ORIGIN_Y + @sprites["card"].oy
    @sprites["card"].zoom_x = 0
    @sprites["card"].z = 1.5   # above the grid/footer, below cancel
    pbDrawTrainerCardFront
  end

  def animateCardFlip
    timer_start = System.uptime
    loop do
      @sprites["card"].zoom_x = lerp(0, 1, 0.3, timer_start, System.uptime)
      Graphics.update
      Input.update
      pbUpdate
      break if @sprites["card"].zoom_x >= 1
    end
    @sprites["card"].zoom_x = 1
  end

  def setupGridBackground
    @sprites["grid"] = IconSprite.new(0, 0, @viewport)
    @sprites["grid"].setBitmap(GRAPHICS_PATH + "grid")
    @sprites["grid"].z = -1
    @gridX = 0
    @gridY = 0
  end

  def updateGridScroll
    return unless @sprites["grid"]
    @gridX -= GRID_SCROLL_SPEED_X
    @gridY -= GRID_SCROLL_SPEED_Y
    @gridX = 0 if @gridX <= GRID_RESET_X
    @gridY = 0 if @gridY <= GRID_RESET_Y
    @sprites["grid"].x = @gridX
    @sprites["grid"].y = @gridY
  end

  def pbDrawTrainerCardFront
    overlay = @sprites["card"].bitmap
    baseColor   = Color.new(255, 255, 255)
    shadowColor = Color.new(156, 156, 156)
    totalsec = $stats.play_time.to_i
    hour = totalsec / 60 / 60
    min = totalsec / 60 % 60
    time = (hour > 0) ? _INTL("{1}h {2}m", hour, min) : _INTL("{1}m", min)
    $PokemonGlobal.startTime = Time.now if !$PokemonGlobal.startTime
    starttime = _INTL("{1} {2}, {3}",
                      pbGetAbbrevMonthName($PokemonGlobal.startTime.mon),
                      $PokemonGlobal.startTime.day,
                      $PokemonGlobal.startTime.year)
    ox = CARD_ORIGIN_X
    oy = CARD_ORIGIN_Y
    textPositions = [
      [_INTL("Name:"), 122 - ox, 76 - oy, :left, baseColor, shadowColor],
      [$player.name, 250 - 40 - ox, 76 - oy, :left, baseColor, shadowColor],
      [_INTL("ID No.:"), 472 - ox, 76 - oy, :left, baseColor, shadowColor],
	  # Previously $player.public_id; if we're emulating the 3DS with the screen resolution I feel like we should also emulate the 3DS with its larger public ID
      [sprintf("%d", $player.id % 1000000), 666 - ox, 76 - oy, :right, baseColor, shadowColor],
      [_INTL("Money:"), 122 - ox, 136 - oy, :left, baseColor, shadowColor],
      [_INTL("${1}", $player.money.to_s_formatted), 272 - ox, 136 - oy, :left, baseColor, shadowColor],
      [_INTL("Pokédex:"), 122 - ox, 184 - oy, :left, baseColor, shadowColor],
      [sprintf("%d/%d", $player.pokedex.owned_count, $player.pokedex.seen_count), 366 - ox, 184 - oy, :left, baseColor, shadowColor],
      [_INTL("Play time:"), 122 - ox, 232 - oy, :left, baseColor, shadowColor],
      [time, 358 - ox, 232 - oy, :left, baseColor, shadowColor],
      [_INTL("Adventure started on:"), 122 - ox, 292 - oy, :left, baseColor, shadowColor],
      [starttime, 440 - ox, 292 - oy, :left, baseColor, shadowColor]
    ]
    pbDrawTextPositions(overlay, textPositions)
    tempTrainerSprite = IconSprite.new(0, 0, @viewport)
    tempTrainerSprite.setBitmap(GameData::TrainerType.player_front_sprite_filename($player.trainer_type))
    tempTrainerSprite.visible = false
    trainerBitmap = tempTrainerSprite.bitmap
    overlay.blt(554 - ox, 136 - oy, trainerBitmap, Rect.new(0, 0, trainerBitmap.width, trainerBitmap.height))
    tempTrainerSprite.dispose

    badgeY = 330 - oy
    badgeXPositions = [110, 154, 198, 242, 286, 330, 374, 418]
    region = @region # previously pbGetCurrentRegion(0); this allows the badge set to be button selected
    imagePositions = []
    8.times do |i|
      if $player.badges[i + (region * 8)]
        imagePositions.push(["Graphics/UI/Trainer Card/icon_badges", badgeXPositions[i] - ox, badgeY, i * 32, region * 32, 32, 32])
      end
    end
    pbDrawImagePositions(overlay, imagePositions)
  end

  def pbTrainerCard
    pbSEPlay("GUI trainer card open")
    loop do
      Graphics.update
      Input.update
      pbUpdate
      cancelClicked = @sprites["cancel"].click?
	  if Input.trigger?(Input::ACTION)
      closeCardFlip
      @page = (@page + 1) % 2 # There are 2 pages
      animateCardFlip
	  end
    @lastUse = 0 if !@lastUse
	  if Input.trigger?(Input::JUMPUP) && System.uptime - 1 > @lastUse
      @lastUse = System.uptime
      @region = (@region + 1) % 3 # There are 3 regions with badges
      # partial setupCard
      @sprites["card"].setBitmap(GRAPHICS_PATH + "card")
      pbSetSystemFont(@sprites["card"].bitmap)
      pbDrawTrainerCardFront
	  end
	  if Input.trigger?(Input::BACK) || cancelClicked
        pbPlayCloseMenuSE
        flashCancelButton
        closeCardFlip
        break
      end
    end
  end

  def flashCancelButton
    2.times do
      @sprites["cancel"].setBitmap(GRAPHICS_PATH + "cancel_p")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
      @sprites["cancel"].setBitmap(GRAPHICS_PATH + "cancel")
      Graphics.update
      Input.update
      pbUpdate
      2.times { Graphics.update }
    end
  end

  def closeCardFlip
    timer_start = System.uptime
    loop do
      @sprites["card"].zoom_x = lerp(1, 0, 0.3, timer_start, System.uptime)
      Graphics.update
      Input.update
      pbUpdate
      break if @sprites["card"].zoom_x <= 0
    end
    @sprites["card"].zoom_x = 0
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end
end

#===============================================================================
#
#===============================================================================
class PokemonTrainerCardScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbTrainerCard
    @scene.pbEndScene
  end
end