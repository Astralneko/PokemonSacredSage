#===============================================================================
# Passive Triggers
#===============================================================================

EventHandlers.add(:on_player_step_taken, :passive_instant_messages,
    proc { 
        next if InstantMessagesSettings::PASSIVE_TRIGGER_TYPE == 0
        next if pbIMReceiveDelayed
        case InstantMessagesSettings::PASSIVE_TRIGGER_TYPE
        when 1
            #Steps
            if $player.im_passive[:StepCount] >= InstantMessagesSettings::PASSIVE_STEP_MIN + rand(InstantMessagesSettings::PASSIVE_STEP_VARIATION)
                pbIMReceivePassive
                $player.im_passive[:StepCount] = 0
            else
                $player.im_passive[:StepCount] += 1
            end   
        when 2
            #Time
            $player.im_passive[:LastTimeReceieved] = pbGetTimeNow if $player.im_passive[:LastTimeReceieved].nil?
            if pbGetTimeNow - $player.im_passive[:LastTimeReceieved] >= (InstantMessagesSettings::PASSIVE_TIME_MIN + rand(InstantMessagesSettings::PASSIVE_TIME_VARIATION)) * 60
                pbIMReceivePassive
                $player.im_passive[:LastTimeReceieved] = pbGetTimeNow
            end  
        when 3
            #Time then Steps     
            $player.im_passive[:LastTimeReceieved] = pbGetTimeNow if $player.im_passive[:LastTimeReceieved].nil?   
            if pbGetTimeNow - $player.im_passive[:LastTimeReceieved] >= (InstantMessagesSettings::PASSIVE_TIME_MIN + rand(InstantMessagesSettings::PASSIVE_TIME_VARIATION)) * 60
                if $player.im_passive[:StepCount] >= InstantMessagesSettings::PASSIVE_STEP_MIN + rand(InstantMessagesSettings::PASSIVE_STEP_VARIATION)
                    pbIMReceivePassive
                    $player.im_passive[:StepCount] = 0
                    $player.im_passive[:LastTimeReceieved] = pbGetTimeNow
                else
                    $player.im_passive[:StepCount] += 1
                end   
            end  
        end
    }
)

def pbIMReceiveDelayed
    $player.im_passive[:PendedDelayed].compact!
    pool = $player.im_passive[:PendedDelayed]
    pool.each_with_index do |d, index|
        id = d[0]
        steps = d[1]
        minutes = d[2]
        timestamp = d[3]
        case InstantMessagesSettings::PASSIVE_TRIGGER_TYPE
        when 1
            #Steps
            if steps <= 0
                ret = pbReceiveIM(id)
                pool[index] = nil
                return ret
            else
                d[1] -= 1
            end   
        when 2
            #Time
            if pbGetTimeNow - timestamp >= minutes * 60
                ret = pbReceiveIM(id)
                pool[index] = nil
                return ret
            end  
        when 3
            #Time then Steps
            if pbGetTimeNow - timestamp >= minutes * 60
                if steps <= 0
                    ret = pbReceiveIM(id)
                    pool[index] = nil
                    return ret
                else
                    d[1] -= 1
                end  
            end  
        end
    end
    return false
end

def pbIMReceivePassive
    id = nil
    type = 1 # 1 = sequencial, 2 = random
    type = 2 if !InstantMessagesSettings::PASSIVE_TRIGGERS_SEQUENCIAL_POOL[$player.im_passive[:SequencialIndex]]
    case InstantMessagesSettings::PASSIVE_TYPE_PRIORITY
    when 1 # (Sequencials > Random)
        r = rand(10)
        type = 2 if r < 3
    when 2 # (Random > Sequencials)
        r = rand(10)
        type = 2 if r >= 3
    else # (Sequencials == Random)
        r = rand(2)
        type = r + 1
    end
    if type == 1 # Sequencial
        pool = InstantMessagesSettings::PASSIVE_TRIGGERS_SEQUENCIAL_POOL
        return false if !pool[$player.im_passive[:SequencialIndex]]
        try = pool[$player.im_passive[:SequencialIndex]]
        case try[1]
        when :Switch
            id = try[0] if $game_switches[try[2]] == try[3]
        when :Variable
            id = try[0] if pbGet(try[2]) >= try[3]
        when :Code
            id = try[0] if eval(try[2])
        else
            id = try[0]
        end
        $player.im_passive[:SequencialIndex] += 1 unless id.nil?
    else # Random
        pool = InstantMessagesSettings::PASSIVE_TRIGGERS_RANDOM_POOL + $player.im_passive[:PendedRandoms]
        return false if pool.length == $player.im_passive[:RandomsReceived].length
        pool.length.times do
            try = pool[rand(pool.length)]
            next if $player.im_passive[:RandomsReceived].include?(try[0])
            case try[1]
            when :Switch
                id = try[0] if $game_switches[try[2]] == try[3]
            when :Variable
                id = try[0] if pbGet(try[2]) >= try[3]
            when :Code
                id = try[0] if eval(try[2])
            else 
                id = try[0]
            end
            break unless id.nil?
        end
    end
    return false if id.nil?
    ret = pbReceiveIM(id)
    $player.im_passive[:RandomsReceived].push(id) if type == 2 && ret
    return ret
end