require 'observer'

require_relative 'event_manager'

module QuickRPG
  class KeyEventAdapter
    attr_reader :keys
    
    def initialize(supported_keys)
      @keys = {}
      
      supported_keys.each do |key|
        @keys[key] = :released
      end
    end
  
    def button_down(id)
      old_state = keys[id]
      
      keys[id] = :down  if hit? id
      keys[id] = :hit   if released? id
      
      new_state = keys[id]
      
      key_changed(id, new_state) if old_state != new_state
    end 
  
    def button_up(id)
      old_state = keys[id]
      
      keys[id] = :released  if up? id
      keys[id] = :up        if down? id
      
      new_state = keys[id]
      
      key_changed(id, new_state) if old_state != new_state
    end

    def hit?(id)
      keys[id] == :hit
    end
  
    def down?(id)
      keys[id] == :down or hit? id
    end
  
    def up?(id)
      keys[id] == :up
    end
  
    def released?(id)
      keys[id] == :released or up? id
    end
  
    def state(id)
      keys[id]
    end
    
    def key_changed(key, changed_to)
      EventManager.post(KeyEvent.new(self, changed_to, key))
    end
  end
end
