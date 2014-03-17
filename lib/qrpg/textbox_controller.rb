module QuickRPG
  class TextboxController
    attr_accessor :next_responder
    
    def show(textbox)
      @textbox = textbox
    end
    
    def active?
      !@textbox.nil?
    end
    
    def handle_key_event(event)
      if active?
      else
        @next_responder.handle_key_event(event)
      end
    end
  end
end
