require 'rubygems'
require 'gosu'
require 'pp'

IMAGE_DIR = File.expand_path(File.join(__dir__, '..', '..', 'gfx'))
SCRIPT_DIR = File.expand_path(File.join(__dir__, '..', '..', 'data'))
MAP_DIR = File.expand_path(File.join(__dir__, '..', '..', 'maps'))

SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240
TILE_SIZE = 16
SCREEN_WIDTH_TILE = 320 / TILE_SIZE
SCREEN_HEIGHT_TILE = 240 / TILE_SIZE

Z_GROUND  = 0b0000001
Z_CHAR    = 0b0000010
Z_LAYER   = 0b0000010 # = Z_CHAR so they don't always overlap
Z_TEXTBOX = 0b1000000

# Limits the keys which have to be checked by KeyEventDispatcher
$supported_keys = [
  K_ESC     = Gosu::KbEscape,
  K_SPACE   = Gosu::KbSpace,
  K_UP      = Gosu::KbUp,
  K_DOWN    = Gosu::KbDown,
  K_LEFT    = Gosu::KbLeft,
  K_RIGHT   = Gosu::KbRight
]

require_relative 'Event'
require_relative 'event_manager'

require_relative 'key_event_dispatcher' # generates key events
require_relative 'key_adapter'

require_relative 'fps'

require_relative 'file'

require_relative 'char'
require_relative 'player'
require_relative 'npc'
require_relative 'map'
require_relative 'script'
require_relative 'textbox'

$show_fps = true
$show_debug = true

#
# The Game-class serves as a window for the Gosu game library
# and controls basic game mechanics.
#
# For forther development I should consider
#

def sprite_file_path(filename)
  File.join(IMAGE_DIR, 'sprites', filename)
end

def image_file_path(filename)
  File.join(IMAGE_DIR, filename)
end

def tileset_file_path(filename)
  File.join(IMAGE_DIR, 'tilesets', filename)
end

def script_file_path(filename)
  File.join(SCRIPT_DIR, filename)
end

def map_file_path(filename)
  File.join(MAP_DIR, filename)
end

class Game < Gosu::Window
  include Gosu, Singleton
  
  attr_reader :show_debug, :player, :map, :script
  
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false, 20)
    self.caption = 'QuickRPG'
    
    EventManager::register(self)
    @keep_going = true
    
    $wnd = self
    $font = Font.new(self, 'Monaco', 12)
    
    Textbox::textbox  = Gosu::Image.new(self, image_file_path("menu.png"), true)
    Textbox::font     = Gosu::Image::load_tiles(self, image_file_path("font.png"), 6, 6, true)
    
    @player = Player.new(Gosu::Image::load_tiles(self, sprite_file_path("cutter.png"), 16, 16, true))
    
    @map = nil
    @script = load_script "start"
    @script.execute!
  end
  
  def handle_event(event)
    if event.instance_of? TickEvent
      #update_controls
    
      update_map unless Textbox::open?
    elsif event.instance_of? CharMoveRequest
      unless @player.animating?
        move_player(event.direction) 
        player.moving_started = true
      end
    elsif event.instance_of? CharTileMoveDone
      if event.source == player and player.moving_started? and not @player.animating?
        move_player(event.direction) 
      end
    elsif event.instance_of? CharStopRequest
      player.moving_started = false
    elsif event.instance_of? QuitEvent
      @keep_going = false
    end
  end
  
  def update
    close unless @keep_going
    EventManager::post(TickEvent.new(self, milliseconds()))
  end
  
  def draw
    draw_background if $show_debug
    
    draw_map
    
    Textbox::draw
    
    draw_rules if $show_debug
    FPS::draw if $show_fps
  end
  
  def use_map(map)
    @map = map
  end
  
  def load_script(filename)
    Script.new self, script_file_path("#{filename}.sc")
  end
  
  #
  # Execute after the player finished current movement
  #
  def execute_script_soon(script)
    @script = script
  end
  
  #
  # Sets up the engine to show a text box
  #
  def create_text_box(name, lines)
    puts "make create_text_box() obsolete!"
    Textbox::create(name.upcase, lines.map{|l| l.upcase})
  end
  
protected
  
  def update_controls
    raise "obsolete"
    
    if Key::hit?(KbEscape)
      close
    end
    
    if Key::hit?(KbF)
      $show_fps = !$show_fps
    end
    
    if Key::hit?(KbD)
      $show_debug = !$show_debug
    end
  
    if Textbox::open?
      if Key::hit?(KbSpace)
        Textbox::close
        
        # Resume execution after finishing the text box
        run_script
      end
    else      
      # Control player movement
      if has_player_control? && !run_script
        if Key::down?(KbRight)
          move_player(:right)
        elsif Key::down?(KbLeft)
          move_player(:left)
        elsif Key::down?(KbUp)
          move_player(:up)
        elsif Key::down?(KbDown)
          move_player(:down)
        end
      end
    end
  end
  
  #
  # Returns true if script is still running, i.e. the player shall not 
  # re-gain control if neccessary.
  #
  def run_script
    if @script && (@script.suspended? || !@script.finished?)
      @script.execute!
      if @script.finished?
        @script.reset
        @script = nil
        return true
      end
      return true if @script.suspended?
    end
    return false
  end
  
  def has_player_control?
    !(@player.walking? || (@script && @script.movement_blocked?))
  end
  
  def move_player(dir)
    unless @map.blocked_in_dir_from?(dir, @player.x, @player.y)
      @map.attempt_scrolling(dir)
      @player.walk_in(dir)
    else
      @player.turn_to(dir)
    end
  end
  
  def update_map
    @map.update unless @map.nil?
  end
  
  def draw_background
    c = 0xFF808080
    draw_quad 0, 0, c, SCREEN_WIDTH, 0, c, 0, SCREEN_HEIGHT, c, SCREEN_WIDTH, SCREEN_HEIGHT, c
  end  
  
  def draw_map
    @map.draw unless @map.nil?
  end
  
  def draw_rules
    (1..15).each { |y| draw_line 0, y*16, 0x40000000, 320, y*16, 0x50000000, 10000}
    (1..19).each { |x| draw_line x*16+1, 0, 0x50000000, x*16, 240, 0x50000000, 10000}
  end
end

game = Game.instance
fps = FPS.instance
keydispatcher = KeyEventDispatcher.instance
keyadapter = KeyAdapter.new
$wnd.show

# main loop
#game.run