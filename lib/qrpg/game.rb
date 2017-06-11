require 'gosu'

require_relative 'game_state/director'
require_relative 'game_state/map_stage'

require_relative 'event/event'
require_relative 'event/event_manager'

require_relative 'keyboard_control/key_consumers'
require_relative 'keyboard_control/key_event_adapter'
require_relative 'keyboard_control/key_event_broadcaster'
require_relative 'keyboard_control/key_adapter'

require_relative 'textbox_controller'
require_relative 'player_movement'
require_relative 'quit_controller'

require_relative 'fps'

require_relative 'file'

require_relative 'char'
require_relative 'player'
require_relative 'npc'
require_relative 'map'
require_relative 'script'
require_relative 'textbox'

module QuickRPG
  class Game < Gosu::Window
    include Gosu, Singleton
  
    attr_reader :show_debug, :player, :script
  
    attr_reader :key_event_adapter
    
    attr_accessor :director
    
    def initialize
      super(Common::SCREEN_WIDTH, Common::SCREEN_HEIGHT, false, 20)
      self.caption = 'QuickRPG'
    
      EventManager::add_listener(self)
      @keep_going = true
    
      $font = Font.new(self, 'Monaco', 12)
    
      Textbox::textbox  = Gosu::Image.new(Common::image_file_path("menu.png"), :tileable => true)
      Textbox::font     = Gosu::Image::load_tiles(Common::image_file_path("font.png"), 6, 6, :tileable => true)
    
      @player = Player.new(Gosu::Image::load_tiles(Common::sprite_file_path("cutter.png"), 16, 16, :tileable => true))
    
      map_stage = QuickRPG::GameState::MapStage.new
      @director = QuickRPG::GameState::Director.new(state: map_stage)
      
      @script = load_script "start"
      @script.execute!
      
      
      @key_event_adapter = KeyEventBroadcaster.new(
        KeyEventAdapter.new(Common::SUPPORTED_KEYS))
      
      @key_consumers = KeyConsumers.new
      @key_consumers << QuitController.new
      @key_consumers << TextboxController.new
      @key_consumers << PlayerMovement.new
      EventManager::add_listener(@key_consumers)
    end
  
    def handle_event(event)
      if event.instance_of? TickEvent
        #update_controls
    
        director.update unless Textbox::open?
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
  
    def button_down(key_id)
      @key_event_adapter.button_down(key_id)
    end
    
    def button_up(key_id)
      @key_event_adapter.button_up(key_id)
    end
    
    def update
      close unless @keep_going
      EventManager::post(TickEvent.new(self, milliseconds()))
    end
  
    def draw
      draw_background if $show_debug

      director.draw
  
      Textbox::draw
  
      draw_rules if $show_debug
      FPS::draw if $show_fps
    
      $screen.nil?
    end
  
    def map=(new_map)
      # TODO workaround wrapper: move to director
      puts "Map Set!\n"
      puts caller
      director.current_state.map = new_map
    end
    
    def map
      # TODO workaround wrapper: move to director
      director.current_state.map
    end
    
    def use_map(map)
      self.map = map
    end
  
    def load_script(filename)
      Script.new self, Common::script_file_path("#{filename}.sc")
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
      unless map.blocked_in_dir_from?(dir, @player.x, @player.y)
        map.attempt_scrolling(dir)
        @player.walk_in(dir)
      else
        @player.turn_to(dir)
      end
    end
    
    def draw_background
      c = 0xFF808080
      draw_quad 0, 0, c, Common::SCREEN_WIDTH, 0, c, 0, Common::SCREEN_HEIGHT, c, Common::SCREEN_WIDTH, Common::SCREEN_HEIGHT, c
    end  
  
    def draw_rules
      (1..15).each { |y| draw_line 0, y*16, 0x40000000, 320, y*16, 0x50000000, 10000}
      (1..19).each { |x| draw_line x*16+1, 0, 0x50000000, x*16, 240, 0x50000000, 10000}
    end
  end
end
