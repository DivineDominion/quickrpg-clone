module QuickRPG
  module HandlesKeyEventsInChain
    attr_accessor :next_responder
    
    def forward_key_event(event)
      @next_responder.handle_key_event(event) if has_next_responder? 
    end
    
    def has_next_responder?
      !@next_responder.nil?
    end
  end
end