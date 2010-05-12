#
# QuickRPG (Role Playing Game)---clone from my 2001 Blitz Basic project.
# 
# Copyright (C) 2009  Christian Tietze
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#     christian.tietze@gmail.com
#     <http://christiantietze.de/>
#     <http://divinedominion.art-fx.org/>


class Char
  # Translate direction symbols to frame-ranges
  DIR_TO_FRAMES = {
    :up => [4, 5], 
    :down => [0, 1], 
    :left => [6, 7],
    :right => [2, 3]
    }
  
  # 16x16 Sprites on a 16x16 world supported only
  FRAME_SIZE = TILE_SIZE
  
  attr_accessor :x, :y
  
  def initialize(x, y, image)
    # Tile position
    @x = x
    @y = y
    
    # Offset on the tile, takes values from 0 to (TILE_SIZE-1)=15
    @x_off = 0 unless defined? @x_off
    @y_off = 0 unless defined? @y_off
    
    @image = image
    @frame = 0
    
    @walking = false unless defined? @waking
    @animating = false unless defined? @animating
    
    @step = 0
  end
  
  def update
    state = walk! if walking?
    
    if @step >= 16
      @step = 0
    else
      @step += 1
    end
    
    if state == :finished
      EventManager.post(CharTileMoveDone.new(self, @direction))
    end
    
    return [@x, @y]
  end
  
  def walking?
    @walking
  end
  
  def animating?
    @animating
  end
  
  def draw(scrolled_x, scrolled_y)
    @image.at(@frame).draw(
      @x * Char::FRAME_SIZE + @x_off - scrolled_x, 
      @y * Char::FRAME_SIZE + @y_off - (@jump ? 1 : 0) - scrolled_y - 6, 
      Z_CHAR)
  end
  
  def turn_to(direction)
    raise "turn_to called while walking" if walking?
    raise "turn_to called while animating" if animating?
    
    @direction = direction
    @frame = Char::DIR_TO_FRAMES[@direction][0]
    @step = 0
  end
  
  def walk_in(direction)
    raise "walk_in called while walking" if walking?
    raise "walk_in called while animating" if animating?
    
    # Reset animation
    turn_to(direction)

    @animating = true
    @walking = true
  end
  
  #
  # Returns an [x,y]-array
  #
  def aim
    raise "not walking at all" unless walking?
    
    case @direction
    when :up
      [@x, @y - 1]
    when :down
      [@x, @y + 1]
    when :right
      [@x + 1, @y]
    when :left
      [@x - 1, @y]
    end
  end
  
  def is_aim?(x, y)
    aim[0].eql?(x) && aim[1].eql?(y)
  end
  
protected

  def walk!
    raise "not walking" unless walking?
    
    if @step >= 16
      @walking = false
      return :finished
    end
    
    # Move on screen
    case @direction
    when :up
      @y_off -= 1
    when :down
      @y_off += 1
    when :left
      @x_off -= 1
    when :right
      @x_off += 1
    end
    
    if @y_off < 0
      @y_off += 16
      @y -= 1
    elsif @y_off > 15
      @y_off -= 16
      @y += 1
    end
    
    if @x_off < 0
      @x_off += 16
      @x -= 1
    elsif @x_off > 15
      @x_off -= 16
      @x += 1
    end
  end
  
  def animate!
    raise "not animating" unless animating?
    
    if @step >= 16
      @animating = false
      return :finished
    end
    
    # Movement/frame change patter
    # @step #  1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16
    # frame #  0  0  0  0  1  1  1  1  1  1  1  0  0  0  0  0
    
    frame_step = 1
    # 1px "jump" when walking (!!) horizontally
    @jump = [:left, :right].member? @direction && walking?
    if @step.between?(0,3) || @step.between?(12, 15)
      frame_step = 0
      @jump = false
    end
    
    @frame = DIR_TO_FRAMES[@direction][frame_step]
  end
end
