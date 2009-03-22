#!/usr/bin/ruby
# Ensure ruby1.8 runs :(

require 'rubygems'
require 'gosu'

require './key'
require './char'

class Game < Gosu::Window
  include Gosu
  
  def initialize
    super(320, 240, false, 20)
    self.caption = 'QuickRPG Ruby Clone'
    
    Key::setup self
    
    @debug_font = Font.new(self, 'Monaco', 12)
    @bgcol = Color.new(255, 128, 128, 128)
    
    # Set up an FPS counter
    @fps_counter = 0
    @fps = 0
    @milliseconds = milliseconds()
    @show_fps = true
    
    cutter_bmp = Gosu::Image::load_tiles(self, "./gfx/sprites/cutter.png", 16, 16, true)
    
    @player = Char.new(0, 0, cutter_bmp)
  end
  
  def update
    update_fps
    Key::update
    
    if Key::hit?(KbEscape)
      close
    end
    
    # Player movement
    if not @player.animating?
      if Key::down?(KbRight)
        @player.walk_in(:right)
      elsif Key::down?(KbLeft)
        @player.walk_in(:left)
      end
    
      if Key::down?(KbUp)
        @player.walk_in(:up)
      elsif Key::down?(KbDown)
        @player.walk_in(:down)
      end
    end
    
    @player.update
  end
  
  def update_fps
    @fps_counter += 1
  
    if milliseconds() - @milliseconds >= 1000
      @fps = @fps_counter
    
      @fps_counter = 0
      @milliseconds = milliseconds
    end
  end
  
  def draw_fps(x = 0.0, y = 0.0, color = 0xff000000)
    @debug_font.draw("FPS: " + @fps.to_s, x, y, 100.0, 1, 1, color)
  end
  
  def draw
    draw_background
    
    @player.draw
    
    draw_fps
  end
  
  def draw_background
    draw_quad 0, 0, @bgcol, 320, 0, @bgcol, 0, 240, @bgcol, 320, 240, @bgcol
  end
end

Game.new.show