module QuickRPG
  class EventManager
    class << self
      def default_manager
        @@default_manager ||= EventManager.new
      end
    
      def add_listener(controller)
        default_manager.add_listener(controller)
      end
    
      def remove_listener(controller)
        default_manager.remove_listener(controller)
      end
    
      def post(event)
        default_manager.post(event)
      end
    end
  
    def add_listener(controller)
      @controllers = Array.new unless defined? @controllers
      unless controller.respond_to?(:handle_event)
        raise NoMethodError, "Controller `#{controller.class}' must respond to `handle_event'"
      end
      @controllers << controller
    end
  
    def remove_listener(controller)
      if defined?(@controllers) && @controllers.include?(controller)
        @controllers.delete(controller)
      end
    end
  
    def post(event)
      return unless defined? @controllers
      @controllers.each do |controller|
        controller.handle_event(event)
      end
    end
  end
end