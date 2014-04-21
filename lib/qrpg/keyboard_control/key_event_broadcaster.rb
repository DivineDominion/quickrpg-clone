# = key_event_dispatcher.rb - Broadcasts key state changes

require_relative '../event/event_manager'
require_relative 'key_event_adapter'

module QuickRPG
  class KeyEventBroadcaster
    attr_accessor :event_manager
    attr_accessor :key_event_adapter
  
    def initialize(key_event_adapter = KeyEventAdapter.new)
      @key_event_adapter = key_event_adapter
    end
  
    def button_down(key_id)
      fire_if_state_changes(key_id) do
        key_event_adapter.button_down(key_id)
      end
    end 

    def button_up(key_id)
      fire_if_state_changes(key_id) do
        key_event_adapter.button_up(key_id)
      end
    end
    
    def event_manager
      @event_manager ||= EventManager.default_manager
    end
  
  private
  
    def fire_if_state_changes(key_id)
      old_state = key_event_adapter.state(key_id)
      yield
      new_state = key_event_adapter.state(key_id)
    
      fire_key_changed(key_id, new_state) if old_state != new_state
    end
  
    def fire_key_changed(key_id, changed_to)
      event_manager.post(KeyEvent.new(self, changed_to, key_id))
    end
  end
end
