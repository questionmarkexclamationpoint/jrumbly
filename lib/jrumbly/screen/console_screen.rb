module Jrumbly
  module Screen
    require 'jrumbly/screen/base'
    require 'jrumbly/util/string'
    require 'jrumbly/util/util'
    class ConsoleScreen < Base
      def initialize
        super
        @running = false
        @eof = 0
      end
      def start
        started = !@running
        unless @running
          @running = true
          
          @input_thread = Thread.new { fetch_input }
          @output_thread = Thread.new { fetch_output }
          @processor.start
          @finish_thread = Thread.new { finish }
        end
        started
      end
      def stop
        stopped = @running
        if @running
          @running = false
          
          @input_thread.join
          @output_thread.join
          @finish_thread.join
          
          @processor.stop
        end
        stopped
      end
      def fetch_input
        while @running
          @processor.input.pop_in
          puts 'Please input an integer: '
          value = gets
          until value.is_i?
            value = gets 'Invalid input. Try again: '
          end
          value = Memory::Word.new('DATA', value)
          @processor.input.push_out(value)
        end
      end
      def fetch_output
        while @running
          value = @processor.output.pop
          puts value
        end
      end
      def finish
        while @running
          @running = @processor.running
        end
      end
      def load_line(line)
        word = Jrumbly::Util.parse_word(line)
        unless word.nil?
          if word.is_a?(Array)
            location, word = word
          else
            location = @eof
            @eof += 1
          end
          @processor.ram[location] = word
        end
      end
    end
  end
end
