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
	south: [28, 7],
	northWest: [27, 2],
	west_28_2: [27, 2]
  }
  
  Route2 = {
	description: "A somewhat dry route near Verela's northern border. The community garden near Tangoseiro City has helped regrow this area.",
	west: [20, 2],
	southWest: [21, 3],
	southWest_21_2: [21, 3],
	east: [26,2]
  }
  
  SouthRoute3 = {
	description: "This part of Route 3 is relatively clear due to past farming in the very plentiful area surrounding the Bossanova River.",
	north: [25,5],
	south: [25,8]
  }
  
  NorthRoute3 = {
	description: "A very dry route thanks to the intensive human activity of recent years. People have campaigned to rehabilitate this area.",
	north: [21,2],
	south: [22,5]
  }
  
  NorthRoute4 = {
	description: "A winding route through central Verela. The north part passes the mighty Paragonas River.",
	description_26_10: "A cave is located here, allowing for slow, but usable crossing of the river.",
	# [26,11] directions
	north_26_11: "Fairdune Cave",
	south_26_11: [26,12],
	# [26,9] directions
	north_26_9: [27,8],
	south_26_9: "Fairdune Cave"
  }
  
  SouthRoute4 = {
	description: "A winding route through central Verela. The south part is flatter, and is part of the Whitepetal Forest.",
	# [28,13] directions
	southEast_28_13: [30,15],
	north_28_13: [28,12],
	# [28,14] directions
	southEast_28_13: [30,15],
	north_28_13: [28,12],
	# [28,15] directions
	east_28_13: [30,15],
	north_28_13: [28,12],
	# [28,16] directions
	northEast_28_13: [30,14],
	east_28_13: [30,15],
  }
  
  WestRoute5 = {
	description: "A path through rolling grassy hills. At times, the calls of Macawk can be heard.",
	# [26,12] directions
	north_26_12: [26,11],
	# all tile directions
	west: [24,12],
	east: [27,12]
  }
  
  EastRoute5 = {
	description: "A path through rolling grassy hills. At times, the calls of Macawk can be heard.",
	# [28,12] directions
	south_28_12: [28,13],
	# all tile directions
	west: [27,12],
	east: [30,12]
  }
  
  Route6 = {
	description: "A route descending into southern Verela through the Whitepetal Forest.",
	description_24_15: "A train station was built just above the cave found at Route 6's southernmost point.",
	# [24,13] directions
	north_24_13: [24,12],
	southEast_24_13: [25,14],
	# [24,14] directions
	north_24_14: [24,12],
	east_24_14: [25,14],
	# [24,15] directions
	northEast_24_15: [25,14],
	south_24_15: "Nova Cancioba Tunnel"
  }
  
  Route7 = {
	description: "A throughfare used very often due to the cities on either end.",
	# [24,18] directions
	west_24_18: [23,18],
	# all tile directions
	north: [24,17],
	south: [24,21]
  }
  
  Route8 = {
	description: "Also known as \"Octave Street,\" Route 8 is a well known bicycle path. Quick-footed Servolley and Togetic sometimes run alongside the bikers.",
	# [30,17] directions
	north_30_17: [30,16],
	south_30_17: [29,20], 
	# [30,18] directions
	north_30_17: [30,16],
	south_30_17: [29,20],
	# [30,19] directions
	north_30_17: [30,16],
	southWest_30_17: [29,20],
	# [30,20] directions
	north_30_17: [30,16],
	west_30_17: [29,20]
  }
  
  Route9 = {
	west: [24,21],
	east: [29,21]
  }
  
  Route10 = {
	west: [17,18],
	east: [24,18]
  }
  
  Route11 = {
	# [15,16] directions
	north_15_16: [14,16],
	southEast_15_16: [16,18],
	# [15,17] directions
	north_15_17: [14,16],
	southEast_15_17: [16,18],
	# [15,18] directions
	north_15_18: [14,16],
	east_15_18: [16,18],
  }
  
  EastRoute12 = {
	# [15,16] directions
	north_15_16: [14,16],
	southEast_15_16: [16,18],
	# [15,17] directions
	north_15_17: [14,16],
	southEast_15_17: [16,18],
	# [15,18] directions
	north_15_18: [14,16],
	east_15_18: [16,18],
  }
  
  # Route 9, 10, 11, E12, W12, E13, W13, 14
  
  Route15 = {
	description: "A winding road through an area that goes through both wet and dry spells, resulting in a wide range of vegetation.",
	# [25,8] directions
	north_25_8: [25,7],
	# [27,8] directions
	south_27_8: [27,9],
	# all tile directions
	west: [21,8],
	east: [28,8]
  }
  
  # Route 16, 17
  
  WhitepetalForest = {
	description: "This forest is well known for its beautiful springtime flowers, giving the area a lavender or white appearance.",
	west: [24,14],
	east: [28,14]
  }
  
  StardewFields = {
	description: "People from central Verela regularly like to camp in this area, or the nearby Whitepetal Forest."
  }
  
  StarviewLake = {
	description: "A quaint lake found near Alipigra City. Fishermen often fish here.",
	east: [24,12],
	northWest: [23,11],
	south: [23,12]
  }
  
  StarviewCave = {
	description: "The cave to the northwest of Starview Lake. Many Pokémon make their home here.",
	south: [23,12]
  }
  
  MaracalezaBeach = {
	description: "A beach that is quite popular for those who simply want to swim or relax away from the hustle and bustle of the Samba Boardwalk.",
	# [31,12]
	west_31_12: [30,12],
	# [31,13]
	northWest_31_13: [30,12],
	# all tile directions
	south: [32,15]
  }
  
  CandlewaxField = {
	description: "An old cemetery. Ghost Pokémon make their home here.",
	north: "Firelight Tower",
	southwest: [29, 15]
  }
  
  PachaquchaPark = {
	description: "A museum and small bit of land dedicated to the ancient Himnora civilization.",
	north: "Museum of Quritaki",
	west: [29, 9]
  }
  
  SambaSeaboard = {
	description: "The docks of São Samba City bustle with activity, as does the airport. Along the seaside are several shops, some based around other regions.",
	west: [31,15],
	northWest: [31,14]
  }
  
  # Tlanti Pikchu, Mastasis Lake, Qatuypa Qata, Laqhamayu, Takuaqu, Quritakikunap Palachona, Pokémon League
  
  AlipigraCity = {
	description: "A moderately sized, modest town near the center of Verela.",
	# [23,12] directions
	northEast_23_12: "Alipigra Gym",
	southEast_23_12: [24,13],
	# [24,12] directions
	northWest_24_12: "Alipigra Gym",
	south_24_12: [24,13],
	# all tile directions
	west: [22,12],
	east: [25,12],
	icon: "AlipigraCity"
  }
  
  CapoeirodaTown = {
	description: "A moderately sized, modest town near the center of Verela.",
	# all tile directions
	northWest: [26,11],
	west: [26,12],
	east: [28,12],
	southEast: [28,13],
	#icon: "CapoeirodaTown"
  }
  
  MaracalezaTown = {
	description: "A beachside town known best for its resort against the Ranselic Ocean.",
	west: [29,12],
	east: [31,12],
	south: "Maracaleza Gym",
	icon: "MaracalezaTown"
  }
  
  RocavideoTown = {
	description: "A town near Verela's rocky interior. A Gym is here, that doubles as a Pokémon habitat.",
	# [21,8] directions
	west_21_8: "Rocavideo Wellspring",
	east_21_8: [22,8],
	# [21,9] directions
	northEast_21_9: [22,9],
	east_21_9: "Rocavideo Gym",
	# both directions
	south: [21,10],
	icon: "RocavideoTown"
  }
  
  NovaCanciobaCity = {
	description: "A town reinvented thanks to its train station, Nova Cancioba City is a growing city that could become Verela's next big metropolis.",
	# [24, 16] directions
	west_24_16: [23, 16],
	north_24_16: "Nova Cancioba Tunnel",
	# [25,16] directions
	south_25_16: "Nova Cancioba Gym",
	west_25_16: [23, 16],
	# [24, 17] directions
	south_24_17: [24,18],
	west_24_17: "Chandela Gym",
	icon: "NovaCanciobaCity"
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