require 'spec_helper'
require 'support/gameloopable_interface.rb'

describe QuickRPG::GameState::Director do
  context "initialization" do
    let(:startup_state) { double() }
    
    it "works without a startup state" do
      expect{ described_class.new }.not_to raise_error
    end
    
    it "accepts a state to start with" do
      expect{ new_with_startup_state }.not_to raise_error
    end
  
    it "stores a state after initialization" do
      director = new_with_startup_state
      expect(director.current_state).to eq startup_state
    end
    
    def new_with_startup_state
      described_class.new(state: startup_state)
    end
  end
  
  describe "state switching" do
    let(:director) { described_class.new }
    let(:first_state) { double() }
        
    it "pulls curtain for first state" do
      expect(first_state).to receive(:curtain_up)
      director.switch_to(first_state)
    end
    
    context "with active first state" do
      let(:second_state) { double() }
      
      before(:each) do
        first_state.stub(:curtain_up)
        director.switch_to(first_state)
      end
      
      it "closes curtain for old state" do
        second_state.stub(:curtain_up)
        expect(first_state).to receive(:curtain_down)
        
        director.switch_to(second_state)
      end
      
      it "pulls curtain for new state" do
        first_state.stub(:curtain_down)
        expect(second_state).to receive(:curtain_up)
        
        director.switch_to(second_state)
      end
    end
  end

  it_behaves_like "a game loop-able interface"
  
  describe "call forwarding" do
    let(:first_state) { nil } # None at first
    let(:director) { described_class.new(state: first_state) }
    
    context "with a state" do
      let(:first_state) { double() }
      
      it "forwards update" do
        expect(first_state).to receive(:update)
        director.update
      end
    
      it "forwards drawing" do
        expect(first_state).to receive(:draw)
        director.draw
      end
    end
    
    context "without a state" do
      it "skips update gracefully" do
        expect{ director.update }.not_to raise_error
      end
      
      it "skips draw gracefully" do
        expect{ director.draw }.not_to raise_error
      end
    end
  end
end
