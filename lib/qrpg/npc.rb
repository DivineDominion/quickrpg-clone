module QuickRPG
  class NPC < Char
    NPC_DIRECTIONS = {
      1 => :down, 
      2 => :up, 
      3 => :left, 
      4 => :right
      }
    
    class << self
    public
      def create_npc(wnd, args, frameset, filename)
        # Remove "bmp" and create full path for image
        frameset = frameset[-3..-1].eql?("bmp") ? frameset[0..-5] : frameset
        img_path = Common::sprite_file_path(frameset + ".png")
      
        ## NpcActive? X Y Movement Frame Y-offset ??? ??? AnimationTimer
      
        # Give the arguments a name
        active = args[0].to_i
        x, y = args[1].to_i, args[2].to_i
        move_type = args[3].to_i
        dir = args[4].to_i + 1 # Used to be "frames" and starting with 0
        offset = args[5].to_i
        # arguments 6 and 7 have an unknown purpose
        timer = args[8].to_i
      
        npc = NPC.new(wnd, x, y, Gosu::Image::load_tiles(wnd, img_path, 16, 16, true))
        npc.turn_to(NPC_DIRECTIONS[dir])
      
        filename = Common::script_file_path("#{filename}.sc")
        if File.exists?(filename)
          movement_pattern, speak_script = parse_npc_script File.open(filename, "r")
          npc.setup_movement(movement_pattern)
          npc.setup_speak_script(speak_script)
        end
      
        return npc
      end
    
    private
      def parse_npc_script(file)
        movement_pattern = []

        (num_steps = file.readint).times { movement_pattern << file.readint }

        if file.readstring.eql?("script")
          speak_script = file.readstring
        end
      
        return movement_pattern, speak_script
      end
    end
  
    def initialize(wnd, x, y, image)
      super(x, y, image)
    
      @wnd = wnd
    
      @movement_pattern = nil
      @speak_script = nil
    end
  
    def update
      result = animate! if animating?
        
      new_coords = super
    
      if result.eql?(:finished)
        unless @movement_pattern.nil?
          progress_movement
        else
          @animating = true #continue walking on spot
        end
      end
    
      return new_coords
    end
  
    def turn_to(direction)
      super
    
      # Animate NPCs even when standing still
      @animating = true
    end
  
    def setup_movement(movement_pattern)
      @movement_pattern = movement_pattern
    
      @movement_progress = 0
    end
  
    def setup_speak_script(filename)
      #@speak_script = wnd.load_script(filename)
    end
  
    def progress_movement
      raise "animate_movement called while walking" if walking?
      raise "animate_movement called while animating" if animating? 
      raise "movement not set up" if @movement_pattern == nil
    
      walk_in(NPC::NPC_DIRECTIONS[@movement_pattern[@movement_progress]])
      @movement_progress += 1
      @movement_progress = 0 if @movement_progress >= @movement_pattern.length
    end  
  end
end
