require 'gosu'
require 'singleton'
require 'observer'

require_relative 'event_manager'

module QuickRPG
  class KeyEventDispatcher
    # Sets up a shorthand and Maps each object method to a class method, 
    # e.g. write Key::state(id) instead of Key.instance.state(id)
    # MapMethodsToClassMethods = proc do
    #   meth = self.public_instance_methods \
    #     - self.superclass.public_instance_methods \
    #     - (self.included_modules.map {|m| m.instance_methods}).flatten
    # 
    #   meth.each do |m|
    #     module_eval <<-END_EVAL
    #       def self.#{m.id2name}(*args, &block)
    #         instance.#{m.id2name}(*args, &block)
    #       end
    #     END_EVAL
    #   end
    # end
#        MapMethodsToClassMethods.call
  
    attr_reader :keys
    
    def initialize(supported_keys)
      @keys = {}
      
      supported_keys.each do |key|
        @keys[key] = :released
      end
    end
  
    def button_down(id)
      old_state = @keys[id]
      
      @keys[id] = :down  if hit? id
      @keys[id] = :hit   if released? id
      
      new_state = @keys[id]
      
      key_changed(id, new_state) if old_state != new_state
    end 
  
    def button_up(id)
      old_state = @keys[id]
      
      @keys[id] = :released  if up? id
      @keys[id] = :up        if down? id
      
      new_state = @keys[id]
      
      key_changed(id, new_state) if old_state != new_state
    end

    def hit?(id)
      @keys[id] == :hit
    end
  
    def down?(id)
      @keys[id] == :down or hit? id
    end
  
    def up?(id)
      @keys[id] == :up
    end
  
    def released?(id)
      @keys[id] == :released or up? id
    end
  
    def state(id)
      @keys[id]
    end
    
    def key_changed(key, changed_to)
      EventManager.post(KeyEvent.new(self, changed_to, key))
    end
  end
end
