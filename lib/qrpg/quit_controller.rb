require_relative 'keyboard_control/handles_key_events_in_chain'

require_relative 'event/event'
require_relative 'event/event_manager'

module QuickRPG
  class QuitController
    include HandlesKeyEventsInChain
    attr_accessor :event_manager
    
    def handle_key_event(event)
      if event.key_id == Common::KEY_ESC
        key_esc_pressed(event)
      else
        forward_key_event(event)
      end
    end
    
    def key_esc_pressed(event)
      quit_event = create_quit_event
      fire_event(quit_event)
    end
    
    def fire_event(event)
      event_manager.post(event)
    end
    
    def create_quit_event
      QuitEvent.new(self)
    end
    
    def event_manager
      @event_manager ||= EventManager.default_manager
    end
  end
end