require 'spec_helper'
require 'support/handles_key_events_interface.rb'
require 'support/can_become_a_chain_link_interface.rb'

describe QuickRPG::QuitController do
  let(:controller) { described_class.new }
  
  it_should_behave_like "it handles key events"
  it_should_behave_like "can become a chain link"
  
  describe "initialization" do
    it "comes with an event manager" do
      expect(controller.event_manager).not_to be_nil
    end
  end
  
  describe "handling keyboard input" do
    let(:event_manager) { double(:post => nil) }
    let(:next_in_chain) { double() }
    
    before(:each) do
      controller.event_manager = event_manager
      controller.next_responder = next_in_chain
    end
    
    def handle_key_event
      controller.handle_key_event(key_event)
    end
    
    context "when it's the ESC key" do
      let(:key_event) { esc_key_event }
      
      it "posts quit event" do
        handle_key_event
        
        expect(event_manager).to have_received(:post).with(an_instance_of(QuickRPG::QuitEvent))
      end
    end
    
    context "when it's another key" do
      let(:next_in_chain) { double(:handle_key_event => nil) }
      let(:key_event) { not_esc_key_event }
            
      it "does not post quit event" do
        handle_key_event
        expect(event_manager).not_to have_received(:post)
      end
      
      context "when there's a next in chain" do
        it "forwards event to next in chain" do
          handle_key_event
          expect(next_in_chain).to have_received(:handle_key_event).with(key_event)
        end
      end
      
      context "when there's no object next in chain" do
        let(:next_in_chain) { nil }
        
        it "does nothing silently" do
          expect {
            handle_key_event
          }.not_to raise_exception
        end
      end
    end
  end
  
  def not_esc_key_event
    irrelevant_key_id = 7891
    expect(irrelevant_key_id).not_to eq QuickRPG::Common::KEY_ESC
    
    QuickRPG::KeyEvent.new(nil, :hit, irrelevant_key_id)
  end
  
  def esc_key_event
    QuickRPG::KeyEvent.new(nil, :hit, QuickRPG::Common::KEY_ESC)
  end
end
