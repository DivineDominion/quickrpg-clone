require 'spec_helper'
require 'support/button_listener_interface.rb'

describe QuickRPG::KeyEventAdapter do
  let(:adapter) { described_class.new }
  
  it_behaves_like "a button listener interface"
end
