=begin
  The following settings for text formatting can be used for the description of each location.
  <b> ... </b>       - Formats the text in bold.
  <i> ... </i>       - Formats the text in italics.
  <u> ... </u>       - Underlines the text.
  <s> ... </s>       - Draws a strikeout line over the text.
  <al> ... </al>     - Left-aligns the text.  Causes line breaks before and after
                       the text.
  <r>                - Right-aligns the text until the next line break.
  <ar> ... </ar>     - Right-aligns the text.  Causes line breaks before and after
                       the text.
  <ac> ... </ac>     - Centers the text.  Causes line breaks before and after the
                       text.
  <br>               - Causes a line break.
  <o=X>              - Displays the text in the given opacity (0-255)
  <outln>            - Displays the text in outline format.
  <outln2>           - Displays the text in outline format (outlines more
                       exaggerated.
  <icon=X>           - Displays the icon X (in Graphics/Icons/).
=end

module ARMLocationPreview
  # Region0
  Route1 = {
	description: "The first route built in the Verelan Urbanization Project. This route leads between Rio Bossano City and Tangoseiro City.",
	south: [33, 7],
	northWest: [32, 3],
	west_33_3: [32, 3]
  }
  
  Route2 = {
	description: "A somewhat dry route near Verela's northern border. The community garden near Tangoseiro City has helped regrow this area.",
	west: [25, 3],
	southWest: [26, 4],
	southWest_26_3: [26, 4],
	east: [31,3]
  }
  
  SouthRoute3 = {
	description: "This part of Route 3 is relatively clear due to past farming in the very plentiful area surrounding the Bossanova River.",
	north: [30,6],
	south: [30,9]
  }
  
  NorthRoute3 = {
	description: "A very dry route thanks to the intensive human activity of recent years. People have campaigned to rehabilitate this area.",
	north: [26,3],
	south: [27,6]
  }
  
  NorthRoute4 = {
	description: "A winding route through central Verela. The north part passes the mighty Paragonas River.",
	description_31_11: "A cave is located here, allowing for slow, but usable crossing of the river.",
	# [31,12] directions
	north_31_12: "Fairdune Cave",
	south_31_12: [31,13],
	# [31,10] directions
	north_31_10: [32,9],
	south_31_10: "Fairdune Cave"
  }
  
  SouthRoute4 = {
	description: "A winding route through central Verela. The south part is flatter, and is part of the Whitepetal Forest.",
	# [33,14] directions
	southEast_33_14: [35,16],
	north_33_14: [33,13],
	# [33,15] directions
	southEast_33_15: [35,16],
	north_33_15: [33,13],
	# [33,16] directions
	east_33_16: [35,16],
	north_33_16: [33,13],
	# [34,16] directions
	northEast_34_16: [35,15],
	east_34_16: [35,16],
  }
  
  WestRoute5 = {
	description: "A path through rolling grassy hills. At times, the calls of Macawk can be heard.",
	# [31,13] directions
	north_31_13: [31,12],
	# all tile directions
	west: [29,13],
	east: [32,13]
  }
  
  EastRoute5 = {
	description: "A path through rolling grassy hills. At times, the calls of Macawk can be heard.",
	# [33,13] directions
	south_33_13: [33,14],
	# all tile directions
	west: [32,13],
	east: [35,13]
  }
  
  Route6 = {
	description: "A route descending into southern Verela through the Whitepetal Forest.",
	description_24_15: "A train station was built just above the cave found at Route 6's southernmost point.",
	# [29,14] directions
	north_29_14: [29,13],
	southEast_29_14: [30,15],
	# [29,15] directions
	north_29_15: [29,13],
	east_29_15: [30,15],
	# [29,16] directions
	northEast_29_16: [30,15],
	south_29_16: "Nova Cancioba Tunnel"
  }
  
  Route7 = {
	description: "A throughfare used very often due to the cities on either end.",
	# [29,19] directions
	west_24_18: [28,19],
	# all tile directions
	north: [29,18],
	south: [29,22]
  }
  
  Route8 = {
	description: "Also known as \"Octave Street,\" Route 8 is a well known bicycle path. Quick-footed Servolley and Togetic sometimes run alongside the bikers.",
	# [35,18] directions
	north_35_18: [35,17],
	south_35_18: [34,21], 
	# [35,19] directions
	north_35_19: [35,17],
	south_35_19: [34,21],
	# [35,20] directions
	north_35_20: [35,17],
	southWest_35_20: [34,21],
	# [35,21] directions
	north_35_21: [35,17],
	west_35_21: [34,21]
  }
  
  Route9 = {
	west: [29,22],
	east: [34,22]
  }
  
  Route10 = {
	west: [22,19],
	east: [29,19]
  }
  
  Route11 = {
	# [20,17] directions
	north_20_17: [19,17],
	southEast_20_17: [21,19],
	# [20,18] directions
	north_20_18: [19,17],
	southEast_20_18: [21,19],
	# [20,19] directions
	north_20_19: [19,17],
	east_20_19: [21,19],
  }
  
  EastRoute12 = {
	# [20,17] directions
	north_20_17: [19,17],
	southEast_20_17: [21,19],
	# [20,18] directions
	north_20_18: [19,17],
	southEast_20_18: [21,19],
	# [20,19] directions
	north_20_19: [19,17],
	east_20_19: [21,19],
  }
  
  # Route 9, 10, 11, E12, W12, E13, W13, 14
  
  Route15 = {
	description: "A winding road through an area that goes through both wet and dry spells, resulting in a wide range of vegetation.",
	# [30,9] directions
	north_30_9: [30,8],
	# [31,9] directions
	south_31_9: [31,10],
	# all tile directions
	west: [26,9],
	east: [33,9]
  }
  
  # Route 16, 17
  
  WhitepetalForest = {
	description: "This forest is well known for its beautiful springtime flowers, giving the area a lavender or white appearance.",
	west: [29,15],
	east: [33,15]
  }
  
  StardewFields = {
	description: "People from central Verela regularly like to camp in this area, or the nearby Whitepetal Forest."
  }
  
  StarviewLake = {
	description: "A quaint lake found near Alipigra City. Fishermen often fish here.",
	east: [29,13],
	northWest: [28,12],
	south: [28,13]
  }
  
  StarviewCave = {
	description: "The cave to the northwest of Starview Lake. Many Pokémon make their home here.",
	south: [28,13]
  }
  
  MaracalezaBeach = {
	description: "A beach that is quite popular for those who simply want to swim or relax away from the hustle and bustle of the Samba Boardwalk.",
	# [36,13]
	west_36_13: [35,13],
	# [36,14]
	northWest_26_14: [35,13],
	# all tile directions
	south: [37,16]
  }
  
  CandlewaxField = {
	description: "An old cemetery. Ghost Pokémon make their home here.",
	north: "Firelight Tower",
	southwest: [34, 16]
  }
  
  PachaquchaPark = {
	description: "A museum and small bit of land dedicated to the ancient Himnora civilization.",
	north: "Museum of Quritaki",
	west: [34, 9]
  }
  
  SambaSeaboard = {
	description: "The docks of São Samba City bustle with activity, as does the airport. Along the seaside are several shops, some based around other regions.",
	west: [36,16],
	northWest: [36,15]
  }
  
  # Tlanti Pikchu, Mastasis Lake, Qatuypa Qata, Laqhamayu, Takuaqu, Quritakikunap Palachona, Pokémon League
  
  AlipigraCity = {
	description: "A moderately sized, modest town near the center of Verela.",
	# [28,13] directions
	northEast_28_13: "Alipigra Gym",
	southEast_28_13: [29,14],
	# [29,13] directions
	northWest_29_13: "Alipigra Gym",
	south_29_13: [29,14],
	# all tile directions
	west: [27,13],
	east: [30,13],
	icon: "AlipigraCity"
  }
  
  CapoeirodaTown = {
	description: "A small town riding the wave of popularity found in Duel Trainers.",
	# all tile directions
	northWest: [31,12],
	west: [31,13],
	east: [33,13],
	southEast: [33,14],
	#icon: "CapoeirodaTown"
  }
  
  MaracalezaTown = {
	description: "A beachside town known best for its resort against the Ranselic Ocean.",
	west: [34,13],
	east: [36,13],
	south: "Maracaleza Gym",
	icon: "MaracalezaTown"
  }
  
  RocavideoTown = {
	description: "A town near Verela's rocky interior. A Gym is here, that doubles as a Pokémon habitat.",
	# [26,9] directions
	west_26_9: "Rocavideo Wellspring",
	east_26_9: [27,9],
	# [26,10] directions
	northEast_26_10: [27,10],
	east_26_10: "Rocavideo Gym",
	# both directions
	south: [26,11],
	icon: "RocavideoTown"
  }
  
  NovaCanciobaCity = {
	description: "A town reinvented thanks to its train station, Nova Cancioba City is a growing city that could become Verela's next big metropolis.",
	# [29, 17] directions
	west_29_17: [28, 17],
	north_29_17: "Nova Cancioba Tunnel",
	# [30,17] directions
	south_30_17: "Nova Cancioba Gym",
	west_30_17: [28, 17],
	# [29, 18] directions
	south_29_18: [29,19],
	west_29_18: "Route 12 Mansion",
	icon: "NovaCanciobaCity"
  }
  
  SãoSambaCity = {
	description: "Known as the 'Marvelous Jewel' of Laurimerita, São Samba City is a city of fun, famous for its massive festival called Carnival.",
	# [35, 16] directions
	west_35_16: [33,14],
	north_35_16: [35,15],
	east_35_16: "São Samba Gym",
	southEast_35_16: "Battle Parade HQ",
	# [36,16] directions
	west_36_16: [33,14],
	south_36_16: "Battle Parade HQ",
	southWest_36_16: "Josen Spirit",
	# [35, 17] directions
	northWest_35_17: "Apuranga Museum",
	west_35_17: "Josen Spirit",
	south_35_17: [35,18],
	east_35_17: [37,16],
	# [36, 17] directions
	north_36_17: "São Samba Gym",
	west_36_17: "Thunderbolt Games",
	southWest_36_17: [35,18],
	east_36_17: [37,16],
	icon: "SãoSambaCity"
  }
  
  RioBossanoCity = {
	description: "Rio Bossano City is a large city with many alleys. It's the largest and oldest settlement in Verela, and has been the home of ancient heroes and Paldean-born leaders.",
	# [33,8] directions
	east_33_8: "Fennel's Laboratory",
	north_33_8: [33,3],
	southEast_33_8: "Sitares Cantus Cathedral",
	south_33_8: "The Azure Guide",
	# [33,9] directions
	east_33_9: "Sitares Cantus Cathedral",
	north_33_9: [33,3],
	south_33_9: "The Azure Guide",
	southEast_33_9: [35,10],
	# [33,10] directions
	south_33_10: "Paragonas River",
	north_33_10: [33,3],
	east_33_10: [35,10],
	northEast_33_10: "Sitares Cantus Cathedral",
	# [34,8] directions
	northWest_34_8: [33,3],
	north_34_8: [34,7],
	south_34_8: "Sitares Cantus Cathedral",
	# [34,9] directions
	north_34_9: "Fennel's Laboratory",
	south_34_9: "Lyra Alley",
	southWest_34_9: "The Azure Guide",
	# [34,10] directions
	north_34_10: "Sitares Cantus Cathedral",
	west_34_10: "The Azure Guide",
	east_34_10: [35,10],
	icon: "RioBossanoCity"
  }

  # Region1
  Here = {
    description: "There's something here but I don't know what!"
  }

  #Region2
  ViraidanCity = {
    description: "All there's known about this place is that they sell Baguette!"
  }
end    