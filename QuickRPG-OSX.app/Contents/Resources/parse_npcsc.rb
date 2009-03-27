# this file is only temporary. I need it to find out what the
# arbitrary NPC-files mean :)

=begin  xx = ""
  i = 0
  while not file.eof?
=begin
#    b = file.readchar.to_i# if i < 32
    # -->
    b = file.read(4).unpack("i")[0].to_i; puts b
#    b = file.read(4).unpack("M") if i >= 32
    c = b >= 49 ? b.chr : nil
    
    if c.nil?
      print "#{b}"
      i += 1
      print " "
    else
      print "#{c}*"
      i = 0
    end
    if i >= 4
      i = 0
      print "||\n"
    end

xx += file.readchar.to_s
  end
  xx
=end












fn = "data/npc3antikatown.sc"

$file = nil

def readint
  $file.read(4).unpack("i").to_s.to_i
end

def readka
  b = $file.readchar.to_i
  c = b >= 49 ? b.chr : nil

  if c.nil?
    b
  else
    c
  end
end

def readchars(n)
  n.times {print readka}
  print "\n"
end

basename = File.basename(fn, ".sc")

puts basename
puts "*" * 20

begin  
  $file = File.open(fn, "rb")
  
  num = readint
  puts "#{num}x"
  num.times do |i|
    puts $file.read(4).unpack("I")
  end

  print "\n"

  num = readint
  puts "#{num}x"
  
  readchars num
  
  num = readint
  puts "#{num}x"
  
  readchars num
  #puts readint
  
  while not $file.eof?  
    print readka
  end
ensure
  file.close if defined? file && !file.nil?
end

puts
