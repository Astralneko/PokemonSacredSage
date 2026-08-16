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
def anPlayerPronoun
	gender = $player.gender
	pronouns = [
		[ # Masculine
			[ # 0 is used only for non-pronoun things, such asective and verb endings
				_INTL("masc ending 1"),_INTL("masc ending 2"),_INTL("masc ending 3"),_INTL("masc ending 4"),
				_INTL("masc ending 5"),_INTL("masc ending 6"),_INTL("masc ending 7"),_INTL("masc ending 8"),
				_INTL("masc ending 9"),_INTL("masc ending 10"),_INTL("masc ending 11"),_INTL("masc ending 12"),
				_INTL("masc ending 13"),_INTL("masc ending 14"),_INTL("masc ending 15"),_INTL("masc ending 16")
			],[ # First person
				_INTL("1SG.M.FOR.NOM"),_INTL("1SG.M.FOR.ACC"),_INTL("1SG.M.FOR.GEN"),_INTL("1SG.M.FOR.DAT"),
				_INTL("1SG.M.FAM.NOM"),_INTL("1SG.M.FAM.ACC"),_INTL("1SG.M.FAM.GEN"),_INTL("1SG.M.FAM.DAT")
			],[ # Second person
				_INTL("2SG.M.FOR.NOM"),_INTL("2SG.M.FOR.ACC"),_INTL("2SG.M.FOR.GEN"),_INTL("2SG.M.FOR.DAT"),
				_INTL("2SG.M.FAM.NOM"),_INTL("2SG.M.FAM.ACC"),_INTL("2SG.M.FAM.GEN"),_INTL("2SG.M.FAM.DAT")
			],[ # Third person
				_INTL("3SG.M.FOR.NOM"),_INTL("3SG.M.FOR.ACC"),_INTL("3SG.M.FOR.GEN"),_INTL("3SG.M.FOR.DAT"),
				_INTL("3SG.M.FAM.NOM"),_INTL("3SG.M.FAM.ACC"),_INTL("3SG.M.FAM.GEN"),_INTL("3SG.M.FAM.DAT")
			],[ # First person plural same
				_INTL("1PL.M.FOR.NOM"),_INTL("1PL.M.FOR.ACC"),_INTL("1PL.M.FOR.GEN"),_INTL("1PL.M.FOR.DAT"),
				_INTL("1PL.M.FAM.NOM"),_INTL("1PL.M.FAM.ACC"),_INTL("1PL.M.FAM.GEN"),_INTL("1PL.M.FAM.DAT")
			],[ # Second person plural same
				_INTL("2PL.M.FOR.NOM"),_INTL("2PL.M.FOR.ACC"),_INTL("2PL.M.FOR.GEN"),_INTL("2PL.M.FOR.DAT"),
				_INTL("2PL.M.FAM.NOM"),_INTL("2PL.M.FAM.ACC"),_INTL("2PL.M.FAM.GEN"),_INTL("2PL.M.FAM.DAT")
			],[ # Third person plural same
				_INTL("3PL.M.FOR.NOM"),_INTL("3PL.M.FOR.ACC"),_INTL("3PL.M.FOR.GEN"),_INTL("3PL.M.FOR.DAT"),
				_INTL("3PL.M.FAM.NOM"),_INTL("3PL.M.FAM.ACC"),_INTL("3PL.M.FAM.GEN"),_INTL("3PL.M.FAM.DAT")
			],[ # First person plural different
				_INTL("1PL.MIX.FOR.NOM"),_INTL("1PL.MIX.FOR.ACC"),_INTL("1PL.MIX.FOR.GEN"),_INTL("1PL.MIX.FOR.DAT"),
				_INTL("1PL.MIX.FAM.NOM"),_INTL("1PL.MIX.FAM.ACC"),_INTL("1PL.MIX.FAM.GEN"),_INTL("1PL.MIX.FAM.DAT")
			],[ # Second person plural different
				_INTL("2PL.MIX.FOR.NOM"),_INTL("2PL.MIX.FOR.ACC"),_INTL("2PL.MIX.FOR.GEN"),_INTL("2PL.MIX.FOR.DAT"),
				_INTL("2PL.MIX.FAM.NOM"),_INTL("2PL.MIX.FAM.ACC"),_INTL("2PL.MIX.FAM.GEN"),_INTL("2PL.MIX.FAM.DAT")
			],[ # Third person plural different
				_INTL("3PL.MIX.FOR.NOM"),_INTL("3PL.MIX.FOR.ACC"),_INTL("3PL.MIX.FOR.GEN"),_INTL("3PL.MIX.FOR.DAT"),
				_INTL("3PL.MIX.FAM.NOM"),_INTL("3PL.MIX.FAM.ACC"),_INTL("3PL.MIX.FAM.GEN"),_INTL("3PL.MIX.FAM.DAT")
			]
		],[ # Feminine
			[ # 0 is used only for non-pronoun things, such asective and verb endings
				_INTL("fem ending 1"),_INTL("fem ending 2"),_INTL("fem ending 3"),_INTL("fem ending 4"),
				_INTL("fem ending 5"),_INTL("fem ending 6"),_INTL("fem ending 7"),_INTL("fem ending 8"),
				_INTL("fem ending 9"),_INTL("fem ending 10"),_INTL("fem ending 11"),_INTL("fem ending 12"),
				_INTL("fem ending 13"),_INTL("fem ending 14"),_INTL("fem ending 15"),_INTL("fem ending 16")
			],[ # First person
				_INTL("1SG.F.FOR.NOM"),_INTL("1SG.F.FOR.ACC"),_INTL("1SG.F.FOR.GEN"),_INTL("1SG.F.FOR.DAT"),
				_INTL("1SG.F.FAM.NOM"),_INTL("1SG.F.FAM.ACC"),_INTL("1SG.F.FAM.GEN"),_INTL("1SG.F.FAM.DAT")
			],[ # Second person
				_INTL("2SG.F.FOR.NOM"),_INTL("2SG.F.FOR.ACC"),_INTL("2SG.F.FOR.GEN"),_INTL("2SG.F.FOR.DAT"),
				_INTL("2SG.F.FAM.NOM"),_INTL("2SG.F.FAM.ACC"),_INTL("2SG.F.FAM.GEN"),_INTL("2SG.F.FAM.DAT")
			],[ # Third person
				_INTL("3SG.F.FOR.NOM"),_INTL("3SG.F.FOR.ACC"),_INTL("3SG.F.FOR.GEN"),_INTL("3SG.F.FOR.DAT"),
				_INTL("3SG.F.FAM.NOM"),_INTL("3SG.F.FAM.ACC"),_INTL("3SG.F.FAM.GEN"),_INTL("3SG.F.FAM.DAT")
			],[ # First person plural same
				_INTL("1PL.F.FOR.NOM"),_INTL("1PL.F.FOR.ACC"),_INTL("1PL.F.FOR.GEN"),_INTL("1PL.F.FOR.DAT"),
				_INTL("1PL.F.FAM.NOM"),_INTL("1PL.F.FAM.ACC"),_INTL("1PL.F.FAM.GEN"),_INTL("1PL.F.FAM.DAT")
			],[ # Second person plural same
				_INTL("2PL.F.FOR.NOM"),_INTL("2PL.F.FOR.ACC"),_INTL("2PL.F.FOR.GEN"),_INTL("2PL.F.FOR.DAT"),
				_INTL("2PL.F.FAM.NOM"),_INTL("2PL.F.FAM.ACC"),_INTL("2PL.F.FAM.GEN"),_INTL("2PL.F.FAM.DAT")
			],[ # Third person plural same
				_INTL("3PL.F.FOR.NOM"),_INTL("3PL.F.FOR.ACC"),_INTL("3PL.F.FOR.GEN"),_INTL("3PL.F.FOR.DAT"),
				_INTL("3PL.F.FAM.NOM"),_INTL("3PL.F.FAM.ACC"),_INTL("3PL.F.FAM.GEN"),_INTL("3PL.F.FAM.DAT")
			],[ # First person plural different
				_INTL("1PL.MIX.FOR.NOM"),_INTL("1PL.MIX.FOR.ACC"),_INTL("1PL.MIX.FOR.GEN"),_INTL("1PL.MIX.FOR.DAT"),
				_INTL("1PL.MIX.FAM.NOM"),_INTL("1PL.MIX.FAM.ACC"),_INTL("1PL.MIX.FAM.GEN"),_INTL("1PL.MIX.FAM.DAT")
			],[ # Second person plural different
				_INTL("2PL.MIX.FOR.NOM"),_INTL("2PL.MIX.FOR.ACC"),_INTL("2PL.MIX.FOR.GEN"),_INTL("2PL.MIX.FOR.DAT"),
				_INTL("2PL.MIX.FAM.NOM"),_INTL("2PL.MIX.FAM.ACC"),_INTL("2PL.MIX.FAM.GEN"),_INTL("2PL.MIX.FAM.DAT")
			],[ # Third person plural different
				_INTL("3PL.MIX.FOR.NOM"),_INTL("3PL.MIX.FOR.ACC"),_INTL("3PL.MIX.FOR.GEN"),_INTL("3PL.MIX.FOR.DAT"),
				_INTL("3PL.MIX.FAM.NOM"),_INTL("3PL.MIX.FAM.ACC"),_INTL("3PL.MIX.FAM.GEN"),_INTL("3PL.MIX.FAM.DAT")
			]
		],[ # Neuter
			[ # 0 is used only for non-pronoun things, such asective and verb endings
				_INTL("neutral ending 1"),_INTL("neutral ending 2"),_INTL("neutral ending 3"),_INTL("neutral ending 4"),
				_INTL("neutral ending 5"),_INTL("neutral ending 6"),_INTL("neutral ending 7"),_INTL("neutral ending 8"),
				_INTL("neutral ending 9"),_INTL("neutral ending 10"),_INTL("neutral ending 11"),_INTL("neutral ending 12"),
				_INTL("neutral ending 13"),_INTL("neutral ending 14"),_INTL("neutral ending 15"),_INTL("neutral ending 16")
			],[ # First person
				_INTL("1SG.N.FOR.NOM"),_INTL("1SG.N.FOR.ACC"),_INTL("1SG.N.FOR.GEN"),_INTL("1SG.N.FOR.DAT"),
				_INTL("1SG.N.FAM.NOM"),_INTL("1SG.N.FAM.ACC"),_INTL("1SG.N.FAM.GEN"),_INTL("1SG.N.FAM.DAT")
			],[ # Second person
				_INTL("2SG.N.FOR.NOM"),_INTL("2SG.N.FOR.ACC"),_INTL("2SG.N.FOR.GEN"),_INTL("2SG.N.FOR.DAT"),
				_INTL("2SG.N.FAM.NOM"),_INTL("2SG.N.FAM.ACC"),_INTL("2SG.N.FAM.GEN"),_INTL("2SG.N.FAM.DAT")
			],[ # Third person
				_INTL("3SG.N.FOR.NOM"),_INTL("3SG.N.FOR.ACC"),_INTL("3SG.N.FOR.GEN"),_INTL("3SG.N.FOR.DAT"),
				_INTL("3SG.N.FAM.NOM"),_INTL("3SG.N.FAM.ACC"),_INTL("3SG.N.FAM.GEN"),_INTL("3SG.N.FAM.DAT")
			],[ # First person plural same
				_INTL("1PL.N.FOR.NOM"),_INTL("1PL.N.FOR.ACC"),_INTL("1PL.N.FOR.GEN"),_INTL("1PL.N.FOR.DAT"),
				_INTL("1PL.N.FAM.NOM"),_INTL("1PL.N.FAM.ACC"),_INTL("1PL.N.FAM.GEN"),_INTL("1PL.N.FAM.DAT")
			],[ # Second person plural same
				_INTL("2PL.N.FOR.NOM"),_INTL("2PL.N.FOR.ACC"),_INTL("2PL.N.FOR.GEN"),_INTL("2PL.N.FOR.DAT"),
				_INTL("2PL.N.FAM.NOM"),_INTL("2PL.N.FAM.ACC"),_INTL("2PL.N.FAM.GEN"),_INTL("2PL.N.FAM.DAT")
			],[ # Third person plural same
				_INTL("3PL.N.FOR.NOM"),_INTL("3PL.N.FOR.ACC"),_INTL("3PL.N.FOR.GEN"),_INTL("3PL.N.FOR.DAT"),
				_INTL("3PL.N.FAM.NOM"),_INTL("3PL.N.FAM.ACC"),_INTL("3PL.N.FAM.GEN"),_INTL("3PL.N.FAM.DAT")
			],[ # First person plural different
				_INTL("1PL.MIX.FOR.NOM"),_INTL("1PL.MIX.FOR.ACC"),_INTL("1PL.MIX.FOR.GEN"),_INTL("1PL.MIX.FOR.DAT"),
				_INTL("1PL.MIX.FAM.NOM"),_INTL("1PL.MIX.FAM.ACC"),_INTL("1PL.MIX.FAM.GEN"),_INTL("1PL.MIX.FAM.DAT")
			],[ # Second person plural different
				_INTL("2PL.MIX.FOR.NOM"),_INTL("2PL.MIX.FOR.ACC"),_INTL("2PL.MIX.FOR.GEN"),_INTL("2PL.MIX.FOR.DAT"),
				_INTL("2PL.MIX.FAM.NOM"),_INTL("2PL.MIX.FAM.ACC"),_INTL("2PL.MIX.FAM.GEN"),_INTL("2PL.MIX.FAM.DAT")
			],[ # Third person plural different
				_INTL("3PL.MIX.FOR.NOM"),_INTL("3PL.MIX.FOR.ACC"),_INTL("3PL.MIX.FOR.GEN"),_INTL("3PL.MIX.FOR.DAT"),
				_INTL("3PL.MIX.FAM.NOM"),_INTL("3PL.MIX.FAM.ACC"),_INTL("3PL.MIX.FAM.GEN"),_INTL("3PL.MIX.FAM.DAT")
			]
		]
	][gender]
end

# Note: the actual code for ppr appears in [002] Text Replacement.rb under Player Gender