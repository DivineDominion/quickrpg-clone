require 'spec_helper'

shared_examples "a game loop-able interface" do
  let(:loopable) { described_class.new }
  
  it "responds to update" do
    expect(loopable).to respond_to(:update)
  end
  
  it "responds to draw" do
    expect(loopable).to respond_to(:draw)
  end
end
