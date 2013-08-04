require_relative 'stage'

module QuickRPG
  module GameState
    class MapStage < Stage
      attr_accessor :map
    
      def initialize(map: nil)
        @map = map
      end
      
      def update
        map.update if map
      end
      
      def draw
        map.draw if map
      end
    end
  end
end
