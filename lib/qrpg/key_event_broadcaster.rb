# = key_event_dispatcher.rb - Broadcasts key state changes

require_relative 'event_manager'
require_relative 'key_event_adapter'

module QuickRPG
  class KeyEventBroadcaster
    attr_reader :key_event_adapter
  
    def initialize(key_event_adapter = KeyEventAdapter.new)
      @key_event_adapter = key_event_adapter
    end
  
    def button_down(key_id)
      fire_state_changes(key_id) do
        key_event_adapter.button_down(key_id)
      end
    end 

    def button_up(key_id)
      fire_state_changes(key_id) do
        key_event_adapter.button_up(key_id)
      end
    end
  
    private
  
    def fire_state_changes(key_id)
      old_state = key_event_adapter.state(key_id)
      yield
      new_state = key_event_adapter.state(key_id)
    
      key_changed(key_id, new_state) if old_state != new_state
    end
  
    def key_changed(key_id, changed_to)
      EventManager.post(KeyEvent.new(self, changed_to, key_id))
    end
  end
end