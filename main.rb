#!/usr/bin/ruby
# Ensure ruby1.8 runs :(

require 'rubygems'
require 'gosu'

require './key'
require './char'

class Game < Gosu::Window
  include Gosu
  
  SCREEN_WIDTH = 320
  SCREEN_HEIGHT = 240
  TILE_SIZE = 16
  SCREEN_WIDTH_TILE = 320 / TILE_SIZE
  SCREEN_HEIGHT_TILE = 240 / TILE_SIZE
  
  attr_reader :scrolled_x, :scrolled_y
  
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
    
    # Scrolling-Offsets
    @scrolled_x = 0 unless defined? @scrolled_x
    @scrolled_y = 0 unless defined? @scrolled_y
    
    # Set up map stuff
    @characters = Hash.new unless defined? @characters
    
    cutter_bmp = Gosu::Image::load_tiles(self, "./gfx/sprites/cutter.png", 16, 16, true)
    
    @player = Char.new(0, 0, cutter_bmp)
    
    add_character(@player)
  end
  
  def update
    update_fps
    Key::update
    
    update_keyboard
    
    update_characters
  end
  
  def draw
    draw_background
    
    draw_characters
    
    draw_fps
    draw_rules
  end
  
  def scrolled_tile_x
    scrolled_x / TILE_SIZE
  end
  
  def scrolled_tile_y
    scrolled_y / TILE_SIZE
  end
  
  def screen_dimension
    {:width => ((scrolled_tile_x)..(scrolled_tile_x + SCREEN_WIDTH_TILE)),
    :height => ((scrolled_tile_y)..(scrolled_tile_y + SCREEN_WIDTH_TILE))}
  end
  
  
protected
  
  def add_character(char)
    @characters[char] = [char.x, char.y]
  end
  
  def update_keyboard
    if Key::hit?(KbEscape)
      close
    end
  
    # Control player movement
    unless @player.animating?
      if Key::down?(KbRight)
        @player.walk_in(:right)
      elsif Key::down?(KbLeft)
        @player.walk_in(:left)
      elsif Key::down?(KbUp)
        @player.walk_in(:up)
      elsif Key::down?(KbDown)
        @player.walk_in(:down)
      end
    end
  end

  def update_characters
    changed_chars = Hash.new
    
    # Update each char (move, animate, ...)
    @characters.each do |char, coords|
      @characters[char] = char.update
    end
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
  
  def draw_characters    
    @characters.each do |char, coords| 
      char.draw if 
        coords[0].between?(scrolled_tile_x, scrolled_tile_x + SCREEN_WIDTH_TILE) && 
        coords[1].between?(scrolled_tile_y, scrolled_tile_y + SCREEN_HEIGHT_TILE)
    end
  end
  
  
  def draw_fps(x = 0.0, y = 0.0, color = 0xff000000)
    @debug_font.draw("FPS: " + @fps.to_s, x, y, 100.0, 1, 1, color)
  end
  
  def draw_rules
    (1..15).each { |y| draw_line 0, y*16, 0x80000000, 320, y*16, 0x80000000}
    (1..19).each { |x| draw_line x*16+1, 0, 0x80000000, x*16, 240, 0x80000000}
  end
end

Game.new.show