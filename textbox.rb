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
#

class Textbox
  private_class_method :new, :clone
  
  @@textbox_image = nil
  @@font_img = nil
  @@box = nil
  
  # Factory and status updater
  class << self
    def textbox=(img)
      @@textbox = img
    end
    
    def font=(img)
      @@font = img
    end
    
    def create(name, lines)
      raise "Box already open" if open?
      @@box = new(name, lines)
    end
    
    def close
      @@box = nil
    end
    
    def open?
      return !@@box.nil?
    end
    
    def draw
      @@box.draw if open?
    end
  end

  public
  
    def initialize(name, lines)
      @name = name
      @lines = lines
    end
  
    def draw
      @@textbox.draw 16 * 3, 16, Z_TEXTBOX
  
      y = 16 * 2 - 2
  
      draw_text_line_at(@name + ":", 16 * 4 - 2, y)
  
      y+= 12
  
      @lines.each do |line|
        x = 16 * 4 + 8
        draw_text_line_at(line, x, y)
        y += 6
      end
    end
  
  private
  
    def draw_text_line_at(line, x, y)
      line.each_byte do |b|
        @@font.at(b - 33).draw x, y, Z_TEXTBOX + 1
        x += 6
      end
    end
end