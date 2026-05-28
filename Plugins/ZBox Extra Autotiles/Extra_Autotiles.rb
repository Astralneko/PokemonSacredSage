#===============================================================================
# ZBox Extra Autotiles 1.0.0
# Credits: Zik
#
# Allows you to define tileset zones to animate automatically or
# act as connecting autotiles without the limitations of the 7 native slots.
#===============================================================================

module ZBoxExtraAutotiles
  # --- ANIMATED TILES CONFIGURATION ---
  # Key(n =>): Tileset ID in RPG Maker XP
  # name: File in Graphics/Autotiles/
  # id: Relative ID in the tileset
  # w: width in tiles
  # h: height in tiles
  # frames: number of horizontal frames in the image
  ANIMATED_CONFIG = {
    1 =>[
     #{ name: "Flowers2", id: 956,  w: 1, h: 1, frames: 5 },
    ]
  }

  # --- CONNECTED AUTOTILES CONFIGURATION ---
  # Key(n =>): Tileset ID in RPG Maker XP
  # name: File in Graphics/Autotiles/
  # id: Relative ID in the tileset
  # frames: Number of horizontal frames (if omitted, defaults to 1)
  CONNECTED_CONFIG = {
    1 =>[
     #{ name: "Light grass", id: 1},
    ]
  }  

  #=============================================================================
  # ANIMATION MANAGER
  #=============================================================================
  module AnimatedManager
    @tiles = {}
    @loaded = false

    def self.load_all
      return if @loaded
      ZBoxExtraAutotiles::ANIMATED_CONFIG.each do |ts_id, configs|
        configs.each do |cfg|
          begin
            bitmap = pbGetAutotile(cfg[:name])
            full_id_base = 384 + cfg[:id]
            frame_w_px = bitmap.width / cfg[:frames]
            
            cfg[:h].times do |y_off|
              cfg[:w].times do |x_off|
                target_id = full_id_base + x_off + (y_off * 8)
                temp_frames =[]
                is_completely_empty = true
                
                cfg[:frames].times do |f|
                  tile_bmp = Bitmap.new(32, 32)
                  src_x = (f * frame_w_px) + (x_off * 32)
                  src_y = y_off * 32
                  tile_bmp.blt(0, 0, bitmap, Rect.new(src_x, src_y, 32, 32))
                  
                  if is_completely_empty
                    empty_frame = true
                    32.times do |px|
                      32.times do |py|
                        if tile_bmp.get_pixel(px, py).alpha > 0
                          empty_frame = false
                          break
                        end
                      end
                      break if !empty_frame
                    end
                    is_completely_empty = false if !empty_frame
                  end
                  temp_frames << tile_bmp
                end
                
                if is_completely_empty
                  temp_frames.each { |bmp| bmp.dispose }
                  next 
                end
                @tiles[[ts_id, target_id]] = temp_frames
              end
            end
          rescue => e
            Console.echoln "[ZBox Extra Autotile] Error loading #{cfg[:name]}: #{e.message}"
          end
        end
      end
      @loaded = true
    end

    def self.get_frame(ts_id, tile_id)
      return nil if !@tiles[[ts_id, tile_id]]
      frames = @tiles[[ts_id, tile_id]]
      if defined?($PokemonSystem.autotile_animations)
        if $PokemonSystem && $PokemonSystem.autotile_animations == 1
          idx = 0
        else
          idx = (System.uptime * 4).to_i % frames.size
        end
      else
        idx = (System.uptime * 4).to_i % frames.size
      end 
      return frames[idx]
    end
    
    def self.is_animated?(ts_id, tile_id)
      load_all if !@loaded
      return @tiles.key?([ts_id, tile_id])
    end
  end

  #=============================================================================
  # CONNECTED AUTOTILE MANAGER
  #=============================================================================
  module ConnectedManager
    @tiles = {}
    @loaded = false

    AUTOTILE_TABLE =[
      46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
      42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
      46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
      42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
      45, 39, 45, 39, 33, 31, 33, 29, 45, 39, 45, 39, 33, 31, 33, 29,
      37, 27, 37, 27, 23, 15, 23, 13, 37, 27, 37, 27, 22, 11, 22,  9,
      45, 39, 45, 39, 33, 31, 33, 29, 45, 39, 45, 39, 33, 31, 33, 29,
      36, 26, 36, 26, 21,  7, 21,  5, 36, 26, 36, 26, 20,  3, 20,  1,
      46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
      42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
      46, 44, 46, 44, 43, 41, 43, 40, 46, 44, 46, 44, 43, 41, 43, 40,
      42, 32, 42, 32, 35, 19, 35, 18, 42, 32, 42, 32, 34, 17, 34, 16,
      45, 38, 45, 38, 33, 30, 33, 28, 45, 38, 45, 38, 33, 30, 33, 28,
      37, 25, 37, 25, 23, 14, 23, 12, 37, 25, 37, 25, 22, 10, 22,  8,
      45, 38, 45, 38, 33, 30, 33, 28, 45, 38, 45, 38, 33, 30, 33, 28,
      36, 24, 36, 24, 21,  6, 21,  4, 36, 24, 36, 24, 20,  2, 20,  0
    ]

    PATTERNS =[
      [26, 27, 32, 33],[4, 27, 32, 33], [26, 5, 32, 33], [4, 5, 32, 33],[26, 27, 32, 11], [4, 27, 32, 11],[26, 5, 32, 11],[4, 5, 32, 11],
      [26, 27, 10, 33],[4, 27, 10, 33],[26, 5, 10, 33], [4, 5, 10, 33],[26, 27, 10, 11],[4, 27, 10, 11], [26, 5, 10, 11],[4, 5, 10, 11],[24, 25, 30, 31], [24, 5, 30, 31],[24, 25, 30, 11], [24, 5, 30, 11],
      [14, 15, 20, 21],[14, 15, 20, 11],[14, 15, 10, 21], [14, 15, 10, 11],[28, 29, 34, 35],[28, 29, 10, 35], [4, 29, 34, 35],[4, 29, 10, 35],[38, 39, 44, 45], [4, 39, 44, 45],[38, 5, 44, 45], [4, 5, 44, 45],
      [24, 29, 30, 35],[14, 15, 44, 45],[12, 13, 18, 19], [12, 13, 18, 11],[16, 17, 22, 23],[16, 17, 10, 23], [40, 41, 46, 47],[4, 41, 46, 47],[36, 37, 42, 43], [36, 5, 42, 43],[12, 17, 18, 23],[12, 13, 42, 43],
      [36, 41, 42, 47],[16, 17, 46, 47],[12, 17, 42, 47], [0, 1, 6, 7]
    ]

    def self.load_all
      return if @loaded
      ZBoxExtraAutotiles::CONNECTED_CONFIG.each do |ts_id, configs|
        configs.each do |cfg|
          begin
            full_bitmap = pbGetAutotile(cfg[:name])
            trigger_id = 384 + cfg[:id]
            num_frames = cfg[:frames] || 1           
            @tiles[[ts_id, trigger_id]] = Array.new(48) { [] }
            is_extended = (full_bitmap.height >= 192)
            num_frames.times do |f|
              frame_h = is_extended ? 192 : 128
              frame_src = Bitmap.new(96, frame_h)
              
              src_x = f * 96
              src_x = 0 if src_x >= full_bitmap.width
              frame_src.blt(0, 0, full_bitmap, Rect.new(src_x, 0, 96, frame_h))
              
              48.times do |shape_idx|
                tile_bmp = Bitmap.new(32, 32)
                if is_extended &&[1, 2, 4, 8].include?(shape_idx)
                  case shape_idx
                  when 1
                    tile_bmp.blt(0, 0, frame_src, Rect.new(0, 128, 32, 32))
                  when 2
                    tile_bmp.blt(0, 0, frame_src, Rect.new(32, 128, 32, 32))
                  when 4
                    tile_bmp.blt(0, 0, frame_src, Rect.new(32, 160, 32, 32))
                  when 8
                    tile_bmp.blt(0, 0, frame_src, Rect.new(0, 160, 32, 32))
                  end
                else
                  pattern = PATTERNS[shape_idx]
                  4.times do |i|
                    mini_idx = pattern[i]
                    sx = (mini_idx % 6) * 16
                    sy = (mini_idx / 6) * 16
                    dx = (i % 2) * 16
                    dy = (i / 2) * 16
                    tile_bmp.blt(dx, dy, frame_src, Rect.new(sx, sy, 16, 16))
                  end
                end
                
                @tiles[[ts_id, trigger_id]][shape_idx] << tile_bmp
              end
              frame_src.dispose
            end
          rescue => e
            Console.echoln "[ZBox Extra Autotile] Error loading connected autotile #{cfg[:name]}: #{e.message}"
          end
        end
      end
      @loaded = true
    end

    def self.get_frame(ts_id, tile_id, shape_index)
      return nil if !@tiles[[ts_id, tile_id]]
      shape_index ||= 0
      frames = @tiles[[ts_id, tile_id]][shape_index]
      return nil if !frames
      if defined?($PokemonSystem.autotile_animations)
        if $PokemonSystem && $PokemonSystem.autotile_animations == 1
          idx = 0
        else
          idx = (System.uptime * 4).to_i % frames.size
        end
      else
        idx = (System.uptime * 4).to_i % frames.size
      end
      return frames[idx]
    end

    def self.is_connected_trigger?(ts_id, tile_id)
      load_all if !@loaded
      return @tiles.key?([ts_id, tile_id])
    end

    def self.calculate_shape(map, x, y, layer, tile_id)
      bits = 0
      neighbors = [[0, -1],[1, -1], [1, 0], [1, 1], [0, 1],[-1, 1], [-1, 0], [-1, -1]]
      
      neighbors.each_with_index do |offset, i|
        nx, ny = x + offset[0], y + offset[1]
        is_same = false
        if map.valid?(nx, ny)
          is_same = true if map.data[nx, ny, layer] == tile_id
        end
        bits |= (1 << i) if is_same
      end
      
      rmxp_bits = 0
      rmxp_bits |= 1   if (bits & 1) != 0
      rmxp_bits |= 4   if (bits & 4) != 0
      rmxp_bits |= 16  if (bits & 16) != 0
      rmxp_bits |= 64  if (bits & 64) != 0
      
      rmxp_bits |= 2   if (bits & 2) != 0   && (bits & 1) != 0 && (bits & 4) != 0
      rmxp_bits |= 8   if (bits & 8) != 0   && (bits & 4) != 0 && (bits & 16) != 0
      rmxp_bits |= 32  if (bits & 32) != 0  && (bits & 16) != 0 && (bits & 64) != 0
      rmxp_bits |= 128 if (bits & 128) != 0 && (bits & 64) != 0 && (bits & 1) != 0
      
      return AUTOTILE_TABLE[rmxp_bits] || 0
    end
  end

  #=============================================================================
  # RENDERING ENGINE
  #=============================================================================
  class Renderer
    def initialize(viewport, map)
      @viewport = viewport
      @map = map
      @sprites =[]
      setup_sprites
    end

    def setup_sprites
      ZBoxExtraAutotiles::AnimatedManager.load_all
      ZBoxExtraAutotiles::ConnectedManager.load_all
      ts_id = @map.tileset_id
      
      (0...@map.width).each do |x|
        (0...@map.height).each do |y|
          [0, 1, 2].each do |layer|
            tile_id = @map.data[x, y, layer]
            next if tile_id == 0

            is_anim = ZBoxExtraAutotiles::AnimatedManager.is_animated?(ts_id, tile_id)
            is_conn = ZBoxExtraAutotiles::ConnectedManager.is_connected_trigger?(ts_id, tile_id)
            
            if is_anim || is_conn
              sprite = TilemapRenderer::TileSprite.new(@viewport)
              shape_index = 0
              
              if is_anim
                sprite.bitmap = ZBoxExtraAutotiles::AnimatedManager.get_frame(ts_id, tile_id)
              else
                shape_index = ZBoxExtraAutotiles::ConnectedManager.calculate_shape(@map, x, y, layer, tile_id)
                sprite.bitmap = ZBoxExtraAutotiles::ConnectedManager.get_frame(ts_id, tile_id, shape_index)
              end
              
              priority = @map.priorities[tile_id] || 0
              if priority == 0
                sprite.z = layer * 2 
              else
                sprite.z = (y * 32) + (priority * 32) + 32
              end
              
              @sprites << { 
                sprite: sprite, 
                tile_id: tile_id,
                x: x, y: y, layer: layer,
                shape_index: shape_index, 
                priority: priority
              }
            end
          end
        end
      end
    end

    def update
      map_display_x = (@map.display_x.to_f / Game_Map::X_SUBPIXELS).round
      map_display_y = (@map.display_y.to_f / Game_Map::Y_SUBPIXELS).round
      ts_id = @map.tileset_id

      @sprites.each do |item|
        sprite = item[:sprite]
        tid    = item[:tile_id]
        
        pbDayNightTint(sprite) if defined?(pbDayNightTint)
        
        if ZBoxExtraAutotiles::AnimatedManager.is_animated?(ts_id, tid)
          sprite.bitmap = ZBoxExtraAutotiles::AnimatedManager.get_frame(ts_id, tid)
        elsif ZBoxExtraAutotiles::ConnectedManager.is_connected_trigger?(ts_id, tid)
          sprite.bitmap = ZBoxExtraAutotiles::ConnectedManager.get_frame(ts_id, tid, item[:shape_index])
        end
        
        base_x = (item[:x] * Game_Map::TILE_WIDTH) - map_display_x
        base_y = (item[:y] * Game_Map::TILE_HEIGHT) - map_display_y
        
        sprite.x = base_x
        sprite.y = base_y
        
        if item[:priority] > 0
          sprite.z = base_y + (item[:priority] * Game_Map::TILE_HEIGHT) + Game_Map::TILE_HEIGHT + 1
        end
      end
    end

    def dispose
      @sprites.each { |item| item[:sprite]&.dispose }
      @sprites.clear
    end
  end
end

#===============================================================================
# Base Tile Hiding
#===============================================================================
class TilemapRenderer
  alias zbox_tile_refresh_tile_z refresh_tile_z unless method_defined?(:zbox_tile_refresh_tile_z)
  def refresh_tile_z(tile, map, y, layer, tile_id)
    zbox_tile_refresh_tile_z(tile, map, y, layer, tile_id)
    if tile.z == 0
      tile.z = layer * 2
    end
  end
  
  alias zbox_tile_refresh_tile refresh_tile unless method_defined?(:zbox_tile_refresh_tile)
  def refresh_tile(tile, x, y, map, layer, tile_id)
    is_anim = ZBoxExtraAutotiles::AnimatedManager.is_animated?(map.tileset_id, tile_id)
    is_conn = ZBoxExtraAutotiles::ConnectedManager.is_connected_trigger?(map.tileset_id, tile_id)
    
    if is_anim || is_conn
      tile.visible = false
      tile.tile_id = tile_id
      tile.priority = 0
      tile.shows_reflection = false
      tile.bridge = false
      tile.animated = false
      tile.need_refresh = false
      return 
    end
    zbox_tile_refresh_tile(tile, x, y, map, layer, tile_id)
  end
end

class Spriteset_Map
  alias zbox_tile_initialize initialize unless method_defined?(:zbox_tile_initialize)
  def initialize(map = nil)
    zbox_tile_initialize(map)
    @zbox_tile_renderer = ZBoxExtraAutotiles::Renderer.new(@@viewport1, @map)
  end
  
  alias zbox_tile_update update unless method_defined?(:zbox_tile_update)
  def update
    zbox_tile_update
    @zbox_tile_renderer&.update
  end
  
  alias zbox_tile_dispose dispose unless method_defined?(:zbox_tile_dispose)
  def dispose
    @zbox_tile_renderer&.dispose
    @zbox_tile_renderer = nil
    zbox_tile_dispose
  end
end