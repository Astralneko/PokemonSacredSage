# anPlayerPronoun is to be used whenever a message has \ppr[X][Y] in it.
#
# X is the person
# 1 for first singular, 2 for second singular, 3 for third singular
# 4-6 are same as 1-3 but for groups of the same gender, while 7-9 are same as 1-3 but for groups of different genders
# use 0 for nonpronoun things such as Spanish adding -o/a/e toectives
#
# Y is a number of the following:
# 0 = formal nominative 1 = formal accusative 2 = formal genitive 3 = formal dative
# 4 = informal nominative 5 = informal accusative 6 = informal genitive 7 = informal dative
#
# These handlers are used so that it's easy to identify these in translation - seeing as >1000 map IDs already mandate a separate english.dat from common, I consider this to be fine
# English translated text will likely use exclusively category 3 due to very rare gender agreement otherwise

# Add Pronouns to MessageTypes for translation
module MessageTypes
	Pronouns = 202
end

# Compiler edit to ensure pronouns are in hash
module Compiler
	class << Compiler
		alias compile_all_astralneko_pronoun compile_all
	end

	def self.compile_all(mustCompile)
		MessageTypes.setMessagesAsHash(MessageTypes::Pronouns,anPronounArray.flatten)
		Translator.gather_script_and_event_texts
		MessageTypes.save_default_messages
		MessageTypes.load_default_messages if FileTest.exist?("Data/messages_core.dat")
		compile_all_astralneko_pronoun(mustCompile) { |msg| pbSetWindowText(msg); echoln(msg) }
	end
end



# Actual methods
def anPlayerPronoun(x = 0, y = 0)
	return MessageTypes.getFromHash(MessageTypes::Pronouns, anPronounArray[$player.gender][x][y])
end

def anPronounArray
	return [
		[ # Masculine
			[ # 0 is used only for non-pronoun things, such asective and verb endings
				"masc ending 1","masc ending 2","masc ending 3","masc ending 4",
				"masc ending 5","masc ending 6","masc ending 7","masc ending 8",
				"masc ending 9","masc ending 10","masc ending 11","masc ending 12",
				"masc ending 13","masc ending 14","masc ending 15","masc ending 16"
			],[ # First person
				"1SG.M.FOR.NOM","1SG.M.FOR.ACC","1SG.M.FOR.GEN","1SG.M.FOR.DAT",
				"1SG.M.FAM.NOM","1SG.M.FAM.ACC","1SG.M.FAM.GEN","1SG.M.FAM.DAT"
			],[ # Second person
				"2SG.M.FOR.NOM","2SG.M.FOR.ACC","2SG.M.FOR.GEN","2SG.M.FOR.DAT",
				"2SG.M.FAM.NOM","2SG.M.FAM.ACC","2SG.M.FAM.GEN","2SG.M.FAM.DAT"
			],[ # Third person
				"3SG.M.FOR.NOM","3SG.M.FOR.ACC","3SG.M.FOR.GEN","3SG.M.FOR.DAT",
				"3SG.M.FAM.NOM","3SG.M.FAM.ACC","3SG.M.FAM.GEN","3SG.M.FAM.DAT"
			],[ # First person plural same
				"1PL.M.FOR.NOM","1PL.M.FOR.ACC","1PL.M.FOR.GEN","1PL.M.FOR.DAT",
				"1PL.M.FAM.NOM","1PL.M.FAM.ACC","1PL.M.FAM.GEN","1PL.M.FAM.DAT"
			],[ # Second person plural same
				"2PL.M.FOR.NOM","2PL.M.FOR.ACC","2PL.M.FOR.GEN","2PL.M.FOR.DAT",
				"2PL.M.FAM.NOM","2PL.M.FAM.ACC","2PL.M.FAM.GEN","2PL.M.FAM.DAT"
			],[ # Third person plural same
				"3PL.M.FOR.NOM","3PL.M.FOR.ACC","3PL.M.FOR.GEN","3PL.M.FOR.DAT",
				"3PL.M.FAM.NOM","3PL.M.FAM.ACC","3PL.M.FAM.GEN","3PL.M.FAM.DAT"
			],[ # First person plural different
				"1PL.MIX.FOR.NOM","1PL.MIX.FOR.ACC","1PL.MIX.FOR.GEN","1PL.MIX.FOR.DAT",
				"1PL.MIX.FAM.NOM","1PL.MIX.FAM.ACC","1PL.MIX.FAM.GEN","1PL.MIX.FAM.DAT"
			],[ # Second person plural different
				"2PL.MIX.FOR.NOM","2PL.MIX.FOR.ACC","2PL.MIX.FOR.GEN","2PL.MIX.FOR.DAT",
				"2PL.MIX.FAM.NOM","2PL.MIX.FAM.ACC","2PL.MIX.FAM.GEN","2PL.MIX.FAM.DAT"
			],[ # Third person plural different
				"3PL.MIX.FOR.NOM","3PL.MIX.FOR.ACC","3PL.MIX.FOR.GEN","3PL.MIX.FOR.DAT",
				"3PL.MIX.FAM.NOM","3PL.MIX.FAM.ACC","3PL.MIX.FAM.GEN","3PL.MIX.FAM.DAT"
			]
		],[ # Feminine
			[ # 0 is used only for non-pronoun things, such asective and verb endings
				"fem ending 1","fem ending 2","fem ending 3","fem ending 4",
				"fem ending 5","fem ending 6","fem ending 7","fem ending 8",
				"fem ending 9","fem ending 10","fem ending 11","fem ending 12",
				"fem ending 13","fem ending 14","fem ending 15","fem ending 16"
			],[ # First person
				"1SG.F.FOR.NOM","1SG.F.FOR.ACC","1SG.F.FOR.GEN","1SG.F.FOR.DAT",
				"1SG.F.FAM.NOM","1SG.F.FAM.ACC","1SG.F.FAM.GEN","1SG.F.FAM.DAT"
			],[ # Second person
				"2SG.F.FOR.NOM","2SG.F.FOR.ACC","2SG.F.FOR.GEN","2SG.F.FOR.DAT",
				"2SG.F.FAM.NOM","2SG.F.FAM.ACC","2SG.F.FAM.GEN","2SG.F.FAM.DAT"
			],[ # Third person
				"3SG.F.FOR.NOM","3SG.F.FOR.ACC","3SG.F.FOR.GEN","3SG.F.FOR.DAT",
				"3SG.F.FAM.NOM","3SG.F.FAM.ACC","3SG.F.FAM.GEN","3SG.F.FAM.DAT"
			],[ # First person plural same
				"1PL.F.FOR.NOM","1PL.F.FOR.ACC","1PL.F.FOR.GEN","1PL.F.FOR.DAT",
				"1PL.F.FAM.NOM","1PL.F.FAM.ACC","1PL.F.FAM.GEN","1PL.F.FAM.DAT"
			],[ # Second person plural same
				"2PL.F.FOR.NOM","2PL.F.FOR.ACC","2PL.F.FOR.GEN","2PL.F.FOR.DAT",
				"2PL.F.FAM.NOM","2PL.F.FAM.ACC","2PL.F.FAM.GEN","2PL.F.FAM.DAT"
			],[ # Third person plural same
				"3PL.F.FOR.NOM","3PL.F.FOR.ACC","3PL.F.FOR.GEN","3PL.F.FOR.DAT",
				"3PL.F.FAM.NOM","3PL.F.FAM.ACC","3PL.F.FAM.GEN","3PL.F.FAM.DAT"
			],[ # First person plural different
				"1PL.MIX.FOR.NOM","1PL.MIX.FOR.ACC","1PL.MIX.FOR.GEN","1PL.MIX.FOR.DAT",
				"1PL.MIX.FAM.NOM","1PL.MIX.FAM.ACC","1PL.MIX.FAM.GEN","1PL.MIX.FAM.DAT"
			],[ # Second person plural different
				"2PL.MIX.FOR.NOM","2PL.MIX.FOR.ACC","2PL.MIX.FOR.GEN","2PL.MIX.FOR.DAT",
				"2PL.MIX.FAM.NOM","2PL.MIX.FAM.ACC","2PL.MIX.FAM.GEN","2PL.MIX.FAM.DAT"
			],[ # Third person plural different
				"3PL.MIX.FOR.NOM","3PL.MIX.FOR.ACC","3PL.MIX.FOR.GEN","3PL.MIX.FOR.DAT",
				"3PL.MIX.FAM.NOM","3PL.MIX.FAM.ACC","3PL.MIX.FAM.GEN","3PL.MIX.FAM.DAT"
			]
		],[ # Neuter
			[ # 0 is used only for non-pronoun things, such asective and verb endings
				"neutral ending 1","neutral ending 2","neutral ending 3","neutral ending 4",
				"neutral ending 5","neutral ending 6","neutral ending 7","neutral ending 8",
				"neutral ending 9","neutral ending 10","neutral ending 11","neutral ending 12",
				"neutral ending 13","neutral ending 14","neutral ending 15","neutral ending 16"
			],[ # First person
				"1SG.N.FOR.NOM","1SG.N.FOR.ACC","1SG.N.FOR.GEN","1SG.N.FOR.DAT",
				"1SG.N.FAM.NOM","1SG.N.FAM.ACC","1SG.N.FAM.GEN","1SG.N.FAM.DAT"
			],[ # Second person
				"2SG.N.FOR.NOM","2SG.N.FOR.ACC","2SG.N.FOR.GEN","2SG.N.FOR.DAT",
				"2SG.N.FAM.NOM","2SG.N.FAM.ACC","2SG.N.FAM.GEN","2SG.N.FAM.DAT"
			],[ # Third person
				"3SG.N.FOR.NOM","3SG.N.FOR.ACC","3SG.N.FOR.GEN","3SG.N.FOR.DAT",
				"3SG.N.FAM.NOM","3SG.N.FAM.ACC","3SG.N.FAM.GEN","3SG.N.FAM.DAT"
			],[ # First person plural same
				"1PL.N.FOR.NOM","1PL.N.FOR.ACC","1PL.N.FOR.GEN","1PL.N.FOR.DAT",
				"1PL.N.FAM.NOM","1PL.N.FAM.ACC","1PL.N.FAM.GEN","1PL.N.FAM.DAT"
			],[ # Second person plural same
				"2PL.N.FOR.NOM","2PL.N.FOR.ACC","2PL.N.FOR.GEN","2PL.N.FOR.DAT",
				"2PL.N.FAM.NOM","2PL.N.FAM.ACC","2PL.N.FAM.GEN","2PL.N.FAM.DAT"
			],[ # Third person plural same
				"3PL.N.FOR.NOM","3PL.N.FOR.ACC","3PL.N.FOR.GEN","3PL.N.FOR.DAT",
				"3PL.N.FAM.NOM","3PL.N.FAM.ACC","3PL.N.FAM.GEN","3PL.N.FAM.DAT"
			],[ # First person plural different
				"1PL.MIX.FOR.NOM","1PL.MIX.FOR.ACC","1PL.MIX.FOR.GEN","1PL.MIX.FOR.DAT",
				"1PL.MIX.FAM.NOM","1PL.MIX.FAM.ACC","1PL.MIX.FAM.GEN","1PL.MIX.FAM.DAT"
			],[ # Second person plural different
				"2PL.MIX.FOR.NOM","2PL.MIX.FOR.ACC","2PL.MIX.FOR.GEN","2PL.MIX.FOR.DAT",
				"2PL.MIX.FAM.NOM","2PL.MIX.FAM.ACC","2PL.MIX.FAM.GEN","2PL.MIX.FAM.DAT"
			],[ # Third person plural different
				"3PL.MIX.FOR.NOM","3PL.MIX.FOR.ACC","3PL.MIX.FOR.GEN","3PL.MIX.FOR.DAT",
				"3PL.MIX.FAM.NOM","3PL.MIX.FAM.ACC","3PL.MIX.FAM.GEN","3PL.MIX.FAM.DAT"
			]
		]
	]
end

# Note: the actual code for ppr appears in [002] Text Replacement.rb under Player Gender