require "spec_helper"
require 'support/gameloopable_interface.rb'

describe QuickRPG::GameState::Stage do
  let(:stage) { described_class.new }
  
  describe "stageable interface" do
    it "responds to curtain_up" do
      expect(stage).to respond_to(:curtain_up)
    end
    
    it "is invisible at first" do
      expect(stage.visible?).to be_false
    end
    
    it "activates when the curtains draw" do
      expect{stage.curtain_up}.to change{ stage.visible? }.from(false).to(true)
    end
  
    it "responds to curtain_down" do
      expect(stage).to respond_to(:curtain_down)
    end
  end
  
  it_behaves_like "a game loop-able interface"
end
