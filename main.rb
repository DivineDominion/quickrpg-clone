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

class Game < Gosu::Window
  include Gosu
  
  attr_reader :show_debug
  
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
    
    cutter_bmp = Gosu::Image::load_tiles(self, "./gfx/sprites/cutter.png", 16, 16, true)
    
    @player = Player.new(2, 18, cutter_bmp)
    
    @map = Map::load(self, "antikatown", "antika", @player)
    
  end
  
  def update
    update_fps
    Key::update
    
    update_keyboard
    
    update_map
  end
  
  def draw
    draw_background if @show_debug
    
    draw_map
    
    draw_fps if @show_fps
    draw_rules if @show_debug
  end
  
protected
  
  def update_keyboard
    if Key::hit?(KbEscape)
      close
    end
    
    if Key::hit?(KbF)
      @show_fps = !@show_fps
    end
    
    if Key::hit?(KbD)
      @show_debug = !@show_debug
    end
  
    # Control player movement
    unless @player.walking?
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
  
  def draw_fps(x = 0.0, y = 0.0, color = 0xff000000)
    @debug_font.draw("FPS: " + @fps.to_s, x, y, 100.0, 1, 1, color)
  end
  
  def draw_rules
    (1..15).each { |y| draw_line 0, y*16, 0x40000000, 320, y*16, 0x50000000, 10000}
    (1..19).each { |x| draw_line x*16+1, 0, 0x50000000, x*16, 240, 0x50000000, 10000}
  end
end

Game.new.show