class Char
  DIR_TO_FRAMES = {
    :up => [4, 5], 
    :down => [0, 1], 
    :left => [6, 7],
    :right => [2, 3]
    }
    
  FRAME_SIZE = TILE_SIZE
  
  attr_accessor :x, :y
  
  def initialize(x, y, image)
    @x = x
    @y = y
    
    @x_off = 0 unless defined? @x_off
    @y_off = 0 unless defined? @y_off
    
    @image = image
    
    @walking = false unless defined? @waking
    @animating = false unless defined? @animating
    
    # When eql :npc the char will animate while standing still
    @movement = :npc unless defined? @movement
    
    turn_to(:down)
  end
  
  def update
    if animating?
      if animate!.eql?(:finished)
        @animating = @movement.eql?(:npc)
      end
    end
    
    if walking?
      if walk!.eql?(:finished)
        # then just stop walking :)
      end
    end
    
    if @step >= 16
      @step = 0
    else
      @step += 1
    end
    
    return [@x, @y]
  end
  
  def walking?
    @walking
  end
  
  def animating?
    @animating
  end
  
  def draw(scrolled_x, scrolled_y)
    @image.at(@frame).draw(
      @x * FRAME_SIZE + @x_off - scrolled_x, 
      @y * FRAME_SIZE + @y_off - (@jump ? 1 : 0) - scrolled_y - 6, 
      100)
  end
  
  #
  # MOVEMENT METHODS
  #
  
  def turn_to(direction)
    raise "turn_to called while walking" if walking?
    
    @direction = direction
    @frame = Char::DIR_TO_FRAMES[@direction][0]
    @animating = @movement.eql?(:npc)
    @step = 0
  end
  
  def walk_in(direction)
    raise "walk_in called while walking" if walking?
    
    # Reset animation
    turn_to(direction)

    @animating = true
    @walking = true
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

  def walk!
    raise "not walking" unless walking?
    
    if @step >= 16
      @walking = false
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
  end
  
  def animate!
    raise "not animating" unless animating?
    
    if @step >= 16
      #@animating = false
      return :finished
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
    
    frame_step = 1
    # 1px "jump" when walking (!!) horizontally
    @jump = [:left, :right].member? @direction && walking?
    if @step.between?(0,3) || @step.between?(12, 15)
      frame_step = 0
      @jump = false
    end
    
    @frame = DIR_TO_FRAMES[@direction][frame_step]
  end
end

#
# Only used to set Player.movement=:player to stop him from
# animating while standing still.
#
class Player < Char
  def initialize(x, y, image)
    @movement = :player
    
    super x, y, image
  end
end