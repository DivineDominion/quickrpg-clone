#
# Extends Rubys +File+ class to read values like Blitz Basic
# does.
#
class File
  #
  # Reads a 4 byte integer
  #
  def readint
    read(4).unpack("i")[0]
  end
  
  #
  # Reads a string.
  # First it's length is determined by reading an integer value,
  # then the corresponding amount of characters is read
  #
  def readstring
    length = readint
    result = ""
    # TODO unpack("%m") or so
    length.times { result << readchar.chr}
    return result
  end
end