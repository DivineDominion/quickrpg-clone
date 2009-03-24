def open(fn)
  file = File.open(fn, "rb")
  
  i = 0
  while not file.eof?
    b = file.readchar.to_i# if i < 32
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

  end
  
rescue Exception
  raise
ensure
  file.close if defined? file && !file.nil?
end

open("data/npc1antikatown.sc")