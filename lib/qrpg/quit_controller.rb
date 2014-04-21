module QuickRPG
  class TextboxController
    def handle_key_event(event)
      # TODO consume ESC key
      @next_responder.handle_key_event(event)
    end
  end
end