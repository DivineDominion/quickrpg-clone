require 'spec_helper'

shared_examples "it handles key events" do
  let(:controller) { described_class.new }
  
  it "responds to handle_key_event" do
    expect(controller).to respond_to(:handle_key_event)
  end
end
