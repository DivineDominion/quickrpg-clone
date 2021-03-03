require 'singleton'

module QuickRPG
  class FPS
    include Singleton

    def self.draw(x = 0.0, y = 0.0)
      instance.draw(x, y)
    end

    def initialize
      @fps_counter = 0
      @fps = 0
      @milliseconds = 0
    end

    def notify(event)
      @fps_counter += 1

      if event.millisecs - @milliseconds >= 1000
        @fps = @fps_counter

        @fps_counter = 0
        @milliseconds = event.millisecs
      end
    end

    def draw(x, y)
      $font.draw_text("FPS: " + @fps.to_s, x+1, y+1, 100.0, 1, 1, 0xff_000000)
      $font.draw_text("FPS: " + @fps.to_s, x,   y,   100.0, 1, 1, 0xff_ffffff)
    end
  end
end
