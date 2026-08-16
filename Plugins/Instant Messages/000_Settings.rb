
#===============================================================================
# Settings
#===============================================================================
module InstantMessagesSettings

    #====================================================================================
    #================================= Display Settings =================================
    #====================================================================================

    #------------------------------------------------------------------------------------
    # The name of the Instant Messages app.
    #------------------------------------------------------------------------------------
    MESSAGE_LIST_TITLE                  = _INTL("Messages")

    #------------------------------------------------------------------------------------
    # The name of the default theme for the app. Set it to a name of a folder in
    # UI/Instant Messages/Themes
    #------------------------------------------------------------------------------------
    DEFAULT_THEME_COLOR                 = "Orange"

    #------------------------------------------------------------------------------------
    # The filename of the windowskin used by the player. Set it to the name of a graphic
    # in UI/Instant Messages/Bubbles
    #------------------------------------------------------------------------------------
    PLAYER_BUBBLE_COLOR                 = "WhiteUser"

    #------------------------------------------------------------------------------------
    # The filename of the windowskin used for system messages. Set it to the name of a 
    # graphic in UI/Instant Messages/Bubbles
    #------------------------------------------------------------------------------------
    SYSTEM_BUBBLE_COLOR                 = "Gray"

    #------------------------------------------------------------------------------------
    # If true, a close button will appear in the top left corner indicating when the    
    # player can close out of the conversation.
    #------------------------------------------------------------------------------------
    SHOW_CLOSE_BUTTON                   = true

    #------------------------------------------------------------------------------------
    # If true, a time stamp of when a conversation was received will appear above that     
    # conversation.
    #------------------------------------------------------------------------------------
    SHOW_TIME_STAMPS                    = true

    #------------------------------------------------------------------------------------
    # The group name that appears at the top of a conversation will have this prefix if 
    # SHOW_CONVERSATION_PREFIX is set to show it.
    #------------------------------------------------------------------------------------
    CONVERSATION_PREFIX                 = _INTL("Conversation with")

    #------------------------------------------------------------------------------------
    # Set when CONVERSATION_PREFIX will appear at the top of a conversation before the 
    # group name.
    # - 0 or false => The prefix will never show.
    # - 1 or true => The prefix will always show.
    # - 2 => The prefix will only show in conversations that contains 1 NPC.
    #------------------------------------------------------------------------------------
    SHOW_CONVERSATION_PREFIX            = 2 

    #------------------------------------------------------------------------------------
    # Set how contact images will be vertically aligned next to message bubbles. 
    # - 0 => Aligned to the top of the message bubble.
    # - 1 => Aligned to the bottom of the message bubble.
    # - 2 => Aligned to the center of the message bubble.
    #------------------------------------------------------------------------------------
    PICTURE_ALIGNMENT                   = 0 

    #------------------------------------------------------------------------------------
    # The string that replaces a message after it is deleted.
    #------------------------------------------------------------------------------------
    MESSAGE_DELETE_TEXT_DEFAULT         = _INTL("<i>(Message was deleted)</i>")

    #------------------------------------------------------------------------------------
    # If true, if a reply to a picture message is created, it will replace the picture
    # with the string in defined in REPLY_PICTURE_REPLACE_TEXT.
    #------------------------------------------------------------------------------------
    REPLY_PICTURE_REPLACE_WITH_TEXT     = false
    REPLY_PICTURE_REPLACE_TEXT          = _INTL("[Image]")

    #------------------------------------------------------------------------------------
    # If true, availability status icons will show on member pictures (requires the 1.4 
    # version of the Social Links plugin).
    #------------------------------------------------------------------------------------
    AVAILABILITY_ICONS_SHOW             = true

    #------------------------------------------------------------------------------------
    # If true, if a member has the Available status, it will show the status icon 
    # (requires the 1.4 version of the Social Links plugin).
    #------------------------------------------------------------------------------------
    AVAILABILITY_ICONS_SHOW_AVAILABLE   = true

    #====================================================================================
    #=============================== Functional Settings ================================
    #====================================================================================

    #------------------------------------------------------------------------------------
    # Set the sound effect to play when the player receives a message.
    #------------------------------------------------------------------------------------
    MESSAGE_RECEIVED_SOUND_EFFECT       = "Mining reveal"

    #------------------------------------------------------------------------------------
    # Set the sound effect to play when a message bubble appears during a conversation.
    #------------------------------------------------------------------------------------
    MESSAGE_BUBBLE_SOUND_EFFECT         = "Notification pop louder"

    #------------------------------------------------------------------------------------
    # If true, the player can use the SPECIAL key to toggle whether messages appear     
    # faster during a conversation.
    #------------------------------------------------------------------------------------
    ALLOW_FAST_FORWARD                  = true

    #------------------------------------------------------------------------------------
    # If true, the player can use the SPECIAL key to change how messages in the menu     
    # are sorted.
    #------------------------------------------------------------------------------------
    ALLOW_SORTING                       = true

    #------------------------------------------------------------------------------------
    # If true, the player can pin or unpin a message when using the ACTION key. A pinned
    # message will always appear at the top of the list.
    #------------------------------------------------------------------------------------
    ALLOW_PINNING                       = true

    #------------------------------------------------------------------------------------
    # If true, when the player received an important conversation, it will open that
    # conversation directly. If false, it will instead open the Instant Messages selction
    # menu.
    #------------------------------------------------------------------------------------
    OPEN_IMPORTANT_MESSAGES_DIRECTLY    = true

    #====================================================================================
    #=============================== Reactions Settings =================================
    #====================================================================================
  
    #------------------------------------------------------------------------------------
    # Set to an array that contains filenames of images in Graphics/Icons to be the 
    # default list of reactions for groups.
    #------------------------------------------------------------------------------------
	# Set to literally all of them because whynaut
    REACTIONS_LIST = ["emojiThumbsUp", "emojiThumbsDown", "emojiHappy", "emojiHappy2",
		"emojiLaugh", "emojiAngry", "emojiSad", "emojiSad2", "emojiSunglasses",
		"emojiSurprised", "emojiSweat", "emojiTongue", "emojiConfused", "emojiEyes",
		"emojiMuscle", "emojiPokeball", "emojiHeart"] 

    #------------------------------------------------------------------------------------
    # Set the sound effect to play when a reaction appears during a conversation.
    #------------------------------------------------------------------------------------
    REACTION_SOUND_EFFECT               = "Notification pop louder"
    REACTION_SOUND_EFFECT_PITCH         = 130

    #------------------------------------------------------------------------------------
    # If true, a reaction will use UI/Instant Messages/react_bubble or react_bubble_long
    # as a background.
    #------------------------------------------------------------------------------------
    REACTIONS_BUBBLE_BG                 = true 

    #------------------------------------------------------------------------------------
    # If true, a reaction will show the picture of the conversation member who send the
    # reaction.
    #------------------------------------------------------------------------------------
    REACTIONS_SHOW_MEMBER_PICTURE       = true 

    #------------------------------------------------------------------------------------
    # If true, the player can choose to not select a reaction when prompted by default.
    # This can be controlled within a message definition.
    #------------------------------------------------------------------------------------
    REACTIONS_CAN_CANCEL_DEFAULT        = false 

    #====================================================================================
    #======================== Passive Message Trigger Settings ==========================
    #====================================================================================
    # The main way to send messages to the player is using pbReceiveIM. However, you can
    # have the player receive messages passively, using steps or time to trigger receiving
    # them.

    #------------------------------------------------------------------------------------
    # Set how you want passive messages to trigger. 
    # - 0 => Don't have passive messages send. Will always require sending them manually.
    # - 1 => Use Steps to determine when to trigger sending.
    # - 2 => Use Time to determine when to trigger sending.
    # - 3 => Use both Time and Steps to determine when to trigger sending. The Time
    #        requirements will be checked first, then Step requirements.
    #------------------------------------------------------------------------------------
    PASSIVE_TRIGGER_TYPE                = 1
	# Note that in this game, most passive messages trigger upon hitting specific values of story progress variables 990-993
	# For example, when the player defeats Aria, a message triggers upon leaving her Gym; this is based on variable 990 being at least 100
	# This is not in the Passive array, as it is a pbPendRandomIM call on the door itself
	# Some sidequests also use passive messages; these are based instead on the quest plugin's unlocked quest and stage

    #------------------------------------------------------------------------------------
    # Set the number of minimum steps the player has to take before receiving the next   
    # passive message.
    #------------------------------------------------------------------------------------
    PASSIVE_STEP_MIN                    = 256

    #------------------------------------------------------------------------------------
    # Set the variation to add on to PASSIVE_STEP_MIN to allow for some randomness.
    # Formula will be: Steps > PASSIVE_STEP_MIN + rand(PASSIVE_STEP_VARIATION)
    #------------------------------------------------------------------------------------
    PASSIVE_STEP_VARIATION              = 256

    #------------------------------------------------------------------------------------
    # Set the minimum amount of in-game minutes that has to pass before receiving the next   
    # passive message.
    #------------------------------------------------------------------------------------
    PASSIVE_TIME_MIN                    = 60

    #------------------------------------------------------------------------------------
    # Set the variation in minutes to add on to PASSIVE_TIME_MIN to allow for some 
    # randomness. Formula will be: Time passed > PASSIVE_TIME_MIN + rand(PASSIVE_TIME_VARIATION)
    #------------------------------------------------------------------------------------
    PASSIVE_TIME_VARIATION              = 15

    #------------------------------------------------------------------------------------
    # Set which type of passive message pool to pull from will get priority.
    # - 1 => The Sequencial Pool will be pulled from more often than the Random Pool.
    # - 2 => The Random Pool will be pulled from more often than the Sequencial Pool.
    # - 3 => The Sequencial and Random Pools will be pulled from about equally.
    #------------------------------------------------------------------------------------
    PASSIVE_TYPE_PRIORITY               = 1

    #------------------------------------------------------------------------------------
    # Set a pool of conversations that will be pulled from in sequencial order. When
    # being sent a passive message. For example, the conversation in index 2 won't be
    # sent until the conversation in index 1 is already sent.
    # Messages Setup format:
    #
    #   [<Conversation ID>, <(Optional) Condition Type>, <(Optional) Parameter>, <(Optional) Parameter 2>]
    #
    # Conversation ID => The ID of the conversation that will be sent to the player.
    # Conditional Type => Optional. If you want to lock the message behind a condition,
    #                     set which type of condition. If not set, the message can 
    #                     always be sent. Available conditions:
    #               - :Switch => Checks a Game Switch
    #               - :Variable => Checks a Game Variable
    #               - :Code => Run code to determine if it can be sent.
    # Parameter => First parameter for the Condition:
    #               - :Switch => Set the integer of the switch ID you want to check.
    #               - :Variable => Set the integer of the variable ID you want to check.
    #               - :Code => Set to a string representing a code snippet to run. It
    #                           must return true or false to work properly.
    # Parameter 2 => Second parameter for the Condition:
    #               - :Switch => The value of the switch that will result in the message
    #                            being sent (true or false)
    #               - :Variable => The value that the variable must be equal to or above
    #                              for the message to be sent.
    #               - :Code => N/A
    #------------------------------------------------------------------------------------
    PASSIVE_TRIGGERS_SEQUENCIAL_POOL    = [
        [:ADVERTISEMENT_TEST_1],
        [:ADVERTISEMENT_TEST_2, :Switch, 5, true],
        [:ADVERTISEMENT_TEST_3, :Code, "$game_switches[7] == true"],
        [:ADVERTISEMENT_TEST_4]
    ]

    #------------------------------------------------------------------------------------
    # Set a pool of conversations that will be pulled from randomly. After one is sent,
    # the same message won't be sent again.
    # Messages Setup format is the same as PASSIVE_TRIGGERS_SEQUENCIAL_POOL above.
    #------------------------------------------------------------------------------------
    PASSIVE_TRIGGERS_RANDOM_POOL        = [
        [:ADVERTISEMENT_RANDOM_1],
        [:ADVERTISEMENT_RANDOM_2, :Variable, 1, 5],
        [:ADVERTISEMENT_RANDOM_3]
    ]

    #------------------------------------------------------------------------------------
    # Set a list of conversations that will be added to the player's message history
    # at the time of game setup (specifically when the player is initialized).
    # Only conversations with the :reltimestamp parameter defined will be added.
    # The array is filled with Conversation IDs. However, if you want a certain conversations
    # to be unread by the player, add it as an array with the format [<Conversation ID>, true].
    # NOTE: if you use this format for unread conversations, you MUST use the same format
    # for any message in the same group that would appear after that message. Otherwise,
    # the order will be messed up when you first view the messages.
    #------------------------------------------------------------------------------------
    MESSAGE_HISTORY_LIST = [
        :OAK_18_MONTHS_AGO,
        [:OAK_YESTERDAY, true],
        [:OAK_30_MIN_AGO, true], # Has to also be unread since the one before it is.
        :CHATBOT_5_MIN_AGO
    ]
    
end