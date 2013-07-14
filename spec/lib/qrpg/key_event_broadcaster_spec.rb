require 'spec_helper'
require 'support/keyboard_listener_interface.rb'

describe QuickRPG::KeyEventBroadcaster do
  let(:adapter) { described_class.new }
  
  it_behaves_like "a keyboard listener interface"
end
