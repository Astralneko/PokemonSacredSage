#===============================================================================
# Functions
#===============================================================================

# Opens your list of active IM conversations
def pbInstantMessages(filter = nil, old_scene = nil)
  pbFadeOutIn {
    scene = InstantMessagesMenu_Scene.new(filter)
    screen = InstantMessagesMenuScreen.new(scene)
    screen.pbStartScreen
    old_scene.refresh if old_scene.is_a?(SocialMedia_Scene)
  }
end

# Directly opens a group 
def pbInstantMessagesDirect(group_id, old_scene = nil)
  pbFadeOutIn {
    scene = InstantMessages_Scene.new(group_id, old_scene)
    screen = InstantMessagesScreen.new(scene)
    screen.pbStartScreen
  }
end

# Receive an IM
def pbReceiveIM(conversation_id, silent = false)
  ret = pbPlayerIMSaved.pbReceiveMessage(conversation_id)
  return false unless ret
  convo = pbIMGetConversation(conversation_id)
  se = InstantMessagesSettings::MESSAGE_RECEIVED_SOUND_EFFECT
  silent = true if convo.not_new && !convo.important
  unless silent || convo.important
    pbSEPlay(se)
    pbMessage(_INTL("You received a message!"))
  end
  if convo.important
    pbSEPlay(se)
    pbMessage(_INTL("You received a message!"))
    if InstantMessagesSettings::OPEN_IMPORTANT_MESSAGES_DIRECTLY
      pbInstantMessagesDirect(pbIMGetGroup(convo.group).id)
    else
      pbInstantMessages
    end
  end
  if convo.queue_after_receive
    queue = convo.queue_after_receive
    if queue[:immediate]
      pbReceiveIM(queue[:id], true)
    else
      pbPendDelayedIM(queue[:id], steps: queue[:steps] || InstantMessagesSettings::PASSIVE_STEP_MIN, 
          time: queue[:time] || InstantMessagesSettings::PASSIVE_STEP_MIN,
          stepvariation: queue[:stepvariation], timevariation: queue[:timevariation])
    end
  end
  return true
end

def pbPendDelayedIM(conversation_id, steps: InstantMessagesSettings::PASSIVE_STEP_MIN, time: InstantMessagesSettings::PASSIVE_STEP_MIN, stepvariation: nil, timevariation: nil)
  if stepvariation && stepvariation != 0
    stepvariation = rand(stepvariation)
  end
  if timevariation && timevariation != 0
    timevariation = rand(timevariation)
  end
  array = [conversation_id, steps + (stepvariation ? stepvariation : rand(InstantMessagesSettings::PASSIVE_STEP_VARIATION)), 
          time + (timevariation ? timevariation : rand(InstantMessagesSettings::PASSIVE_TIME_VARIATION)), pbGetTimeNow]
  $player.im_passive[:PendedDelayed].push(array)
end

def pbPendRandomIM(conversation_id)
  return false if InstantMessagesSettings::PASSIVE_TRIGGERS_RANDOM_POOL.include?(conversation_id) || $player.im_passive[:PendedRandoms].include?(conversation_id)
  $player.im_passive[:PendedRandoms].push([conversation_id])
end

def pbHasReceivedIM?(conversation_id)
  ret = pbPlayerIMSaved.pbHasReceivedMessage?(conversation_id)
  return ret
end

def pbSetIMTheme(color)
  pbPlayerIMSaved.theme_color = color
end

def pbHasUnreadIM?
  ret = pbPlayerIMSaved.pbHasUnreadMessages?
  return ret
end

#===============================================================================
# Menu scene
#===============================================================================
class Window_IM_Menu < Window_DrawableCommand
  attr_accessor :item_max

  def initialize(x, y, width, height, viewport)
    @conversations = []
    super(x, y, width, height, viewport)
    self.windowskin = nil
    @file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
    arrow_file = Essentials::VERSION.include?("21") ? "sel_arrow" : "selarrow"
    @selarrow = AnimatedBitmap.new("Graphics/#{@file_location}/#{arrow_file}")
  end
  
  def conversations=(value)
    @conversations = value
    refresh
  end
  
  def itemCount
    return @conversations.length
  end
    
  def drawItem(index, _count, rect)
    return if index >= self.top_row + self.page_item_max
    rect = Rect.new(rect.x + 16, rect.y, rect.width-16, rect.height)
    group = @conversations[index][1]
    name = group.title

    base = self.baseColor
    shadow = self.shadowColor
    name = "<b>" + name + "</b>" if group.has_unread
    drawFormattedTextEx(self.contents, rect.x ,rect.y + 2, 468, name, base, shadow)
    x_adj = 0
    if InstantMessagesSettings::ALLOW_PINNING 
      x_adj = 30
      if group.pinned
        pbDrawImagePositions(self.contents, [[sprintf("Graphics/UI/Instant Messages/pin"), rect.width - 16, rect.y + 4]]) 
      end
    end
    if group.has_unread
      if group.has_important
        pbDrawImagePositions(self.contents, [[sprintf("Graphics/UI/Instant Messages/important"), rect.width - 16 - x_adj, rect.y + 4]]) 
      else
        pbDrawImagePositions(self.contents, [[sprintf("Graphics/UI/Instant Messages/new"), rect.width - 16 - x_adj, rect.y + 4]]) 
      end
    end
  end
  
  def refresh
    @item_max = itemCount
    dwidth  = self.width - self.borderX
    dheight = self.height - self.borderY
    self.contents = pbDoEnsureBitmap(self.contents, dwidth, dheight)
    self.contents.clear
    for i in 0...@item_max
      next if i < self.top_item || i > self.top_item + self.page_item_max
      drawItem(i, @item_max, itemRect(i))
    end
    drawCursor(self.index, itemRect(self.index)) if itemCount > 0
  end
  
  def update
    super
    @uparrow.x -= 10
    @downarrow.x -= 10
  end
end

class InstantMessagesMenu_Scene
  attr_accessor :sprites

  def initialize(filter = nil)
    @filter = filter
  end

  def pbStartScene
    @sort_method = 0
    pbGetConverstationList
    @sprites = {}
    @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
    @viewport.z = 99999
    @base_color = MessageConfig::DARK_TEXT_MAIN_COLOR
    @shadow_color = MessageConfig::DARK_TEXT_SHADOW_COLOR
    # @title_color = MessageConfig::DARK_TEXT_MAIN_COLOR
    # @title_shadow_color = MessageConfig::DARK_TEXT_SHADOW_COLOR
    @title_color = MessageConfig::LIGHT_TEXT_MAIN_COLOR
    @title_shadow_color = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
    @theme = pbPlayerIMSaved.theme_color
    @sprites["background"] = IconSprite.new(0, 0, @viewport)
    @sprites["background"].setBitmap("Graphics/UI/Instant Messages/Themes/#{@theme}/bg_menu")        
    @last_convo =  nil
    @sprites["itemlist"] = Window_IM_Menu.new(22, 28, Graphics.width - 22, Graphics.height - 28, @viewport)
    @sprites["itemlist"].index = 0
    @sprites["itemlist"].baseColor = @base_color
    @sprites["itemlist"].shadowColor = @shadow_color
    @sprites["itemlist"].conversations = @conversation_list
    @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
    pbSetSystemFont(@sprites["overlay"].bitmap)
    textpos = [[InstantMessagesSettings::MESSAGE_LIST_TITLE,Graphics.width / 2, 6, 2, @title_color, @title_shadow_color]]
    if @sprites["itemlist"].item_max == 0
      if @filter
        textpos.push([_INTL("No matching messages found."), Graphics.width / 2, Graphics.height / 2 - 12, 2, @base_color, @shadow_color])
      else
        textpos.push([_INTL("You have no messages."), Graphics.width / 2, Graphics.height / 2 - 12, 2, @base_color, @shadow_color])
      end
    end
    if InstantMessagesSettings::ALLOW_SORTING && @conversation_list.length > 1
      @sprites["sort_button"] = IconSprite.new(0, 0, @viewport)
      @sprites["sort_button"].setBitmap("Graphics/UI/Instant Messages/sort_button")
      @sprites["sort_button"].x = 4
      @sprites["sort_button"].y = 6
    end

    if InstantMessagesSettings::ALLOW_PINNING && @conversation_list.length > 0
      @sprites["pin_button"] = IconSprite.new(0, 0, @viewport)
      @sprites["pin_button"].setBitmap("Graphics/UI/Instant Messages/pin_button")
      @sprites["pin_button"].x = Graphics.width - @sprites["pin_button"].width - 4
      @sprites["pin_button"].y = 6
      pbSortConversations(false)
    end

    pbDrawTextPositions(@sprites["overlay"].bitmap,textpos)
    pbFadeInAndShow(@sprites) { pbUpdate }
  end

  def pbScene
    loop do
      selected = @sprites["itemlist"].index
      @sprites["itemlist"].active = true
      Graphics.update
      Input.update
      pbUpdate
      if Input.trigger?(Input::BACK)
        if pbCheckForImportant
          pbMessage(_INTL("You should view your important messages!"))
        else
          pbPlayCloseMenuSE
          break
        end
      elsif Input.trigger?(Input::USE)
        if @conversation_list.length == 0
          #pbPlayBuzzerSE
        else
          pbPlayDecisionSE
          pbInstantMessagesDirect(@conversation_list[selected][0], self)
        end
      elsif Input.trigger?(Input::ACTION) && InstantMessagesSettings::ALLOW_PINNING && @conversation_list.length > 0
        pbPlayDecisionSE
        @conversation_list[selected][1].toggle_pin
        pbSortConversations
      elsif Input.trigger?(Input::SPECIAL) && InstantMessagesSettings::ALLOW_SORTING && @conversation_list.length > 1
        commands = [_INTL("Sort by Newest First"),_INTL("Sort by Unread First"),_INTL("Sort Alphabetically")]
        ret = pbShowCommands(nil, commands, -1, @sort_method)
        if ret >= 0 && ret != @sort_method
          pbPlayDecisionSE
          @sort_method = ret
          pbSortConversations
        end
      end
    end
  end

  def pbSortConversations(move_cursor = true)
    if move_cursor
      current_id = @conversation_list[@sprites["itemlist"].index][0]
      old_index = @sprites["itemlist"].index
    end
    if InstantMessagesSettings::ALLOW_PINNING
      case @sort_method
      when 0 # Newest First, default
        @conversation_list.sort_by! { |c| [c[1].pinned ? 1 : 0, c[1].last_received, c[1].title] }
        @conversation_list.reverse!
      when 1 # Unread First
        @conversation_list.sort_by! { |c| [c[1].pinned ? 0 : 1, c[1].has_unread ? 0 : 1, c[1].title] }
      when 2 # Sort Alphabetically
        @conversation_list.sort_by! { |c| [c[1].pinned ? 0 : 1, c[1].title] }
      end
    else
      case @sort_method
      when 0 # Newest First, default
        @conversation_list.sort! { |a, b| a[1].last_received <=> b[1].last_received}
        @conversation_list.reverse!
      when 1 # Unread First
        @conversation_list.sort_by! { |c| c[1].has_unread ? 0 : 1 }
      when 2 # Sort Alphabetically
        @conversation_list.sort! { |a, b| a[1].title <=> b[1].title}
      end
    end
    @sprites["itemlist"].index = @conversation_list.find_index { |c| c[0] == current_id } || old_index if move_cursor
    @sprites["itemlist"].refresh
  end

  def pbGetConverstationList
    @conversation_list = []
    pbPlayerIMSaved.saved_messages.each do |key, value| 
      if @filter && @filter[0] == :Contact
        next unless value.group_data.members.has_value?(@filter[1])
      end
      @conversation_list.push([key, value]) 
    end
  end

  def pbCheckForImportant
    @conversation_list.each do |convo|
      return true if convo[1].has_unread && convo[1].has_important
    end
    return false
  end

  def pbUpdate
    pbUpdateSpriteHash(@sprites)
  end

  def pbEndScene
    pbFadeOutAndHide(@sprites) { pbUpdate }
    pbDisposeSpriteHash(@sprites)
    @viewport.dispose
  end

end

class InstantMessagesMenuScreen
  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    @scene.pbScene
    @scene.pbEndScene
  end
end

#===============================================================================
# Messages scene
#===============================================================================
class InstantMessages_Scene
    attr_accessor :theme

    ACTION_TYPES = [:React, :Delay, :Edit, :Delete, :Typing, :Availability]

    COMMANDS_MAKE_MEMBER_AVAILABLE = [:Text, :RedoText, :React, :Typing, :Edit, :Delete, :Reply, :Forward]

    MESSAGE_MAX_WIDTH = 338

    def initialize(group_id, old_scene = nil)
        @group = pbPlayerIMSaved.saved_messages[group_id]
        @old_scene = old_scene
    end

    def show_availability?
      return PluginManager.installed?("Social Links","1.4") && InstantMessagesSettings::AVAILABILITY_ICONS_SHOW
    end

    def make_member_available(index)
      return unless show_availability?
      return if pbGetMemberAvailability(index).nil? || pbGetMemberAvailability(index) == SocialLinkAvailability::DO_NOT_DISTURB
      pbUpdateMemberAvailability(index, 0)
    end

    def pbUpdateMemberAvailability(index = nil, val = nil)
      return unless show_availability?
      if index.nil? || @members_availability.nil?
        @members_availability = {}
        @members.each_with_index do |m, i|
          next if m.nil?
          @members_availability[i] = {
            :data => m,
            :availability => pbGetSocialLinkAvailability(m.id)
          }
        end
      end
      if index
        return if index == 0
        pbSetSocialLinkAvailability(@members[index].id, val) if val
        @members_availability[index][:availability] = pbGetSocialLinkAvailability(@members[index].id)
      end
    end

    def pbGetMemberAvailability(index)
      return nil unless show_availability?
      return SocialLinkAvailability::ONLINE if index == 0
      return nil if @members_availability.nil?
      return nil if @members_availability[index].nil?
      return @members_availability[index][:availability] || nil
    end

    def pbGetMemberImage(index, small: false, large: false)
      if index.is_a?(Symbol)
        filename = pbIMGetContact(index)&.image || ""
      else
        filename = index == 0 ? @player_picture : "#{@members[index].image}"
      end
      file_path = nil
      if small && small_graphic = pbResolveBitmap(_INTL("Graphics/UI/Instant Messages/Characters/#{filename}_small"))
        file_path = small_graphic
      elsif large && large_graphic = pbResolveBitmap(_INTL("Graphics/UI/Instant Messages/Characters/#{filename}_large"))
        file_path = large_graphic
      else
        file_path = _INTL("Graphics/UI/Instant Messages/Characters/#{filename}")
      end
      return file_path 
    end

    def pbStartScene
      @members = @group.member_data
      pbUpdateMemberAvailability
      @old_texts = []
      @old_convos = []
      @old_convos_timestamps = []
      @unread_convos = []
      @texts = []
      @old_texts_linked_convos = []
      @texts_linked_convos = []
      @new_convos_timestamps = []
      @texts_code_to_execute = []
      @reactions = []
      @group.convo_list.each do |conversation|
        if conversation.read && !@group.hide_old
          ts_index = @old_texts.length
          @old_convos_timestamps[ts_index] = conversation.received_time || nil if !@old_convos_timestamps.include?(conversation.received_time)
          @old_convos.push(conversation)
          conversation.messages.each_with_index do |message, i|
            @old_texts.push(message)
            @old_texts_linked_convos.push([conversation, i])
          end
          # @old_texts += conversation.messages
          if conversation.reactions && !conversation.reactions.empty?
            conversation.reactions.each_with_index do |r, i|
              next unless r
              @reactions[ts_index + i] = r
            end
          end
        else
          ts_index = @texts.length
          @new_convos_timestamps[ts_index] = conversation.received_time || nil if !@new_convos_timestamps.include?(conversation.received_time)
          @unread_convos.push(conversation)
          conversation.messages.each_with_index do |message, i|
            @texts.push(message)
            @texts_linked_convos.push([conversation, i])
          end
        end
      end
      
      @max_texts = @texts.length
      @only_old = @max_texts <= 0
      @player_bubble = InstantMessagesSettings::PLAYER_BUBBLE_COLOR || "White"
      @player_picture = _INTL("Player_#{$player.character_ID}#{($player.outfit > 0 ? "_#{$player.outfit}" : "")}")
      @picture_alignment = InstantMessagesSettings::PICTURE_ALIGNMENT
      @theme = @group.theme || pbPlayerIMSaved.theme_color

      @max_width = MESSAGE_MAX_WIDTH
      @show_index = 0
      @pause_time = pbTXWSecondsToFrameConvert(1.5)
      @system_pause_time = pbTXWSecondsToFrameConvert(0.5)
      @speed_up = false
      @scroll_rate = 32
      @timer = 0
      @typing_timer = 0
      @sprites = {}
      @viewport = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport.z = 99999
      @viewport2 = Viewport.new(0, 0, Graphics.width, Graphics.height)
      @viewport2.z = 99999
      @sprites["background"] = IconSprite.new(0, 0, @viewport)
      @sprites["background"].setBitmap("Graphics/UI/Instant Messages/Themes/#{@theme}/bg")
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      reactions = @group.reactions_list || InstantMessagesSettings::REACTIONS_LIST
      @sprites["reaction_selector"] = ReactSelector.new(reactions, @player_bubble, self, @viewport2)
      @sprites["reaction_selector"].x = 24 # (Graphics.width - @sprites["reaction_selector"].width) / 2
      @sprites["reaction_selector"].y = (Graphics.height - @sprites["reaction_selector"].height) / 2
      @sprites["reaction_selector"].visible = false
      @sprites["top_cover"] = IconSprite.new(0, 0, @viewport2)
      @sprites["top_cover"].setBitmap("Graphics/UI/Instant Messages/Themes/#{@theme}/top_cover")
      @sprites["top_cover"].y = 0
      @sprites["bottom_cover"] = IconSprite.new(0, 0, @viewport2)
      @sprites["bottom_cover"].setBitmap("Graphics/UI/Instant Messages/Themes/#{@theme}/bottom_cover")
      @sprites["bottom_cover"].y = Graphics.height - @sprites["bottom_cover"].height
      
      @sprites["playerreplypicture"] = MemberPhoto.new(0, 0, 0, self, @viewport)
      @sprites["playerreplypicture"].setBitmap(pbGetMemberImage(0))
      @sprites["playerreplypicture"].visible = false
      @sprites["overlay_bottom"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport2)
      pbSetSmallFont(@sprites["overlay_bottom"].bitmap)
      @sprites["overlay_title"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport2)
      if InstantMessagesSettings::SHOW_CLOSE_BUTTON
        @sprites["closebutton"] = IconSprite.new(4, 4, @viewport2)
        @sprites["closebutton"].setBitmap("Graphics/UI/Instant Messages/close")
        @sprites["closebutton"].opacity = 100
      end
      if InstantMessagesSettings::ALLOW_FAST_FORWARD
        @sprites["ffwdbutton"] = IconSprite.new(Graphics.width - 50, Graphics.height - 30, @viewport2)
        @sprites["ffwdbutton"].setBitmap("Graphics/UI/Instant Messages/ffwd")
        @sprites["ffwdbutton"].opacity = 100
      end
      @top_margin = @sprites["top_cover"].height - 6
      @side_margin = 20
      @bottom_margin = @sprites["bottom_cover"].y + 6

      pbRefreshGroupTitle
      @previously_saved_y = nil
      @old_texts.length.times do |i|
        if !ACTION_TYPES.include?(@old_texts[i][1])
          if @old_texts[i][0] > 0
            bubble_color = @members[@old_texts[i][0]].bubble
          elsif @old_texts[i][0] < 0
            bubble_color = InstantMessagesSettings::SYSTEM_BUBBLE_COLOR
            skip_picture = true
          else
            bubble_color = @player_bubble
          end
        end
        
        #replace choice arrays with the one that was selected
        case @old_texts[i][1]
        when :Text, :RedoText, :Reply, :Forward
          if @old_texts[i][2].is_a?(Array)
            if @old_texts[i][4]
              @old_texts[i][2] = @old_texts[i][2][@old_texts[i][4]]
            else
              @old_texts[i][2] = @old_texts[i][2][0]
            end
            pbRunTextThroughReplacement(@old_texts[i][2])
          else
            pbRunTextThroughReplacement(@old_texts[i][2])
          end
        when :Leave
          text_to_show = _INTL("{1} left.", @members[@old_texts[i][2]].name)
        when :Enter
          text_to_show = _INTL("{1} entered.", @members[@old_texts[i][2]].name)
        when :GroupName
          text_to_show = _INTL("Chat name changed to: {1}", @old_texts[i][2])
        when :Picture
          @sprites["old_text_picture#{i}"] = IconSprite.new(0, 0, @viewport)
          @sprites["old_text_picture#{i}"].setBitmap("Graphics/UI/Instant Messages/Pictures/#{@old_texts[i][2]}")
          @sprites["old_text_picture#{i}"].visible = false
          height_override =  @sprites["old_text_picture#{i}"].height
          width_override = @sprites["old_text_picture#{i}"].width
        when :Edit
          pbRunTextThroughReplacement(@old_texts[i][2])
        when :Delete
          pbRunTextThroughReplacement(@old_texts[i][2]) if @old_texts[i][2]
        end
        if [:Edit, :Delete].include?(@old_texts[i][1])
          height_adjustment = 24
          prev = get_previous_oldmessage(i)
          if @old_texts[i][1] == :Edit
            @sprites["oldtext#{prev}"].text = @old_texts[i][2]
            @sprites["oldtext#{prev}"].resizeToFit(@sprites["oldtext#{prev}"].text, @max_width)
            @sprites["oldtext#{prev}"].height += height_adjustment
            @sprites["oldtext#{prev}"].resizeContents(height_adjustment)
            pbSetSmallFont(@sprites["oldtext#{prev}"].contents)
            drawFormattedTextEx(@sprites["oldtext#{prev}"].contents, 0, @sprites["oldtext#{prev}"].contents.height - 21, @sprites["oldtext#{prev}"].contents.width, 
                _INTL("<ar><i>Edited</i></ar>"), @sprites["oldtext#{prev}"].baseColor, @sprites["oldtext#{prev}"].shadowColor, lineheight = 21)
            pbSetSystemFont(@sprites["oldtext#{prev}"].contents)
          elsif @old_texts[i][1] == :Delete
            height_adjustment = 0
            @sprites["oldtext#{prev}"].text = @old_texts[i][2] || InstantMessagesSettings::MESSAGE_DELETE_TEXT_DEFAULT
            @sprites["oldtext#{prev}"].resizeToFit(@sprites["oldtext#{prev}"].text, @max_width)
          end
          @sprites["oldreactions#{prev}"].y += height_adjustment if @sprites["oldreactions#{prev}"] && height_adjustment != 0
          if @sprites["oldpicture#{prev}"]
            @sprites["oldpicture#{prev}"].x = @sprites["oldtext#{prev}"].x + @sprites["oldtext#{prev}"].width + 4
            @sprites["oldpicture#{prev}"].y = @sprites["oldtext#{prev}"].y + get_y_adj(@sprites["oldtext#{prev}"].height, @sprites["oldpicture#{prev}"].height)
          end
        end

        if !ACTION_TYPES.include?(@old_texts[i][1])
          # Added for proper text replacement
          @sprites["oldtext#{i}"] = Window_AdvancedTextPokemonMessages.new(text_to_show || @old_texts[i][2])
          @sprites["oldtext#{i}"].setSkin("Graphics/UI/Instant Messages/Bubbles/#{bubble_color}")
          @sprites["oldtext#{i}"].resizeToFit(@sprites["oldtext#{i}"].text, @max_width)
          @sprites["oldtext#{i}"].height += 32 if [:Reply, :Forward].include?(@old_texts[i][1]) 
          if [:Forward].include?(@old_texts[i][1]) 
            @sprites["oldtext#{i}"].width += 12 
            if @old_texts[i][3]
              min_width = 192
              @sprites["oldtext#{i}"].width += 32
            else
              min_width = 160
            end
            @sprites["oldtext#{i}"].width = @sprites["oldtext#{i}"].width.clamp(min_width, InstantMessages_Scene::MESSAGE_MAX_WIDTH)
          end
          @sprites["oldtext#{i}"].text = "" if @sprites["old_text_picture#{i}"]
          @sprites["oldtext#{i}"].viewport = @viewport
          @sprites["oldtext#{i}"].x = (@old_texts[i][0] != 0 ? @side_margin : Graphics.width - @side_margin - @sprites["oldtext#{i}"].width)
          prev = get_previous_oldmessage(i)
          @sprites["oldtext#{i}"].y = (@sprites["oldtext#{prev}"] ? @sprites["oldtext#{prev}"].y + @sprites["oldtext#{prev}"].height : @top_margin)
          if @sprites["oldreactions#{prev}"]
            bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
            @sprites["oldtext#{i}"].y += (bubble_bg ? 24 : 8)              
          end
          if InstantMessagesSettings::SHOW_TIME_STAMPS && @old_convos_timestamps[i]
            @sprites["oldmessagetimestamp#{i}"] = Divider.new(0, 0, pbConvertTimeStamp(@old_convos_timestamps[i]), false, self, @viewport)
            @sprites["oldmessagetimestamp#{i}"].y = @sprites["oldtext#{i}"].y
            @sprites["oldmessagetimestamp#{i}"].visible = true 
            @sprites["oldtext#{i}"].y += @sprites["oldmessagetimestamp#{i}"].height
          end
          if @sprites["old_text_picture#{i}"]
            sides = @sprites["oldtext#{i}"].edges
            @sprites["old_text_picture#{i}"].x = @sprites["oldtext#{i}"].x + sides[1].width
            @sprites["old_text_picture#{i}"].y = @sprites["oldtext#{i}"].y + sides[0].height
            @sprites["old_text_picture#{i}"].z = @sprites["oldtext#{i}"].z + 1
            @sprites["oldtext#{i}"].height = height_override + sides[0].height + sides[3].height
            @sprites["oldtext#{i}"].width = width_override + sides[1].width + sides[2].width
          end
          @sprites["oldtext#{i}"].orig_y = @sprites["oldtext#{i}"].y
          pbAddReplyToOldMessage(@sprites["oldtext#{i}"], i) if @old_texts[i][1] == :Reply
          pbAddForwardTagToAnyMessage(@sprites["oldtext#{i}"], i, @old_texts[i][3]) if @old_texts[i][1] == :Forward
          @sprites["oldtext#{i}"].visible = true
          @sprites["old_text_picture#{i}"]&.visible = true

          if @reactions[i]
            bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
            member_icons = InstantMessagesSettings::REACTIONS_SHOW_MEMBER_PICTURE
            if !@sprites["oldreactions#{i}"]
              @sprites["oldreactions#{i}"] = BitmapSprite.new(Graphics.width - @side_margin*2, (bubble_bg ? 36 : 32), @viewport)
              @sprites["oldreactions#{i}"].x = @sprites["oldtext#{i}"].x
              @sprites["oldreactions#{i}"].y = @sprites["oldtext#{i}"].y + @sprites["oldtext#{i}"].height - (bubble_bg ? 12 : 24) - 4
              @sprites["oldreactions#{i}"].z = @sprites["oldtext#{i}"].z + 1
            end
            reactimgpos_bg = []
            reactimgpos_members = []
            reactimgpos_icon = []
            reverse = @sprites["oldtext#{i}"].x != @side_margin
            if reverse
              @sprites["oldreactions#{i}"].x = @sprites["oldtext#{i}"].x + @sprites["oldtext#{i}"].width - @sprites["oldreactions#{i}"].width
              @reactions[i].each_with_index do |r, j|
                x_adj = member_icons ? 26 : 0
                if bubble_bg
                  bg = "Graphics/UI/Instant Messages/react_bubble"
                  bg += "_long" if member_icons
                  reactimgpos_bg.push([bg, @sprites["oldreactions#{i}"].width - 6 - (j + 1)*(42 + x_adj), 0])
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", @sprites["oldreactions#{i}"].width - (j + 1)*(42 + x_adj), 0])
                else
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}",  @sprites["oldreactions#{i}"].width - 6 - (j + 1)*(24 + x_adj), 0])
                end
                reactimgpos_members.push(r[1]) if member_icons
              end
            else
              @reactions[i].each_with_index do |r, j|
                x_adj = member_icons ? 26 : 0
                if bubble_bg
                  bg = "Graphics/UI/Instant Messages/react_bubble"
                  bg += "_long" if member_icons
                  reactimgpos_bg.push([bg, 8 + j*(42 + x_adj), 0])
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", 16 + j*(42 + x_adj), 0])
                else
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", 8 + j*(24 + x_adj), 0])
                end
                reactimgpos_members.push(r[1]) if member_icons
              end
            end
            pbDrawImagePositions(@sprites["oldreactions#{i}"].bitmap, reactimgpos_bg)
            if member_icons
              reactimgpos_members.each_with_index do |m, j|
                member_bmp = Bitmap.new(pbGetMemberImage(m, small: true))
                @sprites["oldreactions#{i}"].bitmap.stretch_blt(Rect.new(reactimgpos_icon[j][1] + 24, reactimgpos_icon[j][2] + 4, 
                    member_bmp.width / (member_bmp.width > 28 ? 2 : 1), member_bmp.height / (member_bmp.height > 28 ? 2 : 1)), 
                    member_bmp, Rect.new(0, 0, member_bmp.width, member_bmp.height))
                member_bmp.dispose
              end
            end
            pbDrawImagePositions(@sprites["oldreactions#{i}"].bitmap, reactimgpos_icon)
          end

          # Make picture appear for first unique message
          unless skip_picture
            prev = get_previous_oldmessage(i)
            if @old_texts[i][0] != 0 && (@sprites["oldtext#{prev}"].nil? || (@old_texts[prev][0] != @old_texts[i][0]))
              @sprites["oldpicture#{i}"] = MemberPhoto.new(0, 0, @old_texts[i][0], self, @viewport)
              @sprites["oldpicture#{i}"].setBitmap("Graphics/UI/Instant Messages/Characters/#{@members[@old_texts[i][0]].image}")
              @sprites["oldpicture#{i}"].x = @sprites["oldtext#{i}"].x + @sprites["oldtext#{i}"].width + 4
              @sprites["oldpicture#{i}"].y = @sprites["oldtext#{i}"].y + get_y_adj(@sprites["oldtext#{i}"].height, @sprites["oldpicture#{i}"].height)
              @sprites["oldpicture#{i}"].visible = true
            elsif @old_texts[i][0] == 0 && (@sprites["oldtext#{prev}"].nil? || (@old_texts[prev][0] != @old_texts[i][0]))
              @sprites["oldpicture#{i}"] = MemberPhoto.new(0, 0, @old_texts[i][0], self, @viewport)
              @sprites["oldpicture#{i}"].setBitmap(pbGetMemberImage(0))
              @sprites["oldpicture#{i}"].x = @sprites["oldtext#{i}"].x - @sprites["oldpicture#{i}"].width - 4
              @sprites["oldpicture#{i}"].y = @sprites["oldtext#{i}"].y + get_y_adj(@sprites["oldtext#{i}"].height, @sprites["oldpicture#{i}"].height)
              @sprites["oldpicture#{i}"].visible = true
            end 
          end
        end
        if i == @old_texts.length - 1
          last = i
          while ACTION_TYPES.include?(@old_texts[last][1]) 
            last -= 1
            break if last <= 0
          end
          if @max_texts > 0
            @sprites["unreaddivider"] = Divider.new(0, 0, _INTL("Unread"), true, self, @viewport)
            @sprites["unreaddivider"].y = @sprites["oldtext#{last}"].y + @sprites["oldtext#{last}"].height
            if @sprites["oldreactions#{last}"]
              @sprites["unreaddivider"].y += (InstantMessagesSettings::REACTIONS_BUBBLE_BG ? 24 : 8)
            end
            @sprites["unreaddivider"].visible = true
            @previously_saved_y_end = @sprites["unreaddivider"].y + @sprites["unreaddivider"].height 
          else
            @previously_saved_y_end = @sprites["oldtext#{last}"].y + @sprites["oldtext#{last}"].height 
          end
          last_text = @sprites["oldtext#{last}"]
          y_adj = (@sprites["oldreactions#{last}"] ? (InstantMessagesSettings::REACTIONS_BUBBLE_BG ? 24 : 8) : 0)
          if last_text.y + last_text.height + y_adj > @bottom_margin
            diff = last_text.y + last_text.height + y_adj - @bottom_margin
            pbMoveUp(value: diff)
          end
        end
      end

      if @max_texts > 0
        @retype = []
        @max_texts.times do |i|
          if !ACTION_TYPES.include?(@texts[i][1])
            if @texts[i][0] > 0
              bubble_color = @members[@texts[i][0]].bubble
            elsif @texts[i][0] < 0
              bubble_color = InstantMessagesSettings::SYSTEM_BUBBLE_COLOR
              skip_picture = true
            else
              bubble_color = @player_bubble
            end
          end

          # Added for proper text replacement
          case @texts[i][1]
          when :Text, :RedoText, :Reply, :Forward
            if @texts[i][2].is_a?(Array)
              @texts[i][2].each { |txt| pbRunTextThroughReplacement(txt) }
              text_to_show = @texts[i][2][0]
            else
              pbRunTextThroughReplacement(@texts[i][2])
            end
            @retype[i] = true if @texts[i][1] == :RedoText
          when :Leave
            text_to_show = _INTL("{1} left.", @members[@texts[i][2]].name)
          when :Enter
            text_to_show = _INTL("{1} entered.", @members[@texts[i][2]].name)
          when :GroupName
            @texts_code_to_execute[i] = [@texts[i][1], @texts[i][2]]
            text_to_show = _INTL("Chat name changed to: {1}", @texts[i][2] || @group.original_title)
          when :Picture
            @sprites["text_picture#{i}"] = IconSprite.new(0, 0, @viewport)
            @sprites["text_picture#{i}"].setBitmap("Graphics/UI/Instant Messages/Pictures/#{@texts[i][2]}")
            @sprites["text_picture#{i}"].visible = false
            height_override =  @sprites["text_picture#{i}"].height
            width_override = @sprites["text_picture#{i}"].width
          when :React
            @reactions[i] = true
            next
          when :Delay
            next
          when :Edit
            pbRunTextThroughReplacement(@texts[i][2])
            next
          when :Delete
            pbRunTextThroughReplacement(@texts[i][2]) if @texts[i][2]
            next
          when :Typing, :Availability
            next
          end
          @sprites["text#{i}"] = Window_AdvancedTextPokemonMessages.new(text_to_show || @texts[i][2])
          @sprites["text#{i}"].setSkin("Graphics/UI/Instant Messages/Bubbles/#{bubble_color}")
          @sprites["text#{i}"].resizeToFit(@sprites["text#{i}"].text, @max_width)

          if i == 0 && !@old_texts.empty? && @old_texts[get_previous_oldmessage(@old_texts.length)][0] == 0 && # Player made a choice as the last message of the old messages
                @old_texts[get_previous_oldmessage(@old_texts.length)][4] && @texts[i][2].is_a?(Array) 
                
            old_choice = @old_texts[get_previous_oldmessage(@old_texts.length)][4]
            @texts[i][4] = old_choice  #Add choice selection to index 4
            @sprites["text#{i}"].text = @texts[i][2][old_choice]
            @sprites["text#{i}"].resizeToFit(@sprites["text#{i}"].text, @max_width)
            
          end

          @sprites["text#{i}"].height += 32 if [:Reply, :Forward].include?(@texts[i][1])
          if [:Forward].include?(@texts[i][1]) 
            @sprites["text#{i}"].width += 12 
            if @texts[i][3]
              min_width = 192
              @sprites["text#{i}"].width += 32
            else
              min_width = 160
            end
           @sprites["text#{i}"].width = @sprites["text#{i}"].width.clamp(min_width, InstantMessages_Scene::MESSAGE_MAX_WIDTH)
          end
          @sprites["text#{i}"].text = "" if @sprites["text_picture#{i}"]
          @sprites["text#{i}"].viewport = @viewport
          @sprites["text#{i}"].x = (@texts[i][0] != 0 ? @side_margin : Graphics.width - @side_margin - @sprites["text#{i}"].width)
          if @previously_saved_y_end
            @sprites["text#{i}"].y = @previously_saved_y_end
            @previously_saved_y_end = nil
          else
            prev = get_previous_message(i)
            @sprites["text#{i}"].y = (@sprites["text#{prev}"] ? @sprites["text#{prev}"].y + @sprites["text#{prev}"].height : @top_margin)
          end
          if InstantMessagesSettings::SHOW_TIME_STAMPS && ((i > 0 && @texts_linked_convos[i-1][0] != @texts_linked_convos[i][0] && @texts_linked_convos[i-1][0].instant) || i == 0) &&
                @new_convos_timestamps[i]
            @sprites["newmessagetimestamp#{i}"] = Divider.new(0, 0, pbConvertTimeStamp(@new_convos_timestamps[i]), false, self, @viewport)
            @sprites["newmessagetimestamp#{i}"].y = @sprites["text#{i}"].y
            @sprites["newmessagetimestamp#{i}"].visible = true 
            @sprites["text#{i}"].y += @sprites["newmessagetimestamp#{i}"].height
          end
          if @sprites["text_picture#{i}"]
            sides = @sprites["text#{i}"].edges
            @sprites["text_picture#{i}"].x = @sprites["text#{i}"].x + sides[1].width
            @sprites["text_picture#{i}"].y = @sprites["text#{i}"].y + sides[0].height
            @sprites["text_picture#{i}"].z = @sprites["text#{i}"].z + 1
            @sprites["text#{i}"].height = height_override + sides[0].height + sides[3].height
            @sprites["text#{i}"].width = width_override + sides[1].width + sides[2].width
          end
          @sprites["text#{i}"].orig_y = @sprites["text#{i}"].y
          @sprites["text#{i}"].visible = @texts_linked_convos[i][0].instant #If a convo is instant, it will be already there once created
          @sprites["text_picture#{i}"]&.visible = @sprites["text#{i}"].visible
          # Make picture appear for first unique message
          unless skip_picture
            prev = get_previous_message(i)
            if @texts[i][0] != 0 && (@sprites["text#{prev}"].nil? || (@texts[prev][0] != @texts[i][0]))
              @sprites["picture#{i}"] = MemberPhoto.new(0, 0, @texts[i][0], self, @viewport)
              @sprites["picture#{i}"].setBitmap("Graphics/UI/Instant Messages/Characters/#{@members[@texts[i][0]].image}")
              @sprites["picture#{i}"].x = @sprites["text#{i}"].x + @sprites["text#{i}"].width + 4
              @sprites["picture#{i}"].y = @sprites["text#{i}"].y + get_y_adj(@sprites["text#{i}"].height, @sprites["picture#{i}"].height)
              @sprites["picture#{i}"].visible = @texts_linked_convos[i][0].instant
            elsif @texts[i][0] == 0 && (@sprites["text#{prev}"].nil? || (@texts[prev][0] != @texts[i][0]))
              @sprites["picture#{i}"] = MemberPhoto.new(0, 0, @texts[i][0], self, @viewport)
              @sprites["picture#{i}"].setBitmap(pbGetMemberImage(0))
              @sprites["picture#{i}"].x = @sprites["text#{i}"].x - @sprites["picture#{i}"].width - 4
              @sprites["picture#{i}"].y = @sprites["text#{i}"].y + get_y_adj(@sprites["text#{i}"].height, @sprites["picture#{i}"].height)
              @sprites["picture#{i}"].visible = @texts_linked_convos[i][0].instant
            end
          end
        end
      else
        pbEnableScrolling
      end

      pbSetSystemFont(@sprites["overlay"].bitmap)
      pbFadeInAndShow(@sprites)

    end

    def pbScene
      @allow_scroll = false
      loop do
        Graphics.update
        Input.update
        pbUpdate
        if Input.trigger?(Input::SPECIAL) && InstantMessagesSettings::ALLOW_FAST_FORWARD && !@allow_scroll
          pbToggleFastForward
        elsif Input.trigger?(Input::BACK) && @allow_scroll
          pbPlayCloseMenuSE
          break
        elsif Input.trigger?(Input::USE)

        elsif Input.repeat?(Input::DOWN) && @allow_scroll
          pbMoveUp
        elsif Input.repeat?(Input::JUMPDOWN) && @allow_scroll
          pbMoveUp(true)
        elsif Input.repeat?(Input::UP) && @allow_scroll
          pbMoveDown
        elsif Input.repeat?(Input::JUMPUP) && @allow_scroll
          pbMoveDown(true)
        end
        check_for_next_action
        if check_next_text
          pbEnableScrolling
        end
      end
      @unread_convos.each { |c| c.read = true}
      @group.has_unread = false
      @group.has_important = false
      return
    end

    def get_y_adj(text_height, picture_height)
      y_adj = 0
      case @picture_alignment
      when 1
        y_adj = text_height - picture_height - 6
      when 2
        y_adj = (text_height - picture_height) / 2
      else
        y_adj = 4
      end
      return y_adj
    end

    def get_previous_oldmessage(index = @show_index)
      prev = index - 1
      return nil if prev < 0
      while ACTION_TYPES.include?(@old_texts[prev][1]) 
        prev -= 1
        break if prev <= 0
      end
      return nil if ACTION_TYPES.include?(@old_texts[prev][1])
      return prev
    end

    def get_previous_message(index = @show_index)
      prev = index - 1
      return nil if prev < 0
      while ACTION_TYPES.include?(@texts[prev][1]) 
        prev -= 1
        break if prev <= 0
      end
      return nil if ACTION_TYPES.include?(@texts[prev][1])
      return prev
    end

    def check_for_next_action
      return if @allow_scroll
      return if @texts[@show_index].nil?
      return if !ACTION_TYPES.include?(@texts[@show_index][1])
      prev_text_index = nil
      while ACTION_TYPES.include?(@texts[@show_index][1])
        time = case @texts[@show_index][1]
          when :Delay then @texts[@show_index][2] || 1
          when :React then 0.5
          when :Edit then 0.5
          when :Delete then 0.5
          when :Availability then 0
          when :Typing then @texts[@show_index][2] || 1.5
          else 0
          end
        delay = pbTXWSecondsToFrameConvert(time)
        until delay <= 0
          Graphics.update
          Input.update
          pbUpdate
          if Input.trigger?(Input::SPECIAL) && InstantMessagesSettings::ALLOW_FAST_FORWARD && !@allow_scroll
            pbToggleFastForward
          end
          delay -= 1
          delay -= 1 if @speed_up
          
          if @texts[@show_index][1] == :Typing
            member = @texts[@show_index][0]
            if member.is_a?(Array)
              if member.length > 2
                typing_text = _INTL("Multiple are typing")
              else
                typing_text = _INTL("{1}, {2} are typing", *[@members[member[0]].name, @members[member[1]].name].sort)
              end
              member.each { |m| make_member_available(m) } if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(:Typing)
            elsif member < 0 || member >= @members.length
              typing_text = _INTL("Multiple are typing")
            else
              typing_text = _INTL("{1} is typing", @members[member].name)
              make_member_available(member) if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(:Typing)
            end
            typing_frame = @typing_timer % pbTXWSecondsToFrameConvert(1)
            if typing_frame < pbTXWSecondsToFrameConvert(1) / 4
            elsif typing_frame < pbTXWSecondsToFrameConvert(1) / 2
              typing_text += "."
            elsif typing_frame < pbTXWSecondsToFrameConvert(3) / 4
              typing_text += ".."
            else
              typing_text += "..."
            end
            @sprites["overlay_bottom"].bitmap.clear
            pbDrawTextPositions(@sprites["overlay_bottom"].bitmap,[[typing_text, 32, Graphics.height - 20, 0, MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR]])
            
            @typing_timer += 1
            @typing_timer += 1 if @speed_up
            @typing_timer = 0 if @typing_timer >= pbTXWSecondsToFrameConvert(1)
          end
        end
        if @texts[@show_index][1] == :Typing
          @sprites["overlay_bottom"].bitmap.clear
          @typing_timer = 0
        end

        if @texts[@show_index][1] == :Availability && @texts[@show_index][0] >= 0
          pbUpdateMemberAvailability(@texts[@show_index][0], @texts[@show_index][2])
        end

        if @texts[@show_index][1] == :React
          prev = get_previous_message
          if @sprites["text#{prev}"].y + @sprites["text#{prev}"].height - 12 + @sprites["reaction_selector"].height > @bottom_margin
            diff = @sprites["text#{prev}"].y + @sprites["text#{prev}"].height - 12 + @sprites["reaction_selector"].height - @bottom_margin
            pbMoveUp(value: diff)
          end
          if @texts[@show_index][0] == 0 && @texts[@show_index][2].is_a?(Array)
            @sprites["reaction_selector"].set_reactions(@texts[@show_index][2])
          end
          can_skip = @texts[@show_index][3] || InstantMessagesSettings::REACTIONS_CAN_CANCEL_DEFAULT
          @sprites["reaction_selector"].can_skip = can_skip
          @sprites["reaction_selector"].x = [@sprites["text#{prev}"].x + (@sprites["text#{prev}"].width - @sprites["reaction_selector"].width) / 2,
              @sprites["text#{prev}"].x + 6].max
          @sprites["reaction_selector"].y = @sprites["text#{prev}"].y + @sprites["text#{prev}"].height - 16
          if @texts[@show_index][0] == 0
            reaction = [pbReact, 0]
            @choice_made = (reaction && reaction[0]) ? reaction[0] : -1
            if @texts[@show_index][2].is_a?(Array)
              reaction[0] = @sprites["reaction_selector"].reactions[@choice_made] if @choice_made >= 0
              @sprites["reaction_selector"].reset_reactions
            end
          else
            if @texts[@show_index][2].is_a?(Array)
              if @choice_made
                reaction = [@texts[@show_index][2][@choice_made], @texts[@show_index][0]]
              else
                reaction = [@texts[@show_index][2].sample, @texts[@show_index][0]]
              end
            else
              reaction = [@texts[@show_index][2] || @sprites["reaction_selector"].reactions.sample, @texts[@show_index][0]]
            end
          end
          if reaction && reaction[0] && prev >= 0
            prev_text_index = prev
            bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
            member_icons = InstantMessagesSettings::REACTIONS_SHOW_MEMBER_PICTURE
            @reactions[prev] ||= []
            @texts_linked_convos[prev][0].reactions[@texts_linked_convos[prev][1]] ||= []
            if reaction[0].is_a?(String)
              @reactions[prev].push(reaction)
              @texts_linked_convos[prev][0].reactions[@texts_linked_convos[prev][1]].push(reaction)
            else
              r = [@sprites["reaction_selector"].reactions[reaction[0]], reaction[1]]
              @reactions[prev].push(r)
              @texts_linked_convos[prev][0].reactions[@texts_linked_convos[prev][1]].push(r)
            end
            if !@sprites["reactions#{prev}"]
              @sprites["reactions#{prev}"] = BitmapSprite.new(Graphics.width - @side_margin*2, (bubble_bg ? 36 : 32), @viewport)
              @sprites["reactions#{prev}"].x = @sprites["text#{prev}"].x
              @sprites["reactions#{prev}"].y = @sprites["text#{prev}"].y + @sprites["text#{prev}"].height - (bubble_bg ? 12 : 24)
              @sprites["reactions#{prev}"].z = @sprites["text#{prev}"].z + 1
            end
            reactimgpos_bg = []
            reactimgpos_members = []
            reactimgpos_icon = []
            reverse = @sprites["text#{prev}"].x != @side_margin
            @sprites["reactions#{prev}"].bitmap.clear
            if reverse
              @sprites["reactions#{prev}"].x = @sprites["text#{prev}"].x + @sprites["text#{prev}"].width - @sprites["reactions#{prev}"].width
              @reactions[prev].each_with_index do |r, i|
                x_adj = member_icons ? 26 : 0
                if bubble_bg
                  bg = "Graphics/UI/Instant Messages/react_bubble"
                  bg += "_long" if member_icons
                  reactimgpos_bg.push([bg, @sprites["reactions#{prev}"].width - 6 - (i + 1)*(42 + x_adj), 0])
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", @sprites["reactions#{prev}"].width - (i + 1)*(42 + x_adj), 0])
                else
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", @sprites["reactions#{prev}"].width - 6 - (i + 1)*(24 + x_adj), 0])
                end
                reactimgpos_members.push(r[1]) if member_icons
              end
            else
              @reactions[prev].each_with_index do |r, i|
                x_adj = member_icons ? 26 : 0
                if bubble_bg
                  bg = "Graphics/UI/Instant Messages/react_bubble"
                  bg += "_long" if member_icons
                  reactimgpos_bg.push([bg, 8 + i*(42 + x_adj), 0])
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", 14 + i*(42 + x_adj), 0])
                else
                  reactimgpos_icon.push(["Graphics/Icons/#{r[0]}", 8 + i*(24 + x_adj), 0])
                end
                reactimgpos_members.push(r[1]) if member_icons
              end
            end
            pbDrawImagePositions(@sprites["reactions#{prev}"].bitmap, reactimgpos_bg)
            if member_icons
              reactimgpos_members.each_with_index do |m, i|
                member_bmp = Bitmap.new(pbGetMemberImage(m, small: true))
                @sprites["reactions#{prev}"].bitmap.stretch_blt(Rect.new(reactimgpos_icon[i][1] + 26, reactimgpos_icon[i][2] + 4, 
                    member_bmp.width / (member_bmp.width > 28 ? 2 : 1), member_bmp.height / (member_bmp.height > 28 ? 2 : 1)), member_bmp, Rect.new(0, 0, member_bmp.width, member_bmp.height))
                member_bmp.dispose
              end
            end
            pbDrawImagePositions(@sprites["reactions#{prev}"].bitmap, reactimgpos_icon)
            pbSEPlay(InstantMessagesSettings::REACTION_SOUND_EFFECT, 100, InstantMessagesSettings::REACTION_SOUND_EFFECT_PITCH)
            make_member_available(reaction[1]) if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(:React)
            
            if @sprites["text#{prev}"].y + @sprites["text#{prev}"].height - 12 + @sprites["reactions#{prev}"].height > @bottom_margin
              diff = @sprites["text#{prev}"].y + @sprites["text#{prev}"].height - 12 + @sprites["reactions#{prev}"].height - @bottom_margin
              pbMoveUp(value: diff)
            end
          end
        end
        if [:Edit, :Delete].include?(@texts[@show_index][1])
          height_adjustment = 25
          prev = get_previous_message
          prev_text_index = prev
          if @texts[@show_index][1] == :Edit
            @sprites["text#{prev}"].text = @texts[@show_index][2]
            @sprites["text#{prev}"].resizeToFit(@sprites["text#{prev}"].text, @max_width)
            @sprites["text#{prev}"].height += height_adjustment
            @sprites["text#{prev}"].resizeContents(height_adjustment)
            pbSetSmallFont(@sprites["text#{prev}"].contents)
            drawFormattedTextEx(@sprites["text#{prev}"].contents, 0, @sprites["text#{prev}"].contents.height - 21, @sprites["text#{prev}"].contents.width, 
                _INTL("<ar><i>Edited</i></ar>"), @sprites["text#{prev}"].baseColor, @sprites["text#{prev}"].shadowColor, lineheight = 21)
            pbSetSystemFont(@sprites["text#{prev}"].contents)
            make_member_available(@texts[@show_index][0]) if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(:Edit)
          elsif @texts[@show_index][1] == :Delete
            @sprites["text#{prev}"].text = @texts[@show_index][2] || InstantMessagesSettings::MESSAGE_DELETE_TEXT_DEFAULT
            @sprites["text#{prev}"].resizeToFit(@sprites["text#{prev}"].text, @max_width)
            make_member_available(@texts[@show_index][0]) if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(:Delete)
          end
          @sprites["reactions#{prev}"].y += height_adjustment if @sprites["reactions#{prev}"]
          if @sprites["picture#{prev}"]
            @sprites["picture#{prev}"].x = @sprites["text#{prev}"].x + @sprites["text#{prev}"].width + 4
            @sprites["picture#{prev}"].y = @sprites["text#{prev}"].y + get_y_adj(@sprites["text#{prev}"].height, @sprites["picture#{prev}"].height)
          end
          y_adj = (@sprites["reactions#{prev}"] ? (InstantMessagesSettings::REACTIONS_BUBBLE_BG ? 24 : 8) : 0)
          if @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj > @bottom_margin
            diff = @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj - @bottom_margin
            pbMoveUp(value: diff)
          end
        end
        @show_index += 1
        return if @texts[@show_index].nil?

        #Adjust the next text to get the proper height updates
        if prev_text_index && @sprites["text#{@show_index}"]
          y_adj = (@sprites["reactions#{prev_text_index}"] ? (InstantMessagesSettings::REACTIONS_BUBBLE_BG ? 24 : 8) : 0)
          @sprites["text#{@show_index}"].y = @sprites["text#{prev_text_index}"].y + @sprites["text#{prev_text_index}"].height + y_adj
          @sprites["text#{@show_index}"].orig_y = @sprites["text#{@show_index}"].y
          if @sprites["picture#{@show_index}"]
            @sprites["picture#{@show_index}"].y = @sprites["text#{@show_index}"].y + get_y_adj(@sprites["text#{@show_index}"].height, @sprites["picture#{@show_index}"].height)
          end
        end

      end
    end

    def check_next_text
      return false if @allow_scroll
      return true if @texts[@show_index].nil?

      show_next_message = false
      pause_time = @pause_time
      
      skip_typing = true if [:Picture, :Forward].include?(@texts[@show_index][1])
      if @texts_linked_convos[@show_index][0].instant
        check_next_text_y
        @show_index += 1
        return false
      end
      @sprites["overlay_bottom"].bitmap.clear
      if @show_index == 0 # First message of the chat
        pbMakeMessageVisible(@sprites["text#{@show_index}"], @sprites["picture#{@show_index}"], @show_index)
        check_next_text_y #Do this before adding to index, so it adjusts the first message if long or after old texts
        pbSEPlay(InstantMessagesSettings::MESSAGE_BUBBLE_SOUND_EFFECT, 100)
        @show_index += 1
      elsif @texts[@show_index][0] < 0 # System Text
        skip_typing = true
        pause_time = @system_pause_time
        if @timer > pause_time
          nxt = @show_index + 1
          react_to_message = false
          while @texts[nxt] && ACTION_TYPES.include?(@texts[nxt][1])
            react_to_message = true if @texts[nxt][1] == :React
            nxt += 1
          end
          #Adjust the next text to get the proper height updates
          if @sprites["text#{nxt}"]
            @sprites["text#{nxt}"].y = (@sprites["text#{@show_index}"] ? @sprites["text#{@show_index}"].y + @sprites["text#{@show_index}"].height : @top_margin)
            if react_to_message
              bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
              @sprites["text#{nxt}"].y += (bubble_bg ? 24 : 8)              
            end
            @sprites["text#{nxt}"].orig_y = @sprites["text#{nxt}"].y
            if @sprites["picture#{nxt}"]
              @sprites["picture#{nxt}"].x = @sprites["text#{nxt}"].x + @sprites["text#{nxt}"].width + 4
              @sprites["picture#{nxt}"].y = @sprites["text#{nxt}"].y + get_y_adj(@sprites["text#{nxt}"].height, @sprites["picture#{nxt}"].height)
            end
          end
          show_next_message = true 
        end
      elsif @texts[@show_index][0] == 0 #Player Choice
        pbTXWSecondsToFrameConvert(1).times do
          Graphics.update
          Input.update
          pbUpdate
        end
        if @texts[@show_index][2].is_a?(Array)
          cmds = @texts[@show_index][2]
          choice = pbDisplayForcedCommands(nil,cmds)
          @texts[@show_index][4] = choice #Add choice selection to index 4
          if @texts[@show_index][3] #saves value to variable
            val = @texts[@show_index][3]
            if val.is_a?(String) #Run eval
              val.gsub!(/{VALUE}/i, choice.to_s)
              eval(val)
            elsif val.is_a?(Integer) #game variable
              pbSet(val, choice)
            end
          end
          @sprites["text#{@show_index}"].text = @texts[@show_index][2][choice]
        else
          choice = 0
          @texts[@show_index][4] = choice
          if @texts[@show_index][3] 
            val = @texts[@show_index][3]
            if val.is_a?(String) #Run eval
              val.gsub!(/{VALUE}/i, choice.to_s)
              eval(val)
            elsif val.is_a?(Integer) #game variable
              pbSet(val, choice)
            end
          end
          @sprites["text#{@show_index}"].text = @texts[@show_index][2]
        end
        @sprites["text#{@show_index}"].resizeToFit(@sprites["text#{@show_index}"].text, @max_width)
        @sprites["text#{@show_index}"].x = Graphics.width - @side_margin - @sprites["text#{@show_index}"].width
        prev = get_previous_message
        @sprites["text#{@show_index}"].y = (@sprites["text#{prev}"] ? @sprites["text#{prev}"].y + @sprites["text#{prev}"].height : @top_margin)
        if @sprites["reactions#{prev}"]
          bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
          @sprites["text#{@show_index}"].y += (bubble_bg ? 24 : 8)              
        end
        @sprites["text#{@show_index}"].orig_y = @sprites["text#{@show_index}"].y
        if @sprites["picture#{@show_index}"]
          @sprites["picture#{@show_index}"].x = @sprites["text#{@show_index}"].x - @sprites["picture#{@show_index}"].width - 4
          @sprites["picture#{@show_index}"].y = @sprites["text#{@show_index}"].y + get_y_adj(@sprites["text#{@show_index}"].height, @sprites["picture#{@show_index}"].height)
        end
        @choice_made = choice
        
        nxt = @show_index + 1
        react_to_player = false
        while @texts[nxt] && ACTION_TYPES.include?(@texts[nxt][1])
          react_to_player = true if @texts[nxt][1] == :React
          nxt += 1
        end
        #Adjust the next text to get the proper height updates
        if @sprites["text#{nxt}"]
          @sprites["text#{nxt}"].y = (@sprites["text#{@show_index}"] ? @sprites["text#{@show_index}"].y + @sprites["text#{@show_index}"].height : @top_margin)
          if react_to_player
            bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
            @sprites["text#{nxt}"].y += (bubble_bg ? 24 : 8)              
          end
          @sprites["text#{nxt}"].orig_y = @sprites["text#{nxt}"].y
          if @sprites["picture#{nxt}"]
            @sprites["picture#{nxt}"].x = @sprites["text#{nxt}"].x + @sprites["text#{nxt}"].width + 4
            @sprites["picture#{nxt}"].y = @sprites["text#{nxt}"].y + get_y_adj(@sprites["text#{nxt}"].height, @sprites["picture#{nxt}"].height)
          end
        end
        show_next_message = true
      elsif @timer >= pause_time + (skip_typing ? 0 : pbGetTypingTime )
        if @retype[@show_index]
          @timer = 0
          @retype[@show_index] = nil
          return false
        end
        if @choice_made #Player made a choice before, react to it.
          if @texts[@show_index][2].is_a?(Array)
            @texts[@show_index][4] = @choice_made  #Add choice selection to index 4
            @sprites["text#{@show_index}"].text = @texts[@show_index][2][@choice_made]
            @sprites["text#{@show_index}"].resizeToFit(@sprites["text#{@show_index}"].text, @max_width)
            @sprites["text#{@show_index}"].height += 32 if [:Reply, :Forward].include?(@texts[@show_index][1])
            prev = get_previous_message
            @sprites["text#{@show_index}"].y = (@sprites["text#{prev}"] ? @sprites["text#{prev}"].y + @sprites["text#{prev}"].height : @top_margin)
            if @sprites["reactions#{prev}"]
              bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
              @sprites["text#{@show_index}"].y += (bubble_bg ? 24 : 8)
            end
            @sprites["text#{@show_index}"].orig_y = @sprites["text#{@show_index}"].y
            if @sprites["picture#{@show_index}"]
              @sprites["picture#{@show_index}"].x = @sprites["text#{@show_index}"].x + @sprites["text#{@show_index}"].width + 4
              @sprites["picture#{@show_index}"].y = @sprites["text#{@show_index}"].y + get_y_adj(@sprites["text#{@show_index}"].height, @sprites["picture#{@show_index}"].height)
            end
          end
        end

        nxt = @show_index + 1
        reacts_to_message = false
        while @texts[nxt] && ACTION_TYPES.include?(@texts[nxt][1])
          reacts_to_message = true if @texts[nxt][1] == :React
          nxt += 1
        end

        #Adjust the next text to get the proper height updates
        if @sprites["text#{nxt}"]
          @sprites["text#{nxt}"].y = (@sprites["text#{@show_index}"] ? @sprites["text#{@show_index}"].y + @sprites["text#{@show_index}"].height : @top_margin)
          if reacts_to_message
            bubble_bg = InstantMessagesSettings::REACTIONS_BUBBLE_BG
            @sprites["text#{nxt}"].y += (bubble_bg ? 24 : 8)              
          end
          @sprites["text#{nxt}"].orig_y = @sprites["text#{nxt}"].y
          if @sprites["picture#{nxt}"]
            @sprites["picture#{nxt}"].x = @sprites["text#{nxt}"].x + @sprites["text#{nxt}"].width + 4
            @sprites["picture#{nxt}"].y = @sprites["text#{nxt}"].y + get_y_adj(@sprites["text#{nxt}"].height, @sprites["picture#{nxt}"].height)
          end
        end
        show_next_message = true
      elsif skip_typing.nil? && @show_index > 0 && @timer > pause_time
        typing_text = _INTL("{1} is typing", @members[@texts[@show_index][0]].name)
        if @typing_timer < pbTXWSecondsToFrameConvert(1) / 4
        elsif @typing_timer < pbTXWSecondsToFrameConvert(1) / 2
          typing_text += "."
        elsif @typing_timer < pbTXWSecondsToFrameConvert(3) / 4
          typing_text += ".."
        else
          typing_text += "..."
        end
        pbSetSmallFont(@sprites["overlay_bottom"].bitmap)
        textpos = []
        textpos.push([typing_text, 32, Graphics.height - 20, 0, MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR])
        pbDrawTextPositions(@sprites["overlay_bottom"].bitmap,textpos)
        make_member_available(@texts[@show_index][0]) if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(@texts[@show_index][1])
        @typing_timer += 1
        @typing_timer += 1 if @speed_up
        @typing_timer = 0 if @typing_timer >= pbTXWSecondsToFrameConvert(1)
      end
      if show_next_message
        check_next_text_y
        pbMakeMessageVisible(@sprites["text#{@show_index}"], @sprites["picture#{@show_index}"], @show_index)
        pbSEPlay(InstantMessagesSettings::MESSAGE_BUBBLE_SOUND_EFFECT, 100)
        @show_index += 1
        @timer = 0
        @typing_timer = 0
        return true if @show_index >= @max_texts
      end
      @timer += 1
      @timer += 1 if @speed_up
      return false
    end

    def check_next_text_y
      next_text = @sprites["text#{@show_index}"]
      if next_text.y + next_text.height > @bottom_margin
        diff = next_text.y + next_text.height - @bottom_margin
        pbMoveUp(value: diff)
      end
    end

    def pbConvertTimeStamp(instance)
      now = pbGetTimeNow
      diff = now - instance
      if diff < 86400 && now.day == instance.day # now.strftime("%m/%d/%Y") == instance.strftime("%m/%d/%Y")
        val = _INTL("Today at {1}", instance.strftime("%I:%M %p"))
      elsif diff < 86400 * 2 && (now - 86400).day == instance.day
        val = _INTL("Yesterday at {1}", instance.strftime("%I:%M %p"))
      else 
        days = (diff / 86400).floor
        if days >= 7
          val = _INTL("{1} days ago at {2}", days.to_s_formatted, instance.strftime("%I:%M %p"))
        else
          case instance.wday
          when 0
            wd = "Sun"
          when 1
            wd = "Mon"
          when 2
            wd = "Tue"
          when 3
            wd = "Wed"
          when 4
            wd = "Thur"
          when 5
            wd = "Fri"
          when 6
            wd = "Sat"
          end
          val = _INTL("{1} at {2}", wd, instance.strftime("%I:%M %p"))
        end
      end
      return val
    end

    def pbGetTypingTime
      text = @sprites["text#{@show_index}"].text.clone
      text.gsub!(/\<(\w+)\>/i,   "")
      text.gsub!(/\<\/(\w+)\>/i,   "")
      text.gsub!(/\<icon\=(\w+)\>/i,   "...")       
      return text.length * pbTXWSecondsToFrameConvert(1)/20 
    end

    def pbAddReplyToOldMessage(text_sprite, index)
      source_msg = @old_texts[index][3]
      if source_msg.nil?
        prev = get_previous_oldmessage(index)
      elsif source_msg < 0
        prev = nil
        source_msg.abs.times { prev = get_previous_oldmessage((prev ? prev : index)) }
      else
        prev = index - @old_texts_linked_convos[index][1] + source_msg
      end
      if @sprites["oldtext#{prev}"]
        picture = @sprites["old_text_picture#{prev}"]
        picture_text = InstantMessagesSettings::REPLY_PICTURE_REPLACE_WITH_TEXT ? InstantMessagesSettings::REPLY_PICTURE_REPLACE_TEXT : ""
        text = picture ? picture_text : @sprites["oldtext#{prev}"].text.dup
        member = @old_texts[prev][0]
        
        text_sprite.shiftContentsForReply
        
        if member >= 0
          member_bmp = Bitmap.new(pbGetMemberImage(member, small: true))
        end

        box_height = 28

        member_width = (member_bmp ? member_bmp.width / (member_bmp.width > 28 ? 2 : 1) : 0)
        temp_bmp = Bitmap.new(text_sprite.contents.width - 12 - member_width - text_sprite.edges[1].width - text_sprite.edges[2].width, box_height)
        pbSetSmallFont(temp_bmp)
        icons = []
        text.gsub!(/<icon=([^>]+)>/i) do |match|
          icons.push(match)
          "{ICON#{icons.length - 1}}"
        end
        #text.gsub!(/\\pn/i,  $player.name) if $player
		text.gsub!(/\\ppr\[([0-9]+)\]\[([0-9]+)\]/i) { anPlayerPronoun($1.to_i,$2.to_i) }
		text.gsub!(/\\empty/i, "")
        text = toUnformattedText(text)
        icons.each_with_index do |icon, i|
          text.gsub!("{ICON#{i}}", icon)
        end
        text.gsub!(/\s+/, " ")
        text.strip!
        icon_width = (24.0 / temp_bmp.text_size(" ").width).ceil
        spaces = " " * icon_width
        if temp_bmp.text_size(text.gsub(/<icon=[^>]+>/i, spaces)).width > temp_bmp.width
          chars = text.scan(/<icon=[^>]+>|\s+|./im)
          while chars.length > 0
            try = chars.join.rstrip + "..."
            try = try.gsub(/<icon=[^>]+>/i, spaces)
            break if temp_bmp.text_size(try).width < temp_bmp.width
            chars.pop
          end
          text = chars.join.rstrip + "..."
        end
        drawFormattedTextEx(temp_bmp, 0, 8, text_sprite.contents.width, text, text_sprite.baseColor, text_sprite.shadowColor, lineheight = MessageConfig::SMALL_FONT_SIZE)

        if temp_bmp.width > text_sprite.width
          text_sprite.width += temp_bmp.width - text_sprite.width
          text_sprite.shiftContentsForReply
          @sprites["oldpicture#{index}"].x = text_sprite.x + text_sprite.width + 4 if @sprites["oldpicture#{index}"]
        end

        text_sprite.contents.fill_rect(Rect.new(0, 0, 8, box_height), Color.new(0, 0, 0, 100))
        text_sprite.contents.fill_rect(Rect.new(8, 0, text_sprite.contents.width - 8, box_height), Color.new(255, 255, 255, 200))
              
        text_sprite.contents.blt(12 + member_width + 4, 0, temp_bmp, Rect.new(0, 0, temp_bmp.width, temp_bmp.height))
        text_sprite.contents.stretch_blt(Rect.new(12, 0, member_bmp.width / (member_bmp.width > 28 ? 2 : 1), member_bmp.height / (member_bmp.height > 28 ? 2 : 1)),
            member_bmp, Rect.new(0, 0, member_bmp.width, member_bmp.height)) if member_bmp

        if picture && !InstantMessagesSettings::REPLY_PICTURE_REPLACE_WITH_TEXT
          pic_bmp = picture.bitmap
          text_sprite.contents.stretch_blt(Rect.new(12 + member_width + 4, 2, 
            (((box_height - 4) / pic_bmp.height.to_f) * pic_bmp.width).floor, box_height - 4),
            pic_bmp, Rect.new(0, 0, pic_bmp.width, pic_bmp.height))
        end

        member_bmp&.dispose
        temp_bmp.dispose
      end
    end

    def pbAddReplyToMessage(text_sprite, index)
      source_msg = @texts[index][3]
      if source_msg.nil?
        prev = get_previous_message
      elsif source_msg < 0
        prev = nil
        source_msg.abs.times { prev = get_previous_message((prev ? prev : index)) }
      else
        prev = index - @texts_linked_convos[index][1] + source_msg
        Console.echo_warn("Conversation :#{@texts_linked_convos[index][0].id}, :messages index #{@texts_linked_convos[index][1]}" +
            "\n:Reply in doesn't have a valid reference: index #{prev} => #{@texts[prev]}.") if @sprites["text#{prev}"].nil?
      end
      if @sprites["text#{prev}"]
        picture = @sprites["text_picture#{prev}"]
        picture_text = InstantMessagesSettings::REPLY_PICTURE_REPLACE_WITH_TEXT ? _INTL("[Image]") : ""
        text = picture ? picture_text : @sprites["text#{prev}"].text.dup
        member = @texts[prev][0]
        
        text_sprite.shiftContentsForReply

        if member >= 0
          member_bmp = Bitmap.new(pbGetMemberImage(member, small: true))
        end

        box_height = 28

        member_width = (member_bmp ? member_bmp.width / (member_bmp.width > 28 ? 2 : 1) : 0)
        temp_bmp = Bitmap.new(text_sprite.contents.width - 12 - member_width - text_sprite.edges[1].width - text_sprite.edges[2].width, box_height)
        pbSetSmallFont(temp_bmp)
        icons = []
        text.gsub!(/<icon=([^>]+)>/i) do |match|
          icons.push(match)
          "{ICON#{icons.length - 1}}"
        end
        text = toUnformattedText(text)
        icons.each_with_index do |icon, i|
          text.gsub!("{ICON#{i}}", icon)
        end
        text.gsub!(/\s+/, " ")
        text.strip!
        icon_width = (24.0 / temp_bmp.text_size(" ").width).ceil
        spaces = " " * icon_width
        if temp_bmp.text_size(text.gsub(/<icon=[^>]+>/i, spaces)).width > temp_bmp.width
          chars = text.scan(/<icon=[^>]+>|\s+|./im)
          while chars.length > 0
            try = chars.join.rstrip + "..."
            try = try.gsub(/<icon=[^>]+>/i, spaces)
            break if temp_bmp.text_size(try).width < temp_bmp.width
            chars.pop
          end
          text = chars.join.rstrip + "..."
        end
        # Icons will be too low compared to the small text size. To fix this (will apply everywhere), add the following line 
        # after yStart += 4 in getFormattedText in the DrawText script
        #  yStart -= bitmap&.text_offset_y || 0 if bitmap.font.size == MessageConfig::SMALL_FONT_SIZE
        drawFormattedTextEx(temp_bmp, 0, 8, text_sprite.contents.width, text, text_sprite.baseColor, text_sprite.shadowColor, lineheight = MessageConfig::SMALL_FONT_SIZE)

        if temp_bmp.width > text_sprite.width
          text_sprite.width += temp_bmp.width - text_sprite.width
          text_sprite.shiftContentsForReply
          @sprites["picture#{index}"].x = text_sprite.x + text_sprite.width + 4 if @sprites["picture#{index}"]
        end

        text_sprite.contents.fill_rect(Rect.new(0, 0, 8, box_height), Color.new(0, 0, 0, 100))
        text_sprite.contents.fill_rect(Rect.new(8, 0, text_sprite.contents.width - 8, box_height), Color.new(255, 255, 255, 200))
              
        text_sprite.contents.blt(12 + member_width + 4, 0, temp_bmp, Rect.new(0, 0, temp_bmp.width, temp_bmp.height))
        text_sprite.contents.stretch_blt(Rect.new(12, 0, member_bmp.width / (member_bmp.width > 28 ? 2 : 1), member_bmp.height / (member_bmp.width > 28 ? 2 : 1)),
            member_bmp, Rect.new(0, 0, member_bmp.width, member_bmp.height)) if member_bmp

        if picture && !InstantMessagesSettings::REPLY_PICTURE_REPLACE_WITH_TEXT
          pic_bmp = picture.bitmap
          text_sprite.contents.stretch_blt(Rect.new(12 + member_width + 4, 2, 
            (((box_height - 4) / pic_bmp.height.to_f) * pic_bmp.width).floor, box_height - 4),
            pic_bmp, Rect.new(0, 0, pic_bmp.width, pic_bmp.height))
        end

        member_bmp&.dispose
        temp_bmp.dispose
      end
    end

    def pbAddForwardTagToAnyMessage(text_sprite, index, member = nil)
        text_sprite.shiftContentsForForward

        fwd_bmp = Bitmap.new("Graphics/UI/Instant Messages/forward_icon")
        text_sprite.contents.fill_rect(Rect.new(0, 0, 8, text_sprite.contents.height), Color.new(0, 0, 0, 100))
        text_sprite.contents.blt(12, 0, fwd_bmp, Rect.new(0, 0, fwd_bmp.width, fwd_bmp.height)) if fwd_bmp
        text = _INTL("<i>Forwarded</i>")
        pbSetSmallFont(text_sprite.contents)
        if member && (member.is_a?(Symbol) || member >= 0)
          member_bmp = Bitmap.new(pbGetMemberImage(member, small: true))
          if member_bmp
            tag_width = 12 + (fwd_bmp.width || 0) + text_sprite.contents.text_size(toUnformattedText(text)).width
            member_width = (member_bmp.width / (member_bmp.width > 28 ? 2 : 1))
            text_sprite.contents.stretch_blt(Rect.new(tag_width + 6, 0, member_bmp.width / (member_bmp.width > 28 ? 2 : 1), member_bmp.height / (member_bmp.width > 28 ? 2 : 1)),
                member_bmp, Rect.new(0, 0, member_bmp.width, member_bmp.height))
          end
          member_bmp&.dispose
        end
        drawFormattedTextEx(text_sprite.contents, 12 + fwd_bmp&.width || 0, 8, text_sprite.contents.width, text, text_sprite.baseColor, text_sprite.shadowColor, lineheight = MessageConfig::SMALL_FONT_SIZE)
        pbSetSystemFont(text_sprite.contents)

        fwd_bmp&.dispose
    end

    def pbMakeMessageVisible(text_sprite, picture_sprite, index)
      pbAddReplyToMessage(text_sprite, index) if @texts[index][1] == :Reply
      pbAddForwardTagToAnyMessage(text_sprite, index, @texts[index][3]) if @texts[index][1] == :Forward
      text_sprite.visible = true
      picture_sprite&.visible = true# if picture_sprite
      if @sprites["text_picture#{index}"]
        @sprites["text_picture#{index}"].y = text_sprite.y + text_sprite.edges[0].height
        @sprites["text_picture#{index}"].visible = true
      end
      make_member_available(@texts[@show_index][0]) if COMMANDS_MAKE_MEMBER_AVAILABLE.include?(@texts[index][1])
      pbExecuteCode(index)
    end

    def pbRunTextThroughReplacement(text)
      text.gsub!(/\\pn/i,  $player.name) if $player
      text.gsub!(/\\pm/i,  _INTL("${1}", $player.money.to_s_formatted)) if $player
      text.gsub!(/\\n/i,   "\n")
      text.gsub!(/\\\[([0-9a-f]{8,8})\]/i) { "<c2=" + $1 + ">" }
      text.gsub!(/\\pg/i,  "\\b") if $player&.male?
      text.gsub!(/\\pg/i,  "\\r") if $player&.female?
      text.gsub!(/\\pog/i, "\\r") if $player&.male?
      text.gsub!(/\\pog/i, "\\b") if $player&.female?
      text.gsub!(/\\pg/i,  "")
      text.gsub!(/\\pog/i, "")
      text.gsub!(/\\b/i,   "<c3=3050C8,D0D0C8>")
      text.gsub!(/\\r/i,   "<c3=E00808,D0D0C8>")
      loop do
        last_text = text.clone
        text.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
        break if text == last_text
      end
      return text
    end

    def pbMoveUp(large = false, value: nil, prev_message: nil, to_bottom: false)
      move_val = value || @scroll_rate * (large ? 5 : 1)
      move_val = 999999 if to_bottom
      last = nil
      if @only_old
        last = prev_message || get_previous_oldmessage(@old_texts.length )
        last_text = @sprites["oldtext#{last}"]
      else
        last = prev_message || get_previous_message(@max_texts)
        last_text = @sprites["text#{last}"]
      end
      return if last_text.nil?
      y_adj = 0
      if value.nil?
        bottom = @tempbottomy || @bottom_margin
        y_adj = (@sprites["reactions#{last}"] || (@only_old && @sprites["oldreactions#{last}"])) ? (InstantMessagesSettings::REACTIONS_BUBBLE_BG ? 24 : 8) : 0
        if last_text.y + last_text.height + y_adj <= bottom
          return
        elsif last_text.y + last_text.height + y_adj - move_val < bottom
          diff = last_text.y + last_text.height + y_adj - move_val - bottom
          move_val += diff
        end
      end
      @old_texts.length.times do |j|
        @sprites["oldtext#{j}"]&.y -= move_val
        @sprites["oldpicture#{j}"]&.y -= move_val 
        @sprites["old_text_picture#{j}"]&.y -= move_val
        @sprites["oldmessagetimestamp#{j}"]&.y -= move_val
        @sprites["oldreactions#{j}"]&.y -= move_val
      end
      @sprites["oldmessagedivider"]&.y -= move_val 
      @sprites["unreaddivider"]&.y -= move_val 
      @max_texts.times do |i|
        @sprites["text#{i}"]&.y -= move_val
        @sprites["picture#{i}"]&.y -= move_val 
        @sprites["text_picture#{i}"]&.y -= move_val
        @sprites["newmessagetimestamp#{i}"]&.y -= move_val
        @sprites["reactions#{i}"]&.y -= move_val
      end
    end

    def pbMoveDown(large = false, value: nil)
      move_val = value || @scroll_rate * (large ? 5 : 1)
      if @only_old
        first_text = @sprites["oldtext0"]
      else
        first_text = @sprites["text0"]
      end
      return if first_text.nil?
      if first_text.y == first_text.orig_y
        return
      elsif first_text.y + move_val > first_text.orig_y
        diff = first_text.y + move_val - first_text.orig_y
        move_val -= diff
      end
      @old_texts.length.times do |j|
        @sprites["oldtext#{j}"]&.y += move_val
        @sprites["oldpicture#{j}"]&.y += move_val 
        @sprites["old_text_picture#{j}"]&.y += move_val
        @sprites["oldmessagetimestamp#{j}"]&.y += move_val
        @sprites["oldreactions#{j}"]&.y += move_val
      end
      @sprites["oldmessagedivider"]&.y += move_val 
      @sprites["unreaddivider"]&.y += move_val 
      @max_texts.times do |i|
        @sprites["text#{i}"]&.y += move_val
        @sprites["picture#{i}"]&.y += move_val 
        @sprites["text_picture#{i}"]&.y += move_val
        @sprites["newmessagetimestamp#{i}"]&.y += move_val
        @sprites["reactions#{i}"]&.y += move_val
      end
    end

    def pbEnableScrolling
      @allow_scroll = true
      @sprites["closebutton"]&.opacity = 255
      pbToggleFastForward(false)
    end

    def pbToggleFastForward(value = nil)
      return if !InstantMessagesSettings::ALLOW_FAST_FORWARD
      if value.nil?
        @speed_up = !@speed_up
      else
        @speed_up = value
      end
      @sprites["ffwdbutton"].opacity = (@speed_up ? 255 : 100)
    end

    def pbReact(index = 0)
      can_skip = @sprites["reaction_selector"].can_skip
      @sprites["reaction_selector"].index = index
      @sprites["reaction_selector"].visible = true
      loop do
        Graphics.update
        Input.update
        if Input.trigger?(Input::USE)
          @sprites["reaction_selector"].visible = false
          if can_skip && @sprites["reaction_selector"].index == @sprites["reaction_selector"].reactions.length
            pbPlayCancelSE
            return nil
          else
            return @sprites["reaction_selector"].index
          end
        elsif can_skip && Input.trigger?(Input::BACK)
          pbPlayCancelSE
          @sprites["reaction_selector"].visible = false
          return nil
        elsif Input.trigger?(Input::LEFT)
          pbPlayCursorSE
          @sprites["reaction_selector"].index -= 1
        elsif Input.trigger?(Input::RIGHT)
          pbPlayCursorSE
          @sprites["reaction_selector"].index += 1
        elsif Input.trigger?(Input::SPECIAL) && InstantMessagesSettings::ALLOW_FAST_FORWARD && !@allow_scroll
          pbToggleFastForward
        end
      end
    end

    def pbEndScene
      pbFadeOutAndHide(@sprites)
      pbDisposeSpriteHash(@sprites)
      @viewport.dispose
      @viewport2.dispose
      @old_scene.sprites["itemlist"].refresh if @old_scene && @old_scene.sprites["itemlist"]
    end

    def pbExecuteCode(index)
      array = @texts_code_to_execute[index]
      return unless array
      id = array[0]
      val = array[1]
      case id
      when :GroupName
        if val
          @group.title = val
        else
          @group.reset_title
        end
        pbRefreshGroupTitle
      end
    end

    def pbRefreshGroupTitle
      @sprites["overlay_title"].bitmap.clear
      show_prefix = InstantMessagesSettings::SHOW_CONVERSATION_PREFIX
      case show_prefix
      when 1, true
        prefix = InstantMessagesSettings::CONVERSATION_PREFIX + " "
      when 2
        if @members.length > 2
          prefix = ""
        else
          prefix = InstantMessagesSettings::CONVERSATION_PREFIX + " "
        end
      else
        prefix = ""
      end
      pbSetSmallFont(@sprites["overlay_title"].bitmap)
      textpos = [[_INTL("{1}{2}", prefix, @group.title), Graphics.width / 2, 4, 2, MessageConfig::LIGHT_TEXT_MAIN_COLOR, MessageConfig::LIGHT_TEXT_SHADOW_COLOR]]
      pbDrawTextPositions(@sprites["overlay_title"].bitmap,textpos)
    end
  
    def pbUpdate
      pbUpdateSpriteHash(@sprites)
    end

    def pbDisplayForcedCommands(text, commands)
      ret = -1
      using(cmdwindow = Window_CommandPokemonMessages.new(commands)) {
        cmdwindow.visible = false
        @sprites["playerreplypicture"].visible = false
        player_bubble_color = InstantMessagesSettings::PLAYER_BUBBLE_COLOR || "White"
        cmdwindow.setSkin("Graphics/UI/Instant Messages/Bubbles/#{player_bubble_color}")
        cmdwindow.resizeToFit(commands)
        cmdwindow.x = Graphics.width - cmdwindow.width - @side_margin
        cmdwindow.y = @bottom_margin - cmdwindow.height
        @tempbottomy = cmdwindow.y
        @sprites["playerreplypicture"].x = cmdwindow.x - @sprites["playerreplypicture"].width - 4
        case @picture_alignment
        when 1
          y_adj = cmdwindow.height - @sprites["playerreplypicture"].height - 6
        when 2
          y_adj = (cmdwindow.height - @sprites["playerreplypicture"].height) / 2
        else
          y_adj = 4
        end
        @sprites["playerreplypicture"].y = cmdwindow.y + y_adj

        prev = get_previous_message
        y_adj = (@sprites["reactions#{prev}"] ? (InstantMessagesSettings::REACTIONS_BUBBLE_BG ? 24 : 8) : 0)
        if @sprites["text#{prev}"] && @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj > cmdwindow.y
          diff = @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj - cmdwindow.y
          pbMoveUp(value: diff)
        end
        cmdwindow.z = @viewport.z + 1
        @sprites["playerreplypicture"].z = cmdwindow.z
        cmdwindow.visible = true
        @sprites["playerreplypicture"].visible = true
        reviewing = false
        scrolled_up = false
        loop do
          Graphics.update
          Input.update
          cmdwindow.update
          self.pbUpdate
          if Input.trigger?(Input::USE) && !reviewing
            ret = cmdwindow.index
            @sprites["playerreplypicture"].visible = false
            break
          elsif Input.trigger?(Input::ACTION) || (Input.trigger?(Input::BACK) && reviewing)
            if !reviewing
              reviewing = true
              cmdwindow.active = false
              cmdwindow.visible = false
              @sprites["playerreplypicture"].visible = false
            else 
              pbMoveUp(prev_message: prev, to_bottom: true) if scrolled_up
              scrolled_up = false
              reviewing = false 
              cmdwindow.active = true
              cmdwindow.visible = true
              @sprites["playerreplypicture"].visible = true
            end
          elsif Input.repeat?(Input::DOWN) && reviewing
            pbMoveUp(prev_message: prev)
            scrolled_up = @sprites["text#{prev}"] && @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj > @tempbottomy
          elsif Input.repeat?(Input::JUMPDOWN) && reviewing
            pbMoveUp(true, prev_message: prev)
            scrolled_up = @sprites["text#{prev}"] && @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj > @tempbottomy
          elsif Input.repeat?(Input::UP) && reviewing
            pbMoveDown
            scrolled_up = @sprites["text#{prev}"] && @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj > @tempbottomy
          elsif Input.repeat?(Input::JUMPUP) && reviewing
            pbMoveDown(true)
            scrolled_up = @sprites["text#{prev}"] && @sprites["text#{prev}"].y + @sprites["text#{prev}"].height + y_adj > @tempbottomy
          elsif Input.trigger?(Input::SPECIAL) && InstantMessagesSettings::ALLOW_FAST_FORWARD && !@allow_scroll
            pbToggleFastForward
          end
        end
        @tempbottomy = nil
      }
      return ret
    end

  class Window_AdvancedTextPokemonMessages < Window_AdvancedTextPokemon
    attr_accessor :orig_y

    def edges
      edges = []
      4.times do |i|
        edges.push(@sprites["side#{i}"])
      end
      return edges
    end

    def resizeContents(height_adj = nil, width_adj = nil)
      @bitmapheight += height_adj if height_adj
      @bitmapwidth += width_adj  if width_adj
      oldcontents = self.contents
      return if oldcontents.nil? || oldcontents.disposed?
      copy = Bitmap.new(oldcontents.width, oldcontents.height)
      copy.blt(0, 0, oldcontents, Rect.new(0, 0, oldcontents.width, oldcontents.height))
      newcontents = pbDoEnsureBitmap(self.contents, @bitmapwidth, @bitmapheight)
      newcontents.blt(0, 0, copy, Rect.new(0, 0, copy.width, copy.height))
      self.contents = newcontents
      copy.dispose
    end

    def shiftContentsForReply(height_adjustment = 32)
      width_adjustment = InstantMessages_Scene::MESSAGE_MAX_WIDTH - self.contents.width
      oldcontents = self.contents
      return if oldcontents.nil? || oldcontents.disposed?
      copy = Bitmap.new(oldcontents.width, oldcontents.height)
      copy.blt(0, 0, oldcontents, Rect.new(0, 0, oldcontents.width, oldcontents.height))
      @bitmapheight += height_adjustment
      @bitmapwidth += width_adjustment
      newcontents = pbDoEnsureBitmap(self.contents, @bitmapwidth, @bitmapheight)
      newcontents.blt(0, height_adjustment, copy, Rect.new(0, 0, copy.width, copy.height))
      self.contents = newcontents
      copy.dispose
    end

    def shiftContentsForForward(height_adjustment = 32)
      width_adjustment = 0
      if self.width - self.contents.width > 32 # Added for weird width inconsistency
        width_adjustment = self.width - self.contents.width 
      end
      oldcontents = self.contents
      return if oldcontents.nil? || oldcontents.disposed?
      copy = Bitmap.new(oldcontents.width, oldcontents.height)
      copy.blt(0, 0, oldcontents, Rect.new(0, 0, oldcontents.width, oldcontents.height))
      @bitmapheight += height_adjustment
      @bitmapwidth += width_adjustment
      newcontents = pbDoEnsureBitmap(self.contents, @bitmapwidth, @bitmapheight)
      newcontents.blt(12, height_adjustment, copy, Rect.new(0, 0, copy.width, copy.height))
      self.contents = newcontents
      copy.dispose
    end

  end

  class Window_CommandPokemonMessages < Window_CommandPokemon

    def drawItem(index, _count, rect)
      pbSetSystemFont(self.contents)
      rect = drawCursor(index, rect)
      if toUnformattedText(@commands[index]).gsub(/\n/, "") == @commands[index]
        # Use faster alternative for unformatted text without line breaks
        pbDrawShadowText(self.contents, rect.x, rect.y + 8, rect.width, rect.height,
                        @commands[index], self.baseColor, self.shadowColor)
      else
        chars = getFormattedText(self.contents, rect.x, rect.y + 8, rect.width, rect.height,
                                @commands[index], rect.height, true, true)
        chars.each do |c|
          next unless c[0].include?("Graphics/Icons/emoji")
          c[2] -= 6 
        end
        drawFormattedChars(self.contents, chars)
      end
    end
    
    # Use v22 code to allow it so emojis can appear in choices.
    def getAutoDims(commands, dims, width = nil)
      rowMax = ((commands.length + self.columns - 1) / self.columns).to_i
      windowheight = (rowMax * self.rowHeight)
      windowheight += self.borderY
      if !width || width < 0
        width = 0
        tmp_bitmap = Bitmap.new(1, 1)
        pbSetSystemFont(tmp_bitmap)
        commands.each do |cmd|
          txt = toUnformattedText(cmd).gsub(/\n/, "")
          txt_width = tmp_bitmap.text_size(txt).width
          check_text = cmd
          while check_text[FORMATREGEXP]
            if $~[2].downcase == "icon" && $~[3]
              check_text = $~.post_match
              filename = $~[4].sub(/\s+$/, "")
              temp_graphic = Bitmap.new("Graphics/Icons/#{filename}")
              txt_width += temp_graphic.width
              temp_graphic.dispose
            else
              check_text = $~.post_match
            end
          end
          width = [width, txt_width].max
        end
        # one 16 to allow cursor
        width += 16 + 16 + (Essentials::VERSION.include?("21") ? SpriteWindow_Base::TEXT_PADDING : SpriteWindow_Base::TEXTPADDING)
        tmp_bitmap.dispose
        end
      # Store suggested width and height of window
      dims[0] = [self.borderX + 1,
                (width * self.columns) + self.borderX + ((self.columns - 1) * self.columnSpacing)].max
      dims[1] = [self.borderY + 1, windowheight].max
      dims[1] = [dims[1], Graphics.height].min
    end

    def setSkin(skin)
      super(skin)
      file_location = Essentials::VERSION.include?("21") ? "UI" : "Pictures"
      arrow_name = (Essentials::VERSION.include?("21") ? "sel_arrow" : "selarrow")
      if isDarkWindowskin(self.windowskin)
        @selarrow = AnimatedBitmap.new("Graphics/#{file_location}/#{arrow_name}_white")
      else
        @selarrow = AnimatedBitmap.new("Graphics/#{file_location}/#{arrow_name}")
      end
    end
  end

  class MemberPhoto < IconSprite
    attr_accessor :member_index
  
    def initialize(x, y, member_index, scene, viewport)
      super(viewport)
      @member_index = member_index
      @scene = scene
      @viewport = viewport
      self.x = x
      self.y = y
      if @scene.show_availability?
        @availability = @scene.pbGetMemberAvailability(@member_index)
        if @availability
          @availability_icon = IconSprite.new(0, 0, @viewport)
          @availability_icon.setBitmap("Graphics/UI/Social Links/availability_small")
          @availability_icon_dimensions = [@availability_icon.width/SocialLinkAvailability.count, @availability_icon.height]
          @availability_icon.src_rect = Rect.new(@availability_icon_dimensions[0] * @availability, 0, @availability_icon_dimensions[0], @availability_icon_dimensions[1])
          @availability_icon.x = self.x + self.width - @availability_icon.width
          @availability_icon.y = self.y + self.height - @availability_icon.height
          @availability_icon.visible = false
        end
      end
      refresh
    end

    def refresh_availability
      return if @availability_icon.nil?
      @availability = @scene.pbGetMemberAvailability(@member_index)
      return if @availability.nil?
      @availability_icon.src_rect = Rect.new(@availability_icon_dimensions[0] * @availability, 0, @availability_icon_dimensions[0], @availability_icon_dimensions[1])
      @availability_icon.visible = false if @availability == 0 && !InstantMessagesSettings::AVAILABILITY_ICONS_SHOW_AVAILABLE
    end

    def x=(value)
      super
      refresh
    end

    def y=(value)
      super
      refresh
    end

    def z=(value)
      super
      refresh
    end

    def color=(value)
      super
      refresh
    end
    
    def visible=(value)
      super
      if @availability_icon && !@availability_icon.disposed?
        value = false if @availability == 0 && !InstantMessagesSettings::AVAILABILITY_ICONS_SHOW_AVAILABLE
        @availability_icon.visible = value
      end
    end

    def refresh
      return if disposed?
      if @availability_icon && !@availability_icon.disposed?
        @availability_icon.x     = self.x + self.width - @availability_icon.width
        @availability_icon.y     = self.y + self.height - @availability_icon.height
        @availability_icon.z     = self.z
        @availability_icon.color = self.color
        refresh_availability
      end
    end

    def update
      super
      @availability_icon.update if @availability_icon && !@availability_icon.disposed?
    end

    def dispose
      super
      @availability_icon.dispose if @availability_icon && !@availability_icon.disposed?
    end
  end

  class Divider < IconSprite
    attr_reader :text
  
    def initialize(x, y, text, divider_visible, scene, viewport)
      super(viewport)
      @text = text
      divider_suffix =""
      if ["Unread", "New"].include?(@text)
        divider_suffix ="_unread"
        @text_base_color = MessageConfig::LIGHT_TEXT_MAIN_COLOR
        @text_shadow_color = MessageConfig::LIGHT_TEXT_SHADOW_COLOR
      elsif @text
        divider_suffix ="_text"
        @text_base_color = MessageConfig::DARK_TEXT_MAIN_COLOR
        @text_shadow_color = MessageConfig::DARK_TEXT_SHADOW_COLOR
      end
      @scene = scene
      @viewport = viewport
      @divider_visible = divider_visible
      @sprites = {}
      self.x = x
      self.y = y
      @sprites["bg"] = IconSprite.new(0, 0, @viewport)
      @sprites["bg"].setBitmap("Graphics/UI/Instant Messages/Themes/#{@scene.theme}/divider#{divider_suffix}")
      @sprites["bg"].x = self.x
      @sprites["bg"].y = self.y
      @sprites["bg"].visible = @divider_visible
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      refresh
    end

    def x=(value)
      super
      refresh
    end

    def y=(value)
      super
      refresh
    end

    def color=(value)
      super
      refresh
    end
    
    def visible=(value)
      @sprites["bg"].visible = value && @divider_visible
      @sprites["overlay"].visible = value
    end

    def text=(value)
      return if @text == value
      @text = value
      refresh
    end

    def width
      return @sprites["bg"].width
    end

    def height
      return @sprites["bg"].height
    end

    def refresh_overlay_information
      @sprites["overlay"].bitmap&.clear
      draw_text
    end

    def draw_text
      return if !@text || @text.length == 0
      pbSetSmallFont(@sprites["overlay"].bitmap)
      pbDrawTextPositions(@sprites["overlay"].bitmap,
                          [[@text, self.width/2, 2, 2, @text_base_color, @text_shadow_color]])
    end

    def refresh
      return if disposed?
      if @sprites["overlay"] && !@sprites["overlay"].disposed?
        @sprites["overlay"].x     = self.x
        @sprites["overlay"].y     = self.y
        @sprites["overlay"].color = self.color
        refresh_overlay_information
      end
      if @sprites["bg"] && !@sprites["bg"].disposed?
        @sprites["bg"].x     = self.x
        @sprites["bg"].y     = self.y
        @sprites["bg"].color = self.color
      end
    end

    def update
      super
      @sprites["overlay"].update if @sprites["overlay"] && !@sprites["overlay"].disposed?
      @sprites["bg"].update if @sprites["bg"] && !@sprites["bg"].disposed?
    end
  end

  class ReactSelector < IconSprite
    attr_reader :reactions
    attr_reader :can_skip
    attr_reader :index
  
    def initialize(reactions, skin, scene, viewport)
      super(viewport)
      @reactions = reactions
      @scene = scene
      @viewport = viewport
      @sprites = {}
      @sprites["bg"] = Window_AdvancedTextPokemonMessages.new("")
      @sprites["bg"].setSkin("Graphics/UI/Instant Messages/Bubbles/#{skin}")
      @base_width = reactions.length * 32 + 20
      @sprites["bg"].width = @base_width
      @sprites["bg"].height = 44
      @sprites["bg"].viewport = @viewport
      @sprites["overlay"] = BitmapSprite.new(Graphics.width, Graphics.height, @viewport)
      @sprites["overlay"].z = @sprites["bg"].z
      @sprites["cursor"] = IconSprite.new(0, 0, @viewport)
      @sprites["cursor"].setBitmap("Graphics/UI/Instant Messages/react_cursor")
      @sprites["cursor"].z = @sprites["overlay"].z
      @index = 0
      refresh
    end

    def set_reactions(value)
      @base_reactions = @reactions
      @reactions = value
      @base_width = reactions.length * 32 + 20
      @sprites["bg"].width = @base_width

    end

    def reset_reactions
      @reactions = @base_reactions
      @base_width = reactions.length * 32 + 20
      @sprites["bg"].width = @base_width
    end

    def can_skip=(value)
      @can_skip = value
      if @can_skip
        @sprites["bg"].width = @base_width + 32
      else
        @sprites["bg"].width = @base_width
      end
      refresh
    end

    def index=(value)
      max = @reactions.length - 1
      max += 1 if @can_skip
      value = 0 if value > max
      value = max if value < 0
      @index = value
      refresh
    end

    def draw_icons
      reactimgpos = []
      @reactions.each_with_index do |r, i|
        reactimgpos.push(["Graphics/Icons/#{r}", 10 + 4 + i*32, 4])
      end
      if @can_skip
        reactimgpos.push(["Graphics/UI/Instant Messages/react_cancel", 10 + 4 + @reactions.length*32, 4])
      end
      pbDrawImagePositions(@sprites["overlay"].bitmap, reactimgpos)
    end

    def position_cursor
      @sprites["cursor"].x = self.x + 8 + @index*32
      @sprites["cursor"].y = self.y + 2
    end

    def x=(value)
      super
      refresh
    end

    def y=(value)
      super
      refresh
    end

    def color=(value)
      super
      refresh
    end
    
    def visible=(value)
      @sprites["bg"].visible = value
      @sprites["cursor"].visible = value
      @sprites["overlay"].visible = value
    end

    def width
      return @sprites["bg"].width
    end

    def height
      return @sprites["bg"].height
    end

    def refresh_overlay_information
      @sprites["overlay"].bitmap&.clear
      draw_icons
    end

    def refresh
      return if disposed?
      if @sprites["overlay"] && !@sprites["overlay"].disposed?
        @sprites["overlay"].x     = self.x
        @sprites["overlay"].y     = self.y
        @sprites["overlay"].color = self.color
        refresh_overlay_information
      end
      if @sprites["bg"] && !@sprites["bg"].disposed?
        @sprites["bg"].x     = self.x
        @sprites["bg"].y     = self.y
        @sprites["bg"].color = self.color
      end
      if @sprites["cursor"] && !@sprites["cursor"].disposed?
        @sprites["cursor"].color = self.color
        position_cursor
      end
    end

    def update
      super
      @sprites["bg"].update if @sprites["bg"] && !@sprites["bg"].disposed?
      @sprites["overlay"].update if @sprites["overlay"] && !@sprites["overlay"].disposed?
    end
  end

end

#===============================================================================
# Messages screen
#===============================================================================
class InstantMessagesScreen
  attr_reader :scene

  def initialize(scene)
    @scene = scene
  end

  def pbStartScreen
    @scene.pbStartScene
    ret = @scene.pbScene
    @scene.pbEndScene
    return ret
  end

  def pbUpdate
    @scene.update
  end

  def pbRefresh
    @scene.pbRefresh
  end

  def pbDisplay(text)
    @scene.pbDisplay(text)
  end

  def pbDisplayForcedCommands(text, commands)
    @scene.pbDisplayForcedCommands(text, commands)
  end

  def pbConfirm(text)
    return @scene.pbDisplayConfirm(text)
  end

  def pbShowCommands(helptext, commands, index = 0)
    return @scene.pbShowCommands(helptext, commands, index)
  end

end

def pbTXWSecondsToFrameConvert(seconds)
  return nil if seconds.nil?
  if Essentials::VERSION.include?("21")
    t = ((1 / Graphics.delta) * seconds).round
    i = 0
    while t > seconds * 120
      tt = ((1 / Graphics.delta) * seconds).round
      t = tt if tt < t
      i += 1
      if i > 100
        t = seconds * 120
        break
      end
    end
    return t
  else
    return Graphics.frame_rate * seconds
  end
end