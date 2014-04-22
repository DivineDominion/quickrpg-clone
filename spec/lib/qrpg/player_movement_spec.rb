require 'spec_helper'
require 'support/handles_key_events_interface.rb'
require 'support/can_become_a_chain_link_interface.rb'

describe QuickRPG::PlayerMovement do
  let(:controller) { described_class.new }
  
  it_should_behave_like "can become a chain link"
  
  describe "absorbing key events" do
    let(:key_event) { double() }
    
    before(:each) do
      controller.next_responder = next_in_chain
    end
    
    it "posts move event"
    
    context "without next in chain" do
      let(:next_in_chain) { nil }
      
      it "handles key events" do
        expect {
          controller.handle_key_event(key_event)
        }.not_to raise_exception
      end
    end
    
    context "with next responder in chain" do
      let(:next_in_chain) { double() }
      
      it "consumes key events" do
        expect(next_in_chain).not_to receive(:handle_key_event)
        controller.handle_key_event(key_event)
      end
    end
  end
  
  describe "forwarding key events"
end