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

require 'singleton'

class FPS
  include Singleton
  
  def self.draw(x = 0.0, y = 0.0, color = 0xff000000)
    instance.draw(x, y, color)
  end
  
  def initialize
    @fps_counter = 0
    @fps = 0
    @milliseconds = 0
  end
  
  def notify(event)
    @fps_counter += 1

    if event.millisecs - @milliseconds >= 1000
      @fps = @fps_counter

      @fps_counter = 0
      @milliseconds = event.millisecs
    end
  end
  
  def draw(x, y, color)
    $font.draw("FPS: " + @fps.to_s, x, y, 100.0, 1, 1, color)
  end
end