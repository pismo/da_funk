class Device
  class Display
    def self.adapter
      Device.adapter::Display
    end

    # Same as print, but add "\\n" at end of print
    #
    # @param buf [String] Text to be printed.
    # @param row [Fixnum] Row to start display.
    # @param column [Fixnum] Column to start display.
    # @return [String] buffer to display.
    def self.puts(buf, row = 0, column = 0)
      self.print("#{buf}\n", row, column)
    end

    # Display buffer
    #
    # @param buf [String] Text to be printed.
    # @param row [Fixnum] Row to start display.
    # @param column [Fixnum] Column to start display.
    # @return [String] buffer to display.
    def self.print(buf, row = 0, column = 0)
      adapter.print_line(buf, row, column)
    end

    # Clean display
    #
    # @param line [Fixnum] Line to clear
    def self.clear(line = nil)
      if line.nil?
        adapter.clear
      else
        adapter.clear_line line
      end
    end
  end
end