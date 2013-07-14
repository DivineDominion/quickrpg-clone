class Player < Char
  attr_accessor :moving_started
  
  def initialize(image)
    super(0, 0, image)
    
    @moving_started = false
  end
  
  def moving_started?
    @moving_started
  end
  
  def update
    animate! if animating?

    super
  end
end
