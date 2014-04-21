module QuickRPG
  class Event
    attr_reader :data, :source
    def initialize(source, data)
      @source = source
      @data   = data
    end
  end

  class TickEvent < Event
    def milliseconds
      data.to_i
    end
  end

  class KeyEvent < Event
    def initialize(source, state, key_id)
      super(source, {:state => state, :key_id => key_id})
    end
  
    def state
      data[:state].to_sym
    end
  
    def key_id
      data[:key_id].to_i
    end
  end

  class CharMoveRequest < Event
    def direction
      data.to_sym
    end
  end

  class CharTileMoveDone < Event
    def direction
      data.to_sym
    end
  end

  class CharStopRequest < Event
  end

  class QuitEvent < Event
    def initialize(source)
      super(source, nil)
    end
  end
end