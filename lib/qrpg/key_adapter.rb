module QuickRPG
  class KeyAdapter
    def initialize
      EventManager::register(self)
    end
      
    def handle_event(event)
      if event.instance_of? KeyEvent
        ev = nil
      
        return if not mvClass(event.state)
      
        case event.key_id
        when K_UP
          ev = mvClass(event.state).new(self, :up)
        when K_DOWN
          ev = mvClass(event.state).new(self, :down)
        when K_LEFT
          ev = mvClass(event.state).new(self, :left)
        when K_RIGHT
          ev = mvClass(event.state).new(self, :right)
        when K_ESC
          ev = QuitEvent.new(self)
        when K_SPACE
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