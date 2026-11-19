Dynamic Lighting v1.0
By Retora
Compatible with Pokémon Essentials 21.1 / 20 / 19

---

WHAT IT IS
----------
A real-time dynamic lighting system for Pokémon Essentials. Place events on your
map named "lightsource" (or "lightsource(radius, color)") and they become soft,
glowing light sources drawn over the map — like a handheld lantern, a campfire,
or a glowing window at night.

Lights only really show when it's dark. By default they fade out in bright
daylight and glow at full strength at night or on DarkMap maps, so they layer
nicely on top of Essentials' existing screen tone / time-of-day system rather
than replacing it.

Only maps that opt in render lighting (set the "LightSources" flag in
map_metadata.txt via Debug -> "Edit lighting metadata"), so interiors and other
maps stay untouched unless a mapper explicitly enables them.

EXAMPLE USAGE
-------------
Just name an event and drop it on the map:

  lightsource                       -> default radius (3 tiles), grey glow
  lightsource(3, yellow)            -> radius 3 tiles, named colour
  lightsource(4, #ffcc33)           -> radius 4 tiles, hex colour
  lightsource(2, 255, 180, 60)      -> radius 2 tiles, explicit RGB
  lightsource(5, red, 1.5)          -> radius 5 tiles, 1.5x intensity
  lightsource(5, red, 1.5, 4)       -> ...plus up to 4px radius flicker

Colour can be a name, "#rrggbb"/"0xrrggbb", or r,g,b. Radius is measured in
tiles (a radius-3 light covers about 6 tiles across).

FEATURES
--------
- Events named "lightsource(...)" become soft radial glows with soft edges.
- Per-light radius (tiles), colour (name / hex / RGB), intensity, flicker.
- Fades with world darkness: full at night/DarkMap, invisible in daylight.
- Layers on top of Essentials screen tone / time of day (tone still works).
- Opt-in per map via "LightSources" map metadata flag.
- No edits to Data/Scripts engine scripts (pure plugin).
- Essentials 21.1 / 20 / 19 compatible.

INSTALLATION
------------
1. Copy the "Dynamic Lighting" folder from Plugins/ into your game's Plugins/ folder.
2. Place the "lightsource" events on maps where you want lighting.
3. On those maps, set the map metadata flag LightSources = true (Debug ->
   "Edit lighting metadata" or edit PBS/map_metadata.txt directly).
4. Start a new game (or reload) and test at night.

CREDITS
-------
- Retora — author
- Maruno — Pokémon Essentials
