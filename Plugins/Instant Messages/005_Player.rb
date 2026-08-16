#===============================================================================
# Player
#===============================================================================
class Player < Trainer
    attr_accessor :instant_messages
    attr_accessor :im_passive

    alias tdw_im_player_init initialize
    def initialize(name, trainer_type)
        tdw_im_player_init(name, trainer_type)
        initialize_instant_messages
        @im_passive = {
            :RandomsReceived => [],
            :PendedRandoms => [],
            :PendedDelayed => [],
            :SequencialIndex => 0,
            :StepCount => 0,
            :LastTimeReceieved => nil
        }
    end

    def initialize_instant_messages
        @instant_messages = InstantMessages.new
    end

    def instant_messages
        @instant_messages = InstantMessages.new if !@instant_messages
        return @instant_messages
    end

    def im_passive
        if !@im_passive
            @im_passive = {
                :RandomsReceived => [],
                :PendedRandoms => [],
                :PendedDelayed => [],
                :SequencialIndex => 0,
                :StepCount => 0,
                :LastTimeReceieved => nil
            }
        end

        #Upgrade Handling
        @im_passive[:PendedRandoms] = [] if @im_passive[:PendedRandoms].nil?
        @im_passive[:PendedDelayed] = [] if @im_passive[:PendedDelayed].nil?

        return @im_passive
    end

    class InstantMessages
        attr_accessor :saved_messages
        attr_accessor :theme_color

        def initialize
            @saved_messages = {} #groups
            @theme_color = InstantMessagesSettings::DEFAULT_THEME_COLOR
            pbApplyHistory
        end

        def pbReceiveMessage(conversation_id)
            return false if pbHasReceivedMessage?(conversation_id)
            convo = pbIMGetConversation(conversation_id)
            if convo.reltimestamp
                Console.echo_warn "You are trying to receive a message with a reltimestamp parameter. That timestamp will not apply."
            end
            message = IMConversation.new(conversation_id)
            if convo.set_var_on_receive
              message.messages.each do |m|
                if m[2].is_a?(Array)
                  m[2].each { |s| s.gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] } }
                else
                  m[2].gsub!(/\\v\[([0-9]+)\]/i) { $game_variables[$1.to_i] }
                end
              end
            end
            message.read = true if message.not_new
            # if !@saved_messages[message.group]
            #     @saved_messages[message.group] = IMGroup.new(message.group)
            # end

            array = @saved_messages.to_a
            if !@saved_messages[message.group]
                array.unshift([message.group, IMGroup.new(message.group)])
                @saved_messages = array.to_h
            elsif array[0][0] != message.group
                existing = nil
                array.each_with_index do |val, i|
                    if val[0] == message.group
                        existing = i
                        break
                    end
                end
                deleted = array.delete_at(existing)
                array.unshift(deleted)
                @saved_messages = array.to_h
            end
            @saved_messages[message.group].last_received = pbGetTimeNow
            @saved_messages[message.group].convo_list.push(message)
            @saved_messages[message.group].has_unread = true unless message.not_new
            @saved_messages[message.group].has_important = true if message.important
            return true
        end

        def pbHasReceivedMessage?(conversation_id)
            convo = pbIMGetConversation(conversation_id)
            group = convo.group
            return false if @saved_messages[group].nil?
            @saved_messages[group].convo_list.each { |c| return true if c.id == conversation_id }
            return false
        end

        def pbHasUnreadMessages?
            @saved_messages.each { |group| return true if group[1].has_unread}
            return false
        end

        def pbApplyHistory
            return if !InstantMessagesSettings::MESSAGE_HISTORY_LIST || InstantMessagesSettings::MESSAGE_HISTORY_LIST.empty?
            now = pbGetTimeNow
            adjusted_messages = []
            InstantMessagesSettings::MESSAGE_HISTORY_LIST.each do |conversation_id|
                unread = false
                if conversation_id.is_a?(Array)
                    unread = conversation_id[1]
                    conversation_id = conversation_id[0]
                end
                next if pbHasReceivedMessage?(conversation_id)
                if !pbIMGetConversation(conversation_id).reltimestamp
                    Console.echo_warn conversation_id.to_s + " doesn't have :reltimestamp defined. It was not added."
                    next
                end
                array = pbIMGetConversation(conversation_id).reltimestamp
                6.times do |i|
                    next if array[i]
                    array[i] = 0
                end
                # Subtract seconds, minutes, and hours
                past_time = now - array[5] - (array[4] * 60) - (array[3] * 60 * 60)
                # Subtract days
                past_time -= array[2] * 24 * 60 * 60
                #Handling months and years
                m = past_time.month - array[1]
                y = past_time.year - array[0]
                # If subtracting months makes the month <= 0, roll back to previous year
                while m <= 0
                    m += 12
                    y -= 1
                end
                timestamp = Time.new(y, m, past_time.day, past_time.hour, past_time.min, past_time.sec)
                message = IMConversation.new(conversation_id)
                message.received_time = timestamp
                message.instant = true
                message.read = (unread ? false : true)
                adjusted_messages.push(message)
            end
            # Sort messages by time, with furthest in the past first
            adjusted_messages.sort_by! { |c| c.received_time}
            # Apply messages in order
            adjusted_messages.each do |c|
                array = @saved_messages.to_a
                if !@saved_messages[c.group]
                    array.unshift([c.group, IMGroup.new(c.group)])
                    @saved_messages = array.to_h
                elsif array[0][0] != c.group
                    existing = nil
                    array.each_with_index do |val, i|
                        if val[0] == c.group
                            existing = i
                            break
                        end
                    end
                    deleted = array.delete_at(existing)
                    array.unshift(deleted)
                    @saved_messages = array.to_h
                end
                @saved_messages[c.group].last_received = c.received_time
                @saved_messages[c.group].convo_list.push(c)
                @saved_messages[c.group].has_unread = true if !c.read
            end
        end
    end
end

def pbPlayerIMSaved
    return $player.instant_messages
end
