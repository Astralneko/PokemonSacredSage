#===============================================================================
# Main Module - PBMiniGames
#===============================================================================
module PBMiniGames
  FORCED_EXIT_SWITCH = 90
  INPUT_EXIT = Input::BACK
  
  SURVIVAL_TIME_RECORD_VARS = {
    1 => 37,  # ID 1 uses variable 37
    2 => 38   # ID 2 uses variable 38
    # Add more mappings as needed
  }

#=============================================================================
# DanceGame Class - Rhythm/Dance Minigame
#=============================================================================
  class DanceGame
    INFINITE_HIGH_SCORE_VAR = 36
#=============================================================================
# Method to get the survival time record variable based on ID
#=============================================================================

def calculate_bpm_speed(bpm)
  # Fórmula que mantém a jogabilidade original mas adapta ao BPM
  base_speed = (bpm.to_f / 120.0)  # 120 BPM = speed 1 (padrão)
  [base_speed, 0.5].max  # Garante no mínimo speed 0.5
end

#=============================================================================
    def survival_time_var
      sequence = @sequences[@game_id]
      SURVIVAL_TIME_RECORD_VARS[sequence[:survival_id]] || 37 # Default to variable 37 if not specified
    end


    #===========================================================================
    # Scene Methods (start/end)
    #===========================================================================
    def pbUpdate
      Graphics.update
      Input.update
    end

    def pbStartScene
      pbCreateSprites
      @sprites["background"].opacity = 0 if @sprites["background"]
      
      pbFadeInAndShow(@sprites) do 
        if @sprites["background"]
          @sprites["background"].opacity += 15 if @sprites["background"].opacity < 255
        end
        pbUpdate
      end
    end

    def pbEndScene
      pbFadeOutAndHide(@sprites) { pbUpdate }
      dispose_sprites
    end

    #===========================================================================
    # Reward and Analysis Methods
    #===========================================================================
    def pbShowRewardScene
      current_bgm = $game_system.getPlayingBGM
      
      reward_viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      reward_viewport.z = 99999
      reward_sprites = {}
      
      # Load background (bg_reward)
      bg_path = "Graphics/Minigame/bg_reward.png"
      if FileTest.exist?(bg_path)
        reward_sprites["background"] = Sprite.new(reward_viewport)
        reward_sprites["background"].bitmap = Bitmap.new(bg_path)
        reward_sprites["background"].z = 0
        reward_sprites["background"].opacity = 0
      else
        reward_sprites["background"] = Sprite.new(reward_viewport)
        reward_sprites["background"].bitmap = Bitmap.new(Graphics.width, Graphics.height)
        reward_sprites["background"].bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
        reward_sprites["background"].z = 0
        reward_sprites["background"].opacity = 0
      end
      
      # Background fade-in
      40.times do
        reward_sprites["background"].opacity += 6.375
        Graphics.update
        Input.update
        sleep(0.02)
      end

      # 1. Show only the analysis and wait for confirmation
      analysis_sprite = Sprite.new(reward_viewport)
      analysis_sprite.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      analysis_sprite.z = 10
      show_performance_analysis(analysis_sprite, reward_viewport)
      
      # Wait for analysis confirmation
      loop do
        Graphics.update
        Input.update
        break if Input.trigger?(Input::USE) || Input.trigger?(Input::BACK)
      end

      # 2. Show reward ON TOP of analysis (keeping both visible)
      give_reward(reward_sprites, reward_viewport, analysis_sprite)
      
      # 3. Fade-out background AND analysis TOGETHER
      40.times do
        reward_sprites["background"].opacity -= 6.375
        analysis_sprite.opacity -= 6.375 if analysis_sprite
        Graphics.update
        Input.update
        sleep(0.02)
      end
      
      # Cleanup
      reward_sprites.each_value { |sprite| sprite.dispose }
      analysis_sprite.dispose if analysis_sprite
      reward_viewport.dispose
      
      $game_system.bgm_play(current_bgm) if current_bgm
    end

    #===========================================================================
    # Initialization and Configuration
    #===========================================================================
	def initialize(game_id, bpm = 120)
        @game_id = game_id
       @bpm = bpm.to_f
       @speed = calculate_bpm_speed(bpm)
       @arrows = {
        up: "Graphics/Minigame/arrow_0",
        down: "Graphics/Minigame/arrow_1",
        left: "Graphics/Minigame/arrow_2", 
        right: "Graphics/Minigame/arrow_3"
      }
      @sequences = {
        1 => { 
          name: "Sequence 1",
          moves: [:up, :up, :up, :up, :left, :down, :right, :left, :left, :down],
          bgm: "Audio/BGM/Gym", 
          reward: {
            50 => { type: :item, id: :POTION, quantity: 1 },
            75 => { type: :item, id: :POTION, quantity: 2 },
            90 => { type: :item, id: :SUPERPOTION, quantity: 1 }
          },
          lives: 5
        },
        2 => {
          name: "Sequence 2",
          moves: [:down, :right, :up, :down, :left],
          bgm: "Audio/BGM/Gym",
          reward: {
          },
          lives: 2
        },
        3 => {
          name: "Sequence 3",
          moves: [:down, :right, :up, :down, :left, :up, :left, :down, :right, :left, :left, :down],
          bgm: "Audio/BGM/Gym",
          reward: {
            60 => { type: :item, id: :RARECANDY, quantity: 1 },
            80 => { type: :item, id: :RARECANDY, quantity: 2 },
            95 => { type: :item, id: :PPUP, quantity: 1 }
          }
        },
        4 => {
          name: "Infinite Mode",
          moves: [], # Infinite mode generates its own moves
          bgm: "Audio/BGM/Gym",
          reward: {}, # No rewards or define as desired
          mode: :infinite
        },
        5 => {
          name: "Survival Mode",
          moves: [], # Survival mode generates random moves
          bgm: "Audio/BGM/Gym",
          reward: {
            10 => { type: :item, id: :POTION, quantity: 1 },      # 0-29s
            25 => { type: :item, id: :POKEBALL, quantity: 1 },    # 30s-1:59min
            50 => { type: :item, id: :SUPERPOTION, quantity: 1 }, # 2-3:59min
            75 => { type: :item, id: :HYPERPOTION, quantity: 1 }, # 4-5:59min
            90 => { type: :item, id: :MAXPOTION, quantity: 1 },   # 6-9:59min
            100 => { type: :item, id: :FULLRESTORE, quantity: 1 } # 10+min
          },
          mode: :survival,
          survival_id: 1, # Survival mode ID
          lives: 6
          },
        6 => {
          name: "Survival Mode 2",
          moves: [], # Survival mode generates random moves
          bgm: "Audio/BGM/Gym",
          reward: {
            10 => { type: :item, id: :POTION, quantity: 1 },      # 0-29s
            25 => { type: :item, id: :POKEBALL, quantity: 1 },    # 30s-1:59min
            50 => { type: :item, id: :SUPERPOTION, quantity: 1 }, # 2-3:59min
            75 => { type: :item, id: :HYPERPOTION, quantity: 1 }, # 4-5:59min
            90 => { type: :item, id: :MAXPOTION, quantity: 1 },   # 6-9:59min
            100 => { type: :item, id: :FULLRESTORE, quantity: 1 } # 10+min
          },
          mode: :survival,
          survival_id: 2, # Different ID for another mode
          lives: 4
          }
         }
      @current_move = 0
      @correct_moves = 0
      @error_moves = 0
      @score = 0
      @combo = 0
      @max_combo = 0
      @score_multiplier = 1
      @lives = @sequences[game_id][:lives] || 0
      @game_mode = @sequences[game_id][:mode] || :normal
      @infinite_sequence = [:up, :down, :left, :right].shuffle

      @sprites = {}
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
    end

    #===========================================================================
    # Game Control Methods
    #===========================================================================
    def self.pbDanceGame(game_id, bpm = 120)
  if valid_game_id?(game_id)
    pbFadeOutIn {
      scene = new(game_id, bpm)  # Passa bpm como parâmetro
      scene.start_game
    }
  else
    raise "Minigame not found for ID #{game_id}."
  end
end

    def self.valid_game_id?(game_id)
      new(game_id).valid_game_id?
    end

    def valid_game_id?
      @sequences.key?(@game_id)
    end

    def start_game
      $game_system.bgm_memorize
      pbStartScene
      Audio.bgm_stop

      # Initialize variables
      @current_move = 0
      @correct_moves = 0
      @error_moves = 0
      @score = 0
      @combo = 0
      @max_combo = 0
      @score_multiplier = 1
      @start_time = Time.now
      @lives = @sequences[@game_id][:lives] || 0 if @game_mode == :survival
      @forced_exit = false
      @show_analysis = false

      pbShowSequenceName(@sequences[@game_id][:name])
      pbShowCountdown
      
      bgm_path = @sequences[@game_id][:bgm]
      Audio.bgm_play(bgm_path, 50) if bgm_path

      pbShowTarget
      pbShowLives if @lives > 0
      pbShowScore

      case @game_mode
      when :infinite
        run_infinite_mode
      when :survival
        run_survival_mode
      else
        run_normal_mode
      end
      
      # Only calculate stats if not forced exit
      unless @forced_exit
        total_moves = @correct_moves + @error_moves
        @accuracy = total_moves > 0 ? (@correct_moves.to_f / total_moves * 100).to_i : 0
        @play_time = (Time.now - @start_time).to_i
        $game_variables[35] = @accuracy
        $game_switches[FORCED_EXIT_SWITCH] = false
        
        # Update time record if longer in survival mode
        if @game_mode == :survival
          current_var = survival_time_var
          if @play_time > $game_variables[current_var]
            $game_variables[current_var] = @play_time
          end
        end
      else
        $game_variables[35] = -1
        $game_switches[FORCED_EXIT_SWITCH] = true
      end

      # Update high score if higher in infinite mode
      if @game_mode == :infinite && @score > $game_variables[INFINITE_HIGH_SCORE_VAR] && @score > 0
        $game_variables[INFINITE_HIGH_SCORE_VAR] = @score
      end
      
      $game_system.bgm_restore
      pbEndScene
      
      # Show reward/analysis scene if not forced exit
      pbShowRewardScene unless @forced_exit
    end

    def run_normal_mode
      @sequences[@game_id][:moves].each do |move|
        break if handle_move(move) == :game_over
      end
    end

    def run_infinite_mode
      loop do
        move = @infinite_sequence.sample
        result = handle_move(move)
        
        if result == :exit
          @show_analysis = true
          break
        end
        
        break if result == :game_over
        @infinite_sequence.shuffle! if rand(10) == 0
      end
    end

    def run_survival_mode
      loop do
        move = @infinite_sequence.sample
        break if handle_move(move) == :game_over
      end
    end

    #===========================================================================
    # Movement and Input Logic
    #===========================================================================
    def handle_move(move)
      draw_arrow(move)
      result = handle_input(move)
      
      case result
      when :correct
        @correct_moves += 1
        @combo += 1
        @max_combo = @combo if @combo > @max_combo
        @score_multiplier = 1 + (@combo / 5)
        @score += 100 * @score_multiplier
        pbPlayCorrectSE
        pbShowScore
        @sprites["arrow"].opacity = 0
        
      when :error
        @error_moves += 1
        @combo = 0
        @score_multiplier = 1
        pbPlayErrorSE
        pbFlashArrow(3)
        if @lives > 0
          @lives -= 1
          pbShowLives
          return :game_over if @lives <= 0
        end
        
      when :exit
        return :game_over
      end
      
      @current_move += 1
    end

    #===========================================================================
    # Visual Effects Methods
    #===========================================================================
    def pbSmoothFadeToBlack
      overlay = Sprite.new(@viewport)
      overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      overlay.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      overlay.opacity = 0

      20.times do
        overlay.opacity += 12
        Graphics.update
        Input.update
        sleep(0.03)
      end
      overlay.dispose
    end

    def pbSmoothFadeInFromBlack
      overlay = Sprite.new(@viewport)
      overlay.bitmap = Bitmap.new(Graphics.width, Graphics.height)
      overlay.bitmap.fill_rect(0, 0, Graphics.width, Graphics.height, Color.new(0, 0, 0))
      overlay.opacity = 255

      20.times do
        overlay.opacity -= 12
        Graphics.update
        Input.update
        sleep(0.03)
      end
      overlay.dispose
    end

    def pbFadeInBackground
      background_sprite = Sprite.new(@viewport)
      background_sprite.bitmap = Bitmap.new("Graphics/Minigame/bg_main.png")
      background_sprite.x = 0
      background_sprite.y = 0
      background_sprite.opacity = 0

      15.times do
        background_sprite.opacity += 17
        Graphics.update
        Input.update
        sleep(0.05)
      end
    end

    def pbShowSequenceName(name)
      text_sprite = Sprite.new(@viewport)
      text_bitmap = Bitmap.new(Graphics.width, Graphics.height)
      text_sprite.bitmap = text_bitmap
      text_sprite.x = 0
      text_sprite.y = 0
      text_sprite.z = 9999
      text_sprite.opacity = 0  # Starts invisible

      # Text settings
      text_bitmap.font.size = 48
      shadow_color = Color.new(0, 0, 0, 180)
      text_color = Color.new(255, 255, 255)
      shadow_offset = 2

      # Centered position
      text_height = text_bitmap.text_size(name).height
      y_position = (Graphics.height - text_height) / 2 - 20

      # Draw with shadow
      text_bitmap.font.color = shadow_color
      text_bitmap.draw_text(shadow_offset, y_position + shadow_offset, 
                          Graphics.width, text_height, name, 1)
      text_bitmap.font.color = text_color
      text_bitmap.draw_text(0, y_position, Graphics.width, text_height, name, 1)

      # Fade-in (0.32 seconds)
      16.times do
        text_sprite.opacity += 16
        Graphics.update
        Input.update
        sleep(0.02)
      end

      # Display time (1.5 seconds - 0.32 from fade-in = 1.18 seconds)
      sleep(1.18)

      # Optional fade-out (uncomment if desired)
       16.times do
         text_sprite.opacity -= 16
         Graphics.update
         Input.update
         sleep(0.02)
      end

      text_sprite.dispose
    end

    def pbShowCountdown
      Audio.bgm_stop
      countdown_sprites = [
        "Graphics/Minigame/start_1.png",
        "Graphics/Minigame/start_2.png",
        "Graphics/Minigame/start_3.png"
      ]
      countdown_sound = "Audio/SE/Count"

      countdown_sprites.each_with_index do |sprite_path, index|
        countdown_sprite = Sprite.new(@viewport)
        countdown_sprite.bitmap = Bitmap.new(sprite_path)
        countdown_sprite.x = (Graphics.width - countdown_sprite.bitmap.width) / 2
        countdown_sprite.y = (Graphics.height - countdown_sprite.bitmap.height) / 2
        countdown_sprite.opacity = 255

        # Play corresponding sound
        Audio.se_play(countdown_sound, 80, 150) if FileTest.exist?(countdown_sound + ".wav")

        Graphics.update
        Input.update
        sleep(1)

        countdown_sprite.dispose
      end
    end

    def pbShowTarget
      target_path = "Graphics/Minigame/target.png"
      if FileTest.exist?(target_path)
        target_bitmap = Bitmap.new(target_path)
        @sprites["target"] = Sprite.new(@viewport)
        @sprites["target"].bitmap = target_bitmap
        @sprites["target"].x = (Graphics.width - target_bitmap.width) / 2
        @sprites["target"].y = (Graphics.height - target_bitmap.height) / 2
        @sprites["target"].opacity = 255
      else
        pbMessage("Error: Target image not found.")
        dispose_sprites
      end
    end

    def pbShowLives
      heart_image = "Graphics/Minigame/heart.png"
      return unless FileTest.exist?(heart_image)
      
      @sprites.each_key do |key|
        @sprites[key].dispose if key.to_s.start_with?("heart_")
      end
      @sprites.delete_if { |key| key.to_s.start_with?("heart_") }
      
      heart_bitmap = Bitmap.new(heart_image)
      (0...@lives).each do |i|
        @sprites["heart_#{i}"] = Sprite.new(@viewport)
        @sprites["heart_#{i}"].bitmap = heart_bitmap
        @sprites["heart_#{i}"].x = 14 + (i * (heart_bitmap.width + 5))
        @sprites["heart_#{i}"].y = 10
      end
    end

    def pbShowScore
      if @sprites["score"]
        @sprites["score"].bitmap.clear
      else
        @sprites["score"] = Sprite.new(@viewport)
        @sprites["score"].bitmap = Bitmap.new(200, 60)
        @sprites["score"].x = Graphics.width - 180  # Original X position
        @sprites["score"].y = 40                   # Original Y position
        @sprites["score"].bitmap.font.size = 20
      end

      # Color and shadow settings
      shadow_color = Color.new(0, 0, 0, 150)  # Semi-transparent black shadow
      text_color = Color.new(255, 255, 255)   # White text
      shadow_offset = 1                       # More subtle offset

      # Draw score with shadow
      @sprites["score"].bitmap.font.color = shadow_color
      @sprites["score"].bitmap.draw_text(0 + shadow_offset, 0 + shadow_offset, 200, 30, "Score: #{@score}", 0)
      @sprites["score"].bitmap.font.color = text_color
      @sprites["score"].bitmap.draw_text(0, 0, 200, 30, "Score: #{@score}", 0)

      # Draw combo with shadow
      @sprites["score"].bitmap.font.color = shadow_color
      @sprites["score"].bitmap.draw_text(0 + shadow_offset, 30 + shadow_offset, 200, 30, "Combo: #{@combo}x#{@score_multiplier}", 0)
      @sprites["score"].bitmap.font.color = text_color
      @sprites["score"].bitmap.draw_text(0, 30, 200, 30, "Combo: #{@combo}x#{@score_multiplier}", 0)
    end

    def show_performance_analysis(analysis_sprite, viewport)
      text_bitmap = analysis_sprite.bitmap
      text_bitmap.clear
      
      # Defined colors
      shadow_color = Color.new(80, 80, 80, 180)  # Semi-transparent gray
      text_color = Color.new(255, 255, 255)       # White
      
      # Font settings
      text_bitmap.font.size = 28
      text_bitmap.font.bold = true
      
      x = 50
      y = 50
      line_height = 32
      shadow_offset = 2  # Shadow offset in pixels

      # Helper method to draw text with shadow
      def draw_text_with_shadow(bitmap, x, y, width, height, text, shadow_x, shadow_y, shadow_color, text_color)
        # Draw shadow
        bitmap.font.color = shadow_color
        bitmap.draw_text(x + shadow_x, y + shadow_y, width, height, text)
        
        # Draw main text
        bitmap.font.color = text_color
        bitmap.draw_text(x, y, width, height, text)
      end

      # Title
      draw_text_with_shadow(text_bitmap, x, y, 300, line_height, "Performance Analysis:", 
                         shadow_offset, shadow_offset, shadow_color, text_color)
      y += line_height * 2
      
      # Analysis items (now with shadow)
      [
        "Accuracy: #{@accuracy}%",
        "Correct Moves: #{@correct_moves}",
        "Wrong Moves: #{@error_moves}",
        "Max Combo: #{@max_combo}",
        "Final Score: #{@score}",
        "Time: #{@play_time}"
      ].each do |text|
        draw_text_with_shadow(text_bitmap, x, y, 300, line_height, text,
                             shadow_offset, shadow_offset, shadow_color, text_color)
        y += line_height
      end
      
      y += line_height
      
      # Final message
      final_message = if @accuracy >= 90
        "Perfect! You're a dance master!"
      elsif @accuracy >= 70
        "Great job! Keep practicing!"
      else
        "Good try! You'll do better next time!"
      end
      
      draw_text_with_shadow(text_bitmap, x, y, 300, line_height, final_message,
                           shadow_offset, shadow_offset, shadow_color, text_color)
      
      Graphics.update
      Input.update
    end

    #===========================================================================
    # Reward Methods
    #===========================================================================
    def give_reward(reward_sprites, viewport, analysis_sprite)
      reward_threshold = [calculate_survival_reward, 10].max 
      # Survival mode uses play time instead of accuracy
      if @game_mode == :survival
        reward_threshold = calculate_survival_reward
      else
        reward_threshold = @sequences[@game_id][:reward]&.keys&.sort&.reverse&.find { |t| @accuracy >= t }
      end
      
      return unless reward_threshold && reward_threshold > 0  # Added >0 check
      
      reward = @sequences[@game_id][:reward][reward_threshold]
      return unless reward

      case reward[:type]
      when :item
        item = GameData::Item.get(reward[:id])
        $bag.add(item, reward[:quantity])
        item_name = item.name
        if reward[:quantity] > 1
          pbMessage(_INTL("You received {1} {2}s!", reward[:quantity], item_name))
        else
          pbMessage(_INTL("You received {1} {2}!", reward[:quantity], item_name))
        end
      when :money
        $player.money += reward[:amount]
        pbMessage(_INTL("You received ${1}!", reward[:amount]))
      end
    end

    private

    def calculate_survival_reward
      seconds = @play_time
      case seconds
      when 0..29   then 10    # 0-29 seconds - basic participation
      when 30..119 then 25    # 30s-1:59min - minimal effort
      when 120..239 then 50   # 2-3:59min
      when 240..359 then 75   # 4-5:59min 
      when 360..599 then 90   # 6-9:59min
      else 100                # 10+min
      end
    end

    #===========================================================================
    # Arrow Control Methods
    #===========================================================================
    def draw_arrow(direction)
      arrow_path = "#{@arrows[direction]}.png"
      if FileTest.exist?(arrow_path)
        arrow_bitmap = Bitmap.new(arrow_path)
        @sprites["arrow"] ||= Sprite.new(@viewport)
        @sprites["arrow"].bitmap = arrow_bitmap
        @sprites["arrow"].x = (Graphics.width - arrow_bitmap.width) / 2
        @sprites["arrow"].y = -arrow_bitmap.height
        @sprites["arrow"].opacity = 255
      else
        pbMessage("Error: Arrow image not found.")
        dispose_sprites
      end
    end

    def handle_input(expected_move)
      max_time_allowed = 1.0 / @speed
      frame_time = 1.0 / Graphics.frame_rate
      move_speed = (Graphics.height + @sprites["arrow"].bitmap.height) / (max_time_allowed / frame_time)
      move_speed *= 0.4
      input_map = {
        Input::UP => :up,
        Input::DOWN => :down,
        Input::LEFT => :left,
        Input::RIGHT => :right
      }

      loop do
        Graphics.update
        Input.update
        
        # Modified for infinite mode - BACK shows analysis instead of exiting
        if Input.trigger?(INPUT_EXIT)
          if @game_mode == :infinite
            pbPlayDecisionSE
            return :exit
          else
            pbPlayDecisionSE
            @forced_exit = true
            $game_variables[35] = -1 # Reset variable when exiting with BACK
            return :exit
          end
        end
        
        unless @sprites["arrow"] && @sprites["arrow"].bitmap
          return :error 
        end

        @sprites["arrow"].y += move_speed
        arrow_rect = Rect.new(@sprites["arrow"].x, @sprites["arrow"].y, @sprites["arrow"].bitmap.width, @sprites["arrow"].bitmap.height)
        target_rect = Rect.new(@sprites["target"].x, @sprites["target"].y, @sprites["target"].bitmap.width, @sprites["target"].bitmap.height)

        if arrow_rect.y > Graphics.height
          @sprites["arrow"].opacity = 255
          return :error
        end

        if rects_collide?(arrow_rect, target_rect)
          input_map.each do |key, move|
            if Input.trigger?(key)
              if expected_move == move
                return :correct
              else
                return :error
              end
            end
          end
        end
        if @sprites["arrow"].y > @sprites["target"].y + @sprites["target"].bitmap.height
          return :error
        end
      end
    end

    #===========================================================================
    # Sprite and Viewport Methods
    #===========================================================================
    def pbCreateSprites
      bg_path = "Graphics/Minigame/bg_main.png"
      if FileTest.exist?(bg_path)
        @sprites["background"] = Sprite.new(@viewport)
        @sprites["background"].bitmap = Bitmap.new(bg_path)
        @sprites["background"].z = 0
        @sprites["background"].opacity = 0
      else
        pbMessage("Error: Background image not found at #{bg_path}")
        dispose_sprites
        return
      end

      @arrows.each do |key, path|
        filename = "#{path}.png"
        if FileTest.exist?(filename)
          @sprites[key.to_s] = Sprite.new(@viewport)
          @sprites[key.to_s].bitmap = Bitmap.new(filename)
          @sprites[key.to_s].visible = false
          @sprites[key.to_s].z = 10
        else
          pbMessage("Error: Arrow image not found at #{filename}")
          dispose_sprites
          return
        end
      end

      target_path = "Graphics/Minigame/target.png"
      if FileTest.exist?(target_path)
        @sprites["target"] = Sprite.new(@viewport)
        @sprites["target"].bitmap = Bitmap.new(target_path)
        @sprites["target"].x = (Graphics.width - @sprites["target"].bitmap.width) / 2
        @sprites["target"].y = (Graphics.height - @sprites["target"].bitmap.height) / 2
        @sprites["target"].z = 5
        @sprites["target"].opacity = 0
      else
        pbMessage("Error: Target image not found at #{target_path}")
        dispose_sprites
      end
    end

    def dispose_sprites
      @sprites.each_value do |sprite|
        sprite.dispose if sprite
      end
      @viewport.dispose
    end

    def rects_collide?(rect1, rect2)
      !(rect1.x > rect2.x + rect2.width ||
        rect1.x + rect1.width < rect2.x ||
        rect1.y > rect2.y + rect2.height ||
        rect1.y + rect1.height < rect2.y)
    end

    #===========================================================================
    # Audio Methods
    #===========================================================================
    def pbPlayCorrectSE
      Audio.se_play("Audio/SE/Correct", 40, 100)
    end

    def pbPlayErrorSE
      Audio.se_play("Audio/SE/Error", 40, 100)
    end

    def pbFlashArrow(times)
      times.times do
        @sprites["arrow"].opacity = 128
        Graphics.update
        Input.update
        sleep(0.1)
        @sprites["arrow"].opacity = 255
        Graphics.update
        Input.update
        sleep(0.1)
      end
    end
  end
end

#===============================================================================
# Global Methods
#===============================================================================
def pbShowInfiniteScore
  high_score = $game_variables[PBMiniGames::DanceGame::INFINITE_HIGH_SCORE_VAR]
  pbMessage(_INTL("Your highest score in Infinite Mode is: {1}", high_score))
end

def pbSurvivalTimeRecord(survival_id = 1)
  time_var = PBMiniGames::SURVIVAL_TIME_RECORD_VARS[survival_id] || 37
  record_seconds = $game_variables[time_var]
  
  if record_seconds <= 0
    pbMessage(_INTL("No survival time record yet for mode #{survival_id}."))
  else
    # Convert seconds to minutes:seconds format
    minutes = record_seconds / 60
    seconds = record_seconds % 60
    pbMessage(_INTL("Your best survival time in mode #{survival_id} is: {1}:{2}", 
               minutes.to_s.rjust(2, '0'), 
               seconds.to_s.rjust(2, '0')))
  end
end

def pbDanceGame(game_id, bpm = 120)
  if PBMiniGames::DanceGame.valid_game_id?(game_id)
    PBMiniGames::DanceGame.pbDanceGame(game_id, bpm)
  else
    raise "Minigame not found for ID #{game_id}."
  end
end