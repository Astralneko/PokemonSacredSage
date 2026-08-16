#===============================================================================
# Conversation registrations
#
# The main conversations used in the game. These can be anything from one-off
# messages to the player to involved group conversations between multiple
# contacts.
#===============================================================================
# Parameters:
#   - :id => Symbol - The ID of the specific conversation
#   - :group => Symbol - The ID of the group the conversation is housed in
#   - :messages => Array - Contains each message used in the conversation. See
#                  Messages Setup format below.
#   - :important => (Optional) Boolean - If true, the messages are required to be 
#                   viewed before doing anything else in the game. Will force 
#                   open the Instant Messages app.
#   - :instant => (Optional) Boolean - If true, the messages will appear instantly
#                 when opened, instead of being real-time.
#   - :set_var_on_receive => (Optional) Boolean - If true, any references to
#                 variables using "\\v[x]" will be set at the time of receiving
#                 the conversation, instead of when the message is read.
#   - :not_new => (Optional) Boolean - If true, the message will not be treated
#                 as a new message when it's received. This can be used to add a
#                 player-sent message to a group as if they messaged the group.
#   - :queue_after_receive => (Optional) Hash defining a delayed message to
#                      queue up after the conversation is received, similar to
#                      using pbPendDelayedIM. Use the following structure:
#                      {
#                        :id => CONVERSATION_ID,
#                        :immediate => Boolean,
#                        :steps => Integer,
#                        :time => Integer,
#                        :stepvariation => Integer or Range,
#                        :timevariation => Integer or Range,
#                      }
#                      - :id => The :id of the conversation you want to queue up
#                      - :immediate => If true, the conversation will be received immediately using pbReceiveIM. 
#                                      If false or not set, it will be received using pbPendDelayedIM.
#                      - :steps => Integer representing the minimum number of steps the player needs to take before it is received.
#                      - :time => Integer representing the minimum number of in-game minutes that needs to pass before it is received.
#                      - :stepvariation => Integer or range representing how much random variation to apply to the value set in :steps.
#                      - :timevariation => Integer or range representing how much random variation to apply to the value set in :time.
#   - :reltimestamp => (Optional) Array - Contains the definition of the timestamp
#                      for the message set in the past relative to the moment the  
#                      message is received. This only applies if the message is 
#                      included in MESSAGE_HISTORY_LIST. Format:
#                             [Years, Months, Days, Hours, Minutes, Seconds]
#                      NOTE: You do not need to include all of these. If you don't
#                      care about specific units, you can omit them (as long as
#                      all other array indexes after it are also omitted) or set
#                      them to 0. Examples:
#                      [1, 6, 14] - Sets the time stamp to 1 year, 6 months, and 14
#                                   days in the past relative to Now.
#                      [15, 0, 11, 0, 0, 30] - Sets the time stamp to 15 years, 11
#                                   days and 30 seconds in the past relative to Now.
#
# Messages Setup format:
#   [<Contact ID>, <Message Type>, <Parameter>, <Parameter 2 (Optional)>]
#
# Contact ID => The ID number of member of the group will be speaking, as defined in the Group's members hash.
#                Set to 0 for the Player. Set to -1 for a System Message.
# Message Type => Symbol defining the type of the message. Available options:
#               - :Text => A basic text message.
#               - :RedoText => Same as text, except it will make it look like the contact typed out a message, reconsidered it, and typed out a new one.
#               - :Leave => A system message stating that a contact has left the chat.
#               - :Enter => A system message stating that a contact has entered the chat.
#               - :GroupName => Used to change the group name. Shows a system message stating that the group name has changed.
#               - :Picture => Used to show a picture as a message.
#               - :Delay => Used to pause during a conversation.
#               - :Edit => Used to change the string of the previous message. Add an "Edited" tag to the message.
#               - :Delete => Used to delete the previous message and replace it with the string defined in MESSAGE_DELETE_TEXT_DEFAULT.
#               - :React => Used to add a reaction to the previous message. If Contact ID is 0, a reaction selector will appear
#                           for the player to choose a reaction.
#               - :Typing => Will show the "<name> is typing..." message for the Contact ID without being connected to a real message. 
#                            If you set Contact ID to an array of IDs, it will show multiple contact names. If only 2 IDs are included,
#                            it will say "<name1>, <name2> are typing...". If more than 2 are included, it will say "Multiple are typing...".
#               - :Reply => Same as text, except it makes the message appear as a reply to a previous message in the conversation.
#               - :Forward => Same as text, except it will appear as if the message was being forwarded from somewhere else.
#               - :Availability => (Requires the 1.4 version of the Social Links plugin) Changes the availability status of a contact.
# Parameter => Enter a parameter value based on the Message Type:
#               - :Text => A string representing the text of the message. For a Player Message that show choices to make, or NPC responses that change
#                           based on the Player's choice, use an array of strings.
#               - :RedoText => Same as :Text.
#               - :Leave => The Contact ID of the contact that left.
#               - :Enter => The Contact ID of the contact that entered.
#               - :GroupName => A string representing the new group name. Set to nil to revert it back to the original group name.
#               - :Picture => A string representing the file name of a picture saved in Graphics/UI/Instant Messages/Pictures.
#               - :Delay => An integer or float representing the number of seconds to pause for.
#               - :Edit => A string to change the previous message to.
#               - :Delete => Optional. If you set this to a string, it will change the previous message to that string instead of MESSAGE_DELETE_TEXT_DEFAULT.
#               - :React => Set to a string or an array of strings, where each string is a filename of an image in Graphics/Icons. 
#                           If Contact ID is 0, you do not need to set this paramter if you want the player to choose a
#                           reaction from the default reactions. Othersize, they will only be able to select from the strings set.
#                           For NPCs, if this is set to an array, and the player has made a choice in this conversation (including
#                           a reaction choice), the reaction selected will match the index of the choice the player last made. Otherwise,
#                           the reaction selected will be a random one from that array.
#               - :Typing => An integer or float representing the number of seconds to show the "is typing..." message for.
#               - :Reply => Same as :Text.
#               - :Forward => Same as :Text.
#               - :Availability => An integer representing the availablility status to change the contact to. These are defined
#                                  in the Social Links plugin's 001_Data file. You could also use the variable name for readability,
#                                  like SocialLinkAvailability::OFFLINE for example.    
# Parameter 2 => Optional. 
#               For Player :Text messages:
#               - Set to an integer representing the ID of a Game Variable that you want to be set to the index value of the choice made.
#               - Set to a string representing a code snippet to run, where {VALUE} will be replaced the by index value
#                 of the choice made. For example, "$player.party[0].gender = {VALUE}"
#               For Player :React messages:
#               - Set to true to allow the player to not select a reaction.
#               - If not set, this behavior is determined by REACTIONS_CAN_CANCEL_DEFAULT.
#               For :Reply messages:
#               - If not set, it will make the message reply to the last message received in the conversation.
#               - If set to an integer less than 0, it will make the message reply to a message earlier in the conversation
#                 relative to this message. For example, if you set it to -2, it will reply to the message sent 2 messages 
#                 ago before this one.
#               - If set to an integer greater than or equal to 0, it will make the message reply to the message in that 
#                 index of the conversation's :messages array. It's up to you to make sure it's a message that shows text,
#                 otherwise this will not work. For example, if you set it to 3, it will reply to the message that is defined
#                 in index 3 of the conversation's :messages array.
#               For :Forward messages:
#               - Set to the :id of a InstantMessageContact to show that contact's picture icon, acting as if you are 
#                 forwarding the message from some other contact (they do not have to be in the current conversation).
#

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_TEST_1,
    :group          => :ADVERTISEMENT_1,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Please buy Potions!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_TEST_2,
    :group          => :ADVERTISEMENT_1,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Please buy Super Potions!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_TEST_3,
    :group          => :ADVERTISEMENT_1,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Please buy Hyper Potions!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_TEST_4,
    :group          => :ADVERTISEMENT_1,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Please buy Max Potions!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :PLAYER_MESSAGE_TEST,
    :group          => :ADVERTISEMENT_1,
    :instant        => true,
    :not_new        => true,
    :messages       => [
                        [0, :Text, _INTL("Please stop sending me messages")]
                    ],
    :queue_after_receive => {
                        :id => :ADVERTISEMENT_APOLOGY_TEST,
                        :steps => 0,
                        :time => 5,
                        :stepvariation => 0,
                        :timevariation => -3..3
                    } 
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_APOLOGY_TEST,
    :group          => :ADVERTISEMENT_1,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("We do apologize!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_1,
    :group          => :ADVERTISEMENT_2,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Come visit Pokémon Centers!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_2,
    :group          => :ADVERTISEMENT_2,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Come visit Pokémon Marts!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :ADVERTISEMENT_RANDOM_3,
    :group          => :ADVERTISEMENT_2,
    :instant        => true,
    :messages       => [
                        [1, :Text, _INTL("Come visit Pokémon Gyms!")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :CHATBOT_VARIABLE_TEST,
    :group          => :CHATBOT,
    :important      => true,
    :messages       => [
                        [1, :Text, _INTL("I'm a chat bot.")],
                        [1, :Text, _INTL("Your next choice will save to Game Variable 2"), 0.5],
                        [0, :Text, [_INTL("Set to 0"), _INTL("Set to 1"), _INTL("Set to 2")], 2],
                        [1, :Text, [_INTL("You chose choice 1."), _INTL("You chose choice 2."), _INTL("You chose choice 3.")]],
                        [1, :Text, [_INTL("Choice 1 was a good one."), _INTL("Choice 2 was alright."), _INTL("Choice 3 was not a good choice. You should have chosen another.")]],
                        [1, :RedoText, _INTL("Your next choice will execute code to change your first Pokémon's gender")],
                        [1, :Text, _INTL("Change your Pokémon's gender to what?")],
                        [0, :Text, [_INTL("Male"),_INTL("Female")],"$player.party[0].gender = {VALUE}"],
                        [1, :Text, [_INTL("You chose choice 1."),_INTL("You chose choice 2.")]],
                        [1, :Text, _INTL("That's it for now.")],
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :OAK_TEST,
    :group          => :PROFOAK,
    :important      => true,
    :messages       => [
                        [1, :Text, _INTL("Hello, this is Professor Oak")],
                        [1, :Text, _INTL("Did this message <b>reach</b> you?")],
                        [-1, :Text, _INTL("Please answer the question.")],
                        [0, :Text, [_INTL("Message received"), _INTL("No")]],
                        [1, :Text, [_INTL("<icon=emojiHappy> "), _INTL("<icon=emojiAngry> ")]],
                        [1, :Text, [_INTL("Very good"), _INTL("There is no time for jokes")]],
                        [1, :Text, _INTL("I'm going to try something")],
                        [-1, :Enter, 2, 2],
                        [-1, :GroupName, _INTL("Prof. Oak & Chatbot")],
                        [2, :Text, _INTL("Thank you for including me in your chat.")],
                        [1, :Text, _INTL("Oh no not that")],
                        [2, :Text, _INTL("I wish to stay.")],
                        [-1, :Leave, 2, 0.25],
                        [-1, :GroupName, nil],
                        [1, :Picture, "Pikachu"],
                        [1, :Text, _INTL("I meant to send you that Pikachu picture <icon=emojiPokeball> ")],
                        [1, :Text, _INTL("That's all for now")],
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :OAK_NEW_FEATURES_TEST,
    :group          => :PROFOAK,
    :important      => true,
    :messages       => [
                        [1, :Text, _INTL("Did you know a lot of new features were added in version 1.3?")],
                        [0, :React, ["emojiSurprised", "emojiHappy", "emojiAngry"], true],
                        [-1,:Delay, 1],
                        [2, :React, "emojiSurprised"],
                        [-1,:Delay, 1],
                        [1, :Typing, 2],
                        [[1,2], :Typing, 2],
                        [1, :Typing, 1],
                        [1, :Text, _INTL("You just saw :React and :Delay")],
                        [-1,:Delay, 0.5],
                        [1, :Edit, _INTL("You just saw :React and :Delay. Oh and :Typing")],
                        [2, :Text, _INTL("You just used :Edit")],
                        [2, :Text, _INTL("blahblahblah")],
                        [-1,:Delay, 1],
                        [-1,:Delete],
                        [1, :Reply, _INTL("Good use of :Delete after this"), -2],
                        [1, :Forward, _INTL("You can make choices to impact reactions, too!"), :ADVERTISEMENT],
                        [1, :Text, _INTL("Some good advice")],
                        [0, :Text, [_INTL("Please thumbs up"), _INTL("Please thumbs down")]],
                        [-1,:Delay, 1],
                        [2, :React, ["emojiThumbsUp", "emojiThumbsDown"]],
                        [1, :React, ["emojiThumbsUp", "emojiThumbsDown"]],
                        [1, :Reply, _INTL("Perfect")]
                    ]
})

GameData::InstantMessageConversation.register({
    :id             => :OAK_18_MONTHS_AGO,
    :group          => :PROFOAK,
    :reltimestamp   => [1, 6, 14],
    :messages       => [
                        [1, :Text, _INTL("Hello, this is Professor Oak, but a message from 18 months ago.")]
    ]
})

GameData::InstantMessageConversation.register({
    :id             => :OAK_YESTERDAY,
    :group          => :PROFOAK,
    :reltimestamp   => [0, 0, 1, 5, 0, 15],
    :messages       => [
                        [1, :Text, _INTL("Hello, this is Professor Oak.")],
                        [1, :Text, _INTL("I will message you again tomorrow.")]
    ]
})

GameData::InstantMessageConversation.register({
    :id             => :OAK_30_MIN_AGO,
    :group          => :PROFOAK,
    :reltimestamp   => [0, 0, 0, 0, 30],
    :messages       => [
                        [1, :Text, _INTL("I messaged you again like I said I would.")]
    ]
})

GameData::InstantMessageConversation.register({
    :id             => :CHATBOT_5_MIN_AGO,
    :group          => :CHATBOT,
    :reltimestamp   => [0, 0, 0, 0, 5, 30],
    :messages       => [
                        [1, :Text, _INTL("I'm a bot.")]
    ]
})

#===============================================================================
# Actual AWRFSS messages
#===============================================================================
GameData::InstantMessageConversation.register({
	:id => :InformMonaAboutAria,
	:group => :PlayerFriends,
	:important => true,
	:messages => [
		[0, :Text, _INTL("Hey Mona, we found Aria. She's headed to Maracaleza Town though.")],
		[-1,:Delay, 1],
		[2, :Text, _INTL("Please at least tell me she told the gym guy")],
		[-1,:Delay, 1],
		[0, :Text, _INTL("Aha. No.")],
		[-1,:Delay, 1],
		[1, :Text, _INTL("she looked to be in a huge hurry <icon=emojiSweat>")],
		[-1,:Delay, 3],
		[2, :Text, _INTL("What the hell. I'll go see what she's up to")],
		[-1,:Delay, 2],
		[1, :Text, _INTL("very fair, wanna meet up with mona \\pn")],
		[0, :Text, [_INTL("Doesn't Mona have this?"),_INTL("Sure, whatever")]],
		[-1,:Delay, 1],
		[2, :Text, [_INTL("Actually, I could use your help"),_INTL("Sounds very enthused /s")]],
		[-1,:Delay, 1],
		[2, :Text, _INTL("Meet you in Maracaleza Town")],
		[-1,:Delay, 1],
		[1, :Text, _INTL("sounds like youve been recruited {1} <icon=emojiLaugh>")]
	]
})