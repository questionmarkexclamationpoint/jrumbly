module Jrumbly
  module Screen
    class Base
      require 'jrumbly/bus'
      require 'jrumbly/memory/ram'
      
      attr_accessor :processor
      def initialize
        @processor = Processor.new
        @running = false
      end
    end
  end
end
