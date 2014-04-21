require 'spec_helper'

class ConsumerStub
  attr_accessor :next_responder
  
  def initialize(name = nil)
    @name = name
  end
end

class IllegalConsumerStub
end

describe ConsumerStub do
  it_should_behave_like "can become a chain link"
end

class KeyEventStub < QuickRPG::KeyEvent
  def initialize;
    # don't forward to super    
  end
end

describe QuickRPG::KeyConsumers do
  it_should_behave_like "it handles events"
  it_should_behave_like "it handles key events"
    
  describe "importing a list of consumers" do
    def new_with_imported_consumers
      return described_class.new(existing_consumers)
    end
    
    context "when all consumers can handle being in a responder chain" do
      let(:first_consumer) { ConsumerStub.new(:first) }
      let(:second_consumer) { ConsumerStub.new(:second) }
      let(:third_consumer) { ConsumerStub.new(:third) }
      let(:existing_consumers) { [first_consumer, second_consumer, third_consumer] }
      
      let!(:consumers) { new_with_imported_consumers }
            
      it "sets first responder" do
        expect(consumers.first_responder).to eq first_consumer
      end
          
      it "sets last responder" do
        expect(consumers.last_responder).to eq third_consumer
      end
    end
    
    context "when a consumer can't handle having a next in chain" do
      let(:illegal_consumer) { IllegalConsumerStub.new }
      let(:existing_consumers) { [ConsumerStub.new, illegal_consumer] }
      
      it "throws an exception" do
        expect{
          new_with_imported_consumers
        }.to raise_exception(/must respond to/)
      end
    end
  end
  
  describe "adding a consumer" do
    let(:consumers) { described_class.new }
    let(:new_consumer) { ConsumerStub.new }
    
    context "when it isn't chainable" do
      let(:illegal_consumer) { double() }
      
      it "raises exception" do
        expect{
          consumers << illegal_consumer
        }.to raise_exception(/must respond to/)
      end
    end
    
    context "when no consumer was present" do
      it "becomes first responder" do
        consumers << new_consumer
        expect(consumers.first_responder).to eq new_consumer
      end
    end
    
    context "when a consumer was already present" do
      let(:existing_consumer) { ConsumerStub.new }
      let(:consumers) { described_class.new(existing_consumer) }

      it "doesn't change the first responder" do
        expect(consumers.first_responder).to eq existing_consumer
      end
      
      it "becomes first responder's next in chain" do
        expect(existing_consumer).to receive(:next_responder=)
        
        consumers << new_consumer
      end
    end
  end
  
  describe "handling events" do
    let(:existing_consumer) { ConsumerStub.new }
    let(:consumers) { described_class.new(existing_consumer) }
    
    before(:each) do
      allow(existing_consumer).to receive(:handle_key_event)

      consumers.handle_event(event)
    end
    
    context "when the event is a key event" do
      let(:event) { KeyEventStub.new }
      
      it "forwards the event to the first responder" do
        expect(existing_consumer).to have_received(:handle_key_event).with(event)
      end
    end
    
    context "when the event is something else" do
      let(:event) { double() }
      
      it "doesn't forward the event" do
        expect(existing_consumer).not_to have_received(:handle_key_event)
      end
    end
  end
  
  describe "handling key events" do
    let(:existing_consumer) { ConsumerStub.new }
    let(:consumers) { described_class.new(existing_consumer) }
    let(:event) { KeyEventStub.new }
    
    before(:each) do
      allow(existing_consumer).to receive(:handle_key_event)
      consumers.handle_key_event(event)
    end

    it "forwards the event to the first responder" do
      expect(existing_consumer).to have_received(:handle_key_event).with(event)
    end
  end
end
