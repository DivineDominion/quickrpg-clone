require "spec_helper"
require 'support/gameloopable_interface.rb'

describe QuickRPG::GameState::MapStage do
  it_behaves_like "a game loop-able interface"
  
  describe "drawing" do
    let(:map) { double() }
    
    it "draws the map" do
      map_stage = described_class.new(map: map)
      
      expect(map).to receive(:draw)
      
      map_stage.draw
    end
  end
  
  describe "updating" do
    let(:map) { double() }
    
    it "updates the map" do
      map_stage = described_class.new(map: map)
      
      expect(map).to receive(:update)
      
      map_stage.update
    end
  end
end
