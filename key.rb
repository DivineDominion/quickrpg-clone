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
  
  # Sets up a shorthand and Maps each object method to a class method, 
  # e.g. write Key::state(id) instead of Key.instance.state(id)
  MapMethodsToClassMethods = proc do
    meth = self.public_instance_methods \
      - self.superclass.public_instance_methods \
      - (self.included_modules.map {|m| m.instance_methods}).flatten

    # TODO migrate to Ruby 1.9 soon!!
    meth.map!{|m|m.to_sym} if RUBY_VERSION =~ /^1\.8/

    meth.each do |m|
      module_eval <<-END_EVAL
        def self.#{m.id2name}(*args, &block)
          instance.#{m.id2name}(*args, &block)
        end
      END_EVAL
    end
  end
  
  def initialize
    raise "Setup $wnd which must be instance_of? Gosu::Window" unless defined? $wnd
    
    @keys = Array.new(256, :released) 
  end
  
  def update
    (0..255).each do |id|
      old_state = state(id)
      
      if $wnd.button_down?(id)
        button_down(id)
      else
        button_up(id)
      end
      
      # Notify listeners on state changes
      if state(id) != old_state
        notify_observers(:key_event, id, state(id))
      end
    end
  end
  
  def button_down(id)
    @keys[id] = :down  if hit? id
    @keys[id] = :hit   if released? id
  end 
  
  def button_up(id)
    @keys[id] = :released  if up? id
    @keys[id] = :up        if down? id
  end

  def hit?(id)
    @keys[id] == :hit
  end
  
  def down?(id)
    @keys[id] == :down or hit? id
  end
  
  def up?(id)
    @keys[id] == :up
  end
  
  def released?(id)
    @keys[id] == :released or up? id
  end
  
  def state(id)
    @keys[id]
  end
  
  MapMethodsToClassMethods.call
end