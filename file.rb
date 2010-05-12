#
# QuickRPG (Role Playing Game)---clone from my 2001 Blitz Basic project.
# 
# Copyright (C) 2009  Christian Tietze
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
# 
#     christian.tietze@gmail.com
#     <http://christiantietze.de/>
#     <http://divinedominion.art-fx.org/>
#


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
    length.times { result << readchar.chr }
    return result
  end
end