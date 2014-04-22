require 'spec_helper'

describe QuickRPG::DialogueHandler do
  let(:handler) { described_class.new }
  
  # describe "handling a dialogue" do
  #   let(:dialogue) { double(:textbox => textbox) }
  #   let(:textbox) { double() }
  #   
  #   before(:each) do
  #     # precondition
  #     expect(controller.active?).to be_false
  #   end
  #   
  #   it "requests a textbox" do
  #     controller.handle(dialogue)
  #     expect(dialogue).to have_received(:textbox)
  #   end
  #   
  #   it "becomes active" do
  #     controller.handle(dialogue)
  #     expect(controller.active?).to be_true
  #   end
  #   
  #   it "shows the textbox" do
  #     controller.handle(dialogue)
  #     expect(controller.textbox).to eq textbox
  #   end
  #   
  #   describe "advancing the dialogue" do
  #     before(:each) do
  #       controller.handle(dialogue)
  #     end
  #     
  #     it "requests a textbox" do
  #       controller.close_textbox
  #       expect(dialogue).to have_received(:textbox)
  #     end
  #   end
  # end
end