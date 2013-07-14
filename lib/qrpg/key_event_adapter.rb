# = key_event_adapter.rb - Semantic key states
#
# Makes :hit, :down, :up, :released key states available for querying.

module QuickRPG
  class KeyEventAdapter
    attr_reader :keys
    
    def initialize(supported_keys = (0..255))
      @keys = {}
      
      supported_keys.each do |key|
        @keys[key] = :released
      end
    end
  
    def button_down(id)
      keys[id] = :down  if hit? id
      keys[id] = :hit   if released? id
    end 
  
    def button_up(id)
      keys[id] = :released  if up? id
      keys[id] = :up        if down? id
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
  end
end
