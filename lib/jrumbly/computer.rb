module Jrumbly
  class Computer
    require 'jrumbly/processor'
    require 'jrumbly/memory/ram'
    require 'jrumbly/screen/base'
    attr_reader :processor, :ram, :screen
    def initialize
      @processor = Processor.new
      @ram = Memory::Ram.new
      @screen = Screen::Base.new
      
      @processor.ram = ram
      
      @screen.processor = @processor
    end
    def start
      @screen.start
    end
    def processor=(processor)
      raise ArgumentError.new unless
        processor.is_a? Processor

      @processor = processor
      
      @screen.processor = @processor
      
      @processor
    end
    def screen=(screen)
      raise ArgumentError.new unless
        screen.is_a? Screen::Base
        
      @screen = screen
      
      @screen.processor = @processor
      
      @screen
    end
    def ram=(ram)
      raise ArgumentError.new unless
        ram.is_a? Memory::Ram
      
      @ram = ram
      
      @processor.ram = @ram
      
      @ram
    end
  end
end
