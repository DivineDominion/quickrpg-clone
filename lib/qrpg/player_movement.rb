require_relative 'keyboard_control/handles_key_events_in_chain'

module QuickRPG
  class PlayerMovement
    include HandlesKeyEventsInChain
    
    def handle_key_event(event)
      # TODO handle if arrow keys or action key is pressed only, until then consume all
      # @next_responder.handle_key_event(event)
    end
  end
end
