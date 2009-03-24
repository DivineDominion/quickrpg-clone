#!/usr/bin/ruby
# Ensure ruby1.8 runs :(

require 'rubygems'
require 'gosu'

SCREEN_WIDTH = 320
SCREEN_HEIGHT = 240
TILE_SIZE = 16
SCREEN_WIDTH_TILE = 320 / TILE_SIZE
SCREEN_HEIGHT_TILE = 240 / TILE_SIZE

require './key'
require './char'
require './map'
require './script'

#
# The Game-class serves as a window for the Gosu game library
# and controls basic game mechanics.
#
# For forther development I should consider
#
class Game < Gosu::Window
  include Gosu
  
  attr_reader :show_debug, :player, :map, :script
  
  def initialize
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false, 20)
    self.caption = 'QuickRPG Ruby Clone'
    
    Key::setup self
    
    @debug_font = Font.new(self, 'Monaco', 12)
    @bgcol = Color.new(255, 128, 128, 128)
    
    # Set up an FPS counter
    @fps_counter = 0
    @fps = 0
    @milliseconds = milliseconds()
    @show_fps = true
    @show_debug = true
    
    cutter_bmp = Gosu::Image::load_tiles(self, File.join("gfx", "sprites", "cutter.png"), 16, 16, true)
    
    @show_textbox = false
    @textbox_text = Array.new
    @textbox_img = Gosu::Image.new(self, File.join("gfx", "menu.png"), true)
    @font_img = Gosu::Image::load_tiles(self, File.join("gfx", "font.png"), 6, 6, true)
    
    @player = Player.new(cutter_bmp)
    
    @map = nil
    @script = load_script "start"
    @script.execute!
  end
  
  def update
    update_fps
    Key::update
    
    update_controls
    
    update_map unless @show_textbox
  end
  
  def draw
    draw_background if @show_debug
    
    draw_map
    
    draw_textbox if @show_textbox
    
    draw_fps if @show_fps
    draw_rules if @show_debug
  end
  
  def use_map(map)
    @map = map
  end
  
  def load_script(filename)
    Script.new self, filename
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
    @textbox_text = ([name] + lines).map! {|l| l.upcase}
    @show_textbox = true 
  end
  
protected
  
  def update_controls
    if Key::hit?(KbEscape)
      close
    end
    
    if Key::hit?(KbF)
      @show_fps = !@show_fps
    end
    
    if Key::hit?(KbD)
      @show_debug = !@show_debug
    end
  
    if @show_textbox
      if Key::hit?(KbSpace)
        @show_textbox = false
        
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
#    puts @map.blocked_in_dir_from?(dir, @player.x, @player.y)
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

  def update_fps
    @fps_counter += 1

    if milliseconds() - @milliseconds >= 1000
      @fps = @fps_counter
  
      @fps_counter = 0
      @milliseconds = milliseconds
    end
  end
  
  def draw_background
    draw_quad 0, 0, @bgcol, 320, 0, @bgcol, 0, 240, @bgcol, 320, 240, @bgcol
  end  
  
  def draw_map
    @map.draw unless @map.nil?
  end
  
  def draw_textbox
    @textbox_img.draw TILE_SIZE * 3, TILE_SIZE, 20000
    y = TILE_SIZE * 2 - 2
    draw_text_line_at(@textbox_text[0] + ":", TILE_SIZE * 4 - 2, y)
    y+= 12
    @textbox_text[1..-1].each do |line|
      x = TILE_SIZE * 4 + 8
      draw_text_line_at(line, x, y)
      y += 6
    end
  end
  
  def draw_text_line_at(line, x, y)
    line.each_byte do |b|
      @font_img.at(b - 33).draw x, y, 20001
      x += 6
    end
  end
  
  def draw_fps(x = 0.0, y = 0.0, color = 0xff000000)
    @debug_font.draw("FPS: " + @fps.to_s, x, y, 100.0, 1, 1, color)
  end
  
  def draw_rules
    (1..15).each { |y| draw_line 0, y*16, 0x40000000, 320, y*16, 0x50000000, 10000}
    (1..19).each { |x| draw_line x*16+1, 0, 0x50000000, x*16, 240, 0x50000000, 10000}
  end
end

Game.new.show