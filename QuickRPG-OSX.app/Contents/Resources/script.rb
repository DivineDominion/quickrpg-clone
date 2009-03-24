require 'scriptcommand'

class Script
  def self.create_command(cmd, args)
    case cmd.to_sym
    when :animplayer
      # Not supported!
      AnimPlayerCommand.new(cmd, args)
    when :blockkeyboard
      BlockKeyboardCommand.new(cmd, args)
    when :checkflag
      CheckFlagCommand.new(cmd, args)
    when :end
      EndCommand.new(cmd, args)
    when :flag
      FlagCommand.new(cmd, args)
    when :kollide
      KollideCommand.new(cmd, args)
    when :map
      MapCommand.new(cmd, args)
    when :moveplayer
      MovePlayerCommand.new(cmd, args)
    when :playerpos
      PlayerPosCommand.new(cmd, args)
    when :tag
      TagCommand.new(cmd, args)
    when :talk
      TalkCommand.new(cmd, args)
    else
      raise "command unknown: '#{cmd}'"
    end
  end
  
  def initialize(wnd, filename)
    path = File.join("data", "#{filename}.sc")
    
    file = File.open(path, "r")
    
    @filename = filename
    @wnd = wnd
    @tags = Hash.new unless defined? @tags
    @lines = Array.new unless defined? @lines
    
    @movement_blocked = BlockKeyboardCommand::FREE
    @finished = false
    @line_to_return_to = nil
    
    parse_script file.readlines
  rescue Exception
    raise
  ensure
    file.close if defined? file && !file.nil?
  end
  
  def suspended?
    !@line_to_return_to.nil? && !finished?
  end
  
  def finished?
    @finished
  end
  
  def reset
    @line_to_return_to = nil
    @finished = false
  end
  
  def execute!
    line_num = @line_to_return_to || 0
    @line_to_return_to = nil
    
    @finished = false
    
    while not @finished
      line = @lines[line_num]
      
      raise "Script error: empty line or EOF, script without END? #{line_num+1} of #{@lines.length}" if line.nil? 
      
      case line.command_name
      when :blockkeyboard
        @movement_blocked = line.status
      when :checkflag
        line.check_passed?(@wnd.map.flags)
      when :end
        @finished = true
      when :flag
        line.use_flag_value(@wnd.map.flags)
      when :kollide
        @wnd.map.set_collision(line.x, line.y, line.state)
      when :map
        @wnd.use_map line.load_map!(@wnd)
      when :moveplayer
        #MovePlayerCommand.new(cmd, args)
      when :playerpos
        @wnd.player.x, @wnd.player.y = line.x, line.y
        #@wnd.map.center_map_on @wnd.player
      when :tag
        print "Tag command found upon execution, not cleaned by parser in #{line_num}:#{@filename}.sc.\n"
      when :talk
        @wnd.create_text_box(line.name, line.lines)
        
        # Continue execution in the next line
        @line_to_return_to = line_num + 1
        break
      end
      
      line_num += 1
    end
  end
  
  def movement_blocked?
    @movement_blocked.eql?(BlockKeyboardCommand::BLOCK)
  end
  
private
  
  def parse_script(string_lines)  
    line_num = 0
    i = 0
    while i < string_lines.length
      cmd = parse_line(string_lines[i])
      @lines << cmd
      
      # Make :talk out of "TalkCommand"
      case cmd.command_name
      when :tag
        @tags[cmd.name] = line_num
        # No need to keep the TAG-command, just the line ref
        @lines.pop
        line_num -= 1
      when :talk
        4.times do
          i += 1
          # Add text line w/o quotation marks
          cmd.add_line string_lines[i].strip[1..-2]
        end
      end
      
      line_num += 1
      i += 1
    end
  end
  
  #
  # Transforms a string line into a executable command
  #
  def parse_line(line)
    parts = line.strip.split(",")
    
    cmd = parts[0].downcase
    args = parts[1..-1]
    
    return Script::create_command(cmd, (args.empty? ? nil : args))
  end
end