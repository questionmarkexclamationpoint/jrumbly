module Jrumbly
  module Memory
    class Ram < Array
      require 'jrumbly/memory/word'
      require 'jrumbly/bus'
      def initialize(size = 0)
        super(size, Word.new)
        
        @running = false
      end
      def reset
        map! do |word|
          word = Word.new
        end
      end
    end
  end
end
