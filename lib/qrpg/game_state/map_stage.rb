require_relative 'stage'

module QuickRPG::GameState
  class MapStage < Stage
    attr_accessor :map
    
    def initialize(map: nil)
      @map = map
    end
    
    def draw
      map.draw if map
    end
  end
end
