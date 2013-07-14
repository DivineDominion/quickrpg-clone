class EventManager
  class << self
    def register(controller)
      @@controllers = Array.new unless defined? @@controllers
      unless controller.respond_to?(:handle_event)
        raise NoMethodError, "Controller `#{controller.class}' must respond to `handle_event'"
      end
      @@controllers << controller
    end
    
    def unregister(controller)
      if defined?(@@controllers) && @@controllers.include?(controller)
        @@controllers.delete(controller)
      end
    end
    
    def post(event)
      return unless defined? @@controllers
      @@controllers.each do |controller|
        controller.handle_event(event)
      end
    end
  end
  
  private_class_method :new, :clone
end