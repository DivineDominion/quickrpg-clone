require_relative '../lib/qrpg'

$wnd = game = QuickRPG::Game.instance
fps = QuickRPG::FPS.instance
keydispatcher = QuickRPG::KeyEventDispatcher.instance
keyadapter = QuickRPG::KeyAdapter.new
$wnd.show
