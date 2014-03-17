require 'spec_helper'
require 'support/gameloopable_interface.rb'

describe QuickRPG::TextboxController do
  let(:controller) { described_class.new }
  let(:next_in_chain) { double() }
  
  before(:each) do
    controller.next_responder = next_in_chain
  end
  
  it "is inactive" do
    expect(controller).not_to be_active
  end
  
  it_should_behave_like "it handles key events"
  
  describe "showing a textbox" do
    let(:textbox) { double() }
    
    before(:each) do
      controller.show(textbox)
    end
    
    it "is active" do
      expect(controller).to be_active
    end
  end
  
  describe "absorbing key events" do
    let(:key_event) { double() }
    let(:textbox) { double() }
    
    before(:each) do
      controller.show(textbox)
      
      # precondition
      expect(controller).to be_active
    end
    
    it "doesn't forward the event to the next in chain" do
      expect(next_in_chain).not_to receive(:handle_key_event)
      
      controller.handle_key_event(key_event)
    end
  end
  
  describe "passing on key events" do
    let(:key_event) { double() }
    
    before(:each) do
      # precondition
      expect(controller).not_to be_active
    end
    
    it "forwards key events" do
      expect(next_in_chain).to receive(:handle_key_event).with(key_event)
      
      controller.handle_key_event(key_event)
    end
  end
end
