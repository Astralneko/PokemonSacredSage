#===============================================================================
	# Custom Weather Plugin - Starstorm Weather
	# Multi-coloured animated star particles fall diagonally across the screen,
	# cycling through starburst animation frames exactly as AdvancedWeather does.
	# Each star cycles through: tiny dot → cross → diamond → full cross → shrink
	# in 6 colour families (gold, green, blue, purple, red, orange).
#===============================================================================

STARSTORM_SPRITE_COUNT = 140

class Spriteset_Map
	def starstorm_make_bitmaps
		@starstorm_bitmaps = []
		
		# Colour families — each has 3 shades: outer/mid/bright-core
		# Matching AdvancedWeather's starburst palette
		families = [
			# Gold/yellow
			[Color.new(219, 191,  95), Color.new(233, 210, 142), Color.new(242, 229, 190)],
			# Green
			[Color.new( 44, 166,   0), Color.new( 88, 221,  89), Color.new(205, 246, 205)],
			# Blue
			[Color.new(  5,  88, 168), Color.new(102, 181, 221), Color.new(189, 225, 242)],
			# Purple
			[Color.new( 71,   0, 222), Color.new(155, 107, 255), Color.new(216, 197, 255)],
			# Red/pink
			[Color.new(178,  15,  56), Color.new(196,  55,  84), Color.new(241, 185, 187)],
			# Orange
			[Color.new(222, 124,   0), Color.new(255, 180,  85), Color.new(255, 220, 177)],
		]
		
		# For each colour family, build 6 animation frames:
			# Frame 0: single dot (1px centre)
			# Frame 1: tiny cross (3px arms)
			# Frame 2: diagonal sparkle (corner dots)
			# Frame 3: plus cross (5px arms, thicker)
			# Frame 4: full diamond cross (7px, all arms + diagonals)
		# Frame 5: back to tiny cross (shrinking)
		families.each do |outer, mid, bright|
			# Frame 0 — dot (3x3 soft centre)
			bm = Bitmap.new(16, 16)
			bm.fill_rect(7, 7, 2, 2, mid)
			bm.set_pixel(7,  7, bright)
			bm.set_pixel(8,  7, bright)
			bm.set_pixel(7,  8, bright)
			bm.set_pixel(8,  8, bright)
			@starstorm_bitmaps.push(bm)
			
			# Frame 1 — small cross (5px arms)
			bm = Bitmap.new(16, 16)
			bm.fill_rect(7, 4, 2, 8, mid)    # vertical arm
			bm.fill_rect(4, 7, 8, 2, mid)    # horizontal arm
			bm.fill_rect(7, 6, 2, 4, bright) # bright inner vertical
			bm.fill_rect(6, 7, 4, 2, bright) # bright inner horizontal
			@starstorm_bitmaps.push(bm)
			
			# Frame 2 — diagonal sparkle (X shape)
			bm = Bitmap.new(16, 16)
			# Top-left arm
			bm.set_pixel(2,  2,  outer); bm.set_pixel(3,  3,  outer)
			bm.set_pixel(4,  4,  mid);   bm.set_pixel(5,  5,  mid)
			# Top-right arm
			bm.set_pixel(13, 2,  outer); bm.set_pixel(12, 3,  outer)
			bm.set_pixel(11, 4,  mid);   bm.set_pixel(10, 5,  mid)
			# Centre
			bm.fill_rect(6, 6, 4, 4, mid)
			bm.fill_rect(7, 7, 2, 2, bright)
			# Bottom-left arm
			bm.set_pixel(5,  10, mid);   bm.set_pixel(4,  11, mid)
			bm.set_pixel(3,  12, outer); bm.set_pixel(2,  13, outer)
			# Bottom-right arm
			bm.set_pixel(10, 10, mid);   bm.set_pixel(11, 11, mid)
			bm.set_pixel(12, 12, outer); bm.set_pixel(13, 13, outer)
			@starstorm_bitmaps.push(bm)
			
			# Frame 3 — plus cross (longer arms)
			bm = Bitmap.new(16, 16)
			bm.fill_rect(7, 1, 2, 14, outer)  # vertical outer arm
			bm.fill_rect(1, 7, 14, 2, outer)  # horizontal outer arm
			bm.fill_rect(7, 3, 2, 10, mid)    # vertical mid
			bm.fill_rect(3, 7, 10, 2, mid)    # horizontal mid
			bm.fill_rect(7, 5, 2, 6,  bright) # vertical bright core
			bm.fill_rect(5, 7, 6,  2, bright) # horizontal bright core
			@starstorm_bitmaps.push(bm)
			
			# Frame 4 — full star (plus + diagonals)
			bm = Bitmap.new(16, 16)
			# Outer plus
			bm.fill_rect(7, 1, 2, 14, outer)
			bm.fill_rect(1, 7, 14, 2, outer)
			# Diagonal arms — outer
			bm.set_pixel(2,  2,  outer); bm.set_pixel(3,  3,  outer)
			bm.set_pixel(13, 2,  outer); bm.set_pixel(12, 3,  outer)
			bm.set_pixel(2,  13, outer); bm.set_pixel(3,  12, outer)
			bm.set_pixel(13, 13, outer); bm.set_pixel(12, 12, outer)
			# Diagonal arms — mid
			bm.set_pixel(4,  4,  mid);   bm.set_pixel(5,  5,  mid)
			bm.set_pixel(11, 4,  mid);   bm.set_pixel(10, 5,  mid)
			bm.set_pixel(4,  11, mid);   bm.set_pixel(5,  10, mid)
			bm.set_pixel(11, 11, mid);   bm.set_pixel(10, 10, mid)
			# Mid plus
			bm.fill_rect(7, 3, 2, 10, mid)
			bm.fill_rect(3, 7, 10,  2, mid)
			# Bright core
			bm.fill_rect(7, 5, 2, 6, bright)
			bm.fill_rect(5, 7, 6, 2, bright)
			bm.fill_rect(7, 7, 2, 2, bright)
			@starstorm_bitmaps.push(bm)
			
			# Frame 5 — back to small cross (shrinking, same as frame 1)
			bm = Bitmap.new(16, 16)
			bm.fill_rect(7, 4, 2, 8, mid)
			bm.fill_rect(4, 7, 8, 2, mid)
			bm.fill_rect(7, 6, 2, 4, bright)
			bm.fill_rect(6, 7, 4, 2, bright)
			@starstorm_bitmaps.push(bm)
		end
		
		# Total: 6 families × 6 frames = 36 bitmaps
		@starstorm_frames_per_family = 6
		@starstorm_family_count      = families.size
	end
	
	def starstorm_setup_layer
		@starstorm_viewport   = Viewport.new(0, 0, Graphics.width, Graphics.height)
		@starstorm_viewport.z = 200
		
		STARSTORM_SPRITE_COUNT.times do
			sprite         = Sprite.new(@starstorm_viewport)
			sprite.z       = 1000
			# Pick a random colour family, start at frame 0
			family       = rand(@starstorm_family_count)
			frame        = rand(@starstorm_frames_per_family)
			bm_idx       = family * @starstorm_frames_per_family + frame
			sprite.bitmap  = @starstorm_bitmaps[bm_idx]
			sprite.x       = rand(Graphics.width + 120) - 60
			sprite.y       = rand(Graphics.height)       # pre-scattered
			sprite.opacity = rand(160) + 60
			
			# [family, current_frame, frame_countdown, x_speed, y_speed]
			x_spd = rand(3) + 1   # 1–3 px left per frame
			y_spd = rand(4) + 5   # 5–8 px down per frame (diagonal rain)
			@starstorm_info.push([family, frame, rand(15), x_spd, y_spd])
			@starstorm_sprites.push(sprite)
		end
		
		@starstorm_active = true
	end
	
	def starstorm_update_sprites
		@starstorm_sprites.each_with_index do |sprite, i|
			family, frame, countdown, x_spd, y_spd = @starstorm_info[i]
			
			# Move diagonally — leftward and downward like StarburstRain
			sprite.x -= x_spd
			sprite.y += y_spd
			
			# Cycle through animation frames every 15 ticks (matching AdvancedWeather)
			countdown -= 1
			if countdown <= 0
				frame     = (frame + 1) % @starstorm_frames_per_family
				bm_idx    = family * @starstorm_frames_per_family + frame
				sprite.bitmap = @starstorm_bitmaps[bm_idx]
				countdown = 15
			end
			
			sprite.opacity -= 1
			
			@starstorm_info[i] = [family, frame, countdown, x_spd, y_spd]
			
			# Respawn above/right when faded or off screen
			if sprite.opacity <= 0 || sprite.y > Graphics.height + 8 || sprite.x < -8
				new_family   = rand(@starstorm_family_count)
				new_frame    = 0
				sprite.bitmap = @starstorm_bitmaps[new_family * @starstorm_frames_per_family]
				sprite.opacity = rand(140) + 80
				# Spawn off the right edge or top
				if rand(2) == 0
					sprite.x = rand(Graphics.width + 60)
					sprite.y = -sprite.bitmap.height - rand(20)
					else
					sprite.x = Graphics.width + rand(60)
					sprite.y = rand(Graphics.height / 2)
				end
				@starstorm_info[i] = [new_family, new_frame, 15, rand(3) + 1, rand(4) + 5]
			end
		end
	end
	
	def starstorm_clear_layer
		@starstorm_sprites.each { |s| s.dispose }
		@starstorm_sprites.clear
		@starstorm_info.clear
		@starstorm_viewport.dispose if @starstorm_viewport
		@starstorm_viewport = nil
		@starstorm_active   = false
	end
end

CustomWeather::SpritesetHandlers.register(:Starstorm) do |spriteset|
	spriteset.instance_eval do
		unless @starstorm_bitmaps
			@starstorm_bitmaps           = []
			@starstorm_sprites           = []
			@starstorm_info              = []
			@starstorm_frames_per_family = 6
			@starstorm_family_count      = 6
			@starstorm_viewport          = nil
			@starstorm_active            = false
			starstorm_make_bitmaps
		end
		if $game_screen.weather_type == :Starstorm
			starstorm_setup_layer unless @starstorm_active
			starstorm_update_sprites
			elsif @starstorm_active
			starstorm_clear_layer
		end
	end
end

CustomWeather::SpritesetHandlers.register_dispose(:Starstorm) do |spriteset|
	spriteset.instance_eval do
		starstorm_clear_layer if @starstorm_active
		if @starstorm_bitmaps
			@starstorm_bitmaps.each { |bm| bm.dispose }
			@starstorm_bitmaps.clear
		end
	end
end

#===============================================================================
	# Register Overworld & Battle Weather
#===============================================================================
CustomWeather.register_weather(
	{ :id => :Starstorm, :id_number => 13, :category => :None, :graphics => [],
		:tone_proc => proc { |strength|
			# Subtle warm-cool shimmer — slight violet tint
			Tone.new(strength / 12, -strength / 14, strength / 10, 0)
		}
	},
	{ :id => :Starstorm, :name => _INTL("Starstorm"), :animation => "Starstorm" }
)

CustomWeather::Handlers::StartMessage.add(:Starstorm,
	proc { |weather, battle| next _INTL("Stars fell from the sky!") })
CustomWeather::Handlers::ContinueMessage.add(:Starstorm,
	proc { |weather, battle| next _INTL("Stars continue falling from above!") })
CustomWeather::Handlers::EndMessage.add(:Starstorm,
	proc { |weather, battle| next _INTL("The stars stopped falling.") })
# Currently, there is no EOR damage from Starstorm, but this holds it just in case
CustomWeather::Handlers::DamageImmunity.add(:Starstorm,
	proc { |weather, battler|
		next true if battler.pbHasType?(:CELESTIAL)
		next true if battler.pbHasType?(:ELECTRIC)
		next true if battler.hasActiveAbility?([:OVERCOAT, :IMMUNITY])
		next true if battler.hasActiveItem?(:SAFETYGOGGLES)
		next false
	})
	# Celestial and Electric deal extra damage. Steel and Glitch deal less damage.
	CustomWeather::Handlers::TypeBoost.add(:Starstorm,
		proc { |weather, move_type, user, target|
			next 4/3 if move_type == :CELESTIAL
			next 4/3 if move_type == :ELECTRIC
			next 2/3 if move_type == :STEEL
			next 2/3 if move_type == :GLITCH
			next 1.0
		})
				