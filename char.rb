

class Char
  SPRITEANIM = {
    :up => [4, 5], 
    :down => [0, 1], 
    :left => [6, 7],
    :right => [2, 3]
    }
  FRAMESIZE = 16
  
  attr_reader :x, :y
  
  def initialize(x, y, image)
    @x = x
    @y = y
    
    @yoff = 0
    
    @image = image
    
    @animating = false unless defined? @animating
    
    turn_to(:down)
  end
  
  def update
    animate! if animating?
  end
  
  def animating?
    @animating
  end
  
  def animate!
    if @step >= 16
      @animating = false
      return
    end
    
    # Move on screen
    case @direction
    when :up
      @y -= 1
    when :down
      @y += 1
    when :left
      @x -= 1
    when :right
      @x += 1
    end
    
    #0 q
    #1 q
    #2 q
    #3 q
    #4 w
    #5 w
    #6 w
    #7 w
    #8 w
    #9 w
    #a w
    #b w
    #c q
    #d q
    #e q
    #f q
    
    framenum = 1
    @yoff = -1
    if @step.between?(0,3) || @step.between?(12, 15)
      framenum = 0
      @yoff = 0
    end
    
    @frame = SPRITEANIM[@direction][framenum]
    @step += 1
  end
  
  def turn_to(direction)
    raise "animation not finished" if animating?
    
    @direction = direction
    @frame = Char::SPRITEANIM[@direction][0]
  end
  
  def walk_in(direction)
    raise "walk_in called before finished" if animating?
    
    # Reset animation
    turn_to(direction) if (@direction != direction)

    @step = 0
    @animating = true
  end
  
  def draw
    @image.at(@frame).draw(@x, @y + @yoff, 10)
  end
end