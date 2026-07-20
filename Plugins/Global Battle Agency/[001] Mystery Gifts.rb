#===============================================================================
# Global Battle Agency / Mystery Gifts (v21.1)
#===============================================================================

#===============================================================================
# CONFIG
#===============================================================================
API_URL = "https://global-battle-agency.kirbywithaz.workers.dev"

#===============================================================================
# GLOBAL EVENT CALL
# Call this in events: gba_mystery_gift
#===============================================================================
def gba_mystery_gift
  GlobalBattleAgency.open_redemption_menu
end

#===============================================================================
# CONSOLE DATA GENERATOR
#===============================================================================
def pbGenerateGiftData(type, value, quantity = 1)
  gift = {
    :type     => type,
    :value    => value,
    :quantity => quantity
  }
  encoded = [Marshal.dump(gift)].pack("m0")
  echoln "-----------------------------"
  echoln "NEW GIFT DATA GENERATED"
  echoln "Choose an ID for this code."
  echoln "DATA:"
  echoln encoded
  echoln "-----------------------------"
  pbMessage(_INTL("Gift data generated! Check console."))
end

#===============================================================================
# MAIN MODULE
#===============================================================================
module GlobalBattleAgency

  #-----------------------------
  # Loading Animation (Smoothed)
  #-----------------------------
  def self.show_loading(message = "Connecting to server")
    msgwindow = pbCreateMessageWindow
    msgwindow.letterbyletter = false 
    
    dots = 0
    total_frames = Graphics.frame_rate * 2.5
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

  #---------------------------------------------------------------------------
  def self.trainer
    defined?($player) ? $player : $Trainer
  end

  #---------------------------------------------------------------------------
  def self.bag
    defined?($bag) ? $bag : $PokemonBag
  end

  #---------------------------------------------------------------------------
  def self.open_redemption_menu
    input = pbEnterText(_INTL("Mystery Gift Code?"), 0, 13)

    if input && !input.strip.empty?
      full_code = "GIFT_" + input.strip.upcase
      claim_mystery_gift(full_code)
    else
      pbMessage(_INTL("Please come again."))
    end
  end

  #---------------------------------------------------------------------------
  def self.claim_mystery_gift(code)
    return false if code.nil? || code.strip.empty?

    target_id = code.strip.upcase
    
    # Use the new automatic animation
    self.show_loading(_INTL("Connecting to server"))

    begin
      response = HTTPLite.get("#{API_URL}/get?id=#{target_id}")
      return fail_message("Server did not respond.") if response.nil?

      data = response[:body]
      if data.nil? || data == "NOT_FOUND" || data.empty?
        return fail_message("Gift code not found or already claimed.")
      end

      decoded = data.unpack("m0")[0] rescue nil
      return fail_message("Invalid gift data.") if decoded.nil?

      gift_data = Marshal.load(decoded) rescue nil
      return fail_message("Corrupted gift package.") if gift_data.nil?

      case gift_data[:type]

      when :pokemon
        if trainer.party_full?
          return fail_message("Your party is full!")
        end
        trainer.party << gift_data[:value]
        pbMessage(_INTL("You received a Pokémon!"))

      when :item
        item_id = gift_data[:value]
        qty     = gift_data[:quantity] || 1
        item = GameData::Item.try_get(item_id)
        return fail_message("Invalid item ID.") if item.nil?
        bag.add(item_id, qty)
        pbMessage(_INTL("You received {1} x {2}!", qty, item.name))

      when :money
        trainer.money += gift_data[:value].to_i
        pbMessage(_INTL("You received ${1}!", gift_data[:value]))

      when :cosmetic
        if trainer.respond_to?(:apply_cosmetic)
          trainer.apply_cosmetic(gift_data[:value])
          pbMessage(_INTL("You received a new cosmetic!"))
        else
          pbMessage(_INTL("Cosmetics not supported in this build."))
        end

      else
        pbMessage(_INTL("You received a mysterious gift!"))
      end

      # Delete one-time codes (unless permanent)
      unless target_id.start_with?("GIFT_")
        HTTPLite.get("#{API_URL}/delete?id=#{target_id}")
      end

      Game.save
      pbMessage(_INTL("Game saved successfully!"))
      return true

    rescue => e
      pbMessage(_INTL("Mystery Gift failed: {1}", e.message))
      return false
    end
  end

  #---------------------------------------------------------------------------
  def self.fail_message(msg)
    pbMessage(_INTL(msg))
    return false
  end

end

#===============================================================================
# Interpreter Hook
#===============================================================================
class Game_Interpreter
  def gba_mystery_gift
    GlobalBattleAgency.open_redemption_menu
  end
end