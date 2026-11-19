#===============================================================================
# Dynamic Lighting
#-------------------------------------------------------------------------------
# Real-time dynamic lighting system lighting for Pokemon Essentials.
#
# Events whose NAME is "lightsource" (or "lightsource(radius, color)") are
# turned into soft, glowing light sources drawn over the map. It behaves like
# the Glade Wander lighting: a soft radial glow with a soft edge, which fades
# away in bright daylight and only really shows when it is dark.
#
#   lightsource                     -> default radius (see DEFAULT_RADIUS_TILES)
#   lightsource(3, yellow)          -> radius 3 tiles, named colour
#   lightsource(4, #ffcc33)         -> radius 4 tiles, hex colour
#   lightsource(2, 255, 180, 60)    -> radius 2 tiles, explicit RGB
#   lightsource(5, red, 1.5)        -> radius 5 tiles, red, 1.5x intensity
#   lightsource(5, red, 1.5, 4)     -> ... and up to 4px of radius flicker
#
# Radius is measured in TILES (a light of radius 3 covers ~6 tiles across).
# Colour may be a name (see NAMED_COLORS), "#rrggbb"/"0xrrggbb", or r,g,b.
#
# The ambient darkness is whatever Pokemon Essentials (and the Daylight Cycle
# plugin) already applies through the screen tone / time of day. This plugin
# does NOT replace that tone overlay - it only ADDS glow on top of it, so the
# tone overlay keeps working exactly as before.
#
# ONLY maps whose map metadata enables "LightSources" render dynamic lighting.
# This means interiors (and every other map) stay untouched unless a mapper
# opts in. Set the flag via Debug -> "Edit lighting metadata", or the standard
# Debug -> "Edit map_metadata.txt" editor (both write map_metadata.txt).
#===============================================================================
module DynamicLighting
  # Master switch. Set to false to disable all light sources.
  ENABLED = true

  # Radius (in tiles) used by a bare "lightsource" event with no arguments.
  DEFAULT_RADIUS_TILES = 3

  # Colour used when none is given.
  DEFAULT_COLOR = [180, 180, 180]
  
  # Intensity value used when none is given
  DEFAULT_INTENSITY = 0.3
  
  # Flicker value used when none is given
  DEFAULT_FLICKER = 0

  # Diameter (px) of the generated soft-glow texture. Bigger textures look
  # crisper when zoomed up for large lights, at a one-off generation cost.
  GLOW_TEXTURE_SIZE = 128

  # Z-order of the lights.
  LIGHT_Z = 1000

  # If true, a glow fades with the world's darkness: full brightness at night
  # or on DarkMap maps, invisible in bright daylight (Glade Wander behaviour).
  # If false, every light is always drawn at full intensity.
  LIGHTS_ONLY_WHEN_DARK = true

  # If true, the light cancels the screen tone applied to its colour, so it
  # keeps its own colour instead of being tinted by the day/night overlay.
  LIGHTS_IGNORE_SCREEN_TONE = true

  # Map-metadata property (display name) that gates this plugin per map. Also
  # listed in the dedicated lighting metadata editor.
  METADATA_PROPERTIES = ["LightSources"]

  # Named colours usable in "lightsource(radius, colour)".
  NAMED_COLORS = {
    "natural" => [160, 160, 160],
    "white"   => [255, 255, 255],
    "black"   => [20, 20, 25],
    "red"     => [255, 60, 60],
    "green"   => [90, 255, 90],
    "blue"    => [90, 130, 255],
    "yellow"  => [255, 255, 93],
    "orange"  => [255, 150, 40],
    "purple"  => [200, 90, 255],
    "magenta" => [255, 60, 255],
    "pink"    => [255, 150, 200],
    "cyan"    => [60, 255, 255],
    "teal"    => [60, 220, 200],
    "gold"    => [255, 210, 80],
    "amber"   => [255, 170, 40],
    "warm"    => [255, 220, 160],
    "lamp"    => [255, 240, 200],
    "fire"    => [255, 180, 60],
    "torch"   => [255, 160, 40],
    "moon"    => [170, 200, 255],
    "ghost"   => [120, 255, 180],
    "poison"  => [170, 90, 210],
    "ice"     => [170, 230, 255]
  }

  @glow_cache = {}

  # Returns (and caches) a soft radial-gradient glow texture for a colour, with
  # the colour baked in and the alpha fading to 0 at the edge of the circle.
  def self.glow_bitmap(color)
    key = color.join(",")
    cached = @glow_cache[key]
    return cached if cached && !cached.disposed?
    size = GLOW_TEXTURE_SIZE
    bmp = Bitmap.new(size, size)
    centre = size / 2.0
    radius = size / 2.0
    cr, cg, cb = color[0], color[1], color[2]
    (0...size).each do |y|
      dy = y + 0.5 - centre
      (0...size).each do |x|
        dx = x + 0.5 - centre
        dist = Math.sqrt((dx * dx) + (dy * dy)) / radius
        next if dist >= 1.0
        alpha = 1.0 - dist
        alpha = alpha * alpha * (3.0 - (2.0 * alpha))   # smoothstep (soft edge)
        bmp.set_pixel(x, y, Color.new(cr, cg, cb, (alpha * 255).round))
      end
    end
    @glow_cache[key] = bmp
    return bmp
  end

  def self.number?(str)
    return !str.nil? && str.strip.match?(/\A-?\d+(\.\d+)?\z/)
  end

  # Parses the colour + optional intensity/flicker from the argument list.
  def self.parse_color_and_extras(tokens)
    return [DEFAULT_COLOR, DEFAULT_INTENSITY, DEFAULT_FLICKER] if tokens.empty?
    first = tokens[0]
    named = NAMED_COLORS[first.downcase]
    if named
      intensity = number?(tokens[1]) ? tokens[1].to_f : DEFAULT_INTENSITY
      flicker   = number?(tokens[2]) ? tokens[2].to_i : DEFAULT_FLICKER
      return [named, intensity, flicker]
    end
    if first.match?(/\A(?:#|0x)/i)
      hex = first.sub(/\A(?:#|0x)/i, "")
      if hex.match?(/\A[0-9a-fA-F]{6}\z/)
        rgb = [hex[0, 2], hex[2, 2], hex[4, 2]].map { |h| h.to_i(16) }
        intensity = number?(tokens[1]) ? tokens[1].to_f : DEFAULT_INTENSITY
        flicker   = number?(tokens[2]) ? tokens[2].to_i : DEFAULT_FLICKER
        return [rgb, intensity, flicker]
      end
    end
    if tokens.size >= 3 && number?(tokens[0]) && number?(tokens[1]) && number?(tokens[2])
      rgb = [tokens[0].to_i, tokens[1].to_i, tokens[2].to_i]
      intensity = number?(tokens[3]) ? tokens[3].to_f : DEFAULT_INTENSITY
      flicker   = number?(tokens[4]) ? tokens[4].to_i : DEFAULT_FLICKER
      return [rgb, intensity, flicker]
    end
    return [DEFAULT_COLOR, DEFAULT_INTENSITY, DEFAULT_FLICKER]
  end

  # Returns a settings hash for an event name, or nil if it is not a light.
  def self.parse(name)
    return nil if name.nil?
    text = name.strip
    if text.match?(/\Alightsource\z/i)
      return { :radius => DEFAULT_RADIUS_TILES, :color => DEFAULT_COLOR,
               :intensity => DEFAULT_INTENSITY, :flicker => DEFAULT_FLICKER }
    end
    m = text.match(/\Alightsource\((.+)\)\z/i)
    return nil if !m
    args = m[1].split(",").map { |a| a.strip }
    args.reject! { |a| a.empty? }
    radius = DEFAULT_RADIUS_TILES
    radius = args.shift.to_f if number?(args[0])
    color, intensity, flicker = parse_color_and_extras(args)
    return { :radius => radius, :color => color,
             :intensity => intensity, :flicker => flicker }
  end

  # How dark the world currently is: 0.0 = bright daylight, 1.0 = full dark.
  # Takes the darkest of the time of day, DarkMap flag and screen tone.
  def self.world_darkness
    darkness = 0.0
    if defined?(PBDayNight)
      shade = PBDayNight.getShade
      if shade <= 64
        darkness = 1.0
      elsif shade < 144
        darkness = (144 - shade) / 80.0
      end
    end
    darkness = 1.0 if $game_map && $game_map.metadata && $game_map.metadata.dark_map
    if $game_screen && $game_screen.tone
      t = $game_screen.tone
      tone_dark = [-t.red.to_i, -t.green.to_i, -t.blue.to_i].max / 255.0
      darkness = tone_dark if tone_dark > darkness
    end
    return 1.0 if darkness > 1.0
    return 0.0 if darkness < 0.0
    return darkness
  end
end

#===============================================================================
# A single light source following a map event.
#===============================================================================
class DynamicLighting::LightSourceSprite
  def initialize(viewport, event, map, radius_tiles, color, intensity, flicker)
    @viewport = viewport
    @event = event
    @map = map
    @radius_px = radius_tiles * Game_Map::TILE_WIDTH
    @intensity = intensity.to_f
    @flicker = flicker.to_i
    @sprite = Sprite.new(viewport)
    @sprite.bitmap = DynamicLighting.glow_bitmap(color)
    @sprite.ox = @sprite.bitmap.width / 2
    @sprite.oy = @sprite.bitmap.height / 2
    @sprite.z = DynamicLighting::LIGHT_Z
    @sprite.blend_type = 1   # additive: brightens the (darkened) scene
    update
  end

  def disposed?
    return @sprite.nil? || @sprite.disposed?
  end

  def dispose
    @sprite.dispose if @sprite && !@sprite.disposed?
    @sprite = nil
    @event = nil
  end

  def update
    return if disposed?
    @sprite.x = ScreenPosHelper.pbScreenX(@event)
    @sprite.y = ScreenPosHelper.pbScreenY(@event) - (Game_Map::TILE_HEIGHT / 2)
    radius = @radius_px
    radius += rand(@flicker + 1) if @flicker > 0   # Glade Wander flicker
    base = @sprite.bitmap.width / 2.0
    zoom = radius.to_f / base
    @sprite.zoom_x = zoom
    @sprite.zoom_y = zoom
    max_opacity = 255.0
    opacity = @intensity * max_opacity
    opacity *= DynamicLighting.world_darkness if DynamicLighting::LIGHTS_ONLY_WHEN_DARK
    opacity = 0.0 if opacity < 0.0
    opacity = max_opacity if opacity > max_opacity
    @sprite.opacity = opacity.round
    @sprite.visible = @sprite.opacity > 0
    if DynamicLighting::LIGHTS_IGNORE_SCREEN_TONE
      t = $game_screen.tone
      @sprite.tone = Tone.new(-t.red, -t.green, -t.blue, -t.gray)
    end
  end
end

#===============================================================================
# Turn "lightsource" events into user sprites whenever a map spriteset is made.
#===============================================================================
EventHandlers.add(:on_new_spriteset_map, :add_dynamic_light_sources,
  proc { |spriteset, viewport|
    next if !DynamicLighting::ENABLED
    map = spriteset.map
    meta = map.metadata
    next if !meta || !meta.light_sources
    map.events.each_key do |i|
      event = map.events[i]
      next if !event
      light = DynamicLighting.parse(event.name)
      next if !light
      spriteset.addUserSprite(DynamicLighting::LightSourceSprite.new(
        viewport, event, map, light[:radius], light[:color], light[:intensity], light[:flicker]
      ))
    end
  }
)

#===============================================================================
# Map metadata: add a per-map "LightSources" flag.
#-------------------------------------------------------------------------------
# The flag round-trips through map_metadata.txt because the generic PBS
# compiler and writer both walk GameData::MapMetadata::SCHEMA. It also appears
# in the standard "Edit map_metadata.txt" debug editor, which builds itself
# from editor_properties.
#===============================================================================
class GameData::MapMetadata
  unless GameData::MapMetadata::SCHEMA.key?("LightSources")
    GameData::MapMetadata::SCHEMA["LightSources"] = [:light_sources, "b"]
  end

  attr_reader :light_sources

  unless method_defined?(:__dynamic_lighting_init)
    alias_method :__dynamic_lighting_init, :initialize
    def initialize(hash)
      __dynamic_lighting_init(hash)
      @light_sources = hash[:light_sources]
    end
  end

  class << self
    unless method_defined?(:__dynamic_lighting_editor_properties)
      alias_method :__dynamic_lighting_editor_properties, :editor_properties
      def editor_properties
        props = __dynamic_lighting_editor_properties
        props.push(["LightSources", BooleanProperty,
                    _INTL("If true, 'lightsource' events on this map produce dynamic lighting.")])
        return props
      end
    end
  end
end

#===============================================================================
# A focused editor for lighting-related map metadata. Edits only the lighting
# properties listed in DynamicLighting::METADATA_PROPERTIES, while preserving
# every other metadata field for the map (which it snapshots and writes back).
#===============================================================================
def pbEditLightingMetadata(map_id)
  mapinfos = pbLoadMapInfos
  map_name = (mapinfos[map_id]) ? mapinfos[map_id].name : map_id.to_s
  metadata = GameData::MapMetadata.try_get(map_id)
  metadata = GameData::MapMetadata.new({ :id => map_id }) if !metadata
  all_props = GameData::MapMetadata.editor_properties
  full_data = []
  all_props.each do |prop|
    value = metadata.get_property_for_PBS(prop[0])
    value = prop[1].defaultValue if value.nil? && prop[1].respond_to?(:defaultValue)
    full_data.push(value)
  end
  light_indices = []
  light_props = []
  all_props.each_with_index do |prop, i|
    next if !DynamicLighting::METADATA_PROPERTIES.include?(prop[0])
    light_indices.push(i)
    light_props.push(prop)
  end
  light_data = light_indices.map { |i| full_data[i] }
  return if !pbPropertyList(map_name, light_data, light_props, true)
  light_indices.each_with_index { |idx, i| full_data[idx] = light_data[i] }
  schema = GameData::MapMetadata.schema
  hash = {}
  all_props.each_with_index do |prop, i|
    key = (prop[0] == "ID") ? schema["SectionName"][0] : schema[prop[0]][0]
    hash[key] = full_data[i]
  end
  hash[:pbs_file_suffix] = metadata.pbs_file_suffix
  GameData::MapMetadata.register(hash)
  GameData::MapMetadata.save
  Compiler.write_map_metadata
  pbMessage(_INTL("Lighting metadata saved."))
end

def pbLightingMetadataScreen(map_id = 0)
  loop do
    map_id = pbListScreen(_INTL("LIGHTING METADATA"), MapLister.new(map_id))
    break if map_id < 0
    next if map_id == 0
    pbEditLightingMetadata(map_id)
  end
end

MenuHandlers.add(:debug_menu, :set_lighting_metadata, {
  "name"        => _INTL("Edit lighting metadata"),
  "parent"      => :pbs_editors_menu,
  "description" => _INTL("Enable or disable dynamic lighting (lightsource events) per map."),
  "effect"      => proc {
    pbLightingMetadataScreen(pbDefaultMap)
  }
})
