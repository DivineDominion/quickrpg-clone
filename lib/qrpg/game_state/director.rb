module QuickRPG
  module GameState
    class Director
      attr_reader :current_state
    
      def initialize(state: nil)
        @current_state = state
      end
          
      def switch_to(next_state)
        current_state.curtain_down if current_state
        next_state.curtain_up
        self.current_state = next_state
      end
    
      def update
        current_state.update if current_state
      end
    
      def draw
        current_state.draw if current_state
      end
    
      private
      attr_writer :current_state
    end
  end
end