#===============================================================================
# Modern Questing System + UI
# If you like quests, this is the resource for you!
#===============================================================================
# Original implemenation by mej71
# Updated for v17.2 and v18/18.1 by derFischae
# Heavily edited for v19/19.1 by ThatWelshOne_
# Some UI components borrowed (with permission) from Marin's Easy Questing Interface
# 
#===============================================================================
# Things you can currently customise without editing the scripts themselves
#===============================================================================

# If true, includes a page of failed quests on the UI
# Set this to false if you don't want to have quests that can be failed
SHOW_FAILED_QUESTS = true

# Name of file in Audio/SE that plays when a quest is activated/advanced to new stage/completed
QUEST_JINGLE = "Mining found all.ogg"

# Name of file in Audio/SE that plays when a quest is failed
QUEST_FAIL = "GUI sel buzzer.ogg"

# Option to have quests sorted by story, then time started
SORT_QUESTS = true

# Future plans are to add different backgrounds that can be chosen by you

#===============================================================================
# Utility method for setting colors
#===============================================================================

# Useful Hex to 15-bit color converter: http://www.budmelvin.com/dev/15bitconverter.html
# Add in your own colors here!
def colorQuest(color)
  color = color.downcase if color
  return "76EF7DC0" if color == "blue"
  return "5EBF089D" if color == "red"
  return "4B5626CC" if color == "green"
  return "73956F69" if color == "cyan"
  return "729D5CFA" if color == "magenta"
  return "47BF135D" if color == "yellow"
  return "6F5A5694" if color == "gray"
  return "6B397FDE" if color == "white"
  return "72B77512" if color == "purple"
  return "4F3F0E7F" if color == "orange"
  return "7FFF2D49" # Returns the default white color if all other options are exhausted
end
