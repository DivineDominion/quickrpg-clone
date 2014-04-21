module QuickRPG
  class KeyAdapter
    def handle_event(event)
      if event.instance_of? KeyEvent
        ev = nil
      
        return if not mvClass(event.state)
      
        case event.key_id
        when Common::KEY_UP
          ev = mvClass(event.state).new(self, :up)
        when Common::KEY_DOWN
          ev = mvClass(event.state).new(self, :down)
        when Common::KEY_LEFT
          ev = mvClass(event.state).new(self, :left)
        when Common::KEY_RIGHT
          ev = mvClass(event.state).new(self, :right)
        when Common::KEY_ESC
          ev = QuitEvent.new(self)
        when Common::KEY_SPACE
          # TODO interact
        end
      
        EventManager::post(ev) unless ev.nil?
      end
    end
  
    def mvClass(state)
      if state === :up
        CharStopRequest
      elsif state === :hit# or state === :down
        CharMoveRequest
      end
    end
  end
end