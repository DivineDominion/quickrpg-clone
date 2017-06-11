require 'gosu' # required for the keys

module QuickRPG
  module Common
    IMAGE_DIR = File.join(__dir__, '..', '..', 'gfx')
    SCRIPT_DIR = File.join(__dir__, '..', '..', 'data')
    MAP_DIR = File.join(__dir__, '..', '..', 'maps')

    SCREEN_WIDTH = 425
    SCREEN_HEIGHT = 240
    TILE_SIZE = 16
    SCREEN_WIDTH_TILE = SCREEN_WIDTH / TILE_SIZE
    SCREEN_HEIGHT_TILE = SCREEN_HEIGHT / TILE_SIZE

    Z_GROUND  = 0b0000001
    Z_CHAR    = 0b0000010
    Z_LAYER   = 0b0000010 # = Z_CHAR so they don't always overlap
    Z_TEXTBOX = 0b1000000

    SUPPORTED_KEYS = [
      KEY_ESC     = Gosu::KbEscape,
      KEY_SPACE   = Gosu::KbSpace,
      KEY_UP      = Gosu::KbUp,
      KEY_DOWN    = Gosu::KbDown,
      KEY_LEFT    = Gosu::KbLeft,
      KEY_RIGHT   = Gosu::KbRight
    ]
    
    class << self
      def sprite_file_path(filename)
        File.join(IMAGE_DIR, 'sprites', filename)
      end

      def image_file_path(filename)
        File.join(IMAGE_DIR, filename)
      end

      def tileset_file_path(filename)
        File.join(IMAGE_DIR, 'tilesets', filename)
      end

      def script_file_path(filename)
        File.join(SCRIPT_DIR, filename)
      end

      def map_file_path(filename)
        File.join(MAP_DIR, filename)
      end
    end
  end
end
