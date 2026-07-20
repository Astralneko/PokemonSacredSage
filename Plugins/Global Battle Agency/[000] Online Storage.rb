#===============================================================================
# Global Battle Agency / Online Storage (v21.1)
#===============================================================================

module GlobalBattleAgency
  
  #-----------------------------
  # Configuration
  #-----------------------------
  
  API_URL       = "https://global-battle-agency.kirbywithaz.workers.dev"
  STUDIO_NAME   = "KirbywithaZ_Games"
  SHARED_FOLDER = ENV['AppData'] + "/#{STUDIO_NAME}/"
  IDENTITY_FILE = SHARED_FOLDER + "gba_registry.txt"

  #-----------------------------
  # Loading Animation (Smoothed and Slower)
  #-----------------------------

  def self.show_loading(message = "Connecting to server")
    msgwindow = pbCreateMessageWindow
    msgwindow.letterbyletter = false 
    
    dots = 0
    # Total frames adjusted for a slower feel (approx 2.5 - 3 seconds)
    total_frames = Graphics.frame_rate * 2.5
    # Change dots every 15 frames instead of 10
    dot_speed = 15 

    total_frames.to_i.times do |i|
      if i % dot_speed == 0
        dots = (dots + 1) % 4
        msgwindow.text = _INTL("{1}{2}", message, "." * dots)
      end
      Graphics.update
      Input.update
      msgwindow.update
    end
    
    pbDisposeMessageWindow(msgwindow)
  end

  #-----------------------------
  # Master Key
  #-----------------------------
  
  def self.get_master_key
    "#{$player.name}_#{$player.id}"
  end

  #-----------------------------
  # Identity
  #-----------------------------
  
  def self.save_identity_locally
    begin
      Dir.mkdir(SHARED_FOLDER) unless File.exists?(SHARED_FOLDER)
      registry = {}
      if File.exists?(IDENTITY_FILE)
        begin
          content = File.read(IDENTITY_FILE)
          registry = eval(content) if content.include?("{")
        rescue
          registry = {}
        end
      end
      registry[System.game_title] = self.get_master_key
      File.open(IDENTITY_FILE, "w") { |f| f.write(registry.inspect) }
    rescue
      echoln "GBA: Failed to save local identity."
    end
  end

  #-----------------------------
  # Reunion System
  #-----------------------------
  
  def self.auto_invite_legacy
    if $player.party_full?
      return pbMessage(_INTL("Your party is full!"))
    end

    if File.exists?(IDENTITY_FILE)
      begin
        registry = eval(File.read(IDENTITY_FILE))
        registry.delete(System.game_title)

        if registry.empty?
          return pbMessage(_INTL("No other local game records were found."))
        end

        commands = registry.keys
        choice = pbMessage(_INTL("Past journeys detected! Which record should be accessed?"), commands, -1)
        
        if choice >= 0
          target_game = commands[choice]
          legacy_id = registry[target_game]
          self.show_loading(_INTL("Accessing cloud for {1}", target_game))
          self.fetch_and_load(legacy_id)
        end
      rescue Exception => e
        echoln "GBA Reunion Error: #{e.message}"
        pbMessage(_INTL("The identity registry is corrupted."))
      end
    else
      pbMessage(_INTL("No records of a past journey found on this device."))
    end
  end

  #-----------------------------
  # Deposit
  #-----------------------------
  
  def self.upload_pokemon
    if $player.party.length <= 1
      return pbMessage(_INTL("You must keep at least one Pokémon in your party!"))
    end

    selected_indices = []

    loop do
      break if selected_indices.length >= 5
      break if ($player.party.length - selected_indices.length) <= 1

      msg = selected_indices.empty? ? 
            _INTL("Select a Pokémon to deposit.") : 
            _INTL("{1} selected. Select another or press B to finish.", selected_indices.length)

      pbChoosePokemon(1, 2, proc { |pkmn| !pkmn.egg? })
      idx = pbGet(1)

      if idx < 0
        break if selected_indices.any?
        return
      end

      if selected_indices.include?(idx)
        pbMessage(_INTL("That Pokémon is already selected!"))
      else
        selected_indices.push(idx)
        pbMessage(_INTL("Added to the deposit list.")) if selected_indices.length == 1
      end
    end

    return if selected_indices.empty?

    confirm_msg = selected_indices.length == 1 ? 
                  _INTL("Deposit this Pokémon into the cloud?") : 
                  _INTL("Deposit these {1} Pokémon into the cloud?", selected_indices.length)

    if pbConfirmMessage(confirm_msg)
      self.show_loading(_INTL("Connecting to GBA cloud"))

      sending_party = selected_indices.map { |i| $player.party[i] }
      pokemon_dna = [Marshal.dump(sending_party)].pack("m0")
      payload = { "id" => self.get_master_key, "data" => pokemon_dna }

      begin
        response = HTTPLite.post("#{API_URL}/save", payload)
        if response[:body]&.include?("OK")
          selected_indices.sort.reverse_each { |i| $player.party.delete_at(i) }
          self.save_identity_locally
          msg = selected_indices.length == 1 ? 
                _INTL("Success! The Pokémon was moved to the cloud.") : 
                _INTL("Success! The Pokémon were moved to the cloud.")
          pbMessage(msg)
        else
          pbMessage(_INTL("Cloud error. Please try again later."))
        end
      rescue Exception => e
        pbMessage(_INTL("Connection failed!"))
      end
    end
  end

  #-----------------------------
  # Withdrawal
  #-----------------------------
  
  def self.download_pokemon
    self.show_loading(_INTL("Accessing GBA cloud"))
    self.fetch_and_load(self.get_master_key)
  end

  #-----------------------------
  # Fetch and Load
  #-----------------------------
  
  def self.fetch_and_load(target_id)
    begin
      response = HTTPLite.get("#{API_URL}/get?id=#{target_id}")
      data = response[:body]

      if data && data != "NOT_FOUND" && !data.include?("Error")
        decoded = data.unpack("m0")[0]
        pkmn_data = Marshal.load(decoded)

        new_arrivals = pkmn_data.is_a?(Array) ? pkmn_data : [pkmn_data]
        count = new_arrivals.length

        if ($player.party.length + count) > 6
          return pbMessage(_INTL("Not enough room in the party for {1} Pokémon!", count))
        end

        new_arrivals.each { |p| $player.party.push(p) }
        HTTPLite.get("#{API_URL}/delete?id=#{target_id}")

        msg = count == 1 ? 
              _INTL("Transfer complete! The Pokémon has returned.") : 
              _INTL("Transfer complete! The Pokémon have returned.")
        pbMessage(msg)
      else
        pbMessage(_INTL("No Pokémon found in that locker."))
      end
    rescue Exception => e
      pbMessage(_INTL("Connection error."))
    end
  end
end