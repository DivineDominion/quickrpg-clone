=begin
#Method for parsing the various datatypes from the ECH file
def dump_binary(file, type, length)
  case type
  when 'int'
    #Process integers, assigning appropriate profile based on length
    #such as long int, short int and tiny int.
    case length
    when 4
      value = file.read(length).unpack("l").first.to_i
    when 2
      value = file.read(length).unpack("s").first.to_i
    when 1
      value = file.read(length).unpack("U").first.to_i
    end
  #Process appropriate intergers into datetime format in the database
  when 'datetime'
    case length
    when 4
      value = file.read(length).unpack("l").first.to_i
    end
  #Process strings
  when 'str'
    value = file.read(length).unpack("M").first.to_s.rstrip
  #Process individual bits that are booleans
  when 'bool'
    value = file.read(length).unpack("b8").last.to_s
  #Process that one wierd boolean that is actually an int, instead of a bit
  when 'bool_int'
    value = file.read(length).unpack("U").first.to_i
  end
  return value
end
=end

class Map
  def self.load(filename)
    map = Map::initialize_map filename
    Map::initialize_scripts filename
    
    return map
  end
  
  def self.initialize_map(filename)
    map_path = File.join "maps", (filename + ".map")
    kol_path = File.join "maps", (filename + ".kol")
    lyr_path = File.join "maps", (filename + ".lyr")
    
    raise ".map missing" unless File.exists?(map_path)
    raise ".lyr missing" unless File.exists?(kol_path)
    raise ".kol missing" unless File.exists?(lyr_path)
    
    map_file = File.open(map_path, "rb")
    kol_file = File.open(kol_path, "rb")
    lyr_file = File.open(lyr_path, "rb")
    
    map_data = Map::load_map_header(map_file)
    
    width = map_data[:width]
    height = map_data[:height]
    
    map = Map.new map_data
    
    map.set_ground_layer      Map::load_layer_data(map_file, width, height)
    map.set_collision_layer   Map::load_layer_data(kol_file, width, height)
    map.set_transparent_layer Map::load_layer_data(lyr_file, width, height)
    
    return map
  rescue Exception
    puts "Loading the map was no success!"
    raise
  ensure
    map_file.close if defined? map_file && !map_file.nil?
    kol_file.close if defined? kol_file && !kol_file.nil?
    lyr_file.close if defined? lyr_file && !lyr_file.nil?
  end
  
  def self.initialize_scripts(filename)
    ani_path = File.join "data", (filename + ".ani")
    scr_path = File.join "data", (filename + ".sc")
    
    ani_file = File.open(ani_path, "rb")
    scr_file = File.open(scr_path, "rb")
    
    ani_file.each_line do |line|
      puts line
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
  def self.rotate_array(arr)
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
  def self.load_map_header(file)
    # width & height are array-lengths, not human-readable sizes
    width = file.readchar.to_i + 1
    height = file.readchar.to_i + 1
    
    return {
      :width => width, :height => height, 
      :start_x => file.readchar.to_i, :start_y => file.readchar.to_i
      }
  end
  
  #
  # Loads array dara out of a file
  #
  def self.load_layer_data(file, width, height)
    data = Array.new
    width.times do
      data << Array.new
      height.times { data.last << file.readchar.to_i }
    end
    
    return Map::rotate_array(data)
  end
  
public
  
  def initialize(map_header)
    @width = map_header[:width]
    @height = map_header[:height]
    
    # These weren't used. I set this up in scripts
    @start_x = map_header[:start_x]
    @start_y = map_header[:start_y]
    
    @animations = Array.new unless defined? @animations
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
  
  def update
    animate_tiles
  end
  
  def animate_tiles
  end
  
  def draw
  end
end

Map::load("antikatown")