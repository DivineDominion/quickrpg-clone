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
require 'observer'

class Key
  include Singleton, Observable
  
  # Initialize class variables
  @@wnd = @@keys = nil
  
  def self.setup(wnd)
    @@wnd = wnd
    @@keys = Array.new(256, :released)
  end
  
  def self.update
    raise "Call Key::setup first" unless defined? @@wnd
    
    (0..255).each do |id|
      old_state = Key::state id
      
      if @@wnd.button_down? id
        Key::button_down(id)
      else
        Key::button_up(id)
      end
      
      # Notify listeners on state changes
      if old_state != Key::state(id)
        Key::instance.notify_observers(:key_event, id, Key::state(id))
      end
    end
  end
  
  def self.button_down(id)
    @@keys[id] = :down  if Key::hit? id
    @@keys[id] = :hit   if Key::released? id
  end 
  
  def self.button_up(id)
    @@keys[id] = :released  if Key::up? id
    @@keys[id] = :up        if Key::down? id
  end

  def self.hit?(id)
    @@keys[id] == :hit
  end
  
  def self.down?(id)
    @@keys[id] == :down or Key::hit? id
  end
  
  def self.up?(id)
    @@keys[id] == :up
  end
  
  def self.released?(id)
    @@keys[id] == :released or Key::up? id
  end
  
  def self.state(id)
    @@keys[id]
  end
end