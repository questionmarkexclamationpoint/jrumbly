module Jrumbly
  class Processor
    require 'jrumbly/memory/word'
    require 'jrumbly/bus'
    
    attr_reader :accumulator, :program_counter, :word, :update, :running
    attr_accessor :input, :output, :ram
    
    def initialize(ram: nil)
      @accumulator = 0
      @program_counter = 0
      @word = Memory::Word.new
      @ram = ram || Memory::Ram.new
      
      @input = Bus.new
      @output = Queue.new
      @update = Queue.new
      
      @running = false
    end
    def start
      value = !@running
      unless @running
        program_counter = 0;
        @running = true
        @thread = Thread.new { run }
      end
      value
    end
    def stop
      value = @running
      if @running
        @running = false
        @thread.join
      end
      value
    end
    def run
      while @running
        step
      end
    end
    def step
      fetch
      execute
    end
    def reset
      @accumulator = 0
      @program_counter = 0
      @word = Memory::Word.new
      @ram.reset
    end
    
    private
    
    def fetch
      raise AssemblyError.new('Error: Instruction out of bounds') if @program_counter >= @ram.size
      @word = @ram[@program_counter]
      @program_counter += 1
    end
    def execute
      w = @word.instruction.downcase
      if respond_to? w
        send(w)
      else
        raise AssemblyError.new("Error: Malformed word '#{@word.instruction}' at line #{@program_counter}")
      end
    end
    def read
      word = Memory::Word.new('DATA', @input.request.operand)
      @ram[word.operand] = word
      @update.push(@word.operand)
    end
    def writ
      @output << @ram[@word.operand].operand
    end
    def load
      @accumulator = @ram[@word.operand].operand
    end
    def stor
      word = Memory::Word.new('DATA', @accumulator)
      @ram[@word.operand] = word
      @update << @word.operand
    end
    def add
      @accumulator += @ram[@word.operand].operand
    end
    def sub
      @accumulator -= @ram[@word.operand].operand
    end
    def div
      @accumulator /= @ram[@word.operand].operand
    end
    def mult
      @accumulator *= @ram[@word.operand].operand
    end
    def jump
      @program_counter = @word.operand
    end
    def jmpn
      jump if @accumulator < 0
    end
    def jmpz
      jump if @accumulator < 0
    end
    def moda
      instruction = @ram[@word.operand].instruction
      word = Memory::Word.new(instruction, @accumulator)
      @ram[@word.operand] = word
      @update << @word.operand
    end
    def halt
      @running = false
    end
    def data
      raise AssemblyError.new('Error: Attempted execution of data word')
    end
  end
end
