class AstralnekoTemp
    # Player animations - stores the last direction the player was holding; everything else can be determined algorithmically
	attr_accessor :lastPlayerDirection
	
	def initialize
		@lastPlayerDirection = 2
	end
	
	def setLastPlayerDir(dir)
		@lastPlayerDirection = dir
    end
end
$Astralneko_Temp = AstralnekoTemp.new

class AstralnekoStorage
	# Time overrides
	attr_accessor :overrideTime
	attr_accessor :timeToOverride
	
	def initialize
		@overrideTime = false
		@timeToOverride = 0
	end
	
	def timeOverride?
		return @overrideTime
	end
	
	def setTimeOverride(time)
		@overrideTime = true
		@timeToOverride = time
		PBDayNight.force_tone_update
	end
	
	def removeTimeOverride
		@overrideTime = false
		PBDayNight.force_tone_update
	end
end

# Saves the AstralnekoStorage global variable.
SaveData.register(:astralneko_storage) do
	load_in_bootup
    ensure_class :AstralnekoStorage
    save_value { $Astralneko_Storage }
    load_value { |value| $Astralneko_Storage = value }
    new_game_value { AstralnekoStorage.new }
end

alias pbGetTimeNow_astralneko pbGetTimeNow
def pbGetTimeNow
	if $Astralneko_Storage && $Astralneko_Storage.timeOverride?
		return $Astralneko_Storage.timeToOverride
	else
		return pbGetTimeNow_astralneko
	end
end

module PBDayNight
	def self.force_tone_update
		@dayNightToneLastUpdate = nil
	end
end

def anTimeOverride(*args)
    if args.size == 2 || args.size == 3
		$Astralneko_Storage.setTimeOverride(Time.local(Time.now.year,Time.now.month,Time.now.day,args[0],args[1]))
	else
		if args[0].is_a?(Time)
			$Astralneko_Storage.setTimeOverride(args[0])
		else
		    $Astralneko_Storage.setTimeOverride(Time.local(Time.now.year,Time.now.month,Time.now.day,args[0],0,0))
		end
	end
end

def anRemoveTimeOverride
	$Astralneko_Storage.removeTimeOverride
end

# Play player animation
def anPlayPlayerAnimation(animname, length=1, frequency=2, vehicle=false)
    $Astralneko_Temp.setLastPlayerDir($game_player.direction)
	meta = GameData::Metadata.get_player($player.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if vehicle
			if $PokemonGlobal.diving;     charset = 5   # Diving graphic
			elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
			elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
			end
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		animation = "" + newCharName + "_" + animname
		move_route = Array.new
		move_route.push(PBMoveRoute::TURN_DOWN)
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,0,PBMoveRoute::WAIT,frequency) if length >= 1
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,1,PBMoveRoute::WAIT,frequency) if length >= 2
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,2,PBMoveRoute::WAIT,frequency) if length >= 3
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,3,PBMoveRoute::WAIT,frequency) if length >= 4
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,0,PBMoveRoute::WAIT,frequency) if length >= 5
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,1,PBMoveRoute::WAIT,frequency) if length >= 6
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,2,PBMoveRoute::WAIT,frequency) if length >= 7
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,3,PBMoveRoute::WAIT,frequency) if length >= 8
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,0,PBMoveRoute::WAIT,frequency) if length >= 9
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,1,PBMoveRoute::WAIT,frequency) if length >= 10
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,2,PBMoveRoute::WAIT,frequency) if length >= 11
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,3,PBMoveRoute::WAIT,frequency) if length >= 12
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,0,PBMoveRoute::WAIT,frequency) if length >= 13
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,1,PBMoveRoute::WAIT,frequency) if length >= 14
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,2,PBMoveRoute::WAIT,frequency) if length >= 15
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,3,PBMoveRoute::WAIT,frequency) if length >= 16
		pbMoveRoute($game_player,move_route)
	end
end

# Play player animation from a certain frame
def anPlayPlayerAnimationFromFrame(start_frame, animname, length=1, frequency=2, vehicle=false)
    $Astralneko_Temp.setLastPlayerDir($game_player.direction)
	meta = GameData::Metadata.get_player($player.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if vehicle
			if $PokemonGlobal.diving;     charset = 5   # Diving graphic
			elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
			elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
			end
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		animation = "" + newCharName + "_" + animname
		move_route = Array.new
		move_route.push(PBMoveRoute::TURN_DOWN)
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,0,PBMoveRoute::WAIT,frequency) if length >= 1 && start_frame <= 1
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,1,PBMoveRoute::WAIT,frequency) if length >= 2 && start_frame <= 2
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,2,PBMoveRoute::WAIT,frequency) if length >= 3 && start_frame <= 3
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,3,PBMoveRoute::WAIT,frequency) if length >= 4 && start_frame <= 4
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,0,PBMoveRoute::WAIT,frequency) if length >= 5 && start_frame <= 5
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,1,PBMoveRoute::WAIT,frequency) if length >= 6 && start_frame <= 6
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,2,PBMoveRoute::WAIT,frequency) if length >= 7 && start_frame <= 7
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,3,PBMoveRoute::WAIT,frequency) if length >= 8 && start_frame <= 8
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,0,PBMoveRoute::WAIT,frequency) if length >= 9 && start_frame <= 9
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,1,PBMoveRoute::WAIT,frequency) if length >= 10 && start_frame <= 10
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,2,PBMoveRoute::WAIT,frequency) if length >= 11 && start_frame <= 11
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,3,PBMoveRoute::WAIT,frequency) if length >= 12 && start_frame <= 12
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,0,PBMoveRoute::WAIT,frequency) if length >= 13 && start_frame <= 13
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,1,PBMoveRoute::WAIT,frequency) if length >= 14 && start_frame <= 14
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,2,PBMoveRoute::WAIT,frequency) if length >= 15 && start_frame <= 15
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,3,PBMoveRoute::WAIT,frequency) if length >= 16 && start_frame <= 16
		pbMoveRoute($game_player,move_route)
	end
end

def anReversePlayerAnimation(animname, length=1, frequency=2, vehicle=false)
    $Astralneko_Temp.setLastPlayerDir($game_player.direction)
	meta = GameData::Metadata.get_player($player.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if vehicle
			if $PokemonGlobal.diving;     charset = 5   # Diving graphic
			elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
			elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
			end
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		animation = "" + newCharName + "_" + animname
		move_route = Array.new
		move_route.push(PBMoveRoute::TURN_DOWN)
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,3,PBMoveRoute::WAIT,frequency) if length >= 16
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,2,PBMoveRoute::WAIT,frequency) if length >= 15
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,1,PBMoveRoute::WAIT,frequency) if length >= 14
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,8,0,PBMoveRoute::WAIT,frequency) if length >= 13
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,3,PBMoveRoute::WAIT,frequency) if length >= 12
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,2,PBMoveRoute::WAIT,frequency) if length >= 11
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,1,PBMoveRoute::WAIT,frequency) if length >= 10
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,6,0,PBMoveRoute::WAIT,frequency) if length >= 9
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,3,PBMoveRoute::WAIT,frequency) if length >= 8
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,2,PBMoveRoute::WAIT,frequency) if length >= 7
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,1,PBMoveRoute::WAIT,frequency) if length >= 6
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,4,0,PBMoveRoute::WAIT,frequency) if length >= 5
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,3,PBMoveRoute::WAIT,frequency) if length >= 4
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,2,PBMoveRoute::WAIT,frequency) if length >= 3
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,1,PBMoveRoute::WAIT,frequency) if length >= 2
		move_route.push(PBMoveRoute::GRAPHIC,animation,0,2,0,PBMoveRoute::WAIT,frequency) if length >= 1
		pbMoveRoute($game_player,move_route)
	end
end

def anEndPlayerAnimation
	meta = GameData::Metadata.get_player($Trainer.character_ID)
	if meta
		charset = 1                                 # Regular graphic
		if $PokemonGlobal.diving;     charset = 5   # Diving graphic
		elsif $PokemonGlobal.surfing; charset = 3   # Surfing graphic
		elsif $PokemonGlobal.bicycle; charset = 2   # Bicycle graphic
		end
		newCharName = pbGetPlayerCharset(meta,charset,nil,true)
		case $Astralneko_Temp.lastPlayerDirection
		when 2
		pbMoveRoute($game_player,[
			PBMoveRoute::TURN_DOWN,
			PBMoveRoute::GRAPHIC,newCharName, 
			  0, 2, 0
		])
		when 4
		pbMoveRoute($game_player,[
			PBMoveRoute::TURN_DOWN,
			PBMoveRoute::GRAPHIC,newCharName, 
			  0, 4, 0
		])
		when 6
		pbMoveRoute($game_player,[
			PBMoveRoute::TURN_DOWN,
			PBMoveRoute::GRAPHIC,newCharName, 
			  0, 6, 0
		])
		when 8
		pbMoveRoute($game_player,[
			PBMoveRoute::TURN_DOWN,
			PBMoveRoute::GRAPHIC,newCharName, 
			  0, 8, 0
		])
		end
	end
end

# Do not use, prefer Arcky's Poké Market
def anMart(itemlist)
    badges = $player.badge_count
	
	buyableItems = []
	for i in 0...itemlist.length
		if itemlist[i+1].is_a?(Integer)
			if badges >= itemlist[i+1]
				buyableItems.push(itemlist[i])
			end
		end
	end
	pbPokemonMart(buyableItems)
end

def anStackBitmapsSingle(baseBitmap, addBitmap)
	return nil if !baseBitmap || !addBitmap
	
	# Ensure the new bitmap can fit the larger of the two widths
	if addBitmap.width > baseBitmap.width
		width = addBitmap.width
	else
		width = baseBitmap.width
	end
	# Ensure the new bitmap can fit the larger of the two heights
	if addBitmap.height > baseBitmap.height
		height = addBitmap.height
	else
		height = baseBitmap.height
	end
	
	# blt the two bitmaps together on a new bitmap
	result = Bitmap.new(width,height)
	result.blt(0,0,baseBitmap,Rect.new(0,0,baseBitmap.width,baseBitmap.height))
	result.blt(0,0,addBitmap,Rect.new(0,0,addBitmap.width,addBitmap.height))
	return result
end

# The above function, but generalized to any amount of Bitmap objects instead of two
def anStackBitmaps(*args)
	result = Bitmap.new(10,10)
	for i in args.size
		if args[i].is_a?(Bitmap)
			result = anStackBitmapsSingle(result,args[i])
		else # Assume filename string if not a Bitmap
			if pbResolveBitmap("Graphics/"+args[i])
				bitmap = Bitmap.new(args[i])
				result = anStackBitmapsSingle(result,bitmap)
			else
				return nil
			end
		end
	end
	return result
end

# Generate a new random name from a list
def anRandomName
  names = Astralneko_Config::RANDOM_NAME_LIST
  return names.sample
end

# Generates a random gender, based loosely on the name of the character.
def anRandomGender(name="X")
  guess = defined?(Trainer.nonbinary?) ? rand(3) : rand(2) # 0 = male, 1 = female, 2 = nonbinary (if defined)
  # To maintain the guess, the following checks must not succeed:
  # Name ends in L/O/N/S, 1/2 chance
  guess = 0 if name[/[l|o|n|s]$/] != "" && rand(2) == 0
  # Name ends in O/E/R, 1/4 chance
  guess = 0 if name[/[o|e|r]$/] != "" && rand(4) == 0
  # Name ends in A/IE, 1/2 chance
  guess = 1 if name[/[a|ie]$/] != "" && rand(2) == 0
  # Name ends in A/D/Z/Y, 1/4 chance
  guess = 1 if name[/[a|d|z|y]$/] != "" && rand(4) == 0
  # Whatever guess now is, return it
  return guess
end

# Checking if a certain roamer exists
# index is the 0-indexed position within Settings::ROAMING_SPECIES
def anIsRoamerOn?(index)
	return $game_switches[Settings::ROAMING_SPECIES[index][2]] && ( # Game switch on
			   $PokemonGlobal.roamPokemon.size <= index ||
			   $PokemonGlobal.roamPokemon[index]!=true # Roaming pokemon has not been caught
	)
end

# Alias for checking if any roamers exist
# Returns an array of the IDs of those species if something is found
# Returns an empty array if nothing is found
# To determine how many roamers exist, use anIsAnyRoamerOn?.length
def anIsAnyRoamerOn?
	found_roamers = []
	for roam_pos in $PokemonGlobal.roamPosition
		if anIsRoamerOn?(roam_pos[0])
			found_roamers.push(roam_pos[0])
		end
	end
	return found_roamers
end

# Checking for holidays
# This is used by the television script, but is here because it could be useful for other things
# Returns the 0-indexed id of the holiday in AstralnekoConfig::HOLIDAY_DATES, or -1 if not a holiday
def anIsHoliday?
	Astralneko_Config::HOLIDAY_DATES.each_with_index do |date, index|
		timenow = pbGetTimeNow
		month = timenow.month
		day = timenow.mday
		if date[0] == month && date[1] == day
			return index
		end
	end
	return -1
end

# Used to get exact # days since a certain time
# epoch is a Time object that is considered day epochOffset
# radices, if present, determines how the number of days is displayed (if not present, it'll be an exact number of days)
# radices is an array; each value in radices must be between 2 and 36 inclusive
# epochOffset is the amount of days after day 0 at the Unix epoch (January 1, 1970)
# anLongCount(Time.new(2012,12,21), 93600, Array.[](20,20,18,20,20,20,20,20,20)) for Maya Long Count (the namesake of the function)
# The aforementioned anLongCount call will return C0000 on December 21, 2012
def anLongCount(epoch,epochOffset = 0,radices = nil)
	timenow = pbGetTimeNow
	now_time = timenow.ceil
	epoch_time = epoch.ceil
	# Find day difference
	second_difference = now_time - epoch_time
	day_difference = (second_difference / 86400.0).floor
	# Add epochOffset to day_difference
	day_difference += epochOffset
	# If radices present, string conversion will have a specific representation
	if radices && radices.is_a?(Array)
		longCountRepresentation = []
		for i in 0...radices.length
			this_radix = radices[i]
			num = day_difference % this_radix
			longCountRepresentation.push(num)
			day_difference = (day_difference / this_radix).floor
		end
		ret = ""
		for i in (radices.length-1)..0
			ret = longCountRepresentation[i].to_s(36)
		end
		return ret
	else
		return day_difference.to_s
	end
end
