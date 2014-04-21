require 'spec_helper'

shared_examples "can become a chain link" do
  let(:link) { described_class.new }
  
  it "responds to #next_responder=" do
    expect(link).to respond_to(:next_responder=)
  end
  
  it "responds to #next_responder" do
    expect(link).to respond_to(:next_responder)
  end
end
