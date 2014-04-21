module QuickRPG
  class PlayerMovement
    attr_accessor :next_responder
    
    def handle_key_event(event)
      # TODO handle if arrow keys or action key is pressed
      @next_responder.handle_key_event(event)
    end
  end
end
