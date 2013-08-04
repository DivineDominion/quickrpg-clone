module QuickRPG::GameState
  class Stage
    def initialize
      @visible = false
    end
    
    def curtain_up
      self.visible = true
    end
        
    def curtain_down
      self.visible = false
    end
   
    def visible?
      !!visible # double-negation ensures boolean
    end
   
    def update
    end
    
    def draw
    end
    
    private
    
    attr_accessor :visible
  end
end