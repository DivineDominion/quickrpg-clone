require 'singleton'
require 'observer'

class KeyEventDispatcher
  include Singleton
  
  # Sets up a shorthand and Maps each object method to a class method, 
  # e.g. write Key::state(id) instead of Key.instance.state(id)
  MapMethodsToClassMethods = proc do
    meth = self.public_instance_methods \
      - self.superclass.public_instance_methods \
      - (self.included_modules.map {|m| m.instance_methods}).flatten
    
    meth.each do |m|
      module_eval <<-END_EVAL
        def self.#{m.id2name}(*args, &block)
          instance.#{m.id2name}(*args, &block)
        end
      END_EVAL
    end
  end
  
  def initialize
    raise "Setup $wnd which must be instance_of? Gosu::Window" unless defined? $wnd
    
    EventManager::register(self)
    @keys = Array.new(256, :released) 
    
    # Set up supported keys if not done already
    $supported_keys ||= (0..255)
  end
  
  def handle_event(event)
    if event.instance_of? TickEvent
      $supported_keys.each do |id|
        old_state = state(id)
      
        if $wnd.button_down?(id)
          button_down(id)
        else
          button_up(id)
        end
        
        if state(id) != old_state
          EventManager.post(KeyEvent.new(self, state(id), id))
        end
      end
    end
  end
  
  def button_down(id)
    @keys[id] = :down  if hit? id
    @keys[id] = :hit   if released? id
  end 
  
  def button_up(id)
    @keys[id] = :released  if up? id
    @keys[id] = :up        if down? id
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
  
  MapMethodsToClassMethods.call
end