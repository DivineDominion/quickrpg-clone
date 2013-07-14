class Map
  
  attr_reader :scrolled_x, :scrolled_y
  attr_reader :width, :height
  attr_reader :flags
  
  CARET_BOUNDS = [7..13, 5..10]
  
  class << self
    
    def load(wnd, filename, tileset_name)
      tileset = Gosu::Image.load_tiles(
        wnd, tileset_file_path(tileset_name + ".png"), 
        TILE_SIZE, TILE_SIZE, true)
      
      map = Map::initialize_map(wnd, filename, tileset)
      Map::initialize_scripts(wnd, filename, map)
    
      return map
    end
  
    def initialize_map(wnd, filename, tileset)
      map_path = map_file_path(filename + ".map")
      kol_path = map_file_path(filename + ".kol")
      lyr_path = map_file_path(filename + ".lyr")
    
      raise ".map missing" unless File.exists?(map_path)
      raise ".lyr missing" unless File.exists?(kol_path)
      raise ".kol missing" unless File.exists?(lyr_path)
    
      map_file = File.open(map_path, "rb")
      kol_file = File.open(kol_path, "rb")
      lyr_file = File.open(lyr_path, "rb")
    
      map_data = Map::load_map_header(map_file)
    
      width = map_data[:width]
      height = map_data[:height]
    
      map = Map.new(wnd, map_data, tileset)
    
      map.set_ground_layer      Map::load_layer_data(map_file, width, height)
      map.set_collision_layer   Map::load_layer_data(kol_file, width, height)
      map.set_transparent_layer Map::load_layer_data(lyr_file, width, height)
    
      return map
    rescue Exception
      puts "Loading the map was no success!"
      raise
    ensure
      map_file.close unless map_file.nil?
      kol_file.close unless kol_file.nil?
      lyr_file.close unless lyr_file.nil?
    end
  
    def initialize_scripts(wnd, filename, map)
      ani_path = script_file_path(filename + ".ani") # TODO move somewhere else 2013-07-14
      scr_path = script_file_path(filename + ".sc")
    
      ani_file = File.open(ani_path, "rb")
      scr_file = File.open(scr_path, "rb")
    
      ani_file.each_line do |line|
        args = line.split(" ")
        map.add_animation args[0].to_i, args[1].to_i, args[2].to_i, args[3].to_i
      end
    
      # Don't REALLY know what this number is for ...
      num_hotspots = scr_file.readline.strip.to_i + 1
      num_hotspots.times do
        coords = scr_file.readline.strip.split(" ")
        script = scr_file.readline.strip
        map.add_hotspot coords[0].to_i, coords[1].to_i, wnd.load_script(script)
      end
    
      # Neither do I know it here :(
      num_npcs = scr_file.readline.strip.to_i + 1
      npc_counter = 0
      num_npcs.times do
        npc_counter += 1
        args = scr_file.readline.strip.split(" ")
        frameset = scr_file.readline.strip
        npc_filename = "npc#{npc_counter}#{filename}"
        map.add_character(NPC::create_npc(wnd, args, frameset, npc_filename))
      end
    
    rescue Exception
      puts "Script initialization failed."
      raise
    ensure
      ani_file.close if defined? ani_file && !ani_file.nil?
      scr_file.close if defined? scr_file && !scr_file.nil?
    end
  
  
    #
    # Rotates the map arrays. I don't know why I did x-by-y back then.
    #
    def rotate_array(arr)
      h = arr.length - 1
      w = arr.first.length - 1

      # Populate height*width array with nil
      newarr = Array.new(h + 1).map { Array.new(w + 1) }

      (0..w).each do |x|
        (0..h).each do |y|
          newarr[y][x] = arr[x][y]
        end
      end

      return newarr
    end
  
    #
    # Reads map size and player position from a .map file
    #
    def load_map_header(file)
      # width & height are array-lengths, not human-readable sizes
      width = file.readbyte.to_i + 1
      height = file.readbyte.to_i + 1
    
      return {
        :width => width, :height => height, 
        :start_x => file.readbyte.to_i, :start_y => file.readbyte.to_i
        }
    end
  
    #
    # Loads array dara out of a file
    #
    def load_layer_data(file, width, height)
      data = Array.new
      width.times do
        data << Array.new
        height.times { data.last << file.readbyte.to_i }
      end
    
      return Map::rotate_array(data)
    end
  end
  
public
    
  def initialize(wnd, map_header, tileset)
    @wnd = wnd
    @tileset = tileset
    @player = wnd.player
    
    @width = map_header[:width]
    @height = map_header[:height]
    
    # These weren't used. I set this up in scripts
    @start_x = map_header[:start_x]
    @start_y = map_header[:start_y]
    
    # Scrolling-Offsets
    @scrolled_x = 0 unless defined? @scrolled_x
    @scrolled_y = 0 unless defined? @scrolled_y
    
    # Set up map contents
    @ground = @layer = @collision = nil
    @animations = Array.new(@height).map { Array.new(@width) } unless defined? @animations
    @characters = Array.new(@height).map { Array.new(@width) } unless defined? @characters
    @hotspots = Array.new(@height).map { Array.new(@width) } unless defined? @hotspots
    @flags = Hash.new unless defined? @flags
    @resume_line = 0 # script resuming
    
    @character_list = Hash.new unless defined? @character_list
    
    add_character(@player)
    
    center_map_on(@player)
  end
  
  def set_ground_layer(data)
    if not data.length.eql?(@height) || data.first.length.eql?(@width)
      raise "Size of Ground Layer doesn't match:  " +
        "#{data.first.length}x#{data.length} to #{@width}x#{@height}"
    end
    
    @ground = data
  end
  
  def set_transparent_layer(data)
    if not data.length.eql?(@height) || data.first.length.eql?(@width)
      raise "Size of Transparency Layer doesn't match:  " +
        "#{data.first.length}x#{data.length} to #{@width}x#{@height}"
    end
    
    @layer = data
  end
  
  def set_collision_layer(data)
    if not data.length.eql?(@height) || data.first.length.eql?(@width)
      raise "Size of Collision Layer doesn't match:  " +
        "#{data.first.length}x#{data.length} to #{@width}x#{@height}"
    end
    
    @collision = data
  end
  
  def add_animation(x, y, from, to)
    @animations[y][x] = [from, to, from]
  end
  
  def add_hotspot(x, y, script)
    @hotspots[y][x] = script
  end
  
  def add_character(char)
    @character_list[char] = [char.x, char.y]
    @characters[char.y][char.x] = char
  end
  
  def set_collision(x, y, state)
    @collision[y][x] = state ? 1 : 0
  end
  
  def update
    animate_tiles
    
    # sync scrolling + characters -- player movement!
    animate_scrolling if scrolling?
    update_characters
  end
  
  def draw
    draw_tiles
    
    draw_caret if @wnd.show_debug
  end
  
  def blocked_in_dir_from?(dir, x, y)
    case dir
    when :up
      y -= 1
    when :down
      y += 1
    when :left
      x -= 1
    when :right
      x += 1
    end
    
    @collision[y][x] == 1 || character_blocking?(x, y)
  end
  
  def character_blocking?(x, y)
    @character_list.each do |char, coords|
      if (char.x.eql?(x) && char.y.eql?(y)) || (char.walking? && char.is_aim?(x, y))
        return true
      end
    end
    return false
  end
  
  def hotspot_at(x, y)
    return @hotspots[y][x]
  end
  
  def scrolled_tile_x
    scrolled_x / TILE_SIZE
  end
  
  def scrolled_tile_screen_width
    scrolled_tile_x + SCREEN_WIDTH_TILE
  end
  
  def scrolled_tile_y
    scrolled_y / TILE_SIZE
  end
  
  def scrolled_tile_screen_height
    scrolled_tile_y + SCREEN_HEIGHT_TILE
  end
  
  def attempt_scrolling(dir)
    raise "Scrolling not finished yet" if scrolling?

    @direction = dir
    @steps = 0

    @scrolling = scrolling_possible? && player_in_caret?
  end

protected

  def animate_tiles
    @animations.each do |col|
      col.each do |tile|
        if not tile.nil?
          tile[2] += 1
          
          # Reset if out-of-bounds
          tile[2] = tile[0] if tile[2] > tile[1]
        end
      end
    end
  end
  
  def scrolling_possible?
    case @direction
    when :up
      @scrolled_y > 1 * TILE_SIZE
    when :down
      (@scrolled_y + SCREEN_HEIGHT) < (@height * TILE_SIZE)
    when :left
      @scrolled_x > 1 * TILE_SIZE
    when :right
      (@scrolled_x + SCREEN_WIDTH) < (@width * TILE_SIZE) 
    end
  end
  
  def player_in_caret?
    on_screen_x = @player.x - scrolled_tile_x
    on_screen_y = @player.y - scrolled_tile_y
    
    case @direction
    when :up
      CARET_BOUNDS[1].first > on_screen_y - 1
    when :down
      CARET_BOUNDS[1].last <= on_screen_y + 1
    when :left
      CARET_BOUNDS[0].first > on_screen_x - 1
    when :right
      CARET_BOUNDS[0].last <= on_screen_x + 1
    end
  end
  
  def center_map_on(char)
    center_map(char.x, char.y)
  end
  
  def center_map(x, y)
    unless @width <= SCREEN_WIDTH_TILE
      swt = SCREEN_WIDTH_TILE / 2
      
      if (x - swt) < 1
        x = 1
      elsif (x + swt) >= @width
        x = @width - swt - 1
      else
        x -= swt
      end
    end
    
    unless @height <= SCREEN_HEIGHT_TILE
      sht = SCREEN_HEIGHT_TILE / 2
      
      if (y - sht) < 1
        y = 1
      elsif (y + sht) >= @height
        y = @height - sht - 1
      else
        y -= sht
      end
    end
    
    @scrolled_x = x * TILE_SIZE
    @scrolled_y = y * TILE_SIZE
  end
  
  def scrolling?
    @scrolling || false
  end
  
  def animate_scrolling
    if @steps >= TILE_SIZE
      @scrolling = false
      return :finished
    end
    
    case @direction
    when :up
      @scrolled_y -= 1
    when :down
      @scrolled_y += 1
    when :left
      @scrolled_x -= 1
    when :right
      @scrolled_x += 1
    end
    
    @steps += 1
  end
  
  def update_characters
    # Update each char (move, animate, ...)
    @character_list.each do |char, coords|
      new_coords = char.update
      
      unless new_coords.eql? coords
        @character_list[char] = new_coords
        @characters[coords[1]][coords[0]] = nil
        @characters[new_coords[1]][new_coords[0]] = char
        
        if char.eql?(@player) && !(hotspot = hotspot_at(new_coords[0], new_coords[1])).nil?
          @wnd.execute_script_soon(hotspot)
        end
      end
    end
  end
  
  def draw_tiles
    from_x = scrolled_tile_x
    from_y = scrolled_tile_y
    
    # Keep the map's bounds in mind!
    to_x = from_x + SCREEN_WIDTH_TILE
    to_x = to_x >= @width ? @width - 1 : to_x
    
    to_y = from_y + SCREEN_HEIGHT_TILE
    to_y = to_y >= @height ? @height - 1 : to_y
    
    scroll_off_x = @scrolled_x % TILE_SIZE #- scrolled_tile_x * TILE_SIZE
    scroll_off_y = @scrolled_y % TILE_SIZE # - scrolled_tile_y * TILE_SIZE
    
    (from_y .. to_y).each do |y|
      (from_x .. to_x).each do |x|
        draw_x = (x - from_x) * TILE_SIZE - scroll_off_x
        draw_y = (y - from_y) * TILE_SIZE - scroll_off_y
        
        @tileset.at(@ground[y][x]).draw         draw_x, draw_y, Z_GROUND
        @tileset.at(@animations[y][x][2]).draw  draw_x, draw_y, Z_GROUND unless @animations[y][x].nil?
        @characters[y][x].draw                  @scrolled_x, @scrolled_y unless @characters[y][x].nil?
        draw_hotspot                            x, y, draw_x, draw_y if @wnd.show_debug
        @tileset.at(@layer[y][x]).draw          draw_x, draw_y, Z_LAYER
      end
    end
  end
  
  def draw_caret
    c = 0x20FFFF80
    @wnd.draw_quad CARET_BOUNDS[0].first * TILE_SIZE, CARET_BOUNDS[1].first * TILE_SIZE, c,
      CARET_BOUNDS[0].last * TILE_SIZE, CARET_BOUNDS[1].first * TILE_SIZE, c,
      CARET_BOUNDS[0].first * TILE_SIZE, CARET_BOUNDS[1].last * TILE_SIZE, c,
      CARET_BOUNDS[0].last * TILE_SIZE, CARET_BOUNDS[1].last * TILE_SIZE, c,
      10000
  end
  
  def draw_hotspot(x, y, draw_x, draw_y)
    unless @hotspots[y][x].nil?
      c = 0x80FFFF00
      @wnd.draw_quad draw_x, draw_y, c,
        draw_x + TILE_SIZE, draw_y, c,
        draw_x, draw_y + TILE_SIZE, c,
        draw_x + TILE_SIZE, draw_y + TILE_SIZE, c,
        10000
    end
  end
  
=begin  
  def draw_characters    
    @characters.each do |char, coords| 
      char.draw if 
        coords[0].between?(scrolled_tile_x, scrolled_tile_screen_width) && 
        coords[1].between?(scrolled_tile_y, scrolled_tile_screen_height)
    end
  end
=end
end