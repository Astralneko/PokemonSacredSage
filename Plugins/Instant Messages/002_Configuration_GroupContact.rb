#===============================================================================
# Contact registrations
#
# These are individual NPCs that the player chats with in conversations.
#===============================================================================
# Parameters:
#   - :id => Symbol - The ID used to add the contact to groups 
#   - :name => String - The name of the contact the player will see
#   - :image => String - The filename of the image used to represent the contact. 
#               File location: UI/Instant Messages/Characters
#   - :bubble => String - The filename of the windowskin used by the contact. 
#               File location: UI/Instant Messages/Bubbles
#===============================================================================

GameData::InstantMessageContact.register({
    :id             => :CHATBOT,
    :name		        => _INTL("Chatbot"),
    :image		      => "Chatbot",
    :bubble         => "Green",
    :reactions_list => ["emojiSad", "emojiHeart"]
})

GameData::InstantMessageContact.register({
    :id             => :ADVERTISEMENT,
    :name		        => _INTL("Advertisement"),
    :image		      => "Advertisement",
    :bubble         => "Blue"
})

GameData::InstantMessageContact.register({
    :id             => :PROFOAK,
    :name		        => _INTL("Prof. Oak"),
    :image		      => "Oak",
    :bubble         => "Purple"
})

#===============================================================================
# Actual AWRFSS characters
#===============================================================================
GameData::InstantMessageContact.register({
    :id             => :Natsuki,
    :name		        => _INTL("Natsuki"),
    :image		      => "Natsuki",
    :bubble         => "Rose"
})

GameData::InstantMessageContact.register({
    :id             => :Mona,
    :name		        => _INTL("Mona"),
    :image		      => "Mona",
    :bubble         => "Azure"
})

#===============================================================================
# Group registrations
#
# These are the groups/containers/threads that can contain several conversations.
# These are what appear in the selection menu, and will load conversations once
# opened.
#===============================================================================
# Parameters:
#   - :id => Symbol - The ID used to house specific conversations
#   - :title => String - The name of the group as seen by the player
#   - :members => Hash - Contains contacts included in the group and their
#                 reference numbers used when creating conversation messages.
#                 { <Interger - Reference Number => <Symbol - :id of a contact}         
#   - :hide_old => (Optional) Boolean - Set to false to hide already read message
#   - :reactions_list => (Optional) Array - Contains filenames of images in   
#                        Graphics/Icons that are the default list of reactions 
#                        for the group. If not set, the list defined in 
#                        REACTIONS_LIST is used.
#===============================================================================

GameData::InstantMessageGroup.register({
    :id             => :CHATBOT,
    :title		    => _INTL("Chatbot"),
    :members		=> {1 => :CHATBOT}
})

GameData::InstantMessageGroup.register({
    :id             => :ADVERTISEMENT_1,
    :title		    => _INTL("Advertisement"),
    :members		=> {1 => :ADVERTISEMENT}
})

GameData::InstantMessageGroup.register({
    :id             => :ADVERTISEMENT_2,
    :title		    => _INTL("Advertisement Two"),
    :members		=> {1 => :ADVERTISEMENT}
})

GameData::InstantMessageGroup.register({
    :id             => :PROFOAK,
    :title		    => _INTL("Prof. Oak"),
    :members		=> {1 => :PROFOAK, 2 => :CHATBOT}
})

#===============================================================================
# Actual AWRFSS groups
#===============================================================================
GameData::InstantMessageGroup.register({
    :id             => :PlayerFriends,
    :title		    => _INTL("Alipigra High Battle Club"),
    :members		=> {1 => :Natsuki, 2 => :Mona}
})