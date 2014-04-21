require 'spec_helper'

shared_examples "it handles events" do
  let(:controller) { described_class.new }
  
  it "responds to handle_event" do
    expect(controller).to respond_to(:handle_event)
  end
end
