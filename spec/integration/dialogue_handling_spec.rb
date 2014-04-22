require 'spec_helper'

describe "Dialogue handling" do
  let(:player) { QuickRPG::PlayerMovement.new }
  let(:textbox_controller) { QuickRPG::TextboxController.new }
  let(:key_consumers) { QuickRPG::KeyConsumers.new }
  let(:key_event_broadcaster) { QuickRPG::KeyEventBroadcaster.new }
  
  let(:event_manager) { QuickRPG::EventManager.new }
  
  def fire_down_arrow
    down_key_id = QuickRPG::Common::KEY_DOWN
    key_event_broadcaster.button_down(down_key_id)
  end
  
  def fire_action_key
    action_key_id = QuickRPG::Common::KEY_SPACE
    key_event_broadcaster.button_down(action_key_id)
  end
  
  before(:each) do
    key_event_broadcaster.event_manager = event_manager
    
    key_consumers << textbox_controller
    key_consumers << player
    event_manager.add_listener(key_consumers)
  end
  
  describe "arrow keys" do
    before(:each) do
      allow(player).to receive(:handle_key_event)
      
      fire_down_arrow
    end
    
    it "moves the player" do
      expect(player).to have_received(:handle_key_event) 
    end
  end
  
  context "when a dialogue script is invoked" do
    let(:dialogue_handler) { QuickRPG::DialogueHandler.new }
    let(:dialogue) { double(:textbox => textbox, :advance => nil) }
    let(:textbox) { double() }
    
    before(:each) do
      dialogue_handler.handle(dialogue, textbox_controller)
    end
    
    describe "arrow key" do
      before(:each) do
        allow(player).to receive(:handle_key_event)
      
        fire_down_arrow
      end
      
      it "doesn't move the player" do
        expect(player).not_to have_received(:handle_key_event) 
      end
    end
    
    describe "action key" do
      before(:each) do
        allow(player).to receive(:handle_key_event)
      
        fire_action_key
      end
      
      it "continues the dialogue" do
        # TODO keep dialogue ref in handler, 
        # TODO handler.textbox_closed on action key in textbox
        expect(dialogue).to have_received(:advance)
      end
      
      it "doesn't let the player interact" do
        expect(player).not_to have_received(:handle_key_event) 
      end
      
      describe "action key" do
        it "closes the dialogue"
        describe "arrow keys" do
          it "moves the player again"
        end
      end
    end
  end
end