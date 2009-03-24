# 
# Dumb Interface
#
class ScriptCommand
  attr_reader :command, :args
  
  def initialize(cmd, args)
    @command = cmd
    @args = args
  end
  
  #
  # Return a symbolized version of the classname,
  # e.g. makes :talk out of "TalkCommand"
  #
  def command_name
    self.class.name[0..-8].downcase.to_sym
  end
end

class AnimPlayerCommand < ScriptCommand
end

class BlockKeyboardCommand < ScriptCommand
  BLOCK = :block
  FREE = :free
  
  attr_reader :status
  
  def initialize(cmd, args)
    super cmd, args
    
    @status = args[0].to_i == 1 ? BlockKeyboardCommand::BLOCK : BlockKeyboardCommand::FREE
  end
end

class CheckFlagCommand < ScriptCommand
  attr_reader :flag_no, :operator, :value, :goto_tag
  
  def initialize(cmd, args)
    @flag_no = args[0].to_i
    @operator = args[1].to_s.strip.downcase.to_sym
    @value = args[2].to_i
    @goto_tag = args[3].to_s.strip.downcase
  end
  
  def check_passed?(flags)
    # Abort when the flag isn't set
    false unless flags.has_key? @flag_no
    
    case @operator
    when :lt
      flags[@flag_no] < @value
    when :gt
      flags[@flag_no] > @value
    when :st
      flags[@flag_no] == @value
    end
  end
end

class EndCommand < ScriptCommand
  def initialize(cmd, args)
    super cmd, args
  end
end

class FlagCommand < ScriptCommand
  attr_reader :flag_no, :value
  
  def initialize(cmd, args)
    super cmd, args
    
    @flag_no = args[0].to_i
    @value = args[1].to_i
  end
  
  def use_flag_value(flags)
    flags[@flag_no] = @value
  end
end

class KollideCommand < ScriptCommand
  attr_reader :x, :y, :state
  
  def initialize(cmd, args)
    super cmd, args
    
    @x = args[0].to_i
    @y = args[1].to_i
    @state = args[2].to_i == 1
  end
end

class MapCommand < ScriptCommand
  attr_reader :tileset, :map
  
  def initialize(cmd, args)
    super cmd, args
    
    @tileset = args[0].to_s.strip
    @map = args[1].to_s.strip
  end
  
  def load_map!(wnd)
    Map::load(wnd, @map, @tileset)
  end
end

class MovePlayerCommand < ScriptCommand
  attr_reader :direction
  
  def initialize(cmd, args)
    super cmd, args
    
    @direction = args[0].to_i
  end
end

class PlayerPosCommand < ScriptCommand
  attr_reader :x, :y, :direction
  
  def initialize(cmd, args)
    super cmd, args
    
    # The coordinates are param #1 and in the form "x y"
    coords = args[0].split(" ")
    @x = coords[0].to_i
    @y = coords[1].to_i
    
    @direction = args[1].to_i
  end
end

class TagCommand < ScriptCommand
  attr_reader :name
  
  def initialize(cmd, args)
    super cmd, args
    
    @name = args[0].to_s.strip.downcase
  end
end

class TalkCommand < ScriptCommand
  attr_reader :name, :lines
  
  def initialize(cmd, args)
    super cmd, args
    
    @name = args[0].to_s.strip
    @lines = Array.new unless defined? @lines
  end
  
  def add_line(line)
    raise "too much lines (4 max)" unless @lines.length < 4
    
    @lines << line
  end
end