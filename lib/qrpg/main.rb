require_relative 'common'

# Limits the keys which have to be checked by KeyEventDispatcher
$supported_keys = [
  K_ESC     = Gosu::KbEscape,
  K_SPACE   = Gosu::KbSpace,
  K_UP      = Gosu::KbUp,
  K_DOWN    = Gosu::KbDown,
  K_LEFT    = Gosu::KbLeft,
  K_RIGHT   = Gosu::KbRight
]

require_relative 'game'
require_relative 'key_event_dispatcher' # generates key events
require_relative 'key_adapter'

require_relative 'fps'

$show_fps = true
$show_debug = true


$wnd = game = QuickRPG::Game.instance
fps = QuickRPG::FPS.instance
keydispatcher = QuickRPG::KeyEventDispatcher.instance
keyadapter = QuickRPG::KeyAdapter.new
$wnd.show
