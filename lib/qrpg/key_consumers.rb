module QuickRPG
  class KeyConsumers
    attr_reader :first_responder
    
    def initialize(responders = nil)
      unless responders.nil?
        unless responders.is_a?(Array)
          responders = [responders]
        end
      
        import_responders(responders)
      end
    end
    
    def import_responders(responders)
      responders.each do |responder|
        self << responder
      end
    end
    
    def guard_responder_is_chainable(responder)
      unless responder.respond_to?(:next_responder=)
        raise "element in chain must respond to #next_responder= (#{responder.to_s})"
      end
    end
    
    def <<(responder)
      guard_responder_is_chainable(responder)
      
      if @first_responder.nil?
        @first_responder = responder
      else
        last = self.last_responder
        last.next_responder = responder
      end
    end
    
    def last_responder
      prev_responder = @first_responder
      while prev_responder.next_responder != nil
        prev_responder = prev_responder.next_responder
      end
      prev_responder
    end
    
    def handle_event(event)
      if event.kind_of?(KeyEvent)
        handle_key_event(event)
      end
    end
    
    def handle_key_event(event)
      @first_responder.handle_key_event(event)
    end    
  end
end
