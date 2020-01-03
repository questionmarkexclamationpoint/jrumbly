module Jrumbly
  class Bus
    attr_reader :in, :out
    
    def initialize
      @in = Queue.new
      @out = Queue.new
    end
    def request(value = nil)
      push_in(value)
      pop_out
    end
    def push_in(value)
      @in << value
    end
    def push_out(value)
      @out << value
    end
    def pop_out
      @out.pop
    end
    def pop_in
      @in.pop
    end
  end
end
