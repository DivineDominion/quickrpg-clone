require_relative 'keyboard_control/handles_key_events_in_chain'

module QuickRPG
  class TextboxController
    include HandlesKeyEventsInChain
    
    def show(textbox)
      @textbox = textbox
    end
    
    def active?
      has_text_box?
    end
    
    def has_text_box?
      !@textbox.nil?
    end
    
    def handle_key_event(event)
      if active?
      else
        forward_key_event(event)
      end
    end
  end
end
