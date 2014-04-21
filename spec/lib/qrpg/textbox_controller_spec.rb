require 'spec_helper'
require 'support/handles_key_events_interface.rb'
require 'support/can_become_a_chain_link_interface.rb'

describe QuickRPG::TextboxController do
  let(:controller) { described_class.new }
  
  it_should_behave_like "it handles key events"
  it_should_behave_like "can become a chain link"
  
  describe "initialization" do
    it "starts inactive" do
      expect(controller).not_to be_active
    end
  end
  
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
    let(:next_in_chain) { double() }
    
    before(:each) do
      controller.next_responder = next_in_chain
    end
    
    context "when a textbox is visible" do
      let(:textbox) { double() }
    
      before(:each) do
        controller.show(textbox)
      
        # precondition
        expect(controller).to be_active
      end
    
      it "consumes key events" do
        expect(next_in_chain).not_to receive(:handle_key_event)
      
        controller.handle_key_event(key_event)
      end
    end
    
    context "when no textbox is shown" do
      let(:key_event) { double() }
    
      before(:each) do
        # precondition
        expect(controller).not_to be_active
      end
      
      context "when there's a next responder" do
        it "forwards key events to the next in chain" do
          expect(next_in_chain).to receive(:handle_key_event).with(key_event)
      
          controller.handle_key_event(key_event)
        end
      end
      
      context "when it's the last responder in chain" do
        let(:next_in_chain) { nil }
        
        it "lets it drop" do
          expect {
            controller.handle_key_event(key_event)
          }.not_to raise_exception
        end
      end
    end
  end
end
