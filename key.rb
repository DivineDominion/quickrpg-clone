require 'singleton'

require 'observable'

class Key
  include Singleton, Observable
  
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
        Key::instance.notify :key_event, id, Key::state(id)
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