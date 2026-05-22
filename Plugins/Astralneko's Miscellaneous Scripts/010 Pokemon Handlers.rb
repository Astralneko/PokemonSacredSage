#===============================================================================
# Verelan new Pokémon with forms
#===============================================================================
MultipleForms.register(:AMNIBALL,{
  "getFormOnCreation" => proc { |pkmn|
     darkModeNatures = [:LONELY, :BRAVE, :ADAMANT,:NAUGHTY,
                :RASH, :MODEST, :MILD, :QUIET,
                :HASTY, :NAIVE]
     lightModeNatures = [:BOLD, :RELAXED, :IMPISH,:CALM,
                :GENTLE, :SASSY, :CAREFUL, :TIMID,
                :JOLLY, :LAX]
     next 1 if darkModeNatures.include?(pkmn.nature)
     next 0 if lightModeNatures.include?(pkmn.nature)
     next pkmn.personalID%2
  },
})

MultipleForms.register(:MARIHUSH,{
  "getFormOnEnteringBattle" => proc { |pkmn,wild|
    next 1
  },
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next 0
  }
})

MultipleForms.register(:CRYSTODE,{
  "getFormOnCreation" => proc { |pkmn|
    if $game_map
      ret = 0
      locationmaps = {
        # map 15 - Fairdune Cave
        15  => [20,20,20,
                24,
                30,30],
        # map 9 - Starview Cave
        9   => [20,20,20,20,20,
                22,22,22,
                30,30,
                35,
                38,38,38,38],
        # map 66 - Rocavideo Wellspring
        66  => [20,20,20,
                23,23,
                27,
                30,30,30,
                31,31,
                34]
      }
      locationmaps.each do |f, formlist|
        if $game_map.map_id == f
          next formlist.sample
        end
      end
    end
    next 20+rand(20) # Clear Body forms are 0-19, Type Body forms are 20-39
  },
  "getFormOnLeavingBattle" => proc { |pkmn,battle,usedInBattle,endBattle|
    next pkmn.form+20 if pkmn.form<20
  }
})
MultipleForms.copy(:CRYSTODE,:QUARTZLEM,:DYODETZA)

#===============================================================================
# Verelan regional forms
#===============================================================================

# Upon creating an egg, ensure its regional form matches that of the region tag
MultipleForms.register(:RATTATA, {
  "getFormOnEggCreation" => proc { |pkmn, parent|
    if $game_map
      map_pos = $game_map.metadata&.town_map_position
      if map_pos
        form = 0
        case map_pos[0]
        #-----------------------------------------------------------------------
        when 0  # Verela region
          case pkmn.species
          when :HOPPIP, :WOOBAT, :MAREANIE, :VULLABY
            form = 1
		  when :SHUPPET, :GOLETT # Verelan forms whose base forms have Mega Evolutions
		    form = 2
		  when :MILCERY # Milcery's Verelan form is number 63 due to Galarian Alcremie's 63 forms
		    form = 63
          end
        #-----------------------------------------------------------------------
        when 1  # Unova region - Unova and Alola are considered equivalent for this game
          case pkmn.species
          when :RATTATA, :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE, :GRIMER
            form = 1
          end
        #-----------------------------------------------------------------------
        when 2  # Paldea region - Paldea and Galar are considered equivalent for this game
          case pkmn.species
          when :PONYTA, :SLOWPOKE, :FARFETCHD, :ARTICUNO, :ZAPDOS, :MOLTRES, :CORSOLA, :ZIGZAGOON, :YAMASK, :STUNFISK, :WOOPER
            form = 1
          when :MEOWTH, :DARUMAKA
            form = 2
          when :TAUROS
		    # If parent is Paldean Tauros, match its breed
            form = (parent.form == 0) ? 1 : parent.form
          end
        #-----------------------------------------------------------------------
        when 3  # Hisui region
          case pkmn.species
          when :GROWLITHE, :VOLTORB, :QWILFISH, :SNEASEL, :ZORUA
            form = 1
          end
        end
        next form if form > 0 && GameData::Species.get_species_form(pkmn.species, form).form == form
      end
    end
    next 0
  }
})

MultipleForms.copy(:RATTATA, 
	               :SANDSHREW, :VULPIX, :DIGLETT, :MEOWTH, :GEODUDE, :GRIMER,                # Alolan
                   :PONYTA, :FARFETCHD, :CORSOLA, :ZIGZAGOON, :YAMASK, :STUNFISK,            # Galarian                                   
                   :SLOWPOKE, :ARTICUNO, :ZAPDOS, :MOLTRES,                                  # Galarian (DLC)
                   :GROWLITHE, :VOLTORB, :QWILFISH, :SNEASEL, :ZORUA,                        # Hisuian
                   :TAUROS, :WOOPER,                                                         # Paldean
				   :HOPPIP, :WOOBAT, :MAREANIE, :VULLABY, :SHUPPET, :GOLETT, :MILCERY        # Verelan
                  )  
# Alcremie's 7 forms are handled in an Evolution handler, see the main script section for more.

# Togepi doesn't have regional forms, but its evolution does
MultipleForms.register(:TOGEPI, {
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple >= 2
    if $game_map
      map_pos = $game_map.metadata&.town_map_position
      next 1 if map_pos && map_pos[0] == 0   # Verela region
    end
    next 0
  }
})

# Teddiursa doesn't have regional forms, but its evolution does; due to Bloodmoon Ursaluna this is not a clone of Togepi
MultipleForms.register(:TEDDIURSA, {
  "getForm" => proc { |pkmn|
    next if pkmn.form_simple == 1 || pkmn.form_simple >= 3
    if $game_map
      map_pos = $game_map.metadata&.town_map_position
      next 2 if map_pos && map_pos[0] == 0   # Verela region
    end
    next 0
  }
})