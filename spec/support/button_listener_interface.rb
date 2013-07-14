require 'spec_helper'

shared_examples "a button listener interface" do
  let(:listener) { described_class.new }
  
  it "implements button press" do
    expect(listener).to respond_to(:button_down)
  end
  
  it "implements button release" do
    expect(listener).to respond_to(:button_up)
  end
end
