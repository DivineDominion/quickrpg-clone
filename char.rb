

class Char
  SPRITEANIM = {
    :up => [4, 5], 
    :down => [0, 1], 
    :left => [6, 7],
    :right => [2, 3]
    }
    
  FRAMESIZE = TILE_SIZE
  
  attr_accessor :x, :y
  
  def initialize(x, y, image)
    @x = x
    @y = y
    
    @x_off = 0 unless defined? @x_off
    @y_off = 0 unless defined? @y_off
    
    @image = image
    
    @animating = false unless defined? @animating
    
    turn_to(:down)
  end
  
  def update
    animate! if animating?
    
    return [@x, @y]
  end
  
  def walking?
    animating?
  end
  
  def animating?
    @animating
  end
  
  def draw(scrolled_x, scrolled_y)
    @image.at(@frame).draw(
      @x * FRAMESIZE + @x_off - scrolled_x, 
      @y * FRAMESIZE + @y_off - (@jump ? 1 : 0) - scrolled_y - 6, 
      100)
  end
  
  #
  # MOVEMENT METHODS
  #
  
  def turn_to(direction)
    raise "animation not finished" if walking?
    
    @direction = direction
    @frame = Char::SPRITEANIM[@direction][0]
  end
  
  def walk_in(direction)
    raise "walk_in called before finished" if walking?
    
    # Reset animation
    turn_to(direction) if (@direction != direction)

    @step = 0
    @animating = true
  end
  
  #
  # Returns an [x,y]-array
  #
  def aim
    raise "not walking at all" unless walking?
    
    case @direction
    when :up
      [@x, @y - 1]
    when :down
      [@x, @y + 1]
    when :right
      [@x + 1, @y]
    when :left
      [@x - 1, @y]
    end
  end
  
  def is_aim(x, y)
    aim[0].eql?(x) && aim[1].eql?(y)
  end
  
protected
  def animate!
    if @step >= 16
      @animating = false
      return :finished
    end
    
    # Move on screen
    case @direction
    when :up
      @y_off -= 1
    when :down
      @y_off += 1
    when :left
      @x_off -= 1
    when :right
      @x_off += 1
    end
    
    if @y_off < 0
      @y_off += 16
      @y -= 1
    elsif @y_off > 15
      @y_off -= 16
      @y += 1
    end
    
    if @x_off < 0
      @x_off += 16
      @x -= 1
    elsif @x_off > 15
      @x_off -= 16
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
    # 1px "jump" when moving horizontally
    @jump = [:left, :right].member? @direction
    if @step.between?(0,3) || @step.between?(12, 15)
      framenum = 0
      @jump = false
    end
    
    @frame = SPRITEANIM[@direction][framenum]
    @step += 1
  end
end