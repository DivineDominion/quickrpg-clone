def open(fn)
  file = File.open(fn, "rb")
  
  i = 0
  while not file.eof?
    b = file.readchar.to_i# if i < 32
#    b = file.read(4).unpack("M") if i >= 32
    c = b >= 50 ? b.chr : nil
    
    print c unless c.nil?
    print b if c.nil?
    print " "
    

    i += 1
  end
  
rescue Exception
  raise
ensure
  file.close if defined? file && !file.nil?
end

open("data/npc3antikatown.sc")