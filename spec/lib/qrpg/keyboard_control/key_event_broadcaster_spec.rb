require 'spec_helper'
require 'support/keyboard_listener_interface.rb'

module DelegateStub
  def button_down(x);end
  def button_up(x); end
  def state(x); end
end

class ConstantDelegateStub
  include DelegateStub
  
  def state(x)
    @irrelevant_constant_value ||= 123
  end
end

class ChangingDelegateStub
  include DelegateStub
  
  def initialize
    @toggle = true
  end
  
  def state(x)
    @toggle = !@toggle
  end
end

describe ConstantDelegateStub do
  it_behaves_like "a keyboard listener interface"
end

describe ChangingDelegateStub do
  it_behaves_like "a keyboard listener interface"
end

describe QuickRPG::KeyEventBroadcaster do
  let(:broadcaster) { described_class.new(delegate) }
  let(:delegate) { double(:state => nil, :button_down => nil, :button_up => nil) }
  let(:event_manager) { double(QuickRPG::EventManager, :post => nil) }

  it_behaves_like "a keyboard listener interface"
  
  describe "initialization" do
    it "comes with an event manager" do
      expect(broadcaster.event_manager).not_to be_nil
    end
  end
  
  describe "pressing a button" do
    let(:key_id) { 1234 }

    before(:each) do
      broadcaster.event_manager = event_manager
      
      broadcaster.button_down(key_id)
    end
    
    it "queries the delegate's state twice" do
      expect(delegate).to have_received(:state).with(key_id).exactly(2).times
    end
    
    it "forwards to the delegate" do
      expect(delegate).to have_received(:button_down).with(key_id)
    end
    
    context "when the delegate state changed" do
      let(:delegate) { ChangingDelegateStub.new }
      
      before(:each) do
        allow(event_manager).to receive(:post)
      end
      
      it "fires a change" do
        expect(event_manager).to have_received(:post)
      end
    end
    
    context "when the delegate state remains the same" do
      let(:delegate) { ConstantDelegateStub.new }
    
      before(:each) do
        allow(event_manager).to receive(:post)
      end
    
      it "doesn't fire a change" do
        expect(event_manager).not_to have_received(:post)
      end
    end
  end
  
  describe "releasing a button" do
    let(:key_id) { 678 }

    before(:each) do
      broadcaster.event_manager = event_manager
      
      broadcaster.button_up(key_id)
    end
    
    it "queries the delegate's state twice" do
      expect(delegate).to have_received(:state).with(key_id).exactly(2).times
    end
    
    it "forwards to the delegate" do
      expect(delegate).to have_received(:button_up).with(key_id)
    end
    
    context "when the delegate state changed" do
      let(:delegate) { ChangingDelegateStub.new }
      
      before(:each) do
        allow(event_manager).to receive(:post)
      end
      
      it "fires a change" do
        expect(event_manager).to have_received(:post)
      end
    end
    
    context "when the delegate state remains the same" do
      let(:delegate) { ConstantDelegateStub.new }
    
      before(:each) do
        allow(event_manager).to receive(:post)
      end
    
      it "doesn't fire a change" do
        expect(event_manager).not_to have_received(:post)
      end
    end
  end
end
